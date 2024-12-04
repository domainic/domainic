# frozen_string_literal: true

require 'domainic/dev'
require 'domainic/dev/cli/command/base_command'
require 'domainic/dev/cli/command/mixin/gem_names_argument'
require 'fileutils'
require 'thor'

module Domainic
  module Dev
    class CLI < Thor
      module Command
        # A command to package (build) gem files for the Domainic gems.
        #
        # This class extends {BaseCommand} and includes {Mixin::GemNamesArgument} to provide functionality for
        # packaging gems into `.gem` files in the `pkg` directory.
        #
        # @author {https://aaronmallen.me Aaron Allen}
        # @since 0.1.0
        class PackageGemsCommand < BaseCommand
          include Mixin::GemNamesArgument

          long_desc <<~DESC
            Package one or more domainic gems. If no gem names are provided all gems are packaged.

            Example:

            $ dev package                                           # Build all gems
            $ dev package domainic-dev                              # Build the domainic-dev gem
            $ dev package domainic-dev domainic-attributer          # Build the domainic-dev and domainic-attributer gems
          DESC

          # Execute the gem packaging command.
          #
          # @return [void]
          # @rbs () -> void
          def execute
            FileUtils.mkdir_p Domainic::Dev.root.join('pkg').to_s
            results = gems.map { |gem| package_gem(gem) }
            exit 1 unless results.all?
          end

          private

          # Package a single gem file.
          #
          # @param gem [Gem] the gem to package
          # @return [Boolean] true if packaging was successful
          # @rbs (Gem) -> bool
          def package_gem(gem)
            result = false
            Dir.chdir(gem.paths.root.to_s) do
              result = system 'gem', 'build', '-V', gem.paths.gemspec.to_s

              FileUtils.mv(
                "#{gem.name}-#{gem.version.to_gem_version_string}.gem",
                Domainic::Dev.root.join('pkg').to_s
              )
            end
            result
          end
        end
      end
    end
  end
end
