# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # A constraint for validating that all elements in a collection are unique.
      #
      # This constraint ensures that an enumerable collection contains no duplicate
      # elements by comparing the collection's size before and after removing duplicates.
      # It works with any object that includes the Enumerable module and responds
      # to #uniq and #count.
      #
      # @example Basic uniqueness validation
      #   constraint = UniquenessConstraint.new(:self)
      #   constraint.satisfied?([1, 2, 3])     # => true
      #   constraint.satisfied?([1, 2, 2, 3])  # => false
      #
      # @example With different collection types
      #   constraint = UniquenessConstraint.new(:self)
      #   constraint.satisfied?(Set[1, 2, 3])        # => true
      #   constraint.satisfied?(['a', 'b', 'b'])     # => false
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class UniquenessConstraint
        include Behavior #[nil, Enumerable, {}]

        # Get a human-readable description of the uniqueness requirement.
        #
        # @deprecated this method will be removed in version 0.1.0
        #
        # @example
        #   constraint = UniquenessConstraint.new(:self)
        #   constraint.description # => "unique"
        #
        # @return [String] A description of the uniqueness requirement
        # @rbs override
        def short_description
          'unique'
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
          'not unique'
        end

        protected

        # Check if all elements in the collection are unique.
        #
        # Compares the size of the collection before and after removing duplicates.
        # If the sizes are equal, all elements are unique. If they differ, duplicates
        # were present.
        #
        # @return [Boolean] true if all elements are unique
        # @rbs override
        def satisfies_constraint?
          @actual.uniq.count == @actual.count
        end
      end
    end
  end
end
