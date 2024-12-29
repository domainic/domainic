# frozen_string_literal: true

require 'domainic/command/errors/execution_error'
require 'domainic/command/result'

module Domainic
  module Command
    # Instance methods that are included in any class that includes {Command}. These methods provide
    # the core execution logic and error handling for commands.
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    module InstanceMethods
      # Executes the command with the given context, handling any errors
      #
      # @param context [Hash] The input context for the command
      #
      # @return [Result] The result of the command execution
      # @rbs (**untyped context) -> Result
      def call(**context)
        call!(**context)
      rescue ExecutionError => e
        e.result
      end

      # Executes the command with the given context, raising any errors
      #
      # @param input [Hash] The input context for the command
      #
      # @raise [ExecutionError] If the command execution fails
      # @return [Result] The result of the command execution
      # @rbs (**untyped context) -> Result
      def call!(**input)
        __execute_command!(input)
      rescue StandardError => e
        raise e if e.is_a?(ExecutionError)

        raise ExecutionError.new("#{self.class} failed", Result.failure(e, context.to_h))
      end

      # Executes the command's business logic
      #
      # @abstract Subclass and override {#execute} to implement command behavior
      #
      # @raise [NotImplementedError] If the subclass does not implement {#execute}
      # @return [void]
      # @rbs () -> void
      def execute
        raise NotImplementedError, "#{self.class} does not implement #execute"
      end

      private

      # The runtime context for the command execution
      #
      # @return [Context::RuntimeContext] The runtime context
      attr_reader :context #: Context::RuntimeContext

      # Execute the command with the given input context
      #
      # @param input [Hash] The input context for the command
      #
      # @return [Result] The result of the command execution
      # @rbs (Hash[String | Symbol, untyped] input) -> Result
      def __execute_command!(input)
        input_context = __validate_context!(:input, input)
        @context = self.class.send(:runtime_context_class).new(**input_context.to_h)
        execute
        output_context = __validate_context!(:output, context.to_h)
        Result.success(output_context.to_h)
      end

      # Validates an input or output context
      #
      # @param context_type [Symbol] The type of context to validate
      # @param context [Hash] The context data to validate
      #
      # @raise [ExecutionError] If the context is invalid
      # @return [Context::InputContext, Context::OutputContext] The validated context
      # @rbs (
      #   :input | :output context_type,
      #   Hash[String | Symbol, untyped] context
      #   ) -> (Context::InputContext | Context::OutputContext)
      def __validate_context!(context_type, context)
        self.class.send(:"#{context_type}_context_class").new(**context)
      rescue StandardError => e
        result = context_type == :input ? Result.failure_at_input(e) : Result.failure_at_output(e)
        raise ExecutionError.new("#{self.class} has invalid #{context_type}", result)
      end
    end
  end
end
