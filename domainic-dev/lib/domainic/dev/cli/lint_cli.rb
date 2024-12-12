# frozen_string_literal: true

require 'domainic/dev/cli/command/lint_markdown_command'
require 'domainic/dev/cli/command/lint_ruby_command'
require 'domainic/dev/cli/command/lint_ruby_types_command'
require 'thor'

module Domainic
  module Dev
    class CLI < Thor
      # A command line interface for running linting tools in the Domainic::Dev project.
      #
      # This class extends Thor to provide a unified interface for running various linting tools including:
      # * Markdown linting with mdl via {Command::LintMarkdownCommand}
      # * Ruby linting with RuboCop via {Command::LintRubyCommand}
      # * Ruby type checking with Steep via {Command::LintRubyTypesCommand}
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class LintCLI < Thor
        # steep:ignore:start
        default_command :all
        map 'md' => 'markdown', 'rb' => 'ruby'

        desc 'all', 'Run all linters'
        # Run all available linters.
        #
        # @return [void]
        # @rbs () -> void
        def all
          invoke(:markdown)
          invoke(:ruby)
          invoke(:types)
        end

        long_desc Command::LintMarkdownCommand.long_desc, wrap: false
        register(
          Command::LintMarkdownCommand,
          'markdown',
          'markdown',
          'Lint markdown files with mdl'
        )

        long_desc Command::LintRubyCommand.long_desc, wrap: false
        register(
          Command::LintRubyCommand,
          'ruby',
          'ruby [OPTIONS]',
          'Lint Ruby files with rubocop'
        )

        long_desc Command::LintRubyTypesCommand.long_desc, wrap: false
        register(
          Command::LintRubyTypesCommand,
          'types',
          'types',
          'Lint Ruby files with steep'
        )
        # steep:ignore:end
      end
    end
  end
end
