# frozen_string_literal: true

require 'domainic/dev/cli/command/base_command'
require 'domainic/dev/cli/command/mixin/gem_names_argument'
require 'domainic/dev/gem/version'
require 'thor'

module Domainic
  module Dev
    class CLI < Thor
      module Command
        # A command to publish Domainic gems to RubyGems.org.
        #
        # This class extends {BaseCommand} and includes {Mixin::GemNamesArgument} to provide functionality for
        # publishing gems. It handles dependency resolution, packaging, git tagging, and publishing to RubyGems.org.
        #
        # @author {https://aaronmallen.me Aaron Allen}
        # @since 0.1.0
        class PublishGemsCommand < BaseCommand
          include Mixin::GemNamesArgument

          # List of gems that should not be published.
          #
          # @return [Array<String>] the list of gem names that cannot be published
          DISALLOW_PUBLISH = %w[domainic-dev].freeze #: Array[String]

          long_desc <<~LONGDESC
            Publish one or more domainic gems. If no gem names are provided all gems are published.

            Example:

            $ dev publish                                           # Publish all tests
            $ dev publish domainic-dev                              # Publish domainic-dev
            $ dev publish domainic-dev domainic-attributer          # Publish domainic-dev and domainic-attributer
          LONGDESC

          # Execute the gem publishing command.
          #
          # @return [void]
          # @rbs () -> void
          def execute
            gems.each do |gem|
              next if DISALLOW_PUBLISH.include?(gem.name)

              latest_release = latest_release_for_gem(gem)
              next if latest_release == gem.version.to_semver_string

              publish_dependencies_for_gem(gem)
              package_gem(gem)
              generate_tags_for_gem(gem)
              publish_gem(gem)
            end
          end

          private

          # Generate git tags for a gem release.
          #
          # @param gem [Gem] the gem to generate tags for
          # @return [void]
          # @rbs (Gem gem) -> void
          def generate_tags_for_gem(gem)
            tag_name = gem.name == 'domainic' ? 'v' : "#{gem.name}-v"
            system("git tag #{tag_name}#{gem.version.to_semver_string}")
          end

          # Get the latest released version of a gem.
          #
          # @param gem [Gem] the gem to check
          # @return [String, nil] the latest version string or nil if no releases exist
          # @rbs (Gem gem) -> String?
          def latest_release_for_gem(gem)
            `git tag`.split("\n")
                     .grep(/^#{gem.name}-v|^v\d/)
                     .map { |tag| tag.gsub(/^#{gem.name}-v|^v/, '').strip }
                     .max_by { |tag| Domainic::Dev::Gem::Version.new(tag) }
          end

          # Package a gem for publishing.
          #
          # @param gem [Gem] the gem to package
          # @return [void]
          # @rbs (Gem gem) -> void
          def package_gem(gem)
            system('bin/dev', 'package', gem.name)
          end

          # Publish all dependencies for a gem.
          #
          # @param gem [Gem] the gem whose dependencies should be published
          # @return [void]
          # @rbs (Gem gem) -> void
          def publish_dependencies_for_gem(gem)
            gem.dependencies
               .map(&:name)
               .filter_map { |gem_name| Domainic::Dev::Gem.find(gem_name) }
               .each { |dependency| system('bin/dev', 'publish', dependency.name) }
          end

          # Publish a gem to RubyGems.org.
          #
          # @param gem [Gem] the gem to publish
          # @return [void]
          # @rbs (Gem gem) -> void
          def publish_gem(gem)
            system('gem', 'push', "pkg/#{gem.name}-#{gem.version.to_gem_version_string}.gem")
          end
        end
      end
    end
  end
end
