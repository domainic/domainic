# frozen_string_literal: true

require 'domainic/type/behavior'
require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # A constraint for validating that values match a specific type.
      #
      # This constraint provides type checking functionality through Ruby's standard
      # type system, supporting class inheritance checks, module inclusion checks,
      # and custom type validation through the case equality operator (===).
      #
      # @example Basic class type validation
      #   constraint = TypeConstraint.new(:self, String)
      #   constraint.satisfied?("hello") # => true
      #   constraint.satisfied?(123)     # => false
      #
      # @example Module type validation
      #   constraint = TypeConstraint.new(:self, Enumerable)
      #   constraint.satisfied?([1, 2, 3]) # => true
      #   constraint.satisfied?("string")   # => false
      #
      # @example Custom type validation
      #   class EvenType
      #     def self.===(value)
      #       value.is_a?(Integer) && value.even?
      #     end
      #   end
      #
      #   constraint = TypeConstraint.new(:self, EvenType)
      #   constraint.satisfied?(2)  # => true
      #   constraint.satisfied?(3)  # => false
      #
      # @example Nil type validation
      #   constraint = TypeConstraint.new(:self, nil)
      #   constraint.satisfied?(nil)   # => true
      #   constraint.satisfied?(false) # => false
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class TypeConstraint
        include Behavior #[Class | Module | Type::Behavior | nil, untyped, {}]

        # Get a human-readable description of the expected type.
        #
        # @deprecated this method will be removed in version 0.1.0
        #
        # @example
        #   constraint = TypeConstraint.new(:self, Float)
        #   constraint.description # => "Float"
        #
        #   constraint = TypeConstraint.new(:self, Array)
        #   constraint.description # => "Array"
        #
        # @return [String] A description of the expected type
        # @rbs override
        def short_description
          @expected.to_s
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
          @actual.class.to_s
        end

        protected

        # Coerce the expected type, converting nil to NilClass for type checking.
        #
        # @param expectation [Class, Module, nil] The type to coerce
        #
        # @return [Class, Module] The coerced type
        # @rbs override
        def coerce_expectation(expectation)
          expectation.nil? ? NilClass : expectation
        end

        # Check if the actual value matches the expected type.
        #
        # The check is performed using both the case equality operator (===)
        # and Ruby's is_a? method to provide maximum flexibility in type checking.
        #
        # @return [Boolean] true if the value matches the expected type
        # @rbs override
        def satisfies_constraint?
          @expected === @actual || @actual.is_a?(@expected) # rubocop:disable Style/CaseEquality
        end

        # Validate that the expected type is a valid Ruby type.
        #
        # @param expectation [Object] The type to validate
        #
        # @raise [ArgumentError] if the expectation is not a valid type
        # @return [void]
        # @rbs override
        def validate_expectation!(expectation)
          return if [Class, Module, Type::Behavior].any? { |type| expectation.is_a?(type) }

          raise ArgumentError, 'Expectation must be a Class, Module, or Domainic::Type'
        end
      end
    end
  end
end
