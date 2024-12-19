# frozen_string_literal: true

require 'domainic/dev'
require 'domainic/dev/cli/command/base_command'
require 'set'
require 'thor'

module Domainic
  module Dev
    class CLI < Thor
      module Command
        # A command to lint Markdown files in the Domainic::Dev project.
        #
        # This class extends {BaseCommand} to provide functionality for linting Markdown files using mdl.
        # It checks all Markdown files in the project except those in vendor directories and reports
        # any formatting issues.
        #
        # @author {https://aaronmallen.me Aaron Allen}
        # @since 0.1.0
        class LintMarkdownCommand < BaseCommand
          # @rbs!
          #   type result = { success: bool, message: String, file: Pathname, output: String }

          # @rbs @documentation_messages: Set[String]
          # @rbs @markdown_files: Array[Pathname]
          # @rbs @results: Array[result]

          long_desc <<~DESC
            Lints all Markdown files in the project using mdl.
          DESC

          # Execute the Markdown linting command.
          #
          # @return [void]
          # @rbs () -> void
          def execute
            results.each do |result|
              puts result[:message]
              next if result[:success]

              error_lines = extract_error_lines(result)
              puts error_lines.map { |line| "  - #{line}" }.join("\n")
            end
          end

          # Set the exit status based on linting results.
          #
          # @return [void]
          # @rbs () -> void
          def exit_status
            return if results.all? { |result| result[:success] }

            exit 1
          end

          # Print additional documentation messages for linting failures.
          #
          # @return [void]
          # @rbs () -> void
          def print_documentation_messages
            return if documentation_messages.empty?

            puts "\nFurther documentation is available for these failures:"
            documentation_messages.each { |message| puts " #{message}" }
          end

          private

          # Get the set of documentation messages.
          #
          # @return [Set<String>] the documentation messages
          # @rbs () -> Set[String]
          def documentation_messages
            @documentation_messages ||= Set.new
          end

          # Extract error lines from a result, capturing any documentation messages.
          #
          # @param result [Hash{Symbol => Boolean, Pathname, String}] the lint result
          # @return [Array<String>] the error lines
          # @rbs (result result) -> Array[String]
          def extract_error_lines(result)
            lines = result[:output].gsub("#{result[:file]}:", 'L').lines.map(&:chomp)
            doc_index = lines.index('Further documentation is available for these failures:')

            if doc_index
              error_lines = lines[0...doc_index]
              doc_lines = lines[(doc_index + 1)..]
              # @type var doc_lines: Array[String]
              documentation_messages.merge(doc_lines)
            else
              error_lines = lines
            end

            # @type var error_lines: Array[String]
            error_lines.reject(&:empty?)
          end

          # Get all Markdown files in the project.
          #
          # @return [Array<Pathname>] array of Markdown file paths
          # @rbs () -> Array[Pathname]
          def markdown_files
            @markdown_files ||= Domainic::Dev.root.glob('**/*.md').reject { |path| path.to_s.include?('/vendor/') }
          end

          # Run mdl on all Markdown files and collect results.
          #
          # @return [Array<Hash>] array of lint results
          # @rbs () -> Array[result]
          def results
            @results ||= markdown_files.map do |file|
              output = `bundle exec mdl #{file}`
              success = output.strip.empty?
              relative_file = file.relative_path_from(Domainic::Dev.root)
              message = success ? "#{icon(:check, :green)} #{relative_file}" : "#{icon(:x, :red)} #{relative_file}"
              { success: success, message: message, file: file, output: output }
            end
          end
        end
      end
    end
  end
end
