# frozen_string_literal: true

require 'domainic/command/context/behavior'

module Domainic
  module Command
    module Context
      # A context class for managing command input arguments. This class provides a structured way to define,
      # validate, and access input parameters for commands.
      #
      # @example
      #   class MyInputContext < Domainic::Command::Context::InputContext
      #     argument :name, String, "The name to process"
      #     argument :count, Integer, default: 1
      #   end
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class InputContext
        # @rbs! extend Behavior::ClassMethods

        include Behavior

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
        def self.argument(...) = attribute(...)
      end
    end
  end
end
