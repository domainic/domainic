# frozen_string_literal: true

require 'domainic/attributer/attribute_set'
require 'domainic/attributer/dsl/attribute_builder'
require 'domainic/attributer/dsl/method_injector'
require 'domainic/attributer/undefined'

module Domainic
  module Attributer
    # A module providing class-level methods for attribute definition
    #
    # This module extends classes that include {Domainic::Attributer} with methods for
    # defining and managing attributes. It supports two types of attributes:
    # 1. Arguments - Positional parameters that must be provided in a specific order
    # 2. Options - Named parameters that can be provided in any order
    #
    # @example Defining arguments and options
    #   class Person
    #     include Domainic::Attributer
    #
    #     argument :name, String
    #     argument :age do |value|
    #       value.is_a?(Integer) && value >= 0
    #     end
    #
    #     option :email, String, default: nil
    #     option :role do |value|
    #       %w[admin user guest].include?(value)
    #     end
    #   end
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    module ClassMethods
      # @rbs @__attributes__: AttributeSet

      # Define a positional argument attribute
      #
      # Arguments are required by default and must be provided in the order they are defined.
      # They can be type-validated and configured with additional options like defaults
      # and visibility
      #
      # @see OptionParser#initialize for details about available options
      #
      # @example
      #   class Person
      #     argument :name, String
      #     argument :age, ->(val) { val.is_a?(Integer) && val >= 0 }
      #     argument :role, default: 'user'
      #   end
      #
      # @param attribute_name [String, Symbol] the name of the attribute
      # @param type_validator [Proc, Object, nil] optional validation handler for type checking
      # @param options [Hash{Symbol => Object}] additional configuration options
      #
      # @yield [DSL::AttributeBuilder] configuration block for additional attribute settings
      # @return [void]
      # @rbs (
      #   String | Symbol attribute_name,
      #   ?Attribute::Validator::handler type_validator,
      #   ?callbacks: Array[Attribute::Callback::handler] | Attribute::Callback::handler,
      #   ?callback: Array[Attribute::Callback::handler] | Attribute::Callback::handler,
      #   ?coerce: Array[Attribute::Coercer::handler] | Attribute::Coercer::handler,
      #   ?coercers: Array[Attribute::Coercer::handler],
      #   ?coerce_with: [Attribute::Coercer::handler] | Attribute::Coercer::handler,
      #   ?default: untyped,
      #   ?default_generator: untyped,
      #   ?default_value: untyped,
      #   ?desc: String?,
      #   ?description: String,
      #   ?non_nil: bool,
      #   ?non_null: bool,
      #   ?non_nullable: bool,
      #   ?not_nil: bool,
      #   ?not_nilable: bool,
      #   ?not_null: bool,
      #   ?not_nullable: bool,
      #   ?null: bool,
      #   ?on_change: Array[Attribute::Callback::handler] | Attribute::Callback::handler,
      #   ?optional: bool,
      #   ?position: Integer?,
      #   ?read: Attribute::Signature::visibility_symbol,
      #   ?read_access: Attribute::Signature::visibility_symbol,
      #   ?reader: Attribute::Signature::visibility_symbol,
      #   ?required: bool,
      #   ?validate: Array[Attribute::Validator::handler] | Attribute::Validator::handler,
      #   ?validate_with: Array[Attribute::Validator::handler] | Attribute::Validator::handler,
      #   ?validators: Array[Attribute::Validator::handler] | Attribute::Validator::handler,
      #   ?write_access: Attribute::Signature::visibility_symbol,
      #   ?writer: Attribute::Signature::visibility_symbol,
      #   ) ?{ (?) [self: DSL::AttributeBuilder] -> void } -> void
      def argument(attribute_name, type_validator = Undefined, **options, &)
        position = __attributes__.count { |_, attribute| attribute.signature.argument? }

        attribute = DSL::AttributeBuilder.new(
          self, attribute_name, :argument, type_validator, **options.merge(position:), &
        ).build!

        __attributes__.add(attribute)
        DSL::MethodInjector.inject!(self, attribute)
      end

      # Define a named option attribute
      #
      # Options are optional by default and can be provided in any order. They can be
      # type-validated and configured with additional options like defaults and visibility
      #
      # @see OptionParser#initialize for details about available options
      #
      # @example
      #   class Person
      #     option :email, String
      #     option :age, ->(val) { val.is_a?(Integer) && val >= 0 }
      #     option :role, default: 'user'
      #   end
      #
      # @overload option(attribute_name, type_validator = nil, **options, &block)
      #   @param attribute_name [String, Symbol] the name of the attribute
      #   @param type_validator [Proc, Object, nil] optional validation handler for type checking
      #   @param options [Hash{Symbol => Object}] additional configuration options
      #
      # @yield [DSL::AttributeBuilder] configuration block for additional attribute settings
      # @return [void]
      # @rbs (
      #   String | Symbol attribute_name,
      #   ?Attribute::Validator::handler type_validator,
      #   ?callbacks: Array[Attribute::Callback::handler] | Attribute::Callback::handler,
      #   ?callback: Array[Attribute::Callback::handler] | Attribute::Callback::handler,
      #   ?coerce: Array[Attribute::Coercer::handler] | Attribute::Coercer::handler,
      #   ?coercers: Array[Attribute::Coercer::handler],
      #   ?coerce_with: [Attribute::Coercer::handler] | Attribute::Coercer::handler,
      #   ?default: untyped,
      #   ?default_generator: untyped,
      #   ?default_value: untyped,
      #   ?desc: String?,
      #   ?description: String,
      #   ?non_nil: bool,
      #   ?non_null: bool,
      #   ?non_nullable: bool,
      #   ?not_nil: bool,
      #   ?not_nilable: bool,
      #   ?not_null: bool,
      #   ?not_nullable: bool,
      #   ?null: bool,
      #   ?on_change: Array[Attribute::Callback::handler] | Attribute::Callback::handler,
      #   ?optional: bool,
      #   ?position: Integer?,
      #   ?read: Attribute::Signature::visibility_symbol,
      #   ?read_access: Attribute::Signature::visibility_symbol,
      #   ?reader: Attribute::Signature::visibility_symbol,
      #   ?required: bool,
      #   ?validate: Array[Attribute::Validator::handler] | Attribute::Validator::handler,
      #   ?validate_with: Array[Attribute::Validator::handler] | Attribute::Validator::handler,
      #   ?validators: Array[Attribute::Validator::handler] | Attribute::Validator::handler,
      #   ?write_access: Attribute::Signature::visibility_symbol,
      #   ?writer: Attribute::Signature::visibility_symbol,
      #   ) ?{ (?) [self: DSL::AttributeBuilder] -> void } -> void
      def option(attribute_name, ...)
        attribute = DSL::AttributeBuilder.new(self, attribute_name, :option, ...).build! # steep:ignore

        __attributes__.add(attribute)
        DSL::MethodInjector.inject!(self, attribute)
      end

      private

      # Get the attribute set for this class
      #
      # @return [AttributeSet] the set of attributes defined for this class
      # @rbs () -> AttributeSet
      def __attributes__
        @__attributes__ ||= AttributeSet.new(self)
      end

      # Handle class inheritance for attributes
      #
      # Ensures that subclasses inherit a copy of their parent's attributes while
      # maintaining proper ownership relationships
      #
      # @param subclass [Class] the inheriting class
      # @return [void]
      # @rbs (Class | Module subclass) -> void
      def inherited(subclass)
        super
        subclass.instance_variable_set(:@__attributes__, __attributes__.dup_with_base(subclass))
      end
    end
  end
end
