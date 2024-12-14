# frozen_string_literal: true

require 'domainic/attributer/attribute/callback'
require 'domainic/attributer/attribute/coercer'
require 'domainic/attributer/attribute/signature'
require 'domainic/attributer/attribute/validator'
require 'domainic/attributer/undefined'

module Domainic
  module Attributer
    # A class representing a managed attribute in the Domainic::Attributer system.
    #
    # This class serves as the core component of the attribute management system.
    # It coordinates type information, visibility settings, value coercion,
    # validation, and change notifications for an attribute. Each instance
    # represents a single attribute definition within a class.
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class Attribute
      # @rbs!
      #   type initialize_options = {
      #     ?callbacks: Array[Callback::handler] | Callback::handler,
      #     ?coercers: Array[Coercer::handler] | Coercer::handler,
      #     ?default: untyped,
      #     ?description: String?,
      #     name: String | Symbol,
      #     ?nilable: bool,
      #     ?position: Integer?,
      #     ?read: Signature::visibility_symbol,
      #     ?required: bool,
      #     type: Signature::type_symbol,
      #     ?validators: Array[Validator::handler] | Validator::handler,
      #     ?write: Signature::visibility_symbol
      #   }

      # @rbs @base: __todo__
      # @rbs @callback: Callback
      # @rbs @coercer: Coercer
      # @rbs @default: untyped
      # @rbs @description: String?
      # @rbs @name: Symbol
      # @rbs @signature: Signature
      # @rbs @validator: Validator

      # @return [Class, Module] the class or module this attribute belongs to
      attr_reader :base #: __todo__

      # @return [String, nil] the description of the attribute
      attr_reader :description #: String?

      # @return [Symbol] the name of the attribute
      attr_reader :name #: Symbol

      # @return [Signature] the signature configuration for this attribute
      attr_reader :signature #: Signature

      # Initialize a new Attribute instance.
      #
      # @param base [Class, Module] the class or module this attribute belongs to
      # @param options [Hash] the options to create the attribute with
      # @option options [Array<Proc>, Proc] :callbacks callbacks to trigger on value changes
      # @option options [Array<Proc, Symbol>, Proc, Symbol] :coercers handlers for value coercion
      # @option options [Object] :default the default value or generator
      # @option options [String] :description a description of the attribute
      # @option options [String, Symbol] :name the name of the attribute
      # @option options [Boolean] :nilable (true) whether the attribute can be nil
      # @option options [Integer] :position the position for ordered attributes
      # @option options [Symbol] :read the read visibility
      # @option options [Boolean] :required (false) whether the attribute is required
      # @option options [Symbol] :type the type of attribute
      # @option options [Array<Proc, Object>, Proc, Object] :validators handlers for value validation
      # @option options [Symbol] :write the write visibility
      #
      # @raise [ArgumentError] if the configuration is invalid
      # @return [void]
      #
      # @rbs (
      #   __todo__ base,
      #   ?callbacks: Array[Callback::handler] | Callback::handler,
      #   ?coercers: Array[Coercer::handler] | Coercer::handler,
      #   ?default: untyped,
      #   ?description: String?,
      #   name: String | Symbol,
      #   ?nilable: bool,
      #   ?position: Integer?,
      #   ?read: Signature::visibility_symbol,
      #   ?required: bool,
      #   type: Signature::type_symbol,
      #   ?validators: Array[Validator::handler] | Validator::handler,
      #   ?write: Signature::visibility_symbol
      #   ) -> void
      def initialize(base, **options)
        options = options.transform_keys(&:to_sym)
        # @type var options: initialize_options
        validate_and_apply_initialize_options!(base, options)
      rescue StandardError => e
        raise ArgumentError, e.message
      end

      # Apply a value to the attribute on an instance.
      #
      # This method applies all attribute constraints (coercion, validation) to a value
      # and sets it on the given instance. It manages the complete lifecycle of setting
      # an attribute value including:
      # 1. Handling default values
      # 2. Coercing the value
      # 3. Validating the result
      # 4. Setting the value
      # 5. Triggering callbacks
      #
      # @param instance [Object] the instance to set the value on
      # @param value [Object] the value to set
      #
      # @raise [ArgumentError] if the value is invalid
      # @return [void]
      # @rbs (untyped instance, untyped value) -> void
      def apply!(instance, value = Undefined)
        old_value = instance.instance_variable_get(:"@#{name}")

        coerced_value = value == Undefined ? generate_default(instance) : value
        coerced_value = @coercer.call(instance, coerced_value)

        @validator.call(instance, coerced_value)

        instance.instance_variable_set(:"@#{name}", coerced_value == Undefined ? nil : coerced_value)

        @callback.call(instance, old_value, coerced_value)
      end

      # Check if this attribute has a default value.
      #
      # @return [Boolean] true if a default value is set
      # @rbs () -> bool
      def default?
        @default != Undefined
      end

      # Create a duplicate instance for a new base class.
      #
      # @param new_base [Class, Module] the new base class
      #
      # @return [Attribute] the duplicated instance
      # @rbs (__todo__ new_base) -> Attribute
      def dup_with_base(new_base)
        raise ArgumentError, "invalid base: #{new_base}" unless new_base.is_a?(Class) || new_base.is_a?(Module)

        dup.tap { |duped| duped.instance_variable_set(:@base, new_base) }
      end

      # Generate the default value for this attribute.
      #
      # @param instance [Object] the instance to generate the default for
      #
      # @return [Object] the generated default value
      # @rbs (untyped instance) -> untyped
      def generate_default(instance)
        @default.is_a?(Proc) ? instance.instance_exec(&@default) : @default
      end

      # Merge this attribute's configuration with another.
      #
      # @param other [Attribute] the attribute to merge with
      #
      # @raise [ArgumentError] if other is not an Attribute
      # @return [Attribute] a new attribute with merged configuration
      # @rbs (Attribute other) -> Attribute
      def merge(other)
        raise ArgumentError, 'other must be an instance of Attribute' unless other.is_a?(self.class)

        self.class.new(other.base, **to_options, **other.send(:to_options)) # steep:ignore InsufficientKeywordArguments
      end

      private

      # Apply initialization options to create attribute components.
      #
      # @param base [Class, Module] the base class
      # @param options [Hash] the initialization options
      #
      # @return [void]
      # @rbs (__todo__ base, initialize_options options) -> void
      def apply_initialize_options!(base, options)
        @base = base
        @callback = Callback.new(self, options.fetch(:callbacks, []))
        @coercer = Coercer.new(self, options.fetch(:coercers, []))
        @default = options.fetch(:default, Undefined)
        @description = options.fetch(:description, nil)
        @name = options.fetch(:name).to_sym
        @signature = Signature.new(
          self, type: options.fetch(:type), **options.slice(:nilable, :position, :read, :required, :write)
        )
        @validator = Validator.new(self, options.fetch(:validators, []))
      end

      # Initialize a copy of this attribute.
      #
      # @param source [Attribute] the source attribute
      #
      # @return [Attribute] the initialized copy
      # @rbs override
      def initialize_copy(source)
        @base = source.base
        @callback = source.instance_variable_get(:@callback).dup_with_attribute(self)
        @coercer = source.instance_variable_get(:@coercer).dup_with_attribute(self)
        @default = source.instance_variable_get(:@default)
        @description = source.description
        @name = source.name
        @signature = source.signature.dup_with_attribute(self)
        @validator = source.instance_variable_get(:@validator).dup_with_attribute(self)
        super
      end

      # Get this attribute's configuration as options.
      #
      # @return [Hash] the configuration options
      # @rbs () -> initialize_options
      def to_options
        {
          callbacks: @callback.instance_variable_get(:@handlers),
          coercers: @coercer.instance_variable_get(:@handlers),
          default: @default,
          description: @description,
          name: @name,
          validators: @validator.instance_variable_get(:@handlers)
        }.merge(signature.send(:to_options)) #: initialize_options
      end

      # Validate and apply initialization options.
      #
      # @param base [Class, Module] the base class
      # @param options [Hash] the initialization options
      #
      # @return [void]
      # @rbs (__todo__ base, initialize_options options) -> void
      def validate_and_apply_initialize_options!(base, options)
        validate_initialize_options!(base, options)
        apply_initialize_options!(base, options)
      end

      # Validate initialization options.
      #
      # @param base [Class, Module] the base class
      # @param options [Hash] the initialization options
      #
      # @raise [ArgumentError] if any options are invalid
      # @return [void]
      # @rbs (__todo__ base, initialize_options options) -> void
      def validate_initialize_options!(base, options)
        raise ArgumentError, "invalid base: #{base}" unless base.is_a?(Class) || base.is_a?(Module)
        raise ArgumentError, 'missing keyword :name' unless options.key?(:name)
        raise ArgumentError, 'missing keyword :type' unless options.key?(:type)
      end
    end
  end
end
