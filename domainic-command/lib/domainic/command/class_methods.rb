# frozen_string_literal: true

require 'domainic/command/context/input_context'
require 'domainic/command/context/output_context'
require 'domainic/command/context/runtime_context'

module Domainic
  module Command
    # @since 0.1.0
    module ClassMethods
      # @rbs @input_context_class: Context::InputContext
      # @rbs @output_context_class: Context::OutputContext
      # @rbs @runtime_context_class: Context::RunTimeContext

      # @rbs (Context::InputContext input_context_class) -> void
      def accepts_arguments_matching(input_context_class)
        @input_context_class = input_context_class
      end

      # @rbs (
      #   String | Symbol name,
      #   ?(String | Context::Attribute::type_validator)? type_validator_or_description,
      #   ?(String | Context::Attribute::type_validator)? description_or_type_validator,
      #   ?default: untyped?,
      #   ?default_generator: untyped?,
      #   ?default_value: untyped?,
      #   ?desc: String?,
      #   ?description: String?,
      #   ?required: bool?,
      #   ?type: type_validator?
      #   ) -> void
      def argument(...)
        unless input_context_class.name == "#{name}::InputContext"
          # TODO: raise something other than a runtime error here...
          raise 'Cannot define arguments on external context class'
        end

        input_context_class.argument(...)
      end

      def call(**context)
        # @type self: Class & Command
        new.call(**context)
      end

      # @rbs (**untyped context) -> untyped
      def call!(**context)
        # @type self: Class & Command
        new.call!(**context)
      end

      # @rbs (
      #   String | Symbol name,
      #   ?(String | Context::Attribute::type_validator)? type_validator_or_description,
      #   ?(String | Context::Attribute::type_validator)? description_or_type_validator,
      #   ?default: untyped?,
      #   ?default_generator: untyped?,
      #   ?default_value: untyped?,
      #   ?desc: String?,
      #   ?description: String?,
      #   ?required: bool?,
      #   ?type: type_validator?
      #   ) -> void
      def returns(...)
        unless output_context_class.name == "#{name}::OutputContext"
          # TODO: raise something other than a runtime error here...
          raise 'Cannot define returns on external context class'
        end

        output_context_class.returns(...)
      end

      # @rbs (Context::OutputContext output_context_class) -> void
      def returns_data_matching(output_context_class)
        @output_context_class = output_context_class
      end

      private

      # @rbs () -> Context::InputContext
      def input_context_class
        # @type self: Class & Command
        @input_context_class ||= begin
          const_set(:InputContext, Class.new(Context::InputContext)) unless const_defined?(:InputContext)
          const_get(:InputContext)
        end
      end

      # @rbs () -> Context::OutputContext
      def output_context_class
        # @type self: Class & Command
        @output_context_class ||= begin
          const_set(:OutputContext, Class.new(Context::OutputContext)) unless const_defined?(:OutputContext)
          const_get(:OutputContext)
        end
      end

      # @rbs () -> Context::RunTimeContext
      def runtime_context_class
        # @type self: Class & Command
        @runtime_context_class ||= begin
          const_set(:RuntimeContext, Class.new(Context::RuntimeContext)) unless const_defined?(:RuntimeContext)
          const_get(:RuntimeContext)
        end
      end
    end
  end
end
