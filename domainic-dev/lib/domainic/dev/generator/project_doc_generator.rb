# frozen_string_literal: true

require 'domainic/dev'
require 'domainic/dev/generator/base_generator'

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
        argument :name, type: :string # steep:ignore NoMethod
        argument :id, type: :numeric # steep:ignore NoMethod

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

              Be sure to add your project to docs/projects/README.md

            ##########################################################
          INSTRUCTIONS
        end

        # @rbs! def id: () -> Integer
        # @rbs! def name: () -> String

        # rubocop:enable Layout/OrderedMethods
        private

        # The name of the project directory based on the project name.
        #
        # @return [String]
        # @rbs () -> String
        def directory_name
          name.split.join('-').downcase
        end
      end
    end
  end
end
