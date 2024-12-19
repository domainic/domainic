# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # A constraint that combines multiple constraints with logical AND behavior.
      #
      # The AndConstraint validates that a value satisfies all of its provided constraints,
      # implementing logical AND behavior. This enables validation rules like "must be both
      # a string and non-empty" or "must be numeric and positive".
      #
      # Key features:
      # - Combines multiple constraints with AND logic
      # - Short-circuits on first failing constraint
      # - Provides clear error messages for failing validations
      # - Supports incremental constraint addition
      #
      # @example Validating a value is both a String and non-empty
      #   string_constraint = StringConstraint.new(:self)
      #   non_empty = LengthConstraint.new(:length, minimum: 1)
      #   string_and_non_empty = AndConstraint.new(:self, [string_constraint, non_empty])
      #
      #   string_and_non_empty.satisfied?("test")  # => true
      #   string_and_non_empty.satisfied?("")      # => false
      #   string_and_non_empty.satisfied?(123)     # => false
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class AndConstraint
        include Behavior #[Array[Behavior[untyped, untyped, untyped]], untyped, {}]

        # Get a description of what the constraint expects.
        #
        # @return [String] a description combining all constraint descriptions with 'and'
        # @rbs override
        def short_description
          descriptions = @expected.map(&:short_description)
          return descriptions.first if descriptions.size == 1

          *first, last = descriptions
          "#{first.join(', ')} and #{last}"
        end

        # @rbs! def expecting: (Behavior[untyped, untyped, untyped]) -> self

        # The description of the violations that caused the constraint to be unsatisfied.
        #
        # This method provides detailed feedback about which constraints failed,
        # listing all violations that prevented validation from succeeding.
        #
        # @return [String] The combined violation descriptions from all constraints
        # @rbs override
        def short_violation_description
          violations = @expected.reject { |constraint| constraint.satisfied?(@actual) }
          descriptions = violations.map(&:short_violation_description)
          return descriptions.first if descriptions.size == 1

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

        # Check if the value satisfies all expected constraints.
        #
        # Short-circuits on the first failing constraint for efficiency.
        #
        # @return [Boolean] whether all constraints are satisfied
        # @rbs override
        def satisfies_constraint?
          @expected.all? { |constraint| constraint.satisfied?(@actual) }
        end

        # Validate that the expectation is an array of valid constraints.
        #
        # @param expectation [Object] the expectation to validate
        #
        # @raise [ArgumentError] if the expectation is not valid
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
