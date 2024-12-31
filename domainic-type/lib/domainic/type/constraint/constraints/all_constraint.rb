# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # A constraint that ensures all elements in an enumerable satisfy a given constraint.
      #
      # The AllConstraint allows applying a constraint to every element within an enumerable value,
      # making it possible to validate collections where each element must meet certain criteria.
      #
      # Key features:
      # - Validates each element against the expected constraint
      # - Short-circuits on first failing element
      # - Provides clear error messages about failing elements
      # - Handles empty collections appropriately
      #
      # @example Validating array of strings
      #   string_constraint = StringConstraint.new(:self)
      #   all_strings = AllConstraint.new(:self, string_constraint)
      #
      #   all_strings.satisfied?(['a', 'b', 'c']) # => true
      #   all_strings.satisfied?(['a', 1, 'c'])   # => false
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class AllConstraint
        include Behavior #[Behavior[untyped, untyped, untyped], Enumerable, {}]

        # Get a description of what the constraint expects.
        #
        # @deprecated this method will be removed in version 0.1.0
        #
        # @return [String] the constraint description
        # @rbs override
        def short_description
          @expected.short_description
        end

        # The description of the violations that caused the constraint to be unsatisfied.
        #
        # This is used to help compose a error message when the constraint is not satisfied.
        # Implementing classes can override this to provide more specific failure messages.
        #
        # @deprecated this method will be removed in version 0.1.0
        #
        # @return [String] The description of the constraint when it fails.
        # @rbs override
        def short_violation_description
          return 'not Enumerable' unless @actual.is_a?(Enumerable) # steep:ignore NoMethod

          @actual.filter_map do |element|
            next if @expected.satisfied?(element)

            @expected.short_violation_description
          end.uniq.join(', ')
        end

        protected

        # Check if all elements satisfy the expected constraint.
        #
        # @return [Boolean] whether the constraint is satisfied
        # @rbs override
        def satisfies_constraint?
          @actual.all? { |element| @expected.satisfied?(element) }
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
