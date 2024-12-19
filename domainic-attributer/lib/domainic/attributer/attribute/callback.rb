# frozen_string_literal: true

require 'domainic/attributer/attribute/mixin/belongs_to_attribute'
require 'domainic/attributer/errors/callback_execution_error'

module Domainic
  module Attributer
    class Attribute
      # A class responsible for managing change callbacks for an attribute
      #
      # This class handles the execution of callbacks that are triggered when an
      # attribute's value changes. Each callback must be a Proc that accepts two
      # arguments: the old value and the new value
      #
      # @api private
      # @!visibility private
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class Callback
        # @rbs!
        #   type handler = ^(untyped old_value, untyped new_value) -> void | Proc

        # @rbs @handlers: Array[handler]

        include BelongsToAttribute

        # Initialize a new Callback instance
        #
        # @param attribute [Attribute] the {Attribute} this instance belongs to
        # @param handlers [Array<Proc>] the handlers to use for processing
        #
        # @return [Callback] the new Callback instance
        # @rbs (Attribute attribute, Array[handler] | handler handlers) -> void
        def initialize(attribute, handlers = [])
          super
          @handlers = [*handlers].map do |handler|
            validate_handler!(handler)
            handler
          end.uniq
        end

        # Execute all callbacks for a value change
        #
        # @param instance [Object] the instance on which to execute callbacks
        # @param old_value [Object] the previous value
        # @param new_value [Object] the new value
        #
        # @raise [CallbackExecutionError] if any callback handlers raises an error
        # @return [void]
        # @rbs (untyped instance, untyped old_value, untyped new_value) -> void
        def call(instance, old_value, new_value)
          errors = []

          @handlers.each do |handler|
            instance.instance_exec(old_value, new_value, &handler)
          rescue StandardError => e
            errors << e
          end

          raise CallbackExecutionError, errors unless errors.empty?
        end

        private

        # Validate that a callback handler is a valid Proc
        #
        # @param handler [Object] the handler to validate
        #
        # @raise [TypeError] if the handler is not a valid Proc
        # @return [void]
        # @rbs (handler handler) -> void
        def validate_handler!(handler)
          return if handler.is_a?(Proc)

          raise TypeError, "`#{attribute_method_name}`: invalid handler: #{handler.inspect}. Must be a Proc"
        end
      end
    end
  end
end
