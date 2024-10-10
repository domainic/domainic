# frozen_string_literal: true

module Domainic
  module Dev
    class CLI < Thor
      # Linting commands for the Domainic Dev command line interface.
      #
      # @since 0.1.0
      class Lint < Thor
        default_command :all

        desc 'all', 'Run all linters'
        long_desc <<~LONGDESC, wrap: false
          Run all linters for the Domainic Dev project. This includes running Rubocop, Markdown Lint and Steep.
        LONGDESC
        def all
          invoke(:markdown)
          invoke(:ruby)
          invoke(:types)
        end

        desc 'markdown', 'Run the Markdown linter'
        long_desc <<~LONGDESC, wrap: false
          Run the Markdown linter for the Domainic Dev project.
        LONGDESC
        def markdown
          system 'bundle exec mdl **/*.md'
        end

        desc 'ruby [OPTIONS]', 'Run the Ruby linter'
        long_desc <<~LONGDESC, wrap: false
          Run the Ruby linter for the Domainic Dev project. For a list of options run `rubocop --help`.
        LONGDESC
        def ruby(*options)
          system('bundle', 'exec', 'rubocop', *options)
        end

        desc 'types', 'Run the type checker'
        long_desc <<~LONGDESC, wrap: false
          Run the type checker for the Domainic Dev project.
        LONGDESC
        def types
          system 'bundle exec steep check'
        end
      end
    end
  end
end
