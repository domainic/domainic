# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # A constraint for validating that values are equal to an expected value.
      #
      # This constraint uses Ruby's standard equality operator (==) to compare values,
      # allowing for type-specific equality definitions while maintaining consistent
      # behavior across different value types.
      #
      # @example Basic equality validation
      #   constraint = EqualityConstraint.new(:self, 42)
      #   constraint.satisfied?(42)    # => true
      #   constraint.satisfied?(41)    # => false
      #
      # @example Complex object comparison
      #   point = Struct.new(:x, :y).new(1, 2)
      #   constraint = EqualityConstraint.new(:self, point)
      #   constraint.satisfied?(Struct.new(:x, :y).new(1, 2)) # => true
      #   constraint.satisfied?(Struct.new(:x, :y).new(2, 1)) # => false
      #
      # @example Array comparison
      #   constraint = EqualityConstraint.new(:self, [1, 2, 3])
      #   constraint.satisfied?([1, 2, 3]) # => true
      #   constraint.satisfied?([3, 2, 1]) # => false
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class EqualityConstraint
        include Behavior #[untyped, untyped, {}]

        # Get a human-readable description of the equality requirement.
        #
        # @example
        #   constraint = EqualityConstraint.new(:self, 42)
        #   constraint.description # => "equal to 42"
        #
        # @return [String] A description of the expected value
        # @rbs override
        def short_description
          "equal to #{@expected.inspect}"
        end

        # Get a human-readable description of why equality validation failed.
        #
        # @example
        #   constraint = EqualityConstraint.new(:self, 42)
        #   constraint.satisfied?(41)
        #   constraint.short_violation_description # => "not equal to 42"
        #
        # @return [String] A description of the equality failure
        # @rbs override
        def short_violation_description
          "not equal to #{@expected.inspect}"
        end

        protected

        # Check if the actual value equals the expected value.
        #
        # Uses Ruby's standard equality operator (==) for comparison, allowing
        # objects to define their own equality behavior.
        #
        # @return [Boolean] true if the values are equal
        # @rbs override
        def satisfies_constraint?
          @actual == @expected
        end
      end
    end
  end
end
