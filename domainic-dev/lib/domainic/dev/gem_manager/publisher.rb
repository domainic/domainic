# frozen_string_literal: true

module Domainic
  module Dev
    module GemManager
      # Publish Domainic gems to rubygems.org
      #
      # @since 0.1.0
      # @author {https://aaronmallen.me Aaron Allen}
      class Publisher
        # Initialize a new instance of Publisher
        #
        # @param gem [Gem] The gem to be published.
        # @return [Publisher]
        def initialize(gem)
          @gem = gem
        end

        # Publish the gem to rubygems.org
        #
        # @return [void]
        def publish!
          return unless should_publish?

          publish_dependencies
          prepare_release
          system("gem push pkg/#{gem.name}-#{gem.version.to_gem_version}.gem")
        end

        private

        attr_reader :gem

        # Generates a git tag for the release, prefixed by the gem name.
        #
        # For the main `domainic` gem, the tag is prefixed with `v`. For other gems, the tag is prefixed
        # with the gem name.
        #
        # @return [void]
        def generate_tags
          tag_name = gem.name == 'domainic' ? 'v' : "#{gem.name}-v"
          system("git tag #{tag_name}#{gem.version.to_semver}")
        end

        # Retrieves the latest release version from the git tags.
        #
        # The method filters and processes the git tags to find the latest release tag matching
        # the gem's versioning pattern.
        #
        # @return [String, nil]
        def latest_release
          @latest_release ||= `git tag`.split("\n")
                                       .grep(/^#{gem.name}-v|^v\d/)
                                       .map { |tag| tag.gsub(/^#{gem.name}-v|^v/, '').strip }
                                       .max_by { |tag| Semantic::Version.new(tag) }
        end

        # Prepares the gem for release by building the gem and generating git tags.
        #
        # @return [void]
        def prepare_release
          puts "== Releasing #{gem.name} #{gem.version.to_semver} =="
          gem.build!
          generate_tags
        end

        # Releases the gem's dependencies by recursively releasing all gems that the current gem depends on.
        #
        # @return [void]
        def publish_dependencies
          gem.dependencies
             .map(&:name)
             .filter_map { |dependency| GemManager.gem(dependency) }
             .each { |dependency| Publisher.new(dependency).publish! }
        end

        # Determines if the gem should be released.
        #
        # The gem is not released if it is already at the latest version or if it is the `domainic-dev` gem.
        #
        # @return [Boolean]
        def should_publish?
          return false if gem.name == 'domainic-dev'

          if latest_release == gem.version.to_semver
            puts "== Skipping #{gem.name} (v#{gem.version.to_semver}) already released =="
            return false
          end
          true
        end
      end
    end
  end
end
