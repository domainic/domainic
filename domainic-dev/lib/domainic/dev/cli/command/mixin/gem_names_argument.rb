# frozen_string_literal: true

require 'domainic/dev/gem'
require 'thor'

module Domainic
  module Dev
    class CLI < Thor
      module Command
        module Mixin
          # A mixin to add gem name argument handling to CLI commands.
          #
          # This module provides functionality for accepting and validating gem names as command arguments. When
          # included, it adds a `gem_names` argument to the command and provides methods for resolving those names to
          # {Gem} instances.
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.1.0
          module GemNamesArgument
            # @rbs @gems: Array[Gem]

            class << self
              private

              # Configure the including class with the gem_names argument.
              #
              # @param base [Class] the class including this module
              # @return [void]
              # @rbs (untyped base) -> void
              def included(base)
                base.class_eval do
                  argument :gem_names, type: :array, banner: '[GEM_NAMES]', default: [] # steep:ignore
                end
              end
            end

            private

            # Get the {Gem} instances for the provided gem names.
            #
            # @return [Array<Gem>] array of {Gem} instances
            # @raise [ArgumentError] if a provided gem name cannot be found
            # @rbs () -> Array[Gem]
            def gems
              @gems ||= if gem_names.empty? # steep:ignore NoMethod
                          Domainic::Dev::Gem.all
                        else
                          gem_names.map do |gem_name| # steep:ignore NoMethod
                            gem = Domainic::Dev::Gem.find(gem_name)
                            raise ArgumentError, "Unknown gem: #{gem_name}" if gem.nil?

                            gem
                          end
                        end
            end
          end
        end
      end
    end
  end
end
