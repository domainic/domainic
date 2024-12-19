# frozen_string_literal: true

require 'domainic/attributer/attribute/mixin/belongs_to_attribute'
require 'domainic/attributer/errors/error'
require 'domainic/attributer/errors/validation_execution_error'
require 'domainic/attributer/undefined'

module Domainic
  module Attributer
    class Attribute
      # A class responsible for validating attribute values
      #
      # This class manages the validation of values assigned to an attribute. Validation
      # can be performed either by a {Proc} that accepts a single value argument and returns
      # a boolean, or by any object that responds to the `===` operator
      #
      # @api private
      # @!visibility private
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class Validator
        # @rbs!
        #   type handler = proc | Proc | _ValidHandler
        #
        #   type proc = ^(untyped value) -> bool
        #
        #   interface _ValidHandler
        #     def !=: (untyped value) -> bool
        #
        #     def ==: (untyped value) -> bool
        #
        #     def ===: (untyped value) -> bool
        #
        #     def inspect: () -> untyped
        #
        #     def is_a?: (Class | Module) -> bool
        #
        #     def respond_to?: (Symbol) -> bool
        #   end

        include BelongsToAttribute

        # @rbs @handlers: Array[handler]

        # Initialize a new Validator instance
        #
        # @param attribute [Attribute] the {Attribute} this instance belongs to
        # @param handlers [Array<Class, Module, Object, Proc>] the handlers to use for processing
        #
        # @return [Validator] the new Validator instance
        # @rbs (Attribute attribute, Array[handler] | handler handlers) -> void
        def initialize(attribute, handlers = [])
          super
          @handlers = [*handlers].map do |handler|
            validate_handler!(handler)
            handler
          end.uniq
        end

        # Validate a value using all configured validators
        #
        # @param instance [Object] the instance on which to perform validation
        # @param value [Object] the value to validate
        #
        # @raise [ArgumentError] if the value fails validation
        # @raise [ValidationExecutionError] if errors occur during validation execution
        # @return [void]
        # @rbs (untyped instance, untyped value) -> void
        def call(instance, value)
          return if value == Undefined && handle_undefined!
          return if value.nil? && handle_nil!

          run_validations!(instance, value)
        end

        private

        # Handle a nil value
        #
        # @raise [ArgumentError] if the attribute is not nilable
        # @return [Boolean] true if the attribute is nilable
        # @rbs () -> bool
        def handle_nil!
          return true if @attribute.signature.nilable?

          raise ArgumentError, "`#{attribute_method_name}`: cannot be nil"
        end

        # Handle an {Undefined} value
        #
        # @raise [ArgumentError] if the attribute is required
        # @return [Boolean] true if the attribute is optional
        # @rbs () -> bool
        def handle_undefined!
          return true if @attribute.signature.optional?

          raise ArgumentError, "`#{attribute_method_name}`: is required"
        end

        # Run all configured validations
        #
        # @param instance [Object] the instance on which to perform validation
        # @param value [Object] the value to validate
        #
        # @raise [ArgumentError] if the value fails validation
        # @raise [ValidationExecutionError] if errors occur during validation execution
        # @return [void]
        # @rbs (untyped instance, untyped value) -> void
        def run_validations!(instance, value)
          errors = []
          is_valid = true

          @handlers.each do |handler|
            is_valid = validate_value!(handler, instance, value)
          rescue StandardError => e
            errors << e
          end

          raise ValidationExecutionError, errors unless errors.empty?
          raise ArgumentError, "`#{attribute_method_name}`: has invalid value: #{value.inspect}" unless is_valid
        end

        # Validate that a validation handler is valid
        #
        # @param handler [Object] the handler to validate
        #
        # @raise [TypeError] if the handler is not valid
        # @return [void]
        # @rbs (handler handler) -> void
        def validate_handler!(handler)
          return if handler.is_a?(Proc) || (!handler.is_a?(Proc) && handler.respond_to?(:===))

          raise TypeError, "`#{attribute_method_name}`: invalid validator: #{handler.inspect}. Must be a Proc " \
                           'or an object responding to `#===`.'
        end

        # Validate a value using a single handler
        #
        # @param handler [Object] the handler to use for validation
        # @param instance [Object] the instance on which to perform validation
        # @param value [Object] the value to validate
        #
        # @return [Boolean] true if validation succeeds
        # @rbs (handler handler, untyped instance, untyped value) -> bool
        def validate_value!(handler, instance, value)
          if handler.is_a?(Proc)
            instance.instance_exec(value, &handler)
          elsif handler.respond_to?(:===)
            handler === value # rubocop:disable Style/CaseEquality
          else
            # We should never get here because we validate the handlers in the initializer
            raise TypeError, "`#{attribute_method_name}`: invalid validator: #{handler.inspect}"
          end
        end
      end
    end
  end
end
