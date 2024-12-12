# frozen_string_literal: true

module Domainic
  module Dev
    class Gem
      # A class responsible for managing semantic versioning in the Domainic gem.
      #
      # This class provides a way to parse and manipulate semantic version strings within the {Gem}'s structure. It
      # follows the SemVer 2.0.0 specification for version number formatting and precedence ordering.
      #
      # @see https://semver.org
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class Version
        include Comparable

        # Regular expression for parsing semantic version strings.
        #
        # @return [Regexp] the regular expression used to parse semantic version strings
        SEMVER_REGEXP = /
          \A
          (0|[1-9]\d*)\.
          (0|[1-9]\d*)\.
          (0|[1-9]\d*)
          (?:-
            (
              (?:0|[1-9]\d*|\d*[a-zA-Z-][a-zA-Z0-9-]*)
              (?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][a-zA-Z0-9-]*))*
            )
          )?
          (?:\+
            (
              [0-9A-Za-z-]+
              (?:\.[0-9A-Za-z-]+)*
            )
          )?
          \Z
        /x #: Regexp

        # @return [String, nil] the build metadata of the version
        attr_reader :build #: String?

        # @return [Integer] the major version number
        attr_reader :major #: Integer

        # @return [Integer] the minor version number
        attr_reader :minor #: Integer

        # @return [Integer] the patch version number
        attr_reader :patch #: Integer

        # @return [String, nil] the pre-release version string
        attr_reader :pre #: String?

        # Initialize a new Version instance.
        #
        # @param semver_version_string [String] a semantic version string
        # @return [Version] a new instance of Version
        # @raise [ArgumentError] if the version string is not a valid semantic version
        # @rbs (String semver_version_string) -> void
        def initialize(semver_version_string)
          parts = semver_version_string.match(SEMVER_REGEXP)

          if parts.nil?
            raise ArgumentError, "#{semver_version_string} is not a valid SemVer Version (http://semver.org)"
          end

          @major = parts[1].to_i
          @minor = parts[2].to_i
          @patch = parts[3].to_i
          @pre   = parts[4]
          @build = parts[5]
        end

        # Compare two version instances for sorting.
        #
        # @param other [Version] the other version to compare with
        # @return [Integer, nil] -1, 0, or 1 based on version precedence, nil if other is not a Version
        # @rbs (untyped other) -> Integer?
        def <=>(other)
          return nil unless other.is_a?(Version)

          cmp = major <=> other.major
          return cmp unless cmp.zero?

          cmp = minor <=> other.minor
          return cmp unless cmp.zero?

          cmp = patch <=> other.patch
          return cmp unless cmp.zero?

          compare_pre(pre, other.pre)
        end

        # Compare two pre-release version strings.
        #
        # @param prea [String, nil] first pre-release version string
        # @param preb [String, nil] second pre-release version string
        # @return [Integer, nil] -1, 0, or 1 based on pre-release precedence
        # @rbs (untyped prea, untyped preb) -> Integer?
        def compare_pre(prea, preb)
          return 0 if prea.nil? && preb.nil?
          return 1 if prea.nil?
          return -1 if preb.nil?

          map_identifiers(identifiers(prea)) <=> map_identifiers(identifiers(preb))
        end

        # Compare two version instances for equality.
        #
        # @param other [Version] the other version to compare with
        # @return [Boolean] true if versions are equal
        # @rbs (untyped other) -> bool
        def eql?(other)
          hash == other.hash
        end

        # Generate a hash value for the version.
        #
        # @return [Integer] the hash value
        # @rbs () -> Integer
        def hash
          to_array.hash
        end

        # Split a pre-release version string into its constituent parts.
        #
        # @param pre [String] pre-release version string
        # @return [Array<Integer, String, nil>] array of pre-release identifiers
        # @rbs (String pre) -> Array[Integer | String | nil]
        def identifiers(pre)
          pre.split(/[\.\-]/).map { |e| /\A\d+\z/.match?(e) ? Integer(e) : e }
        end

        # Convert the version to an array representation.
        #
        # @return [Array<Integer, String, nil>] array containing version components
        # @rbs () -> Array[Integer | String | nil]
        def to_array
          [major, minor, patch, pre, build]
        end
        alias to_a to_array

        # Convert the version to a gem version string.
        #
        # @return [String] gem version string representation
        # @rbs () -> String
        def to_gem_version_string
          [major, minor, patch, pre, build].compact.join('.').strip
        end

        # Convert the version to a hash representation.
        #
        # @return [Array<Symbol, Integer, String, nil>] hash containing version components
        # @rbs () -> Hash[Symbol, Integer | String | nil]
        def to_hash
          { major:, minor:, patch:, pre:, build: }
        end
        alias to_h to_hash

        # Convert the version to a semantic version string.
        #
        # @return [String] semantic version string representation
        # @rbs () -> String
        def to_semver_string
          semver = "#{major}.#{minor}.#{patch}"
          semver += "-#{pre}" if pre
          semver += "+#{build}" if build
          semver
        end
        alias to_s to_semver_string
        alias to_string to_semver_string

        private

        # Map identifiers for comparison.
        #
        # @param identifiers [Array<Integer, String, nil>] array of identifiers to map
        # @return [Array<Array<Integer, String, nil>>] mapped identifiers
        # @rbs (Array[Integer | String | nil] identifiers) -> Array[Array[Integer | String | nil]]
        def map_identifiers(identifiers)
          identifiers.map { |id| id.is_a?(Integer) ? [0, id] : [1, id] }
        end
      end
    end
  end
end
