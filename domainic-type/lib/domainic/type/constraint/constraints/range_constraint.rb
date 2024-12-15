# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # @since 0.1.0
      class RangeConstraint
        # @rbs!
        #   type expected: { ?minimum: Integer, ?maximum: Integer }

        include Behavior

        # @rbs @expected: expected

        # @rbs override
        def description
          min, max = @expected.values_at(:minimum, :maximum)

          if !min.nil? && !max.nil?
            "greater than or equal to #{min} and less than or equal to #{max}"
          elsif !min.nil?
            "greater than or equal to #{min}"
          elsif !max.nil?
            "less than or equal to #{max}"
          else
            ''
          end
        end

        # @rbs override
        def failure_description
          'was not'
        end

        private

        # @rbs override
        def satisfies_constraint?
          min, max = @expected.values_at(:minimum, :maximum)

          @actual >= (min || -Float::INFINITY) && @actual <= (max || Float::INFINITY)
        end

        # @rbs (expected expectation) -> void
        def validate_minimum_maximum_presence!(expectation)
          return if expectation.key?(:minimum) || expectation.key?(:maximum)

          raise ArgumentError, 'expectation must contain :minimum and/or :maximum'
        end

        # @rbs (expected expectation) -> void
        def validate_minimum_maximum_type!(expectation)
          min, max = expectation.values_at(:minimum, :maximum)
          return if min.is_a?(Numeric) && max.is_a?(Numeric)

          raise ArgumentError, 'minimum must be a Numeric' unless min.is_a?(Numeric) || min.nil?
          raise ArgumentError, 'maximum must be a Numeric' unless max.is_a?(Numeric) || max.nil?
        end

        # @rbs override
        def validate_expectation!(expectation)
          raise ArgumentError, 'expectation must be a Hash' unless expectation.is_a?(Hash)

          validate_minimum_maximum_presence!(expectation)
          validate_minimum_maximum_type!(expectation)
        end

        # @rbs override
        def validate_subject!(value)
          return if value.is_a?(Numeric)

          raise ArgumentError, 'value must be a Numeric'
        end
      end
    end
  end
end
