# frozen_string_literal: true

require 'domainic/command/context/input_context'
require 'domainic/command/context/output_context'
require 'domainic/command/context/runtime_context'

module Domainic
  module Command
    # Class methods that are extended onto any class that includes {Command}. These methods provide
    # the DSL for defining command inputs and outputs, as well as class-level execution methods.
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    module ClassMethods
      # @rbs @input_context_class: singleton(Context::InputContext)
      # @rbs @output_context_class: singleton(Context::OutputContext)
      # @rbs @runtime_context_class: singleton(Context::RuntimeContext)

      # Specifies an external input context class for the command
      #
      # @param input_context_class [Class] A subclass of {Context::InputContext}
      #
      # @raise [ArgumentError] If the provided class is not a subclass of {Context::InputContext}
      # @return [void]
      # @rbs (singleton(Context::InputContext) input_context_class) -> void
      def accepts_arguments_matching(input_context_class)
        unless input_context_class < Context::InputContext
          raise ArgumentError, 'Input context class must be a subclass of Context::InputContext'
        end

        # @type self: Class & ClassMethods
        @input_context_class = begin
          const_set(:InputContext, Class.new(input_context_class))
          const_get(:InputContext)
        end
      end

      # Defines an input argument for the command
      #
      # @overload argument(name, *type_validator_and_description, **options)
      #   @param name [String, Symbol] The name of the argument
      #   @param type_validator_and_description [Array<Class, Module, Object, Proc, String, nil>] Type validator or
      #     description arguments
      #   @param options [Hash] Configuration options for the argument
      #   @option options [Object] :default A static default value
      #   @option options [Proc] :default_generator A proc that generates the default value
      #   @option options [Object] :default_value Alias for :default
      #   @option options [String, nil] :desc Short description of the argument
      #   @option options [String, nil] :description Full description of the argument
      #   @option options [Boolean] :required Whether the argument is required
      #   @option options [Class, Module, Object, Proc] :type A type validator
      #
      # @return [void]
      # @rbs (
      #   String | Symbol name,
      #   *(Class | Module | Object | Proc | String)? type_validator_and_description,
      #   ?default: untyped,
      #   ?default_generator: untyped,
      #   ?default_value: untyped,
      #   ?desc: String?,
      #   ?description: String?,
      #   ?required: bool,
      #   ?type: Class | Module | Object | Proc
      #   ) -> void
      def argument(...)
        input_context_class.argument(...)
      end

      # Executes the command with the given context, handling any errors
      #
      # @param context [Hash] The input context for the command
      #
      # @return [Result] The result of the command execution
      # @rbs (**untyped context) -> Result
      def call(**context)
        # @type self: Class & ClassMethods & InstanceMethods
        new.call(**context)
      end

      # Executes the command with the given context, raising any errors
      #
      # @param context [Hash] The input context for the command
      #
      # @raise [ExecutionError] If the command execution fails
      # @return [Result] The result of the command execution
      # @rbs (**untyped context) -> Result
      def call!(**context)
        # @type self: Class & ClassMethods & InstanceMethods
        new.call!(**context)
      end

      # Defines an output field for the command
      #
      # @overload output(name, *type_validator_and_description, **options)
      #   @param name [String, Symbol] The name of the output field
      #   @param type_validator_and_description [Array<Class, Module, Object, Proc, String, nil>] Type validator or
      #     description arguments
      #   @param options [Hash] Configuration options for the output
      #   @option options [Object] :default A static default value
      #   @option options [Proc] :default_generator A proc that generates the default value
      #   @option options [Object] :default_value Alias for :default
      #   @option options [String, nil] :desc Short description of the output
      #   @option options [String, nil] :description Full description of the output
      #   @option options [Boolean] :required Whether the output is required
      #   @option options [Class, Module, Object, Proc] :type A type validator
      #
      # @return [void]
      # @rbs (
      #   String | Symbol name,
      #   *(Class | Module | Object | Proc | String)? type_validator_and_description,
      #   ?default: untyped,
      #   ?default_generator: untyped,
      #   ?default_value: untyped,
      #   ?desc: String?,
      #   ?description: String?,
      #   ?required: bool,
      #   ?type: Class | Module | Object | Proc
      #   ) -> void
      def output(...)
        output_context_class.field(...)
      end

      # Specifies an external output context class for the command
      #
      # @param output_context_class [Class] A subclass of {Context::OutputContext}
      #
      # @raise [ArgumentError] If the provided class is not a subclass of {Context::OutputContext}
      # @return [void]
      # @rbs (singleton(Context::OutputContext) output_context_class) -> void
      def returns_data_matching(output_context_class)
        unless output_context_class < Context::OutputContext
          raise ArgumentError, 'Output context class must be a subclass of Context::OutputContext'
        end

        # @type self: Class & ClassMethods
        @output_context_class = begin
          const_set(:OutputContext, Class.new(output_context_class))
          const_get(:OutputContext)
        end
      end

      private

      # Returns the input context class for the command
      #
      # @return [Class] A subclass of {Context::InputContext}
      # @rbs () -> singleton(Context::InputContext)
      def input_context_class
        # @type self: Class & ClassMethods
        @input_context_class ||= begin
          const_set(:InputContext, Class.new(Context::InputContext)) unless const_defined?(:InputContext)
          const_get(:InputContext)
        end
      end

      # Returns the output context class for the command
      #
      # @return [Class] A subclass of {Context::OutputContext}
      # @rbs () -> singleton(Context::OutputContext)
      def output_context_class
        # @type self: Class & ClassMethods
        @output_context_class ||= begin
          const_set(:OutputContext, Class.new(Context::OutputContext)) unless const_defined?(:OutputContext)
          const_get(:OutputContext)
        end
      end

      # Returns the runtime context class for the command
      #
      # @return [Class] A subclass of {Context::RuntimeContext}
      # @rbs () -> singleton(Context::RuntimeContext)
      def runtime_context_class
        # @type self: Class & ClassMethods
        @runtime_context_class ||= begin
          const_set(:RuntimeContext, Class.new(Context::RuntimeContext)) unless const_defined?(:RuntimeContext)
          const_get(:RuntimeContext)
        end
      end
    end
  end
end
