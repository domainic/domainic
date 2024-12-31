# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # A constraint for validating numeric parity (even or odd).
      #
      # This constraint verifies a number's parity by calling Ruby's standard
      # even? and odd? methods. It normalizes method names
      # to ensure compatibility with Ruby's predicate method naming conventions.
      #
      # @example Basic polarity checks
      #   constraint = ParityConstraint.new(:self).expecting(:even)
      #   constraint.satisfied?(2)   # => true
      #   constraint.satisfied?(-2)  # => true
      #   constraint.satisfied?(1)    # => false
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class ParityConstraint
        # @rbs!
        #   type expected = :even | :even? | :odd | :odd?

        include Behavior #[expected, Numeric, {}]

        # Get a human-readable description of the parity requirement.
        #
        # @deprecated this method will be removed in version 0.1.0
        #
        # @example
        #   constraint = ParityConstraint.new(:self).expecting(:even)
        #   constraint.short_description  # => "even"
        #
        # @return [String] Description of the parity requirement
        # @rbs override
        def short_description
          @expected.to_s.delete_suffix('?')
        end

        # Get a human-readable description of why parity validation failed.
        #
        # @deprecated this method will be removed in version 0.1.0
        #
        # @example
        #   constraint = ParityConstraint.new(:self).expecting(:positive)
        #   constraint.satisfied?(0)
        #   constraint.short_violation_description  # => "odd"
        #
        # @return [String] Description of the validation failure
        # @rbs override
        def short_violation_description
          case @expected
          when :even?
            'odd'
          when :odd?
            'even'
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
        #   coerce_expectation(:even)   # => :even?
        #   coerce_expectation(:even?)  # => :eve?
        #
        # @param expectation [Symbol, String] The parity check to perform
        #
        # @return [Symbol] The coerced method name
        # @rbs override
        def coerce_expectation(expectation)
          expectation.to_s.end_with?('?') ? expectation.to_sym : :"#{expectation}?" #: expected
        end

        # Check if the value satisfies the parity constraint.
        #
        # @return [Boolean] true if the value matches the parity requirement
        # @rbs override
        def satisfies_constraint?
          @actual.public_send(@expected)
        end

        # Validate that the expectation is a valid parity check.
        #
        # @param expectation [Object] The value to validate
        #
        # @raise [ArgumentError] if the expectation is not :even, :even?, :odd, or :odd?
        # @return [void]
        # @rbs override
        def validate_expectation!(expectation)
          return if %i[even? odd?].include?(expectation)

          raise ArgumentError, "Invalid expectation: #{expectation}. Must be one of :even, :even?, :odd, or :odd?"
        end
      end
    end
  end
end
