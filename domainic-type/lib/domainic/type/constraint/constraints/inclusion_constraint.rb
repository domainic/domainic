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
      # @example Array inclusion
      #   constraint = InclusionConstraint.new(:self, 2)
      #   constraint.satisfied?([1, 2, 3])  # => true
      #   constraint.satisfied?([1, 3, 4])  # => false
      #
      # @example String inclusion
      #   constraint = InclusionConstraint.new(:self, 'b')
      #   constraint.satisfied?('abc')  # => true
      #   constraint.satisfied?('ac')   # => false
      #
      # @example Range inclusion
      #   constraint = InclusionConstraint.new(:self, 5)
      #   constraint.satisfied?(1..10)  # => true
      #   constraint.satisfied?(11..20) # => false
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class InclusionConstraint
        include Behavior #[untyped, Enumerable[untyped], {}]

        # Get a human-readable description of the inclusion requirement.
        #
        # @deprecated this method will be removed in version 0.1.0
        #
        # @example
        #   constraint = InclusionConstraint.new(:self, 42)
        #   constraint.short_description # => "including 42"
        #
        # @return [String] A description of the inclusion requirement
        # @rbs override
        def short_description
          "including #{@expected.inspect}"
        end

        # Get a human-readable description of why inclusion validation failed.
        #
        # @deprecated this method will be removed in version 0.1.0
        #
        # @example
        #   constraint = InclusionConstraint.new(:self, 42)
        #   constraint.satisfied?([1, 2, 3])
        #   constraint.short_violation_description # => 'excluding 42'
        #
        # @return [String] A description of which value was missing
        # @rbs override
        def short_violation_description
          "excluding #{@expected.inspect}"
        end

        protected

        # Check if the collection includes the expected value.
        #
        # Uses the collection's #include? method to verify that the expected
        # value is present in the collection being validated.
        #
        # @return [Boolean] true if the collection includes the expected value
        # @rbs override
        def satisfies_constraint?
          @actual.include?(@expected)
        end
      end
    end
  end
end
