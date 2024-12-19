# frozen_string_literal: true

require 'domainic/type/accessors'

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
      #     def short_description
      #       "greater than #{@expected}"
      #     end
      #
      #     def short_violation_description
      #       @actual.to_s
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
        #   type options = { ?abort_on_failure: bool, ?coerce_with: Array[Proc] | Proc }

        # @rbs @accessor: Type::accessor
        # @rbs @actual: Actual
        # @rbs @expected: Expected
        # @rbs @options: options
        # @rbs @quantifier_description: (String | Symbol)?
        # @rbs @result: bool?

        attr_reader :quantifier_description #: (String | Symbol)?

        # Initialize a new constraint instance.
        #
        # @param accessor [Symbol] The accessor to use to retrieve the value being constrained
        # @param quantifier_description [String, Symbol, nil] The description of how the constraint applies
        #   to elements, such as "all", "any", or "none" for collection constraints, or a specific type name
        #   for type constraints. Used to form natural language descriptions like "having elements of String"
        #   or "containing any of [1, 2, 3]"
        #
        # @raise [ArgumentError] if the accessor is not included in {VALID_ACCESSORS}
        # @return [Behavior] A new instance of the constraint.
        # @rbs (Type::accessor accessor, ?(String | Symbol)? quantifier_description) -> void
        def initialize(accessor, quantifier_description = nil)
          validate_accessor!(accessor)

          @accessor = accessor.to_sym
          @options = {}
          @quantifier_description = quantifier_description
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

        # Set the expected value to compare against.
        #
        # @param expectation [Object] The expected value to compare against.
        #
        # @raise [ArgumentError] if the expectation is invalid according to {#validate_expectation!}
        # @return [self] The constraint instance.
        # @rbs (untyped expectation) -> self
        def expecting(expectation)
          expectation = coerce_expectation(expectation)
          validate_expectation!(expectation)

          # @type var expectation: Expected
          @expected = expectation
          self
        end

        # Whether the constraint is a failure.
        #
        # @return [Boolean] `true` if the constraint is a failure, `false` otherwise.
        # @rbs () -> bool
        def failure?
          @result == false
        end
        alias failed? failure?

        # The full description of the constraint.
        #
        # @return [String, nil] The full description of the constraint.
        # @rbs () -> String?
        def full_description
          full_description_for(short_description)
        end

        # The full description of the violations that caused the constraint to be unsatisfied.
        #
        # @return [String, nil] The full description of the constraint when it fails.
        # @rbs () -> String?
        def full_violation_description
          full_description_for(short_violation_description)
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
          @result = nil
          constrained = @accessor == :self ? value : value.public_send(@accessor)
          @actual = coerce_actual(coerce_actual_for_type(constrained))
          @result = satisfies_constraint? #: bool
        rescue StandardError
          @result = false #: bool
        end

        # The short description of the constraint.
        #
        # This is used to help compose a error message when the constraint is not satisfied.
        # Implementing classes should override this to provide meaningful descriptions of their
        # constraint behavior.
        #
        # @return [String] The description of the constraint.
        # @rbs () -> String
        def short_description
          @expected.to_s
        end

        # The short description of the violations that caused the constraint to be unsatisfied.
        #
        # This is used to help compose a error message when the constraint is not satisfied.
        # Implementing classes can override this to provide more specific failure messages.
        #
        # @return [String] The description of the constraint when it fails.
        # @rbs () -> String
        def short_violation_description
          @actual.to_s
        end

        # Whether the constraint is a success.
        #
        # @return [Boolean] `true` if the constraint is a success, `false` otherwise.
        # @rbs () -> bool
        def successful?
          @result == true
        end
        alias success? successful?

        # Merge additional options into the constraint.
        #
        # @param options [Hash{String, Symbol => Object}] Additional options
        # @option options [Boolean] :abort_on_failure (false) Whether to {#abort_on_failure?}
        # @option options [Array<Proc>, Proc] :coerce_with Coercers to run on the value before validating the
        #   constraint.
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
        # @rbs (untyped actual) -> Actual
        def coerce_actual(actual)
          actual
        end

        # Coerce actual values using type-provided coercion procs
        #
        # This method processes the actual value through any type-level coercion procs
        # that were provided via options. This runs after the constraint's own coercion
        # but before validation.
        #
        # @param actual [Object] The actual value to coerce
        #
        # @return [Object] The coerced value
        # @rbs (untyped actual) -> untyped
        def coerce_actual_for_type(actual)
          coercers = @options[:coerce_with]
          return actual if coercers.nil?

          Array(coercers).reduce(actual) do |accumulator, proc|
            # @type var proc: Proc
            proc.call(accumulator)
          end
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
        # @rbs (untyped expectation) -> Expected
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
        # @rbs (untyped expectation) -> void
        def validate_expectation!(expectation); end

        private

        # Generate the full description for the corresponding short description.
        #
        # @param description [String] The short description to expand.
        #
        # @return [String] The full description.
        # @rbs (String description) -> String?
        def full_description_for(description)
          return if quantifier_description.to_s.include?('not_described')

          if quantifier_description.is_a?(Symbol)
            "#{quantifier_description.to_s.split('_').join(' ')} #{description}"
          else
            "#{quantifier_description} #{description}"
          end.strip
        end

        # Validate the accessor.
        #
        # @param accessor [Symbol] The accessor to validate.
        #
        # @raise [ArgumentError] if the accessor is not included in {VALID_ACCESSORS}.
        # @return [void]
        # @rbs (Type::accessor accessor) -> void
        def validate_accessor!(accessor)
          return if Type::ACCESSORS.include?(accessor)

          raise ArgumentError, "Invalid accessor: #{accessor} must be one of #{Type::ACCESSORS.sort.join(', ')}"
        end
      end
    end
  end
end
