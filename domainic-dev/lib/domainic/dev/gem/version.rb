# frozen_string_literal: true

module Domainic
  module Dev
    class Gem
      # Represents a semantic version of a gem.
      #
      # @since 0.1.0
      class Version
        include Comparable

        # @rbs @build: String?
        # @rbs @major: Integer
        # @rbs @minor: Integer
        # @rbs @patch: Integer
        # @rbs @pre: String?

        # A regular expression to match SemVer strings.
        #
        # @return [Regexp]
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

        # @!attribute [r] build
        #   The Version build metadata string.
        #
        #   @return [String, nil] the build metadata.
        attr_reader :build #: String?

        # @!attribute [r] major
        #   The Version major version number.
        #
        #   @return [Integer] the major version.
        attr_reader :major #: Integer

        # @!attribute [r] minor
        #   The Version minor version number.
        #
        #   @return [Integer] the minor version.
        attr_reader :minor #: Integer

        # @!attribute [r] patch
        #   The Version patch version number.
        #
        #   @return [Integer] the patch version.
        attr_reader :patch #: Integer

        # @!attribute [r] pre
        #   The Version pre-release version string.
        #
        #   @return [String, nil] the pre-release version.
        attr_reader :pre #: String?

        # Initializes a new instance of Version.
        #
        # @param semver_version_string [String] the semantic version string.
        # @raise [ArgumentError] If the provided string does not conform to SemVer.
        # @return [Version] a new instance of Version.
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

        # Defines the spaceship operator for Comparable.
        #
        # @param other [Version] Another Version instance to compare against.
        #
        # @return [Integer] Returns `1` if self > other, `-1` if self < other, or `0` if equal.
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

        # Compares two pre-release version strings according to Semantic Versioning rules.
        #
        # This method compares two pre-release version strings (`prea` and `preb`) to determine their precedence.
        # It returns:
        # - `1` if `prea` has higher precedence than `preb`,
        # - `-1` if `prea` has lower precedence than `preb`,
        # - `0` if both have equal precedence.
        #
        # Pre-release versions have lower precedence than the associated normal version.
        # Precedence is determined by comparing each dot-separated identifier from left to right.
        # Identifiers consisting of only digits are compared numerically.
        # Identifiers with letters or hyphens are compared lexically in ASCII sort order.
        # Numeric identifiers always have lower precedence than non-numeric identifiers.
        # A larger set of pre-release fields has higher precedence than a smaller set if all
        # preceding identifiers are equal.
        #
        # @param prea [String, nil] The first pre-release version string.
        # @param preb [String, nil] The second pre-release version string.
        #
        # @return [Integer] Returns `1` if `prea` > `preb`, `-1` if `prea` < `preb`, or `0` if equal.
        # @rbs (String? prea, String? preb) -> Integer?
        def compare_pre(prea, preb)
          return 0 if prea.nil? && preb.nil?
          return 1 if prea.nil?
          return -1 if preb.nil?

          map_identifiers(identifiers(prea)) <=> map_identifiers(identifiers(preb))
        end

        # Checks equality based on hash value.
        #
        # @param other [Object] The object to compare with.
        #
        # @return [Boolean] `true` if other is a Version with the same attributes, `false` otherwise.
        # @rbs (untyped other) -> bool
        def eql?(other)
          hash == other.hash
        end

        # Provides a hash value for the Version instance.
        #
        # @return [Integer] The hash value based on major, minor, patch, pre, and build.
        # @rbs () -> Integer
        def hash
          to_array.hash
        end

        # Splits a pre-release or build metadata string into individual identifiers,
        # converting purely numeric identifiers to integers.
        #
        # This method takes a string representing the pre-release or build metadata
        # portion of a semantic version (e.g., "alpha.1", "build-123") and splits it
        # into an array of identifiers. Numeric identifiers are converted from strings
        # to integers to facilitate accurate semantic version comparisons.
        #
        # @param pre [String] The pre-release or build metadata string to be split.
        #
        # @return [Array<String, Integer>] An array of identifiers where:
        #   - Alphanumeric identifiers remain as strings.
        #   - Purely numeric identifiers are converted to integers.
        # @rbs (String pre) -> Array[String | Integer]
        def identifiers(pre)
          pre.split(/[\.\-]/).map { |e| /\A\d+\z/.match?(e) ? Integer(e) : e }
        end

        # Converts the Version instance to an Array.
        #
        # @return [Array<Integer, String, nil>] an Array representation of the Version.
        # @rbs () -> Array[(Integer | String)?]
        def to_array
          [major, minor, patch, pre, build]
        end
        alias to_a to_array

        # Converts the Version instance to a Gem::Version friendly string.
        #
        # @return [String] the Gem::Version friendly string.
        # @rbs () -> String
        def to_gem_version_string
          [major, minor, patch, pre, build].compact.join('.').strip
        end

        # Converts the Version instance to a Hash.
        #
        # @return [Hash{Symbol => String, Integer, nil}] A Hash representation of the Version.
        # @rbs () -> Hash[Symbol, (String | Integer)?]
        def to_hash
          { major:, minor:, patch:, pre:, build: }
        end
        alias to_h to_hash

        # Converts the Version instance to a SemVer friendly string.
        #
        # @return [String] the SemVer friendly string.
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

        # Maps identifiers to a structured format for comparison.
        #
        # This method transforms each identifier into a tuple where:
        # - The first element indicates the type (`0` for Integer, `1` for String).
        # - The second element is the identifier's value.
        #
        # This structure ensures that numeric identifiers are considered lower than
        # alphanumeric ones during comparison, adhering to SemVer rules.
        #
        # @param identifiers [Array<String, Integer>] The array of identifiers to map.
        #
        # @return [Array<Array<Integer, String, Integer>>] The mapped array of identifiers.
        # @rbs (Array[String | Integer]) -> Array[Array[Integer | String]]
        def map_identifiers(identifiers)
          identifiers.map { |id| id.is_a?(Integer) ? [0, id] : [1, id] }
        end
      end
    end
  end
end
