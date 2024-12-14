# frozen_string_literal: true

require 'domainic/attributer/attribute/mixin/belongs_to_attribute'
require 'domainic/attributer/undefined'

module Domainic
  module Attributer
    class Attribute
      # A class responsible for coercing attribute values.
      #
      # This class manages the coercion of values assigned to an attribute. Coercion can be
      # handled by either a Proc that accepts a single value argument, or by referencing an
      # instance method via Symbol.
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class Coercer
        # @rbs!
        #   type handler = proc | Proc | Symbol
        #
        #   type proc = ^(untyped value) -> untyped

        include BelongsToAttribute

        # @rbs @handlers: Array[handler]

        # Initialize a new Coercer instance.
        #
        # @param attribute [Attribute] the attribute this Coercer belongs to
        # @param handlers [Array<Proc, Symbol>] the handlers to use for processing
        #
        # @return [Coercer] the new instance of Coercer
        # @rbs (Attribute attribute, Array[handler] | handler handlers) -> void
        def initialize(attribute, handlers = [])
          super
          @handlers = [*handlers].map do |handler|
            validate_handler!(handler)
            handler
          end.uniq
        end

        # Process a value through all coercion handlers.
        #
        # @param instance [Object] the instance on which to perform coercion
        # @param value [Object] the value to coerce
        #
        # @return [Object, nil] the coerced value
        # @rbs (untyped instance, untyped? value) -> untyped?
        def call(instance, value)
          return value if value == Undefined
          return value if value.nil? && !@attribute.signature.nilable?

          @handlers.reduce(value) { |accumulator, handler| coerce_value(instance, handler, accumulator) }
        end

        private

        # Process a value through a single coercion handler.
        #
        # @param instance [Object] the instance on which to perform coercion
        # @param handler [Proc, Symbol] the coercion handler
        # @param value [Object] the value to coerce
        #
        # @raise [TypeError] if the handler is invalid
        # @return [Object] the coerced value
        # @rbs (untyped instance, handler, untyped value) -> untyped
        def coerce_value(instance, handler, value)
          case handler
          when Proc
            instance.instance_exec(value, &handler)
          when Symbol
            instance.send(handler, value)
          else
            # We should never get here because we validate the handlers in the initializer.
            raise TypeError, "`#{attribute_method_name}`: invalid coercer: #{handler}. "
          end
        end

        # Validate that a coercion handler is valid.
        #
        # @param handler [Object] the handler to validate
        #
        # @raise [TypeError] if the handler is not valid
        # @return [void]
        # @rbs (handler handler) -> void
        def validate_handler!(handler)
          return if handler.is_a?(Proc)
          return if handler.is_a?(Symbol) &&
                    (@attribute.base.method_defined?(handler) || @attribute.base.private_method_defined?(handler))

          raise TypeError, "`#{attribute_method_name}`: invalid coercer: #{handler.inspect}. Must be a Proc " \
                           'or a Symbol referencing a method.'
        end
      end
    end
  end
end
