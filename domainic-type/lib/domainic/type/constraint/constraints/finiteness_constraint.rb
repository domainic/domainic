# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # A constraint for validating that numeric values are finite or infinite.
      #
      # This constraint verifies whether a numeric value is finite or infinite by calling
      # Ruby's standard finite?/infinite? methods. It's useful for ensuring numbers remain
      # within computable bounds and handling edge cases in numerical computations.
      #
      # @example Basic finiteness check
      #   constraint = FinitenessConstraint.new(:self).expecting(:finite)
      #   constraint.satisfied?(42)      # => true
      #   constraint.satisfied?(Float::INFINITY)  # => false
      #
      # @example Checking for infinity
      #   constraint = FinitenessConstraint.new(:self).expecting(:infinite)
      #   constraint.satisfied?(Float::INFINITY)  # => true
      #   constraint.satisfied?(42)      # => false
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class FinitenessConstraint
        # @rbs!
        #   type expected = :finite | :finite? | :infinite | :infinite?

        include Behavior #[expected, Numeric, {}]

        # Get a human-readable description of the finiteness requirement.
        #
        # @return [String] Description of the finiteness requirement
        # @rbs override
        def short_description
          @expected.to_s.delete_suffix('?')
        end

        # Get a human-readable description of why finiteness validation failed.
        #
        # @return [String] Description of the validation failure
        # @rbs override
        def short_violation_description
          if @expected == :finite?
            'infinite'
          elsif @expected == :infinite?
            'finite'
          else
            ''
          end
        end

        protected

        # Coerce the expectation into the correct method name format.
        #
        # Ensures the expectation ends with a question mark to match Ruby's
        # standard method naming for predicate methods.
        #
        # @param expectation [Symbol, String] The finiteness check to perform
        #
        # @return [Symbol] The coerced method name
        # @rbs override
        def coerce_expectation(expectation)
          expectation.to_s.end_with?('?') ? expectation.to_sym : :"#{expectation}?" #: expected
        end

        # Check if the value satisfies the finiteness constraint.
        #
        # @return [Boolean] true if the value matches the finiteness requirement
        # @rbs override
        def satisfies_constraint?
          interpret_result(@actual.public_send(@expected))
        end

        # Validate that the expectation is a valid finiteness check.
        #
        # @param expectation [Object] The value to validate
        #
        # @raise [ArgumentError] if the expectation is not :finite, :finite?, :infinite, or :infinite?
        # @return [void]
        # @rbs override
        def validate_expectation!(expectation)
          return if %i[finite? infinite?].include?(expectation)

          raise ArgumentError, "Invalid expectation: #{expectation}. Must be one of :finite, :finite?, :infinite, " \
                               'or :infinite?'
        end

        private

        # Interpret the result from Ruby's finite?/infinite? methods.
        #
        # Handles the different return values from Ruby's finiteness checking methods:
        # - finite? returns true/false
        # - infinite? returns nil (for finite numbers), 1 (for +∞), or -1 (for -∞)
        #
        # @example
        #   interpret_result(true)   # => true
        #   interpret_result(false)  # => false
        #   interpret_result(nil)    # => false
        #   interpret_result(1)      # => true
        #   interpret_result(-1)     # => true
        #
        # @param result [Boolean, Integer, nil] The result from finite? or infinite?
        #
        # @return [Boolean] true if the result indicates the desired finiteness state
        # @rbs ((bool | Numeric)? result) -> bool
        def interpret_result(result)
          case result
          when true, false
            result
          when nil
            false
          else
            true
          end
        end
      end
    end
  end
end
