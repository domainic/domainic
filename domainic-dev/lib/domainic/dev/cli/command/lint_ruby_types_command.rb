# frozen_string_literal: true

require 'domainic/dev/cli/command/base_command'
require 'thor'

module Domainic
  module Dev
    class CLI < Thor
      module Command
        # A command to type check Ruby files in the Domainic::Dev project.
        #
        # This class extends {BaseCommand} to provide functionality for type checking Ruby files using Steep.
        #
        # @author {https://aaronmallen.me Aaron Allen}
        # @since 0.1.0
        class LintRubyTypesCommand < BaseCommand
          # steep:ignore:start
          class_option :severity_level, type: :string, default: 'error'
          # steep:ignore:end

          long_desc <<~DESC
            Lint Ruby files with steep.
          DESC

          # Execute the Ruby type checking command.
          #
          # @return [void]
          # @rbs () -> void
          def execute
            # steep:ignore:start
            result = system 'bundle', 'exec', 'steep', 'check', '--severity-level', options[:severity_level]
            # steep:ignore:end
            exit 1 unless result
          end
        end
      end
    end
  end
end
