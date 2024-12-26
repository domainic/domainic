# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # A constraint for validating that numeric values fall within a specified range.
      #
      # This constraint allows for validating numeric values against minimum and maximum
      # boundaries. It supports specifying either or both boundaries, allowing for
      # open-ended ranges when appropriate.
      #
      # @example Validating with both minimum and maximum
      #   constraint = RangeConstraint.new(:self, { minimum: 1, maximum: 10 })
      #   constraint.satisfied?(5)  # => true
      #   constraint.satisfied?(15) # => false
      #
      # @example Validating with only minimum
      #   constraint = RangeConstraint.new(:self, { minimum: 0 })
      #   constraint.satisfied?(10)  # => true
      #   constraint.satisfied?(-1)  # => false
      #
      # @example Validating with only maximum
      #   constraint = RangeConstraint.new(:self, { maximum: 100 })
      #   constraint.satisfied?(50)   # => true
      #   constraint.satisfied?(150)  # => false
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class RangeConstraint
        # @rbs!
        #   type expected = { ?minimum: Numeric, ?maximum: Numeric }
        #
        #   type options = { ?inclusive: bool }

        include Behavior #[expected, Numeric, options]

        # Get a human-readable description of the range constraint.
        #
        # @example With both bounds
        #   constraint = RangeConstraint.new(:self, { minimum: 1, maximum: 10 })
        #   constraint.description
        #   # => "greater than or equal to 1 and less than or equal to 10"
        #
        # @example With only minimum
        #   constraint = RangeConstraint.new(:self, { minimum: 0 })
        #   constraint.description # => "greater than or equal to 0"
        #
        # @example With only maximum
        #   constraint = RangeConstraint.new(:self, { maximum: 100 })
        #   constraint.description # => "less than or equal to 100"
        #
        # @return [String] A description of the range bounds
        # @rbs override
        def short_description
          min, max = @expected.values_at(:minimum, :maximum)
          min_description = "greater than#{inclusive? ? ' or equal to' : ''} #{min}"
          max_description = "less than#{inclusive? ? ' or equal to' : ''} #{max}"

          return "#{min_description} and #{max_description}" unless min.nil? || max.nil?
          return min_description unless min.nil?

          max_description
        end

        # The description of the violations that caused the constraint to be unsatisfied.
        #
        # This is used to help compose a error message when the constraint is not satisfied.
        # Implementing classes can override this to provide more specific failure messages.
        #
        # @return [String] The description of the constraint when it fails.
        # @rbs override
        def short_violation_description
          @actual.inspect
        end

        protected

        # @rbs override
        def coerce_expectation(expectation)
          @expected.is_a?(Hash) && expectation.is_a?(Hash) ? @expected.merge(expectation) : expectation #: expected
        end

        # Check if the actual value falls within the specified range.
        #
        # Uses -Infinity and +Infinity as default bounds when minimum or maximum
        # are not specified, respectively.
        #
        # @return [Boolean] true if the value is within range
        # @rbs override
        def satisfies_constraint?
          min, max = @expected.values_at(:minimum, :maximum)
          min_comparison, max_comparison = inclusive? ? %i[>= <=] : %i[> <]

          @actual.send(min_comparison, (min || -Float::INFINITY)) &&
            @actual.send(max_comparison, (max || Float::INFINITY))
        end

        # Validate that the expected value is a properly formatted range specification.
        #
        # @param expectation [Hash] The range specification to validate
        #
        # @raise [ArgumentError] if the specification is invalid
        # @return [void]
        # @rbs override
        def validate_expectation!(expectation)
          unless expectation.is_a?(Hash) && (expectation.key?(:minimum) || expectation.key?(:maximum))
            raise ArgumentError, 'Expectation must be a Hash including :minimum and/or :maximum'
          end

          validate_minimum_and_maximum!(expectation)
        end

        # Validate the minimum and maximum values in a range specification.
        #
        # @param expectation [Hash] The range specification to validate
        #
        # @raise [ArgumentError] if the values are invalid
        # @return [void]
        # @rbs (untyped expectation) -> void
        def validate_minimum_and_maximum!(expectation)
          expectation.each_pair do |property, value|
            raise ArgumentError, ":#{property} must be a Numeric" unless value.nil? || value.is_a?(Numeric)
          end

          min, max = expectation.values_at(:minimum, :maximum)
          return if min.nil? || max.nil? || min <= max

          raise ArgumentError, ':minimum must be less than or equal to :maximum'
        end

        private

        # Check if the range constraint is inclusive.
        #
        # @return [Boolean] `true` if the range is inclusive, `false` otherwise
        # @rbs () -> bool
        def inclusive?
          @options.fetch(:inclusive, true) #: bool
        end
      end
    end
  end
end
