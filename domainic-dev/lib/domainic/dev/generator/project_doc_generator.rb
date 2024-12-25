# frozen_string_literal: true

require 'domainic/dev'
require 'domainic/dev/generator/base_generator'
require 'uri'

module Domainic
  module Dev
    module Generator
      # A generator for creating new project documentation.
      #
      # This creates new project documentation in the `docs/projects` directory.
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class ProjectDocGenerator < BaseGenerator
        # @rbs @due_date: String
        # @rbs @start_date: String
        # @rbs @status: String

        # steep:ignore:start
        argument :name, type: :string
        argument :id, type: :numeric

        class_option :status, type: :string, default: 'In Progress', desc: 'The status of the project'
        class_option :start_date, type: :string, desc: 'The start date of the project'
        class_option :due_date, type: :string, desc: 'The end date of the project', default: 'TBD'
        # steep:ignore:end

        def initialize(arguments, *options)
          super
          status, start_date, due_date = self.options.values_at(:status, :start_date, :due_date) # steep:ignore NoMethod
          @due_date = URI.encode_uri_component(due_date)
          @start_date = URI.encode_uri_component(start_date || Date.today.strftime('%m/%d/%Y'))
          @status = URI.encode_uri_component(status)
        end

        # rubocop:disable Layout/OrderedMethods

        # Ensure the project does not already exist.
        #
        # @raise [ArgumentError] if the project already exists
        # @return [void]
        # @rbs () -> void
        def ensure_project_does_not_exist
          return unless Domainic::Dev.root.join("docs/projects/#{directory_name}").exist?

          raise ArgumentError, "Project #{name} already exists."
        end

        # Create the project directory.
        #
        # @return [void]
        # @rbs () -> void
        def create_project_directory
          empty_directory("docs/projects/#{directory_name}") # steep:ignore NoMethod
        end

        # Create the project README file.
        #
        # @return [void]
        # @rbs () -> void
        def create_project_readme
          template('README.md.erb', "docs/projects/#{directory_name}/README.md") # steep:ignore NoMethod
        end

        # Print instructions for the user.
        #
        # @return [void]
        # @rbs () -> void
        def print_instructions
          puts <<~INSTRUCTIONS

            ##########################################################

              Be sure to add your project to docs/projects/projects.md

            ##########################################################
          INSTRUCTIONS
        end

        # @rbs! def id: () -> Integer
        # @rbs! def name: () -> String

        # rubocop:enable Layout/OrderedMethods
        private

        attr_reader :due_date, :start_date, :status #: String

        # The name of the project directory based on the project name.
        #
        # @return [String]
        # @rbs () -> String
        def directory_name
          name.split.join('-').downcase
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
      end
    end
  end
end
