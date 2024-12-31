# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # A constraint for validating values using a custom predicate function.
      #
      # This constraint allows for custom validation logic through a Proc that returns
      # a boolean value. It enables users to create arbitrary validation rules when
      # the built-in constraints don't cover their specific needs.
      #
      # @example Basic usage
      #   constraint = PredicateConstraint.new(:self, ->(x) { x > 0 })
      #   constraint.satisfied?(1)   # => true
      #   constraint.satisfied?(-1)  # => false
      #
      # @example With custom violation description
      #   constraint = PredicateConstraint.new(:self, ->(x) { x > 0 }, violation_description: 'not greater than zero')
      #   constraint.satisfied?(-1)  # => false
      #   constraint.short_violation_description  # => "not greater than zero"
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class PredicateConstraint
        # @rbs!
        #   type expected = ^(untyped value) -> bool
        #
        #   type options = { ?violation_description: String}

        include Behavior #[expected, untyped, options]

        # Get a description of what the constraint expects.
        #
        # @deprecated this method will be removed in version 0.1.0
        #
        # @note This constraint type does not provide a description as predicates are arbitrary.
        #
        # @return [String] an empty string
        # @rbs override
        def short_description = ''

        # Get a description of why the predicate validation failed.
        #
        # @deprecated this method will be removed in version 0.1.0
        #
        # @return [String] the custom violation description if provided
        # @rbs override
        def short_violation_description
          # @type ivar @options: { ?violation_description: String }
          @options.fetch(:violation_description, '')
        end

        protected

        # Check if the value satisfies the predicate function.
        #
        # @return [Boolean] true if the predicate returns true
        # @rbs override
        def satisfies_constraint?
          @expected.call(@actual)
        end

        # Validate that the expectation is a Proc.
        #
        # @param expectation [Object] the expectation to validate
        #
        # @raise [ArgumentError] if the expectation is not a Proc
        # @return [void]
        # @rbs override
        def validate_expectation!(expectation)
          return if expectation.is_a?(Proc)

          raise ArgumentError, 'Expectation must be a Proc'
        end
      end
    end
  end
end
