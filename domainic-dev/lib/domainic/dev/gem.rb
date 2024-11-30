# frozen_string_literal: true

require 'domainic/dev/gem/path_set'
require 'domainic/dev/gem/version'

module Domainic
  module Dev
    # Manager, build, version, and publish Domainic gems.
    #
    # @since 0.1.0
    class Gem
      # @rbs @dependencies: Array[::Gem::Dependency]
      # @rbs @name: String
      # @rbs @paths: PathSet
      # @rbs @version: Version

      # @!attribute [r] dependencies
      #   The dependencies of the Gem.
      #
      #   @return [Array<::Gem::Dependency>] the dependencies of the Gem.
      attr_reader :dependencies #: Array[::Gem::Dependency]

      # @!attribute [r] name
      #   The name of the Gem.
      #
      #   @return [String] the name of the Gem.
      attr_reader :name #: String

      # @!attribute [r] paths
      #   The {PathSet paths} belonging to the Gem.
      #
      #   @return [PathSet] the {PathSet paths} belonging to the Gem.
      attr_reader :paths #: PathSet

      # @!attribute [r] version
      #   The Gem's {Version}.
      #
      #   @return [Version] the Gem's {Version}.
      attr_reader :version #: Version

      # Get all gems in the Domainic mono-repo.
      #
      # @return [Array<Gem>] all gems in the Domainic mono-repo.
      # @rbs () -> Array[Gem]
      def self.all
        Domainic::Dev.root.glob('{*/*.gemspec,domainic.gemspec}').map(&:dirname).map do |root_directory|
          new(root_directory)
        end
      end

      # Find a Domainic gem in the Domainic mono-repo by name.
      #
      # @param gem_name [String] the name of the gem to find.
      # @return [Gem, nil] the gem with the given name, or `nil` if no gem with the given name is found.
      # @rbs (String gem_name) -> Gem?
      def self.find(gem_name)
        all.find { |gem| gem.name == gem_name.strip }
      end

      # Initialize a new instance of Gem.
      #
      # @param root_directory [Pathname] the root directory of the Gem.
      # @raise [RuntimeError] if the Gem's gemspec is missing a valid SEMVER.
      # @return [Gem] a new instance of Gem.
      # @rbs (Pathname root_directory) -> void
      def initialize(root_directory)
        @paths = PathSet.new(root_directory)
        initialize_with_gemspec
        initialize_version
      end

      # The {#name} in a constant friendly format.
      #
      # @return [String] the {#name} in a constant friendly format.
      # @rbs () -> String
      def constant_name
        name.split(/[-_]/).map(&:upcase).join('_')
      end

      private

      # Initialize dependencies and name from the gemspec file.
      #
      # @return [void]
      # @rbs () -> void
      def initialize_with_gemspec
        spec = ::Gem::Specification.load(paths.gemspec.to_s)
        @dependencies = spec.dependencies
        @name = spec.name
      end

      # Initialize the {Version}.
      #
      # @return [void]
      # @raise [RuntimeError] if the Gem's gemspec is missing a valid SEMVER.
      # @return [void]
      # @rbs () -> void
      def initialize_version
        semver = paths.gemspec.read.match(/[\w]+_SEMVER\s*=\s*['"]([^'"]+)['"]/)&.[](1)
        raise "#{name} gemspec is missing a valid SEMVER" unless semver

        @version = Version.new(semver)
      end
    end
  end
end
