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
          if @expected.to_s.start_with?('A', 'E', 'I', 'O', 'U')
            "an #{@expected}"
          else
            "a #{@expected}"
          end
        end

        # @rbs override
        def failure_description
          if @actual.class.to_s.start_with?('A', 'E', 'I', 'O', 'U')
            "an #{@actual.class}"
          else
            "a #{@actual.class}"
          end
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
