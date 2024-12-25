# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # A constraint for validating that a value is an instance of a specified class or module.
      #
      # This constraint checks if the value is a direct instance of the expected class or module
      # (excluding subclasses or other related types).
      #
      # @example Basic instance validation
      #   constraint = InstanceOfConstraint.new(:self, String)
      #   constraint.satisfied?("test")     # => true
      #   constraint.satisfied?(:symbol)   # => false
      #
      # @example Custom class validation
      #   class MyClass; end
      #   constraint = InstanceOfConstraint.new(:self, MyClass)
      #   constraint.satisfied?(MyClass.new) # => true
      #   constraint.satisfied?("test")      # => false
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class InstanceOfConstraint
        include Behavior #[Class | Module, untyped, {}]

        # Get a human-readable description of the instance requirement.
        #
        # @example
        #   constraint = InstanceOfConstraint.new(:self, String)
        #   constraint.description # => "instance of String"
        #
        # @return [String] A description of the expected instance type
        # @rbs override
        def short_description
          "instance of #{@expected}"
        end

        # Get a human-readable description of why instance validation failed.
        #
        # @example
        #   constraint = InstanceOfConstraint.new(:self, String)
        #   constraint.satisfied?(:symbol)
        #   constraint.short_violation_description # => "not an instance of String"
        #
        # @return [String] A description of the instance validation failure
        # @rbs override
        def short_violation_description
          "not an instance of #{@expected}"
        end

        protected

        # Check if the actual value is an instance of the expected class or module.
        #
        # @return [Boolean] true if the value is an instance of the expected class/module
        # @rbs override
        def satisfies_constraint?
          @actual.class < @expected || @actual.instance_of?(@expected)
        end

        # Validate that the expected value is a Class or Module.
        #
        # @raise [ArgumentError] if the expected value is not a Class or Module
        # @return [void]
        # @rbs override
        def validate_expectation!(expectation)
          return if [Class, Module].any? { |mod| expectation.is_a?(mod) }

          raise ArgumentError, 'Expectation must be a Class or Module'
        end
      end
    end
  end
end
