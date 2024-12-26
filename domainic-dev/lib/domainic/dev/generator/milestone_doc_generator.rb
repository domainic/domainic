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
        # @rbs @start_date: String
        # @rbs @status: String

        # steep:ignore:start
        argument :name, type: :string
        argument :id, type: :numeric

        class_option :status, type: :string, default: 'In Progress', desc: 'The status of the project'
        class_option :start_date, type: :string, desc: 'The start date of the milestone'
        class_option :due_date, type: :string, desc: 'The due date of the project', default: 'TBD'
        # steep:ignore:end

        # rubocop:disable Layout/OrderedMethods

        # Initialize a new MilestoneDocGenerator instance.

        # @param arguments [Array<Object>] the generator arguments
        # @param options [Array<Object>] additional options
        # @return [void]
        # @rbs (Array[untyped], *untyped) -> void
        def initialize(arguments, *options)
          super
          status, start_date, due_date = self.options.values_at(:status, :start_date, :due_date) # steep:ignore NoMethod
          @due_date = URI.encode_uri_component(due_date) # steep:ignore NoMethod
          @start_date = URI.encode_uri_component(start_date || Date.today.strftime('%m/%d/%Y')) # steep:ignore NoMethod
          @status = URI.encode_uri_component(status) # steep:ignore NoMethod
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

        # Add the milestone to the README.md file.
        #
        # @return [void]
        # @rbs () -> void
        def add_to_readme
          readme_path = Domainic::Dev.root.join('docs/milestones/README.md')
          content = File.read(readme_path.to_s)

          section = "### #{gem_name}\n"
          entry = "* [#{version_name}](./#{filename})\n"

          # Find the section and add the entry after the last bullet point
          content.sub!(/#{section}\n((?:\* \[.*\n)*)/) do |_match|
            existing_entries = ::Regexp.last_match(1)
            "#{section}\n#{existing_entries}#{entry}"
          end

          File.write(readme_path.to_s, content)
        end

        # rubocop:enable Layout/OrderedMethods
        private

        attr_reader :due_date, :start_date, :status #: String

        # The name of the project directory based on the project name.
        #
        # @return [String]
        # @rbs () -> String
        def filename
          "#{name.split.join('-').downcase}.md"
        end

        # Extract the gem name from the milestone name.
        #
        # @return [String]
        # @rbs () -> String
        def gem_name
          "Domainic::#{name.split('-')[1].capitalize}"
        end

        # The color to use for the status badge.
        #
        # @return [String]
        # @rbs () -> String
        def status_color
          case options[:status] # steep:ignore NoMethod
          when 'In Progress'
            'orange'
          when 'Planned'
            'blue'
          else
            ''
          end
        end

        # Extract the version name from the milestone name.
        #
        # @return [String]
        # @rbs () -> String
        def version_name
          "v#{name.split('-v').last}"
        end
      end
    end
  end
end
