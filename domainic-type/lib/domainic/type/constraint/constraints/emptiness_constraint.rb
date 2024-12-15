# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # @since 0.1.0
      class EmptinessConstraint
        include Behavior

        # @rbs @expected: nil

        # @rbs override
        def description
          'being empty'
        end

        # @rbs override
        def failure_description
          'empty'
        end

        private

        # @rbs override
        def satisfies_constraint?
          @actual.empty?
        end

        # @rbs override
        def validate_subject!(value)
          raise ArgumentError, 'value does not respond to #empty?' unless value.respond_to?(:empty?)
        end
      end
    end
  end
end
