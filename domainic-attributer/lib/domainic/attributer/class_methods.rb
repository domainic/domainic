# frozen_string_literal: true

require 'domainic/attributer/attribute_set'
require 'domainic/attributer/dsl/attribute_builder'
require 'domainic/attributer/dsl/method_injector'
require 'domainic/attributer/undefined'

module Domainic
  module Attributer
    # This module extends classes that include {Domainic::Attributer} with methods for defining and managing attributes.
    # It supports two types of attributes:
    # 1. Arguments - Positional parameters that must be provided in a specific order
    # 2. Options - Named parameters that can be provided in any order
    #
    # @note This module is automatically extended when {Domainic::Attributer} is included in a class
    #
    # @example Defining arguments and options
    #   class Person
    #     include Domainic::Attributer
    #
    #     argument :name, String
    #     argument :age, Integer do
    #       validate_with ->(val) { val >= 0 }
    #     end
    #
    #     option :email, String, default: nil
    #     option :role do
    #       validate_with ->(val) { %w[admin user guest].include?(val) }
    #     end
    #   end
    #
    #   person = Person.new('Alice', 30, email: 'alice123@gmail.com', role: 'user')
    #   # => #<Person:0x0000000104bc5f98 @age=30, @email="alice123@gmail.com", @name="Alice", @role="user">
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    module ClassMethods
      # @rbs @__attributes__: AttributeSet

      # Define a positional argument attribute
      #
      # Arguments are required by default and must be provided in the order they are defined unless they have a default
      # value. They can be type-validated and configured with additional options like defaults and visibility
      #
      # @see DSL::AttributeBuilder
      #
      # @example Using the options API
      #   class Person
      #     argument :name, String
      #     argument :age, ->(val) { val.is_a?(Integer) && val >= 0 }
      #     argument :role, default: 'user'
      #   end
      #
      # @example Using the block API
      #   class Person
      #     argument :name, String do
      #       validate_with ->(val) { val.length >= 3 }
      #     end
      #
      #     argument :age, Integer do
      #       coerce_with ->(val) { val.to_i }
      #       validate_with ->(val) { val >= 0 }
      #     end
      #
      #     argument :role, String do
      #       validate_with ->(val) { VALID_USER_ROLES.include?(val) }
      #       default 'user'
      #     end
      #   end
      #
      # @overload argument(attribute_name, type_validator = nil, **options)
      #   @param attribute_name [String, Symbol] the name of the attribute
      #   @param type_validator [Proc, Object, nil] optional validation handler for type checking
      #   @param options [Hash{Symbol => Object}] additional configuration options
      #   @option options [Array<Proc>, Proc] :callbacks handlers for attribute change events (priority over
      #     :callback, :on_change)
      #   @option options [Array<Proc>, Proc] :callback alias for :callbacks
      #   @option options [Array<Proc, Symbol>, Proc, Symbol] :coerce handlers for value coercion (priority over
      #     :coercers, :coerce_with)
      #   @option options [Array<Proc, Symbol>, Proc, Symbol] :coercers alias for :coerce
      #   @option options [Array<Proc, Symbol>, Proc, Symbol] :coerce_with alias for :coerce
      #   @option options [Object] :default the default value (priority over :default_generator, :default_value)
      #   @option options [Object] :default_generator alias for :default
      #   @option options [Object] :default_value alias for :default
      #   @option options [String] :desc short description (overridden by :description)
      #   @option options [String] :description description text
      #   @option options [Boolean] :non_nil require non-nil values (priority over :non_null, :non_nullable, :not_nil,
      #     :not_nilable, :not_null, :not_nullable)
      #   @option options [Boolean] :non_null alias for :non_nil
      #   @option options [Boolean] :non_nullable alias for :non_nil
      #   @option options [Boolean] :not_nil alias for :non_nil
      #   @option options [Boolean] :not_nilable alias for :non_nil
      #   @option options [Boolean] :not_null alias for :non_nil
      #   @option options [Boolean] :not_nullable alias for :non_nil
      #   @option options [Boolean] :null inverse of :non_nil
      #   @option options [Array<Proc>, Proc] :on_change alias for :callbacks
      #   @option options [Boolean] :optional whether attribute is optional (overridden by :required)
      #   @option options [Integer] :position specify order position
      #   @option options [Symbol] :read read visibility (:public, :protected, :private) (priority over :read_access,
      #     :reader)
      #   @option options [Symbol] :read_access alias for :read
      #   @option options [Symbol] :reader alias for :read
      #   @option options [Boolean] :required whether attribute is required
      #   @option options [Array<Object>, Object] :validate validators for the attribute (priority over
      #     :validate_with, :validators)
      #   @option options [Array<Object>, Object] :validate_with alias for :validate
      #   @option options [Array<Object>, Object] :validators alias for :validate
      #   @option options [Symbol] :write_access write visibility (:public, :protected, :private) (priority over
      #     :writer)
      #   @option options [Symbol] :writer alias for :write_access
      #
      #   @yield [DSL::AttributeBuilder] configuration block for additional attribute settings
      #   @return [void]
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
      # @see DSL::AttributeBuilder
      # @see DSL::AttributeBuilder::OptionParser#initialize
      #
      # @example Using the options API
      #   class Person
      #     option :email, String
      #     option :age, ->(val) { val.is_a?(Integer) && val >= 0 }
      #     option :role, default: 'user'
      #   end
      #
      # @example Using the block API
      #   class Person
      #     option :email, String do
      #       coerce_with ->(val) { val.downcase }
      #       validate_with ->(val) { URI::MailTo::EMAIL_REGEXP.match?(val) }
      #     end
      #
      #     option :age, Integer do
      #       coerce_with ->(val) { val.to_i }
      #       validate_with ->(val) { val >= 0 }
      #     end
      #
      #     option :role, String do
      #       validate_with ->(val) { VALID_USER_ROLES.include?(val) }
      #       default 'user'
      #     end
      #   end
      #
      # @overload option(attribute_name, type_validator = nil, **options)
      #   @param attribute_name [String, Symbol] the name of the attribute
      #   @param type_validator [Proc, Object, nil] optional validation handler for type checking
      #   @param options [Hash{Symbol => Object}] additional configuration options
      #   @option options [Array<Proc>, Proc] :callbacks handlers for attribute change events (priority over
      #     :callback, :on_change)
      #   @option options [Array<Proc>, Proc] :callback alias for :callbacks
      #   @option options [Array<Proc, Symbol>, Proc, Symbol] :coerce handlers for value coercion (priority over
      #     :coercers, :coerce_with)
      #   @option options [Array<Proc, Symbol>, Proc, Symbol] :coercers alias for :coerce
      #   @option options [Array<Proc, Symbol>, Proc, Symbol] :coerce_with alias for :coerce
      #   @option options [Object] :default the default value (priority over :default_generator, :default_value)
      #   @option options [Object] :default_generator alias for :default
      #   @option options [Object] :default_value alias for :default
      #   @option options [String] :desc short description (overridden by :description)
      #   @option options [String] :description description text
      #   @option options [Boolean] :non_nil require non-nil values (priority over :non_null, :non_nullable, :not_nil,
      #     :not_nilable, :not_null, :not_nullable)
      #   @option options [Boolean] :non_null alias for :non_nil
      #   @option options [Boolean] :non_nullable alias for :non_nil
      #   @option options [Boolean] :not_nil alias for :non_nil
      #   @option options [Boolean] :not_nilable alias for :non_nil
      #   @option options [Boolean] :not_null alias for :non_nil
      #   @option options [Boolean] :not_nullable alias for :non_nil
      #   @option options [Boolean] :null inverse of :non_nil
      #   @option options [Array<Proc>, Proc] :on_change alias for :callbacks
      #   @option options [Boolean] :optional whether attribute is optional (overridden by :required)
      #   @option options [Integer] :position specify order position
      #   @option options [Symbol] :read read visibility (:public, :protected, :private) (priority over :read_access,
      #     :reader)
      #   @option options [Symbol] :read_access alias for :read
      #   @option options [Symbol] :reader alias for :read
      #   @option options [Boolean] :required whether attribute is required
      #   @option options [Array<Object>, Object] :validate validators for the attribute (priority over
      #     :validate_with, :validators)
      #   @option options [Array<Object>, Object] :validate_with alias for :validate
      #   @option options [Array<Object>, Object] :validators alias for :validate
      #   @option options [Symbol] :write_access write visibility (:public, :protected, :private) (priority over
      #     :writer)
      #   @option options [Symbol] :writer alias for :write_access
      #
      #   @yield [DSL::AttributeBuilder] configuration block for additional attribute settings
      #   @return [void]
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
