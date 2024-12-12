# frozen_string_literal: true

require 'domainic/dev/cli/command/base_command'
require 'thor'

module Domainic
  module Dev
    class CLI < Thor
      module Command
        # A command to lint Ruby files in the Domainic::Dev project.
        #
        # This class extends {BaseCommand} to provide functionality for linting Ruby files using RuboCop.
        # It includes options for safe and unsafe auto-correction of detected issues.
        #
        # @author {https://aaronmallen.me Aaron Allen}
        # @since 0.1.0
        class LintRubyCommand < BaseCommand
          # steep:ignore:start
          class_option :autocorrect, type: :boolean, default: false,
                                     desc: "Autocorrect offenses (only when it's safe)", aliases: %w[-a]
          class_option :autocorrect_all, type: :boolean, default: false,
                                         desc: 'Autocorrect offenses (safe and unsafe).', aliases: %w[-A]
          # steep:ignore:end

          long_desc <<~DESC
            Lints all Ruby files in the project using RuboCop.

            Options:

            -a, --autocorrect              Autocorrect offenses (only when it's safe).
            -A, --autocorrect-all          Autocorrect offenses (safe and unsafe).
          DESC

          # Execute the Ruby linting command.
          #
          # @return [void]
          # @rbs () -> void
          def execute
            result = system 'bundle', 'exec', 'rubocop', *flags
            exit 1 unless result
          end

          private

          # Get the command-line flags based on options.
          #
          # @return [Array<String>] array of command-line flags
          # @rbs () -> Array[String]
          def flags
            flags = []
            flags << '-a' if options[:autocorrect] # steep:ignore
            flags << '-A' if options[:autocorrect_all] # steep:ignore

            flags
          end
        end
      end
    end
  end
end
