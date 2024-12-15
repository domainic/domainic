# frozen_string_literal: true

module Domainic
  module Type
    module Constraint
      # @since 0.1.0
      class NotConstraint
        include Behavior

        # @rbs @expected: Behavior

        # @rbs override
        def description
          "not: #{@expected.description}"
        end

        # @rbs override
        def failure_description
          "was: #{@expected.description}"
        end

        private

        # @rbs override
        def satisfies_constraint?
          !@expected.satisfied?(@actual)
        end

        # @rbs override
        def validate_expectation!(expectation)
          return if expectation.is_a?(Behavior)

          raise ArgumentError, 'expectation must be a Domainic::Type::Constraint'
        end
      end
    end
  end
end
