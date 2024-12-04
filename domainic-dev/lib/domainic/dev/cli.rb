# frozen_string_literal: true

require 'domainic/dev/cli/command/run_tests_command'
require 'thor'

module Domainic
  module Dev
    # A command line interface for development tools in the Domainic gem.
    #
    # This class extends Thor to provide CLI commands for development tasks like running tests. Each command inherits
    # from {Command::BaseCommand} and can include mixins from the {Command::Mixin} namespace for common functionality.
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class CLI < Thor
      # Whether to exit with a non-zero status on command failure.
      #
      # @return [Boolean] `true` to exit with non-zero status on failure
      # @rbs () -> bool
      def self.exit_on_failure? = true

      # steep:ignore:start
      long_desc Command::RunTestsCommand.long_desc, wrap: false
      register(Command::RunTestsCommand, 'test', 'test [GEM_NAMES]', 'Run tests for one or more domainic gems')
      # steep:ignore:end
    end
  end
end
