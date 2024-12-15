# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # @since 0.1.0
      class DivisibilityConstraint
        include Behavior

        DEFAULT_TOLERANCE = 1e-10 #: Float

        # @rbs @expected: Numeric

        # @rbs override
        def description
          "be divisible by #{@expected}"
        end

        # @rbs override
        def failure_description
          "was not divisible by #{@expected}"
        end

        private

        # @rbs (Numeric value) -> Float?
        def parse_value(value)
          Float(value)
        rescue ArgumentError, TypeError
          nil
        end

        # @rbs override
        def satisfies_constraint?
          subject = parse_value(@actual)
          expected_value = parse_value(@expected)

          return false if subject.nil? || expected_value.nil?
          return false if expected_value.zero?

          quotient = subject / expected_value
          remainder = quotient % 1.0
          remainder.abs < @options.fetch(:tolerance, DEFAULT_TOLERANCE)
        end

        # @rbs override
        def validate_expectation!(expectation)
          raise ArgumentError, 'expectation must be a Numeric' unless expectation.is_a?(Numeric)
          raise ArgumentError, 'expectation must be a non-zero Numeric' if expectation.zero?
        end

        # @rbs override
        def validate_subject!(value)
          raise ArgumentError, 'value must be a Numeric' unless value.is_a?(Numeric)
        end
      end
    end
  end
end
