# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # A constraint for validating that a collection includes a specific value.
      #
      # This constraint verifies that a collection contains an expected value by using
      # the collection's #include? method. It works with any object that responds to
      # #include?, such as Arrays, Sets, Strings, and Ranges.
      #
      # @example Array inclusion validation
      #   constraint = InclusionConstraint.new(:self, 2)
      #   constraint.satisfied?([1, 2, 3])  # => true
      #   constraint.satisfied?([1, 3, 4])  # => false
      #
      # @example String inclusion validation
      #   constraint = InclusionConstraint.new(:self, 'b')
      #   constraint.satisfied?('abc')  # => true
      #   constraint.satisfied?('ac')   # => false
      #
      # @example Range inclusion validation
      #   constraint = InclusionConstraint.new(:self, 5)
      #   constraint.satisfied?(1..10)  # => true
      #   constraint.satisfied?(11..20) # => false
      #
      # @api private
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class InclusionConstraint
        include Behavior #[untyped, untyped, {}]

        # Get a human-readable description of the inclusion requirement.
        #
        # @example
        #   constraint = InclusionConstraint.new(:self, 42)
        #   constraint.description # => "including 42"
        #
        # @return [String] A description of the inclusion requirement
        # @rbs override
        def short_description
          "including #{@expected.inspect}"
        end

        # Get a human-readable description of why inclusion validation failed.
        #
        # @example
        #   constraint = InclusionConstraint.new(:self, 42)
        #   constraint.satisfied?([1, 2, 3])
        #   constraint.short_violation_description # => "excluding 42"
        #
        # @return [String] A description of the inclusion failure
        # @rbs override
        def short_violation_description
          "excluding #{@expected.inspect}"
        end

        protected

        # Check if the collection includes the expected value.
        #
        # Uses the collection's #include? method to verify that the expected
        # value is present.
        #
        # @return [Boolean] true if the collection includes the value
        # @rbs override
        def satisfies_constraint?
          @actual.include?(@expected)
        end
      end
    end
  end
end
