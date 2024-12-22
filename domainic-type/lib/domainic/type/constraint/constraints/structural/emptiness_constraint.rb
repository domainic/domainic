# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # A constraint for validating that a collection is empty.
      #
      # This constraint ensures that an enumerable collection contains no elements
      # by checking the collection's #empty? method. It works with any object that
      # includes the Enumerable module and responds to #empty?.
      #
      # @example Basic emptiness validation
      #   constraint = EmptinessConstraint.new(:self)
      #   constraint.satisfied?([])        # => true
      #   constraint.satisfied?([1, 2, 3]) # => false
      #
      # @example With different collection types
      #   constraint = EmptinessConstraint.new(:self)
      #   constraint.satisfied?(Set.new)    # => true
      #   constraint.satisfied?(['a', 'b']) # => false
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class EmptinessConstraint
        include Behavior #[nil, untyped, {}]

        # Get a human-readable description of the emptiness requirement.
        #
        # @example
        #   constraint = EmptinessConstraint.new(:self)
        #   constraint.description # => "empty"
        #
        # @return [String] A description of the emptiness requirement
        # @rbs override
        def short_description
          'empty'
        end

        # Get a human-readable description of why emptiness validation failed.
        #
        # @example
        #   constraint = EmptinessConstraint.new(:self)
        #   constraint.satisfied?([1, 2, 3])
        #   constraint.short_violation_description # => "not empty"
        #
        # @return [String] A description of the emptiness failure
        # @rbs override
        def short_violation_description
          'not empty'
        end

        protected

        # Check if the collection is empty.
        #
        # Uses the collection's #empty? method to determine if it contains
        # any elements.
        #
        # @return [Boolean] true if the collection is empty
        # @rbs override
        def satisfies_constraint?
          @actual.empty?
        end
      end
    end
  end
end
