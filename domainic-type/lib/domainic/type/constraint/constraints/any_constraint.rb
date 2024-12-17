# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # A constraint that ensures any element in an enumerable satisfies a given constraint.
      #
      # The AnyConstraint validates that at least one element in an enumerable value meets
      # the provided constraint. This enables validation rules like "must contain at least
      # one string" or "must have any positive number".
      #
      # Key features:
      # - Validates enumerable elements against a constraint
      # - Short-circuits on first satisfying element
      # - Provides clear error messages for failing elements
      # - Handles non-enumerable values gracefully
      #
      # @example Validating an array contains any string
      #   string_constraint = StringConstraint.new(:self)
      #   any_string = AnyConstraint.new(:self, string_constraint)
      #
      #   any_string.satisfied?(['a', 1, 'c'])  # => true
      #   any_string.satisfied?([1, 2, 3])      # => false
      #   any_string.satisfied?(nil)            # => false (not enumerable)
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class AnyConstraint
        include Behavior #[Behavior[untyped, untyped, untyped], Enumerable, {}]

        # Get a description of what the constraint expects.
        #
        # @return [String] a description combining all constraint descriptions
        # @rbs override
        def description
          @expected.description
        end

        # The description of the violations that caused the constraint to be unsatisfied.
        #
        # This method provides detailed feedback when no constraints are satisfied,
        # listing all the ways in which the value failed validation.
        #
        # @return [String] The combined violation descriptions from all constraints
        # @rbs override
        def violation_description
          return 'not Enumerable' unless @actual.is_a?(Enumerable) # steep:ignore NoMethod

          @actual.filter_map do |element|
            next if @expected.satisfied?(element)

            @expected.violation_description
          end.uniq.join(', ')
        end

        protected

        # Check if the value satisfies any of the expected constraints.
        #
        # @return [Boolean] whether any constraint is satisfied
        # @rbs override
        def satisfies_constraint?
          @actual.any? { |element| @expected.satisfied?(element) }
        end

        # Validate that the expectation is an array of valid constraints.
        #
        # @param expectation [Object] the expectation to validate
        #
        # @raise [ArgumentError] if the expectation is not valid
        # @return [void]
        # @rbs override
        def validate_expectation!(expectation)
          return if expectation.is_a?(Behavior)

          raise ArgumentError, "expected a Domainic::Type::Constraint, got #{expectation.class}"
        end
      end
    end
  end
end
