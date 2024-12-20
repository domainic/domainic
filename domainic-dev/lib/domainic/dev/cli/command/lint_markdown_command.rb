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

          # Pattern to match a GitHub link in an mdl documentation message.
          #
          # @return [Regexp] the pattern
          MDL_DOCSTRING_TO_GITHUB_LINK_PATTERN = %r{https://github\.com/[^\s]+} #: Regexp

          # Pattern to match an mdl violation line and extract the file, line number, rule ID, and message.
          #
          # @return [Regexp] the pattern
          MDL_VIOLATION_TO_LINE_AND_RULE_PATTERN = /^(.+?):(\d+): (MD\d+)(.*)$/i #: Regexp

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

              error_lines = parse_result(result)
              puts error_lines.map { |line| "  #{line}" }.join("\n")
            end
            print_documentation_messages
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

          # Generate a linked line number for a Markdown file.
          #
          # @param file [String] the file path
          # @param line_number [String] the line number
          # @return [String] the linked line number
          # @rbs (String file, String line_number) -> String
          def linked_line_number(file, line_number)
            formatted_line_num = line_number.rjust(2, '0').strip
            colorize(hyper_link("#{file}:#{line_number}", formatted_line_num), :red).strip
          end

          # Generate a linked mdl rule id.
          #
          # @param mdl_rule_id [String] the mdl rule id
          # @return [String] the linked mdl rule id
          # @rbs (String mdl_rule_id) -> String
          def linked_mdl_rule(mdl_rule_id)
            doc_string = documentation_messages.find { |entry| entry.include?(mdl_rule_id) }
            doc_link = doc_string&.match(MDL_DOCSTRING_TO_GITHUB_LINK_PATTERN)&.[](0) || ''
            colorize(hyper_link(doc_link, mdl_rule_id), :cyan).strip
          end

          # Get all Markdown files in the project.
          #
          # @return [Array<Pathname>] array of Markdown file paths
          # @rbs () -> Array[Pathname]
          def markdown_files
            @markdown_files ||= Domainic::Dev.root.glob('**/*.md').reject { |path| path.to_s.include?('/vendor/') }
          end

          # Extract mdl violation lines from a result, capturing any mdl documentation messages.
          #
          # @param result [Hash{Symbol => Boolean, Pathname, String}] the lint result
          # @return [Array<String>] the error lines
          # @rbs (result result) -> Array[String]
          def parse_result(result)
            lines = result[:output].lines.map(&:chomp)
            doc_index = lines.index('Further documentation is available for these failures:')

            if doc_index
              violation_lines = lines[0...doc_index]
              doc_lines = lines[(doc_index + 1)..]
              # @type var doc_lines: Array[String]
              documentation_messages.merge(doc_lines)
            else
              violation_lines = lines
            end

            # @type var violation_lines: Array[String]
            parse_violation_lines(violation_lines)
          end

          # Parse a single violation line from mdl output.
          #
          # @param line [String] the violation line
          # @return [String] the parsed violation line
          # @rbs (String line) -> String
          def parse_violation_line(line)
            file, line_number, mdl_rule_id, message = line.match(MDL_VIOLATION_TO_LINE_AND_RULE_PATTERN)&.captures
            return '' unless file && line_number && mdl_rule_id && message

            linked_line_number = linked_line_number(file, line_number)
            linked_mdl_rule = linked_mdl_rule(mdl_rule_id)

            "#{embolden(linked_line_number)}: #{embolden(linked_mdl_rule)}:#{message}"
          end

          # Parse all violation lines from mdl output.
          #
          # Sorts violations by line number and parses each line.
          #
          # @param violation_lines [Array<String>] the violation lines
          # @return [Array<String>] the parsed violation lines
          # @rbs (Array[String] violation_lines) -> Array[String]
          def parse_violation_lines(violation_lines)
            violation_lines.reject(&:empty?)
                           .sort_by { |line| line.match(MDL_VIOLATION_TO_LINE_AND_RULE_PATTERN)&.[](2).to_i }
                           .map { |line| parse_violation_line(line) }
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
              { success: success, message: message, output: output }
            end
          end
        end
      end
    end
  end
end
