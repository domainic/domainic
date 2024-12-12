# frozen_string_literal: true

require 'domainic/dev'
require 'domainic/dev/gem/path_set'
require 'domainic/dev/gem/version'

module Domainic
  module Dev
    # A class responsible for managing gem information within the Domainic gem.
    #
    # This class provides a way to access and manipulate gem metadata including dependencies, paths, and version
    # information. It uses {PathSet} for file system operations and {Version} for semantic version handling.
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class Gem
      # @rbs @dependencies: Array[untyped]
      # @rbs @name: String
      # @rbs @paths: PathSet
      # @rbs @version: Version

      # @return [Array<Object>] the gem's dependencies
      attr_reader :dependencies #: Array[untyped]

      # @return [String] the gem's name
      attr_reader :name #: String

      # @return [PathSet] the gem's path set
      attr_reader :paths #: PathSet

      # @return [Version] the gem's version
      attr_reader :version #: Version

      # Get all gems in the project.
      #
      # @return [Array<Gem>] array of all gems
      # @rbs () -> Array[Gem]
      def self.all
        Domainic::Dev.root.glob('{*/*.gemspec,domainic.gemspec}').map(&:dirname).map do |root_directory|
          new(root_directory)
        end
      end

      # Find a gem by name.
      #
      # @param gem_name [String] name of the gem to find
      # @return [Gem, nil] the found gem or nil
      # @rbs (String) -> Gem?
      def self.find(gem_name)
        all.find { |gem| gem.name == gem_name.strip }
      end

      # Initialize a new Gem instance.
      #
      # @param root_directory [Pathname] the root directory of the gem
      # @return [Gem] a new instance of Gem
      # @raise [RuntimeError] if the gemspec is missing a valid SEMVER
      # @rbs (Pathname root_directory) -> void
      def initialize(root_directory)
        @paths = PathSet.new(root_directory)
        initialize_with_gemspec
        initialize_version
      end

      # Get the constant name for the gem.
      #
      # @return [String] the constant name
      # @rbs () -> String
      def constant_name
        name.split(/[-_]/).map(&:upcase).join('_')
      end

      # Get the module name for the gem.
      #
      # @return [String] the module name
      # @rbs () -> String
      def module_name
        name.gsub('-', '::')
            .gsub(/(^|_|::)([a-z])/) { (::Regexp.last_match(1) || '') + (::Regexp.last_match(2)&.upcase || '') }
            .delete('_')
      end

      private

      # Initialize gem information from gemspec.
      #
      # @return [void]
      # @rbs () -> void
      def initialize_with_gemspec
        spec = ::Gem::Specification.load(paths.gemspec.to_s) # steep:ignore
        @dependencies = spec.dependencies
        @name = spec.name
      end

      # Initialize version information.
      #
      # @return [void]
      # @raise [RuntimeError] if the gemspec is missing a valid SEMVER
      # @rbs () -> void
      def initialize_version
        semver = paths.gemspec.read.match(/[\w]+_SEMVER\s*=\s*['"]([^'"]+)['"]/)&.[](1)
        raise "#{name} gemspec is missing a valid SEMVER" unless semver

        @version = Version.new(semver)
      end
    end
  end
end
