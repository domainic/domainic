# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # A constraint that ensures none of the provided constraints are satisfied.
      #
      # The NorConstraint validates that none of the elements in an enumerable value meet
      # any of the provided constraints. This enables validation rules like "must not contain
      # any strings or negative numbers".
      #
      # Key features:
      # - Validates enumerable elements against multiple constraints with NOR logic
      # - Short-circuits on first satisfying constraint for performance
      # - Provides clear error messages for violating constraints
      # - Handles non-enumerable values gracefully
      # - Supports incremental constraint addition
      #
      # @example Validating an array contains no strings or negative numbers
      #   string_constraint = StringConstraint.new(:self)
      #   negative_number_constraint = NegativeNumberConstraint.new(:self)
      #   no_strings_or_negatives = NorConstraint.new(:self, [string_constraint, negative_number_constraint])
      #
      #   no_strings_or_negatives.satisfied?([1, 2, 3])            # => true
      #   no_strings_or_negatives.satisfied?(['a', 1, 'c'])        # => false
      #   no_strings_or_negatives.satisfied?([1, -2, 3])           # => false
      #   no_strings_or_negatives.satisfied?(nil)                  # => false (not enumerable)
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class NorConstraint
        include Behavior #[Array[Behavior[untyped, untyped, untyped]], untyped, {}]

        # Get a description of what the constraint expects.
        #
        # @return [String] a description combining all constraint descriptions with 'nor'
        # @rbs override
        def short_description
          descriptions = @expected.map(&:short_description)
          return descriptions.first if descriptions.size == 1

          *first, last = descriptions
          "#{first.join(', ')} nor #{last}"
        end

        # The description of the violations that caused the constraint to be unsatisfied.
        #
        # This method provides detailed feedback about which constraints were satisfied,
        # listing all violations that caused the validation to fail.
        #
        # @return [String] The combined violation descriptions from all satisfied constraints
        # @rbs override
        def short_violation_description
          violations = @expected.select { |constraint| constraint.satisfied?(@actual) }
          descriptions = violations.map(&:short_violation_description)
          return descriptions.first if descriptions.size == 1
          return '' if descriptions.empty?

          *first, last = descriptions
          "#{first.join(', ')} and #{last}"
        end

        protected

        # Coerce the expectation into an array and append new constraints.
        #
        # This enables both initializing with an array of constraints and adding
        # new constraints incrementally via expecting().
        #
        # @param expectation [Behavior] the constraint to add
        #
        # @return [Array<Behavior>] the updated array of constraints
        # @rbs (untyped expectation) -> Array[Behavior[untyped, untyped, untyped]]
        def coerce_expectation(expectation)
          expectation.is_a?(Array) ? (@expected || []).concat(expectation) : (@expected || []) << expectation
        end

        # Check if none of the values satisfy any of the expected constraints.
        #
        # Short-circuits on the first satisfying constraint for efficiency.
        #
        # @return [Boolean] whether none of the constraints are satisfied
        # @rbs override
        def satisfies_constraint?
          @expected.none? { |constraint| constraint.satisfied?(@actual) }
        end

        # Validate that the expectation is an array of valid constraints.
        #
        # @param expectation [Object] the expectation to validate
        #
        # @raise [ArgumentError] if the expectation is not a valid Domainic::Type::Constraint
        # @return [void]
        # @rbs override
        def validate_expectation!(expectation)
          return if expectation.is_a?(Array) && expectation.all?(Behavior)

          raise ArgumentError, 'Expectation must be a Domainic::Type::Constraint'
        end
      end
    end
  end
end
