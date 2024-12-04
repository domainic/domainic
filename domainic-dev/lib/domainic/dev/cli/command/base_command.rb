# frozen_string_literal: true

require 'thor'

module Domainic
  module Dev
    class CLI < Thor
      module Command
        # Base class for all CLI commands in the Domainic::Dev.
        #
        # This class extends Thor::Group to provide common functionality for CLI commands. All command classes should
        # inherit from this class to ensure consistent behavior and interface. It provides helper methods for terminal
        # output formatting including colorization and icon display.
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

          # Terminal color codes for output formatting.
          #
          # @return [Hash{Symbol => Integer}] the color codes
          COLOR_CODES = {
            blue: 34,
            cyan: 36,
            green: 32,
            red: 31,
            magenta: 35,
            white: 37,
            yellow: 33
          }.freeze #: Hash[Symbol, Integer]

          # Common icons used in outputs.
          #
          # @return [Hash{Symbol => String}] the icons
          ICONS = {
            check: '✔',
            x: '✘'
          }.freeze #: Hash[Symbol, String]

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

          private

          # Colorizes the given text with the specified color.
          #
          # @param text [String] the text to colorize
          # @param color [Symbol] the color to apply
          # @return [String] the colorized text
          # @raise [ArgumentError] if the specified color is invalid
          # @rbs (String text, Symbol color) -> String
          def colorize(text, color)
            color_code = COLOR_CODES[color.to_sym]
            raise ArgumentError, "Invalid color: #{color}" unless color_code

            "\e[#{color_code}m#{text}\e[0m"
          end

          # Retrieves the icon for the given name.
          #
          # @param name [String, Symbol] the name of the icon
          # @param color [Symbol, nil] the color to apply
          # @return [String] the icon
          # @rbs (String | Symbol name, ?Symbol? color) -> String
          def icon(name, color = nil)
            icon = ICONS[name.to_sym]
            if color.nil?
              icon
            else
              colorize(icon, color)
            end
          end
        end
      end
    end
  end
end
