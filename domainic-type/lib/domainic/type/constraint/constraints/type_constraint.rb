# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # @since 0.1.0
      class TypeConstraint
        include Behavior

        # @rbs @expected: Class | Module | Type::Behavior

        # @rbs override
        def description
          @expected.to_s.match?(/^[AEIOU]/i) ? "an #{@expected}" : "a #{@expected}"
        end

        # @rbs override
        def failure_description
          @actual.class.to_s.match?(/^[AEIOU]/i) ? "an #{@actual.class}" : "a #{@actual.class}"
        end

        private

        # @rbs override
        def satisfies_constraint?
          @expected === @actual # rubocop:disable Style/CaseEquality
        end

        # @rbs override
        def validate_expectation!(expectation)
          return if expectation.is_a?(Class) || expectation.is_a?(Module) || expectation.respond_to?(:===)

          raise ArgumentError, "#{expectation} must be a Class, Module, or Domainic::Type"
        end
      end
    end
  end
end
