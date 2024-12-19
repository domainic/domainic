# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # A constraint that combines multiple constraints with logical OR behavior.
      #
      # The OrConstraint validates that a value satisfies at least one of its provided constraints,
      # implementing logical OR behavior. This enables validation rules like "must be either a
      # string or a symbol" or "must be nil or a positive number".
      #
      # Key features:
      # - Combines multiple constraints with OR logic
      # - Short-circuits on first passing constraint
      # - Provides clear error messages listing all failed attempts
      # - Supports incremental constraint addition
      #
      # @example Validating a value is either a String or Symbol
      #   string_constraint = StringConstraint.new(:self)
      #   symbol_constraint = SymbolConstraint.new(:self)
      #   string_or_symbol = OrConstraint.new(:self, [string_constraint, symbol_constraint])
      #
      #   string_or_symbol.satisfied?("test")  # => true
      #   string_or_symbol.satisfied?(:test)   # => true
      #   string_or_symbol.satisfied?(123)     # => false
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class OrConstraint
        include Behavior #[Array[Behavior[untyped, untyped, untyped]], untyped, {}]

        # Get a description of what the constraint expects.
        #
        # @return [String] a description combining all constraint descriptions with 'or'
        # @rbs override
        def short_description
          descriptions = @expected.map(&:short_description)
          return descriptions.first if descriptions.size == 1

          *first, last = descriptions
          "#{first.join(', ')} or #{last}"
        end

        # @rbs! def expecting: (Behavior[untyped, untyped, untyped]) -> self

        # The description of the violations that caused the constraint to be unsatisfied.
        #
        # This method provides detailed feedback when no constraints are satisfied,
        # listing all the ways in which the value failed validation. Uses 'and' in the
        # message because all constraints failed (e.g., "was not a string AND was not a
        # symbol" rather than "was not a string OR was not a symbol").
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

        # Check if the value satisfies any of the expected constraints.
        #
        # Short-circuits on the first satisfied constraint for efficiency.
        #
        # @return [Boolean] whether any constraint is satisfied
        # @rbs override
        def satisfies_constraint?
          @expected.any? { |constraint| constraint.satisfied?(@actual) }
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
