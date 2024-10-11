# frozen_string_literal: true

module Domainic
  module Dev
    module GemManager
      # Manage gem versions
      #
      # @since 0.1.0
      class Version
        # Initialize a new instance of Version.
        #
        # @param version_string [String] The version string to parse.
        # @return [Version] The new instance of Version.
        def initialize(version_string)
          @semantic = Semantic::Version.new(version_string)
        end

        # @!method build
        #  The build number of the version.
        #  @return [String, nil] The build version.
        #
        # @!method major
        #  The major number of the version.
        #  @return [Integer] The major version.
        #
        # @!method minor
        #  The minor number of the version.
        #  @return [Integer] The minor version.
        #
        # @!method patch
        #  The patch number of the version.
        #  @return [Integer] The patch version.
        #
        # @!method pre
        #  The pre-release number of the version.
        #  @return [String, nil] the pre-release version.
        %i[build major minor patch pre].each do |method|
          define_method(method) { @semantic.public_send(method) }
        end

        # @!method build=(value)
        #  Set the build version.
        #  @param value [String, nil] The build version.
        #  @return [String, nil] The build version.
        #
        # @!method pre=(value)
        #  Set the pre-release version.
        #  @param value [String, nil] The pre-release version.
        #  @return [String, nil] The pre-release version.
        %i[pre build].each do |method|
          define_method(:"#{method}=") { |value| @semantic.public_send(:"#{method}=", value) }
        end

        # Increment a version part.
        #
        # @param version_part [Symbol] The version part to increment.
        # @return [self] The incremented version.
        def increment!(version_part)
          @semantic = @semantic.increment!(version_part)
          self
        end

        # The version as a Gem version friendly string.
        #
        # @return [String] The version string.
        def to_gem_version
          [major, minor, patch, pre, build].compact.join('.')
        end

        # The version as a Semantic version friendly string.
        #
        # @return [String] The version string.
        def to_semver
          @semantic.to_s
        end
      end
    end
  end
end
