# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # @since 0.1.0
      class UniquenessConstraint
        include Behavior

        # @rbs @expected: nil

        # @rbs override
        def description
          'unique elements'
        end

        # @rbs override
        def failure_description
          'non-unique elements'
        end

        private

        # @rbs override
        def satisfies_constraint?
          @actual.uniq == @actual
        end

        # @rbs override
        def validate_subject!(value)
          return if value.is_a?(Enumerable)

          raise ArgumentError, "#{value} must be an Enumerable"
        end
      end
    end
  end
end
