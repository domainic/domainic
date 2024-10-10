# frozen_string_literal: true

module Domainic
  module Dev
    module GemManager
      # The Gem class is responsible for managing the gem's metadata and dependencies.
      #
      # @!attribute [r] dependencies
      #  The dependencies of the gem.
      #  @return [Array<::Gem::Dependency>]
      #
      # @!attribute [r] name
      #  The name of the gem.
      #  @return [String]
      #
      # @!attribute [r] paths
      #  The paths of the gem.
      #  @return [Paths]
      #
      # @since 0.1.0
      class Gem
        # Important paths for the gem.
        #
        # @!attribute [r] gemspec
        #  The path to the gemspec file of the gem.
        #  @return [Pathname]
        #
        # @!attribute [r] lib
        #  The path to the lib directory of the gem.
        #  @return [Pathname]
        #
        # @!attribute [r] root
        #  The path to the root directory of the gem.
        #  @return [Pathname]
        #
        # @!attribute [r] sig
        #  The path to the signatures directory of the gem.
        #  @return [Pathname]
        #
        # @!attribute [r] test
        #  The path to the test directory of the gem.
        #  @return [Pathname]
        Paths = Struct.new(:gemspec, :lib, :root, :sig, :test, keyword_init: true)

        # @dynamic dependencies
        # @dynamic name
        # @dynamic paths
        attr_reader :dependencies, :name, :paths

        # Initialize a new instance of Gem.
        #
        # @param root_directory [Pathname] The path to the root directory of the gem.
        # @return [Gem] the new instance of Gem.
        def initialize(root_directory)
          initialize_paths(root_directory)

          spec = ::Gem::Specification.load(paths.gemspec.to_s)
          @dependencies = spec.dependencies
          @name = spec.name
        end

        # Build the gem and move the built gem file to the `pkg` directory.
        #
        # @return [void]
        def build!
          sync!
          system("gem build -V #{paths.gemspec}")
          built_gem_path = Dir.glob('*.gem').first
          FileUtils.mkdir_p('pkg')
          FileUtils.mv(built_gem_path, 'pkg') if built_gem_path
        end

        # The gem name in a constant friendly format.
        #
        # @return [String] the constant friendly name of the gem.
        def constant_name
          parts = name.split(/[-_]/).map(&:upcase)
          parts.join('_')
        end

        # Sync the gemspec file with the current {#version}.
        #
        # @return [void]
        def sync!
          paths.gemspec.write(build_gemspec)
        end

        # The {Version} instance for the gem.
        #
        # @raise [RuntimeError] if the gemspec does not contain a SEMVER constant.
        # @return [Version]
        def version
          @version ||= begin
            semver = paths.gemspec.read.match(/[\w]+_SEMVER\s*=\s*['"]([^'"]+)['"]/)&.[](1)
            raise "#{name} gemspec does not contain a SEMVER constant." unless semver

            Version.new(semver)
          end
        end

        private

        # Build the gemspec file with updated version constants.
        #
        # @return [String] the updated gemspec file.
        def build_gemspec
          paths.gemspec.read.gsub(/^#{Regexp.escape(constant_name)}_(GEM_VERSION|SEMVER)\s*=\s*['"].*['"]/) do
            version_type = Regexp.last_match(1)
            version_value = version_type == 'GEM_VERSION' ? version.to_gem_version : version.to_semver
            "#{constant_name}_#{version_type} = '#{version_value}'"
          end
        end

        # Initialize the {Paths} instance for the gem
        #
        # @param root_directory [Pathname] The path to the root directory of the gem.
        # @return [void]
        def initialize_paths(root_directory)
          @paths = Paths.new(
            gemspec: root_directory.glob('*.gemspec').first,
            lib: root_directory.join('lib'),
            root: root_directory,
            sig: root_directory.join('sig'),
            test: root_directory.join('spec')
          )
        end
      end
    end
  end
end
