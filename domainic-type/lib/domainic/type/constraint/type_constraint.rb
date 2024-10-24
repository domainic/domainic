# frozen_string_literal: true

require_relative 'relational_constraint'
require_relative 'specification/with_access_qualification'

module Domainic
  module Type
    module Constraint
      # The `TypeConstraint` class ensures that a given subject is of a specified type.
      # It inherits from `ExpectationConstraint` and defines the expectation method `:is_type?`.
      #
      # The expected type can be a standard Ruby class, a custom Domainic type,
      # or any class that responds to `primitive_type`.
      #
      # @since 0.1.0
      class TypeConstraint < RelationalConstraint
        include Specification::WithAccessQualification

        # Defines the expectation method `:is_type?` for the constraint.
        expectation :is_type?

        # Add a coercer to the `:expected` parameter that converts `nil` values to `NilClass`.
        parameter :expected do
          coercer do |value|
            value.include?(nil) ? value.compact.push(NilClass) : value
          end
        end

        private

        # Checks if the subject is of the expected type.
        #
        # @param subject [Object] The value to check.
        # @param type [Class, Module, Domainic::Type::BaseType] The expected type.
        # @return [Boolean] `true` if the subject is of the expected type, `false` otherwise.
        def is_type?(subject, type) # rubocop:disable Naming/PredicateName
          type = resolve_type(type)
          type.is_a?(Domainic::Type::BaseType) ? type.validate(subject) : subject.is_a?(type)
        end

        def resolve_type(type)
          return type if type.is_a?(Domainic::Type::BaseType)
          return type.new if type.is_a?(Class) && type < Domainic::Type::BaseType

          type
        end
      end
    end
  end
end
