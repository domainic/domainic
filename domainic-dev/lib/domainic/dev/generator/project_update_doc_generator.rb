# frozen_string_literal: true

require 'date'
require 'domainic/dev'
require 'domainic/dev/generator/base_generator'

module Domainic
  module Dev
    module Generator
      # This generator creates a new document for a project update.
      #
      # @since 0.1.0
      class ProjectUpdateDocGenerator < BaseGenerator
        # @rbs @date_string: String
        # @rbs @project_directory: Pathname
        # @rbs @update_number: String

        argument :project_name, type: :string # steep:ignore NoMethod

        # rubocop:disable Layout/OrderedMethods

        # Ensure the project exists
        #
        # @raise [ArgumentError] if the project does not exist
        # @return [void]
        # @rbs () -> void
        def ensure_project_exists
          raise ArgumentError, "Unknown project: #{project_name}" unless project_directory.exist?
        end

        # Create the updates directory if it does not exist
        #
        # @return [void]
        # @rbs () -> void
        def create_update_directory
          empty_directory("#{project_directory}/updates") # steep:ignore NoMethod
        end

        # Create the new update document
        #
        # @return [void]
        # @rbs () -> void
        def create_update_document
          # steep:ignore:start
          template('update.md.erb', "#{project_directory}/updates/#{date_string}-#{update_number}.md")
          # steep:ignore:end
        end

        # Print instructions for the user.
        #
        # @return [void]
        # @rbs () -> void
        def print_instructions
          puts <<~INSTRUCTIONS

            #################################################################

              Be sure to add your project update to docs/projects/projects.md

            #################################################################
          INSTRUCTIONS
        end

        # @rbs! def project_name: () -> String

        # rubocop:enable Layout/OrderedMethods

        private

        # Today's date as a string in the format 'YYYY-MM-DD'
        #
        # @return [String]
        # @rbs () -> String
        def date_string
          @date_string ||= Date.today.strftime('%Y-%m-%d')
        end

        # The directory for the project's documentation
        #
        # @return [Pathname]
        # @rbs () -> Pathname
        def project_directory
          @project_directory ||= Domainic::Dev.root.join("docs/projects/#{project_name.split.join('_').downcase}")
        end

        # The update number for the new document
        #
        # @return [String]
        # @rbs () -> String
        def update_number
          @update_number ||= begin
            updates = project_directory.glob('updates/*.md').select do |file|
              file.basename.to_s.start_with?(date_string)
            end
            updates.empty? ? '01' : (updates.count + 1).to_s.rjust(2, '0')
          end
        end
      end
    end
  end
end
