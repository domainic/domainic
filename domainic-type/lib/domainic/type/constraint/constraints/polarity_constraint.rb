# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # A constraint for validating numeric polarity (positive, negative, zero, nonzero).
      #
      # This constraint verifies a number's polarity by calling Ruby's standard
      # positive?, negative?, zero?, and nonzero? methods. It normalizes method names
      # to ensure compatibility with Ruby's predicate method naming conventions.
      #
      # @example Basic polarity checks
      #   constraint = PolarityConstraint.new(:self).expecting(:positive)
      #   constraint.satisfied?(42)   # => true
      #   constraint.satisfied?(-42)  # => false
      #   constraint.satisfied?(0)    # => false
      #
      # @example Zero checks
      #   constraint = PolarityConstraint.new(:self).expecting(:zero)
      #   constraint.satisfied?(0)    # => true
      #   constraint.satisfied?(42)   # => false
      #
      # @example Nonzero checks
      #   constraint = PolarityConstraint.new(:self).expecting(:nonzero)
      #   constraint.satisfied?(42)   # => true
      #   constraint.satisfied?(0)    # => false
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class PolarityConstraint
        # @rbs!
        #   type expected = :negative | :negative? | :nonzero | :nonzero? | :positive | :positive? | :zero | :zero?

        include Behavior #[expected, Numeric, {}]

        # Get a human-readable description of the polarity requirement.
        #
        # @example
        #   constraint = PolarityConstraint.new(:self).expecting(:positive)
        #   constraint.short_description  # => "positive"
        #
        # @return [String] Description of the polarity requirement
        # @rbs override
        def short_description
          @expected.to_s.delete_suffix('?')
        end

        # Get a human-readable description of why polarity validation failed.
        #
        # @example
        #   constraint = PolarityConstraint.new(:self).expecting(:positive)
        #   constraint.satisfied?(0)
        #   constraint.short_violation_description  # => "zero"
        #
        # @return [String] Description of the validation failure
        # @rbs override
        def short_violation_description # rubocop:disable Metrics/MethodLength
          case @expected
          when :positive?
            @actual.zero? ? 'zero' : 'negative'
          when :negative?
            @actual.zero? ? 'zero' : 'positive'
          when :zero?
            'nonzero'
          when :nonzero?
            'zero'
          else
            ''
          end
        end

        protected

        # Coerce the expectation into the correct method name format.
        #
        # Ensures the expectation ends with a question mark to match Ruby's
        # standard method naming for predicate methods.
        #
        # @example
        #   coerce_expectation(:positive)   # => :positive?
        #   coerce_expectation(:positive?)  # => :positive?
        #
        # @param expectation [Symbol, String] The polarity check to perform
        #
        # @return [Symbol] The coerced method name
        # @rbs override
        def coerce_expectation(expectation)
          expectation.to_s.end_with?('?') ? expectation.to_sym : :"#{expectation}?" #: expected
        end

        # Check if the value satisfies the polarity constraint.
        #
        # @return [Boolean] true if the value matches the polarity requirement
        # @rbs override
        def satisfies_constraint?
          interpret_result(@actual.public_send(@expected))
        end

        # Validate that the expectation is a valid polarity check.
        #
        # @param expectation [Object] The value to validate
        #
        # @raise [ArgumentError] if the expectation is not :negative, :negative?, :nonzero,
        #   :nonzero?, :positive, :positive?, :zero, or :zero?
        # @return [void]
        # @rbs override
        def validate_expectation!(expectation)
          return if %i[negative? nonzero? positive? zero?].include?(expectation)

          raise ArgumentError, "Invalid expectation: #{expectation}. Must be one of :negative, :negative?, :nonzero, " \
                               ':nonzero?, :positive, :positive?, :zero, or :zero?'
        end

        private

        # Interpret the result from Ruby's polarity methods.
        #
        # Handles the different return values from Ruby's polarity checking methods:
        # - positive?/negative?/zero? return true/false
        # - nonzero? returns nil for zero, and self for nonzero
        #
        # @example
        #   interpret_result(true)   # => true
        #   interpret_result(false)  # => false
        #   interpret_result(nil)    # => false
        #   interpret_result(42)     # => true
        #
        # @param result [Boolean, Integer, nil] The result from the polarity check
        #
        # @return [Boolean] true if the result indicates the desired polarity state
        # @rbs ((bool | Numeric)? result) -> bool
        def interpret_result(result)
          case result
          when true, false
            result
          when nil
            false
          else
            true
          end
        end
      end
    end
  end
end
