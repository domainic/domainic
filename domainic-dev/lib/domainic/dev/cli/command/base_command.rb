# frozen_string_literal: true

require 'thor'

module Domainic
  module Dev
    class CLI < Thor
      module Command
        # Base class for all CLI commands in the Domainic::Dev.
        #
        # This class extends Thor::Group to provide common functionality for CLI commands. All command classes should
        # inherit from this class to ensure consistent behavior and interface.
        #
        # @abstract Subclass and implement CLI command behavior
        # @author {https://aaronmallen.me Aaron Allen}
        # @since 0.1.0
        class BaseCommand < Thor::Group
          # Whether to exit with a non-zero status on command failure.
          #
          # @return [Boolean] true to exit with non-zero status on failure
          # @rbs () -> bool
          def self.exit_on_failure? = true

          # @rbs @long_desc: String?

          # Get or set the long form description for the command.
          #
          # @param text [String] the long form description text
          # @return [String, nil] the long form description
          # @rbs (?String text) -> String?
          def self.long_desc(text = '')
            return @long_desc if text.empty?

            @long_desc = text
          end
        end
      end
    end
  end
end
