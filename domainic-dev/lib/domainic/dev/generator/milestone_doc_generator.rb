# frozen_string_literal: true

require 'date'
require 'domainic/dev'
require 'domainic/dev/generator/base_generator'

module Domainic
  module Dev
    module Generator
      # A generator for creating new milestone documentation.
      #
      # This creates new milestone documentation in the `docs/milestone` directory.
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class MilestoneDocGenerator < BaseGenerator
        # @rbs @due_date: String

        argument :name, type: :string # steep:ignore NoMethod
        argument :id, type: :numeric # steep:ignore NoMethod

        class_option :due, type: :string, desc: 'The due date for the milestone', default: 'TBD' # steep:ignore

        # rubocop:disable Layout/OrderedMethods

        # Initialize a new MilestoneDocGenerator instance.

        # @param arguments [Array<Object>] the generator arguments
        # @param options [Array<Object>] additional options
        # @return [void]
        # @rbs (Array[untyped], *untyped) -> void
        def initialize(arguments, *options)
          super
          parse_due_date!
        end

        # Ensure the milestone does not already exist.
        #
        # @raise [ArgumentError] if the milestone already exists
        # @return [void]
        # @rbs () -> void
        def ensure_project_does_not_exist
          return unless Domainic::Dev.root.join("docs/milestones/#{filename}").exist?

          raise ArgumentError, "Milestone #{name} already exists."
        end

        def create_milestone_documentation
          template('milestone.md.erb', "docs/milestones/#{filename}") # steep:ignore NoMethod
        end

        # @rbs! def id: () -> Integer
        # @rbs! def name: () -> String

        # rubocop:enable Layout/OrderedMethods
        private

        attr_reader :due_date

        # The name of the project directory based on the project name.
        #
        # @return [String]
        # @rbs () -> String
        def filename
          "#{name.split.join('-').downcase}.md"
        end

        def parse_due_date!
          @due_date = if options[:due] == 'TBD' # steep:ignore NoMethod
                        'TBD'
                      else
                        date = Date.parse(options[:due]) # steep:ignore NoMethod
                        "#{date.month}%2F#{date.day}%2F#{date.year}"
                      end
        end
      end
    end
  end
end
