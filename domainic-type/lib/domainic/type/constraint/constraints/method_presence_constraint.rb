# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # A constraint that validates whether an object responds to a specified method
      #
      # This constraint checks if an object implements a particular interface by verifying
      # it responds to a given method name. The method name must be provided as a Symbol.
      #
      # @example
      #   constraint = MethodPresenceConstraint.new(:to_s)
      #   constraint.satisfied_by?(Object.new)  # => true
      #   constraint.satisfied_by?(BasicObject.new)  # => false
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class MethodPresenceConstraint
        include Behavior #[Symbol, untyped, {}]

        # Get a short description of what this constraint expects
        #
        # @deprecated this method will be removed in version 0.1.0
        #
        # @return [String] description of the expected method
        # @rbs override
        def short_description
          "responding to #{@expected}"
        end

        # Get a short description of why the constraint was violated
        #
        # @deprecated this method will be removed in version 0.1.0
        #
        # @return [String] description of the missing method
        # @rbs override
        def short_violation_description
          "not responding to #{@expected}"
        end

        protected

        # Coerce the expectation into a symbol
        #
        # @param expectation [Symbol] the method name to check
        #
        # @return [Symbol] coerced method name
        # @rbs override
        def coerce_expectation(expectation)
          expectation.to_sym
        end

        # Check if the actual value satisfies the constraint
        #
        # @return [Boolean] true if the object responds to the expected method
        # @rbs override
        def satisfies_constraint?
          @actual.respond_to?(@expected)
        end

        # Validate that the expectation is a Symbol
        #
        # @param expectation [Object] the expectation to validate
        #
        # @raise [ArgumentError] if the expectation is not a Symbol
        # @return [void]
        # @rbs override
        def validate_expectation!(expectation)
          raise ArgumentError, 'Expectation must be a Symbol' unless expectation.is_a?(Symbol)
        end
      end
    end
  end
end
