# frozen_string_literal: true

module Domainic
  module Type
    module Constraint
      # A module providing core functionality for implementing type constraints.
      #
      # The Behavior module serves as the foundation for all type constraints in the Domainic::Type system.
      # It provides a flexible interface for defining how values should be constrained, supporting both
      # simple type checking and complex validation rules.
      #
      # Key features include:
      # - Flexible value access through configurable accessors
      # - Support for custom validation logic
      # - Coercion hooks for both actual and expected values
      # - Detailed failure reporting
      # - Type-aware error messages
      #
      # @abstract Implementing classes must override {#satisfies_constraint?} to define their specific
      #   constraint logic.
      #
      # @example Implementing a basic numeric constraint
      #   class GreaterThanConstraint
      #     include Domainic::Type::Constraint::Behavior
      #
      #     def description
      #       "greater than #{@expected}"
      #     end
      #
      #     def failure_description
      #       "not greater than #{@expected}"
      #     end
      #
      #     protected
      #
      #     def satisfies_constraint?
      #       @actual > @expected
      #     end
      #
      #     def validate_expectation!(expectation)
      #       raise ArgumentError, 'Expected value must be numeric' unless expectation.is_a?(Numeric)
      #     end
      #   end
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      # @rbs generic Expected < Object -- The type of @expected
      # @rbs generic Actual < Object -- The type of @actual
      # @rbs generic Options < Hash[Symbol, untyped] -- The type of @options
      module Behavior
        # @rbs!
        #   type accessor_symbol = :begin | :count | :end | :first | :keys | :last | :length | :self | :size | :value
        #
        #   type options = { ?abort_on_failure: bool, ?is_type_failure: bool }

        # A list of valid accessor methods that can be used to retrieve values for constraint validation.
        # These methods represent common Ruby interfaces for accessing collection sizes, ranges, and values.
        #
        # - :begin, :end - For Range-like objects
        # - :count, :length, :size - For measuring collections
        # - :first, :last - For accessing sequence endpoints
        # - :keys, :values - For Hash-like objects
        # - :self - For operating directly on the value
        #
        # @return [Array<Symbol>] The valid accessors that can be used to retrieve the value being constrained.
        VALID_ACCESSORS = %i[begin count end first keys last length self size values].freeze #: Array[accessor_symbol]

        # @rbs @accessor: accessor_symbol
        # @rbs @actual: Actual
        # @rbs @expected: Expected
        # @rbs @options: options

        # Initialize a new constraint instance.
        #
        # @param accessor [Symbol] The accessor to use to retrieve the value being constrained
        # @param expectation [Object] The expected value to compare against
        # @param options [Hash{String, Symbol => Object}] Additional options
        # @option options [Boolean] :abort_on_failure (false) Whether to {#abort_on_failure?}
        # @option options [Boolean] :is_type_failure (false) Whether to consider as {#type_failure?}
        #
        # @raise [ArgumentError] if the accessor is not included in {VALID_ACCESSORS}
        # @return [Behavior] A new instance of the constraint.
        # @rbs (
        #   accessor_symbol accessor,
        #   ?Expected expectation,
        #   ?(options & Options) options
        #   ) -> void
        def initialize(accessor, expectation = nil, options = {})
          validate_accessor!(accessor)
          validate_expectation!(expectation) unless expectation.nil?

          @accessor = accessor.to_sym
          @expected = expectation
          @options = options.transform_keys(&:to_sym)
        end

        # Whether to abort further validation on an unsatisfied constraint.
        #
        # When this is true it tells the type to stop validating the value against the remaining constraints.
        # This is particularly useful for fundamental type constraints where subsequent validations would
        # be meaningless if the basic type check fails.
        #
        # @return [Boolean] Whether to abort on failure.
        # @rbs () -> bool
        def abort_on_failure?
          @options.fetch(:abort_on_failure, false)
        end

        # The description of the constraint.
        #
        # This is used to help compose a failure message when the constraint is not satisfied.
        # Implementing classes should override this to provide meaningful descriptions of their
        # constraint behavior.
        #
        # @return [String] The description of the constraint.
        # @rbs () -> String
        def description
          ''
        end

        # Set the expected value to compare against.
        #
        # @param expectation [Object] The expected value to compare against.
        #
        # @raise [ArgumentError] if the expectation is invalid according to {#validate_expectation!}
        # @return [self] The constraint instance.
        # @rbs (Expected expectation) -> self
        def expecting(expectation)
          expectation = coerce_expectation(expectation)
          validate_expectation!(expectation)

          @expected = expectation
          self
        end

        # The description of the constraint when it fails.
        #
        # This is used to help compose a failure message when the constraint is not satisfied.
        # Implementing classes can override this to provide more specific failure messages.
        #
        # @return [String] The description of the constraint when it fails.
        # @rbs () -> String
        def failure_description
          ''
        end

        # Whether the constraint is satisfied.
        #
        # This method orchestrates the constraint validation process by:
        # 1. Accessing the value using the configured accessor
        # 2. Coercing the actual value if needed
        # 3. Checking if the constraint is satisfied
        # 4. Handling any errors that occur during validation
        #
        # @param value [Object] The value to validate against the constraint.
        #
        # @return [Boolean] Whether the constraint is satisfied.
        # @rbs (Actual value) -> bool
        def satisfied?(value)
          @actual = coerce_actual(@accessor == :self ? value : value.public_send(@accessor))
          satisfies_constraint?
        rescue StandardError
          false
        end

        # Whether the constraint is considered a type failure.
        #
        # This flag indicates if the constraint represents a fundamental type check.
        # When true, failure messages will not include additional type information since
        # the constraint itself is already expressing type requirements.
        #
        # @return [Boolean] Whether the constraint is a type failure.
        # @rbs () -> bool
        def type_failure?
          @options.fetch(:is_type_failure, false)
        end

        # Merge additional options into the constraint.
        #
        # @param options [Hash{String, Symbol => Object}] Additional options
        # @option options [Boolean] :abort_on_failure (false) Whether to {#abort_on_failure?}
        # @option options [Boolean] :is_type_failure (false) Whether to consider as {#type_failure?}
        #
        # @return [self] The constraint instance.
        # @rbs (?(options & Options) options) -> self
        def with_options(options = {})
          @options.merge!(options.transform_keys(&:to_sym))
          self
        end

        protected

        # Coerce the value being validated into the expected type.
        #
        # This hook allows implementing classes to transform the actual value before validation.
        # This is particularly useful when the constraint needs to handle multiple input formats
        # or needs to normalize values before comparison.
        #
        # @example Coerce input into an array
        #   def coerce_actual(actual)
        #     Array(actual)
        #   end
        #
        # @param actual [Object] The actual value to coerce.
        #
        # @return [Object] The coerced value.
        # @rbs (Actual actual) -> Actual
        def coerce_actual(actual)
          actual
        end

        # Coerce the expected value into the expected type.
        #
        # This hook allows implementing classes to transform or normalize the expected value
        # when it's set. This is useful for handling different formats of expected values
        # or combining multiple expectations.
        #
        # @example Coerce a range specification
        #   def coerce_expectation(expectation)
        #     case expectation
        #     when Range then { minimum: expectation.begin, maximum: expectation.end }
        #     when Hash then @expected.merge(expectation)
        #     else expectation
        #     end
        #   end
        #
        # @param expectation [Object] The expected value to coerce.
        #
        # @return [Object] The coerced value.
        # @rbs (Expected expectation) -> Expected
        def coerce_expectation(expectation)
          expectation
        end

        # The primary implementation of the constraint.
        #
        # This is the core method that all constraints must implement to define their specific
        # validation logic. It is called by {#satisfied?} after the value has been accessed
        # and coerced.
        #
        # The implementing class has access to two instance variables:
        # - @actual: The actual value being validated (after coercion)
        # - @expected: The expected value to validate against (after coercion)
        #
        # @example Implementing a greater than constraint
        #   def satisfies_constraint?
        #     @actual > @expected
        #   end
        #
        # @raise [NotImplementedError] if the including class doesn't implement this method
        # @return [Boolean] Whether the constraint is satisfied.
        # @rbs () -> bool
        def satisfies_constraint?
          raise NotImplementedError
        end

        # Validate the expected value.
        #
        # This hook allows implementing classes to validate the expected value when it's set.
        # Override this method when the constraint requires specific types or formats for
        # the expected value.
        #
        # @example Validate numeric expectation
        #   def validate_expectation!(expectation)
        #     return if expectation.is_a?(Numeric)
        #
        #     raise ArgumentError, "Expected value must be numeric, got #{expectation.class}"
        #   end
        #
        # @param expectation [Object] The expected value to validate.
        #
        # @return [void]
        # @rbs (Expected expectation) -> void
        def validate_expectation!(expectation); end

        private

        # Validate the accessor.
        #
        # @param accessor [Symbol] The accessor to validate.
        #
        # @raise [ArgumentError] if the accessor is not included in {VALID_ACCESSORS}.
        # @return [void]
        # @rbs (accessor_symbol accessor) -> void
        def validate_accessor!(accessor)
          return if VALID_ACCESSORS.include?(accessor)

          raise ArgumentError, "Invalid accessor: #{accessor} must be one of #{VALID_ACCESSORS.join(', ')}"
        end
      end
    end
  end
end
