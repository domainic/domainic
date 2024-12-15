# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # @since 0.1.0
      class AllConstraint
        include Behavior

        # @rbs @expected: Behavior

        # @rbs override
        def description
          "all elements to #{@expected.description}"
        end

        # @rbs override
        def failure_description
          failure_descriptions = @actual.map do |element|
            next if @expected.satisfied?(element)

            @expected.failure_description
          end

          "had elements that #{failure_descriptions.join(', and ')}"
        end

        private

        # @rbs override
        def satisfies_constraint?
          @actual.all? { |element| @expected.satisfied?(element) }
        end

        # @rbs override
        def validate_expectation!(expectation)
          return if expectation.is_a?(Behavior)

          raise ArgumentError, 'expectation must be a Domainic::Type::Constraint'
        end

        # @rbs override
        def validate_subject!(value)
          raise ArgumentError, 'value must be an Enumerable' unless value.is_a?(Enumerable)
        end
      end
    end
  end
end
