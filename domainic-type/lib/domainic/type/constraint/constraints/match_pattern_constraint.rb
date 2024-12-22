# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # A constraint for validating that strings match a given pattern.
      #
      # This constraint verifies that a string value matches a specified regular expression
      # pattern. It supports both Regexp objects and string patterns that are converted to
      # regular expressions.
      #
      # @example Basic pattern matching
      #   constraint = MatchPatternConstraint.new(:self, /\A\d+\z/)
      #   constraint.satisfied?("123")  # => true
      #   constraint.satisfied?("abc")  # => false
      #
      # @example String pattern conversion
      #   constraint = MatchPatternConstraint.new(:self, '\A\w+@\w+\.\w+\z')
      #   constraint.satisfied?("test@example.com")  # => true
      #   constraint.satisfied?("invalid-email")     # => false
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class MatchPatternConstraint
        include Behavior #[Regexp, untyped, {}]

        # Get a human-readable description of the pattern requirement.
        #
        # @example
        #   constraint = MatchPatternConstraint.new(:self, /\d+/)
        #   constraint.short_description # => "matches /\\d+/"
        #
        # @return [String] A description of the pattern requirement
        # @rbs override
        def short_description
          "matching #{@expected.inspect}"
        end

        # Get a human-readable description of why pattern validation failed.
        #
        # @example
        #   constraint = MatchPatternConstraint.new(:self, /\d+/)
        #   constraint.satisfied?("abc")
        #   constraint.short_violation_description # => "does not match /\\d+/"
        #
        # @return [String] A description of the pattern mismatch
        # @rbs override
        def short_violation_description
          "does not match #{@expected.inspect}"
        end

        protected

        # Coerce string patterns into Regexp objects.
        #
        # @param expectation [String, Regexp] The pattern to coerce
        #
        # @return [Regexp] The coerced pattern
        # @rbs override
        def coerce_expectation(expectation)
          expectation.is_a?(String) ? Regexp.new(expectation) : expectation #: Expected
        end

        # Check if the value matches the expected pattern.
        #
        # @return [Boolean] true if the value matches the pattern
        # @rbs override
        def satisfies_constraint?
          @expected.match?(@actual)
        end

        # Validate that the expectation is a valid regular expression.
        #
        # @param expectation [Object] The pattern to validate
        #
        # @raise [ArgumentError] if the expectation is not a Regexp
        # @return [void]
        # @rbs override
        def validate_expectation!(expectation)
          raise ArgumentError, 'expectation must be a Regexp' unless expectation.is_a?(Regexp)
        end
      end
    end
  end
end
