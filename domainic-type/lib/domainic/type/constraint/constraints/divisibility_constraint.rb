# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # A constraint for validating that numeric values are divisible by a specified value.
      #
      # This constraint checks if one number is evenly divisible by another, allowing for
      # a configurable tolerance to handle floating-point arithmetic imprecision. It can
      # be used to validate properties like:
      # - Even/odd numbers (divisible by 2)
      # - Factors and multiples
      # - Decimal place alignment (divisible by 0.1, 0.01, etc)
      #
      # @example Basic divisibility check
      #   constraint = DivisibilityConstraint.new(:self, 5)
      #   constraint.satisfied?(10)  # => true
      #   constraint.satisfied?(7)   # => false
      #
      # @example With floating point values
      #   constraint = DivisibilityConstraint.new(:self, 0.1)
      #   constraint.satisfied?(0.3)  # => true
      #   constraint.satisfied?(0.35) # => false
      #
      # @example Custom tolerance
      #   constraint = DivisibilityConstraint.new(:self)
      #   constraint.expecting(3)
      #   constraint.with_options(tolerance: 1e-5)
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class DivisibilityConstraint
        # @rbs!
        #   type options = { ?tolerance: Numeric }

        include Behavior #[Numeric, Numeric, options]

        # Default tolerance for floating-point arithmetic comparisons.
        #
        # @return [Float] The default tolerance value
        DEFAULT_TOLERANCE = 1e-10 #: Float

        # Get a human-readable description of the divisibility requirement.
        #
        # @example
        #   constraint = DivisibilityConstraint.new(:self, 5)
        #   constraint.short_description # => "divisible by 5"
        #
        # @return [String] Description of the divisibility requirement
        # @rbs override
        def short_description
          "divisible by #{@expected.inspect}"
        end

        # Get a human-readable description of why divisibility validation failed.
        #
        # @example With non-numeric value
        #   constraint = DivisibilityConstraint.new(:self, 5)
        #   constraint.satisfied?("not a number")
        #   constraint.short_violation_description # => "not Numeric"
        #
        # @example With non-divisible value
        #   constraint = DivisibilityConstraint.new(:self, 5)
        #   constraint.satisfied?(7)
        #   constraint.short_violation_description # => "not divisible by 5"
        #
        # @return [String] Description of the validation failure
        # @rbs override
        def short_violation_description
          return 'not Numeric' unless @actual.is_a?(Numeric)

          "not divisible by #{@expected.inspect}"
        end

        protected

        # Check if the actual value is evenly divisible by the expected value.
        #
        # This method handles both integer and floating-point values, using the
        # configured tolerance to account for floating-point arithmetic imprecision.
        #
        # @return [Boolean] true if the value is evenly divisible
        # @rbs override
        def satisfies_constraint?
          actual = parse_value(@actual)
          expected = parse_value(@expected)

          return false if actual.nil? || expected.nil?
          return false if expected.zero?

          tolerance = @options.fetch(:tolerance, DEFAULT_TOLERANCE)
          # @type var tolerance: Numeric
          ((actual / expected) - (actual / expected).round).abs < tolerance
        end

        # Validate that the expected value is a non-zero number.
        #
        # @param expectation [Object] The value to validate
        #
        # @raise [ArgumentError] if the value is not a non-zero number
        # @return [void]
        # @rbs override
        def validate_expectation!(expectation)
          raise ArgumentError, 'Expectation must be Numeric' unless expectation.is_a?(Numeric)
          raise ArgumentError, 'Expectation must be non-zero' if expectation.zero?
        end

        private

        # Parse a value into a float, returning nil if parsing fails.
        #
        # @param value [Numeric] The value to parse
        #
        # @return [Float, nil] The parsed float value or nil if parsing failed
        # @rbs (Numeric value) -> Float?
        def parse_value(value)
          Float(value)
        rescue ArgumentError, TypeError
          nil
        end
      end
    end
  end
end
