# frozen_string_literal: true

require 'domainic/command/context/behavior'

module Domainic
  module Command
    module Context
      # A context class for managing command output values. This class provides a structured way to define,
      # validate, and access the return values from commands.
      #
      # @example
      #   class MyOutputContext < Domainic::Command::Context::OutputContext
      #     field :processed_name, String, "The processed name"
      #     field :status, Symbol, default: :success
      #   end
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class OutputContext
        # @rbs! extend Behavior::ClassMethods

        include Behavior

        # Defines a return value for the command
        #
        # @overload field(name, *type_validator_and_description, **options)
        #   @param name [String, Symbol] The name of the return value
        #   @param type_validator_and_description [Array<Class, Module, Object, Proc, String, nil>] Type validator or
        #     description arguments
        #   @param options [Hash] Configuration options for the return value
        #   @option options [Object] :default A static default value
        #   @option options [Proc] :default_generator A proc that generates the default value
        #   @option options [Object] :default_value Alias for :default
        #   @option options [String, nil] :desc Short description of the return value
        #   @option options [String, nil] :description Full description of the return value
        #   @option options [Boolean] :required Whether the return value is required
        #   @option options [Class, Module, Object, Proc] :type A type validator
        #
        #   @return [void]
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
        def self.field(...) = attribute(...)
      end
    end
  end
end
