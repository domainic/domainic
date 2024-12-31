# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # A constraint for validating string character sets.
      #
      # This constraint verifies that string values contain only characters from
      # specific character sets:
      # - ascii: ASCII characters (0x00-0x7F)
      # - alphanumeric: Letters and numbers
      # - alpha: Letters only
      # - numeric: Numbers only
      # - printable: Visible characters and spaces
      #
      # @example ASCII validation
      #   constraint = CharacterSetConstraint.new(:self, :ascii)
      #   constraint.satisfied?("hello")  # => true
      #   constraint.satisfied?("héllo")  # => false
      #
      # @example Alphanumeric validation
      #   constraint = CharacterSetConstraint.new(:self, :alphanumeric)
      #   constraint.satisfied?("abc123")  # => true
      #   constraint.satisfied?("abc-123") # => false
      #
      # @example Numeric validation
      #   constraint = CharacterSetConstraint.new(:self, :numeric)
      #   constraint.satisfied?("12345")   # => true
      #   constraint.satisfied?("123.45")  # => false
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class CharacterSetConstraint
        # @rbs!
        #   type expected = :ascii | :alphanumeric | :alpha | :numeric | :printable

        include Behavior #[expected, untyped, {}]

        # Valid character set patterns
        #
        # @return [Hash{Symbol => Regexp}] Map of set names to validation patterns
        VALID_SETS = {
          ascii: /\A[\x00-\x7F]*\z/, # Any ASCII character
          alphanumeric: /\A[[:alnum:]]*\z/,   # Letters and numbers
          alpha: /\A[[:alpha:]]*\z/,          # Letters only
          numeric: /\A[[:digit:]]*\z/,        # Numbers only
          printable: /\A[[:print:]]*\z/       # Visible chars and spaces
        }.freeze #: Hash[expected, Regexp]

        # Get a human-readable description of the character set requirement.
        #
        # @deprecated this method will be removed in version 0.1.0
        #
        # @example
        #   constraint = CharacterSetConstraint.new(:self, :numeric)
        #   constraint.short_description # => "only numeric characters"
        #
        # @return [String] A description of the character set requirement
        # @rbs override
        def short_description
          "only #{@expected} characters"
        end

        # Get a human-readable description of why character validation failed.
        #
        # @deprecated this method will be removed in version 0.1.0
        #
        # @example
        #   constraint = CharacterSetConstraint.new(:self, :numeric)
        #   constraint.satisfied?("abc123")
        #   constraint.short_violation_description # => "non-numeric characters"
        #
        # @return [String] A description of the character set violation
        # @rbs override
        def short_violation_description
          "non-#{@expected} characters"
        end

        protected

        # Convert character set name to symbol.
        #
        # @param expectation [String, Symbol] The character set name
        #
        # @return [Symbol] The character set name as a symbol
        # @rbs override
        def coerce_expectation(expectation)
          expectation.to_sym
        end

        # Check if the string contains only characters from the expected set.
        #
        # @return [Boolean] true if all characters match the expected set
        # @rbs override
        def satisfies_constraint?
          pattern = VALID_SETS.fetch(@expected)
          pattern.match?(@actual)
        end

        # Validate that the expectation is a valid character set.
        #
        # @param expectation [Object] The character set to validate
        #
        # @raise [ArgumentError] if the expectation is not a valid character set
        # @return [void]
        # @rbs override
        def validate_expectation!(expectation)
          raise ArgumentError, "set must be one of: #{VALID_SETS.keys.join(', ')}" unless VALID_SETS.key?(expectation)
        end
      end
    end
  end
end
