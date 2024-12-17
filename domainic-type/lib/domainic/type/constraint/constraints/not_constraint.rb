# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # A constraint that negates another constraint's validation logic.
      #
      # The NotConstraint inverts the validation result of its inner constraint,
      # allowing for negative validation rules. This enables expressing conditions
      # like "not equal to", "not included in", etc.
      #
      # Key features:
      # - Inverts any constraint's validation logic
      # - Maintains clear error messages with proper negation
      # - Can be composed with other logical constraints
      # - Preserves the original constraint's type safety
      #
      # @example Validating a value is not a specific type
      #   string_constraint = StringConstraint.new(:self)
      #   not_string = NotConstraint.new(:self, string_constraint)
      #
      #   not_string.satisfied?(123)     # => true
      #   not_string.satisfied?("test")  # => false
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class NotConstraint
        include Behavior #[Behavior[untyped, untyped, untyped], {}, {}]

        # Get a description of what the constraint expects.
        #
        # @return [String] the negated constraint description
        # @rbs override
        def description
          "not #{@expected.description}"
        end

        # The description of the violations that caused the constraint to be unsatisfied.
        #
        # This is used to help compose a error message when the constraint is not satisfied.
        # Implementing classes can override this to provide more specific failure messages.
        #
        # @return [String] The description of the constraint when it fails.
        # @rbs override
        def violation_description
          "not #{@expected.description}"
        end

        protected

        # Check if the value does not satisfy the expected constraint.
        #
        # @return [Boolean] whether the constraint is satisfied
        # @rbs override
        def satisfies_constraint?
          !@expected.satisfied?(@actual)
        end

        # Validate that the expectation is a valid constraint.
        #
        # @param expectation [Object] the expectation to validate
        #
        # @raise [ArgumentError] if the expectation is not a valid constraint
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
