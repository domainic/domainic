# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # A constraint for validating that collection elements are in sorted order.
      #
      # This constraint ensures that elements in a collection are in ascending order
      # by comparing the collection to its sorted version. The constraint works with
      # any collection whose elements implement the Comparable module and respond to
      # the <=> operator.
      #
      # @example Basic ordering validation
      #   constraint = OrderingConstraint.new(:self)
      #   constraint.satisfied?([1, 2, 3])     # => true
      #   constraint.satisfied?([1, 3, 2])     # => false
      #
      # @example With string elements
      #   constraint = OrderingConstraint.new(:self)
      #   constraint.satisfied?(['a', 'b', 'c']) # => true
      #   constraint.satisfied?(['c', 'a', 'b']) # => false
      #
      # @example With mixed types that can be compared
      #   constraint = OrderingConstraint.new(:self)
      #   constraint.satisfied?([1, 1.5, 2])     # => true
      #   constraint.satisfied?([2, 1, 1.5])     # => false
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class OrderingConstraint
        include Behavior #[nil, untyped, {}]

        # Get a human-readable description of the ordering requirement.
        #
        # @example
        #   constraint = OrderingConstraint.new(:self)
        #   constraint.description # => "ordered"
        #
        # @return [String] A description of the ordering requirement
        # @rbs override
        def short_description
          'ordered'
        end

        # Get a human-readable description of why ordering validation failed.
        #
        # @example
        #   constraint = OrderingConstraint.new(:self)
        #   constraint.satisfied?([3, 1, 2])
        #   constraint.short_violation_description # => "not ordered"
        #
        # @return [String] A description of the ordering failure
        # @rbs override
        def short_violation_description
          'not ordered'
        end

        protected

        # Check if the collection elements are in sorted order.
        #
        # Compares the collection to its sorted version to determine if the
        # elements are already in ascending order.
        #
        # @return [Boolean] true if the elements are in sorted order
        # @rbs override
        def satisfies_constraint?
          @actual.sort == @actual
        end
      end
    end
  end
end
