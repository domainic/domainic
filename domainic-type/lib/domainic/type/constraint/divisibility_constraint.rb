# frozen_string_literal: true

require_relative 'relational_constraint'

module Domainic
  module Type
    module Constraint
      # The `DivisibilityConstraint` checks if the subject is divisible by one or more expected values.
      # It inherits from `ExpectationConstraint` and defines the expectation method `:divisible_by?`.
      #
      # @since 0.1.0
      class DivisibilityConstraint < RelationalConstraint
        # Tolerance level used to account for floating-point precision errors when checking for zero remainder.
        #
        # In floating-point arithmetic, operations that should mathematically result in whole numbers
        # might have small rounding errors due to the way floating-point numbers are represented in memory.
        # The `TOLERANCE` constant defines a small threshold value. If the absolute value of the remainder
        # is less than this threshold, it is considered to be effectively zero.
        #
        # @return [Float] the tolerance value used in divisibility checks.
        TOLERANCE = 1e-10

        expectation :divisible_by?

        private

        # Define the expectation method
        #
        # @param subject [Numeric] The number to check.
        # @param expected_value [Numeric] The number that the subject should be divisible by.
        # @return [boolean] True if subject is divisible by expected_value, false otherwise.
        def divisible_by?(subject, expected_value)
          subject = parse_value(subject)
          expected_value = parse_value(expected_value)

          return false if subject.nil? || expected_value.nil?
          return false if expected_value.zero?

          quotient = subject / expected_value
          remainder = quotient % 1.0
          remainder.abs < TOLERANCE
        end

        # Parse the value to a numeric type (Float)
        #
        # @param value [Object] The value to parse.
        # @return [Float, nil] The parsed value as a Float, or nil if parsing fails.
        def parse_value(value)
          Float(value)
        rescue ArgumentError, TypeError
          nil
        end
      end
    end
  end
end
