# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # A constraint that ensures no element in an enumerable satisfies a given constraint.
      #
      # The NoneConstraint validates that none of the elements in an enumerable value meet
      # the provided constraint. This enables validation rules like "must not contain any
      # strings" or "must have no negative numbers".
      #
      # Key features:
      # - Validates enumerable elements against a constraint
      # - Short-circuits on first violating element
      # - Provides clear error messages for violating elements
      # - Handles non-enumerable values gracefully
      #
      # @example Validating an array contains no strings
      #   string_constraint = StringConstraint.new(:self)
      #   no_strings = NoneConstraint.new(:self, string_constraint)
      #
      #   no_strings.satisfied?([1, 2, 3])        # => true
      #   no_strings.satisfied?(['a', 1, 'c'])    # => false
      #   no_strings.satisfied?(nil)              # => false (not enumerable)
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class NoneConstraint
        include Behavior #[Behavior[untyped, untyped, untyped], Enumerable, {}]

        # Get a description of what the constraint expects.
        #
        # @deprecated this method will be removed in version 0.1.0
        #
        # @return [String] a description negating the expected constraint description
        # @rbs override
        def short_description
          "not #{@expected.short_description}"
        end

        # The description of the violations that caused the constraint to be unsatisfied.
        #
        # This method provides detailed feedback when any constraints are satisfied,
        # listing all the ways in which the value failed validation.
        #
        # @deprecated this method will be removed in version 0.1.0
        #
        # @return [String] The combined violation descriptions from all violating elements
        # @rbs override
        def short_violation_description
          return 'not Enumerable' unless @actual.is_a?(Enumerable) # steep:ignore NoMethod

          @actual.filter_map do |element|
            next unless @expected.satisfied?(element)

            @expected.short_description
          end.uniq.join(', ')
        end

        protected

        # Check if the value satisfies none of the expected constraints.
        #
        # @return [Boolean] whether no constraints are satisfied
        # @rbs override
        def satisfies_constraint?
          @actual.none? { |element| @expected.satisfied?(element) }
        end

        # Validate that the expectation is a valid constraint.
        #
        # @param expectation [Object] the expectation to validate
        #
        # @raise [ArgumentError] if the expectation is not a valid Domainic::Type::Constraint
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
