# frozen_string_literal: true

require 'domainic/attributer/attribute'
require 'domainic/attributer/attribute_definition'
require 'domainic/attributer/method_injector'
require 'domainic/attributer/undefined'

module Domainic
  module Attributer
    # Builder provides a fluent interface for defining Attributes.
    # It manages the lifecycle of attribute creation, from initial definition through
    # configuration to final instantiation and method injection.
    #
    # The Builder accumulates attribute definitions and configurations before
    # building them all at once or individually. Each attribute can be customized
    # with coercers, validators, callbacks, and default values.
    #
    # @since 0.1.0
    class Builder
      # @rbs @base: untyped
      # @rbs @current_definition: Hash[Symbol, untyped]?
      # @rbs @data: Hash[Symbol, untyped]
      # @rbs @method_injector: MethodInjector

      # Creates a new Builder for the given base object.
      #
      # @param base [Class, Object] The class or instance to build attributes for
      # @return [void]
      # @rbs (untyped base) -> void
      def initialize(base)
        @base = base
        @data = {}
        @method_injector = MethodInjector.new(@base)
      end

      # Builds all pending attribute definitions or just the current one.
      #
      # @return [self] the Builder instance
      # @rbs () -> self
      def build!
        @current_definition.nil? ? build_all_definitions : build_definition(current_definition)
        @current_definition = nil
        self
      end

      # Adds a coercer to transform attribute values.
      #
      # @param proc_symbol_or_true [Proc, Symbol, true, nil] The coercer to add
      # @yield An optional block to use as the coercer
      # @return [self] the Builder instance
      # @rbs (
      #   ^(untyped value) -> untyped | Symbol | true proc_symbol_or_true
      #   ) ?{ (?) -> void } -> self
      def coerce_with(proc_symbol_or_true = nil, &block)
        ensure_current_definition!
        current_definition[:attribute_options][:coercers] << (proc_symbol_or_true || block)
        self
      end
      alias coerce coerce_with

      # Sets a default value or generator for the attribute.
      #
      # @param value_or_proc [Object, Proc, nil] The default value or a proc to generate it
      # @yield An optional block to generate the default value
      # @return [self] the Builder instance
      # @rbs (
      #   ^() -> untyped | untyped value_or_proc,
      #   ) ?{ (?) -> void } -> self
      def default(value_or_proc = Undefined, &block)
        ensure_current_definition!
        current_definition[:attribute_options][:default] = value_or_proc == Undefined ? block : value_or_proc
        self
      end

      # Begins the definition of a new attribute.
      #
      # @param attribute_name [String, Symbol] The name of the attribute
      # @param type_validator [Class, Module, Proc, nil] Optional type constraint
      # @param options [Hash] Configuration options for the attribute
      # @yield [Builder] An optional block for additional configuration
      # @return [self] the Builder instance
      # @rbs (
      #   String | Symbol attribute_name,
      #   Class | Module | ^(untyped value) -> bool type_validator,
      #   **untyped options,
      #   ) ?{ (?) [self: Builder] -> void } -> self
      def define(attribute_name, type_validator = nil, **options, &block)
        build_current_definition(attribute_name, type_validator, **options)
        instance_exec(&block) if block
        self
      end

      # Sets the description for the current attribute.
      #
      # @param text [String] Documentation for the attribute
      # @return [self] the Builder instance
      # @rbs (String text) -> self
      def description(text)
        ensure_current_definition!
        current_definition[:attribute_options][:description] = text
        self
      end
      alias desc description

      # Creates a duplicate of this Builder with a new base object.
      #
      # @param new_base [Class, Object] The new base object
      # @return [Builder] A new Builder instance
      # @rbs (untyped new_base) -> instance
      def dup_with_base(new_base)
        dup.tap do |duped|
          duped.instance_variable_set(:@base, new_base)
          duped.instance_variable_set(:@method_injector, @method_injector.dup_with_base(new_base))
        end
      end

      # Adds a callback to be executed when the attribute's value changes.
      #
      # @param proc [Proc, nil] The callback to execute
      # @yield An optional block to use as the callback
      # @return [self] the Builder instance
      # @rbs (^(untyped value) -> void proc) ?{ (?) -> void } -> self
      def on_change(proc = nil, &block)
        ensure_current_definition!
        current_definition[:attribute_options][:callbacks] << (proc || block)
        self
      end

      # Makes the current attribute required (non-nil).
      #
      # @return [self] the Builder instance
      # @rbs () -> self
      def required
        ensure_current_definition!
        current_definition[:attribute_options][:required] = true
        self
      end

      # Adds a validator to the current attribute.
      #
      # @param case_equality_or_proc [#===, Proc, nil] The validator to add
      # @yield An optional block to use as the validator
      # @return [self] the Builder instance
      # @rbs (
      #   Class | Module | ^(untyped value) -> bool case_equality_or_proc,
      #   ) ?{ (?) -> void } -> self
      def validate_with(case_equality_or_proc = nil, &block)
        ensure_current_definition!
        current_definition[:attribute_options][:validators] << (case_equality_or_proc || block)
        self
      end
      alias validates validate_with

      private

      # Builds all pending attribute definitions.
      #
      # @return [void]
      # @rbs () -> void
      def build_all_definitions
        @data.each_value { |definition_options| build_definition(definition_options) }
      end

      # Sets up a new attribute definition.
      #
      # @param attribute_name [String, Symbol] The name of the attribute
      # @param type_validator [Class, Module, Proc] Optional type constraint
      # @param options [Hash] Configuration options for the attribute
      # @return [void]
      # @rbs (
      #   String | Symbol attribute_name,
      #   (Class | Module | ^(untyped value) -> bool) type_validator,
      #   **untyped options
      #   ) -> void
      def build_current_definition(attribute_name, type_validator, **options)
        @current_definition = @data[attribute_name.to_sym] ||= {}
        current_definition.merge!(reader: options.fetch(:reader, :public), writer: options.fetch(:writer, :public))
        build_current_definition_attribute_options(
          attribute_name,
          type_validator,
          **options.transform_keys(&:to_sym).except(:reader, :writer)
        )
      end

      # Sets up the options for the current attribute definition.
      #
      # @param attribute_name [String, Symbol] The name of the attribute
      # @param type_validator [Class, Module, Proc] Optional type constraint
      # @param options [Hash] Configuration options for the attribute
      # @return [void]
      # @rbs (
      #   String | Symbol attribute_name,
      #   Class | Module | ^(untyped value) -> bool type_validator,
      #   **untyped options
      #   ) -> void
      def build_current_definition_attribute_options(attribute_name, type_validator, **options)
        attribute_options = current_definition[:attribute_options] ||=
          Attribute::DEFAULT_OPTIONS.transform_values(&:dup)
        attribute_options[:name] ||= attribute_name.to_sym
        attribute_options.merge!(**options)
        attribute_options[:validators] << type_validator if type_validator
      end

      # Constructs and injects an attribute from its definition.
      #
      # @param definition_options [Hash] The complete attribute definition
      # @return [void]
      # @rbs (Hash[Symbol, untyped] definition_options) -> void
      def build_definition(definition_options)
        attribute = Attribute.new(@base, **definition_options[:attribute_options])
        definition = AttributeDefinition.new(attribute, **definition_options.except(:attribute_options))
        @method_injector.inject!(definition)
        @base.send(:__attribute_definitions__)[definition.attribute.name] = definition
      end

      # Retrieves the current attribute definition being built.
      #
      # @return [Hash] The current definition or an empty hash
      # @rbs () -> Hash[Symbol, untyped]
      def current_definition
        @current_definition || {}
      end

      # Ensures there is a current attribute definition to modify.
      #
      # @raise [RuntimeError] If no attribute is currently being defined
      # @return [void]
      def ensure_current_definition!
        raise 'No current definition to modify. Call #define first.' if @current_definition.nil?
      end
    end
  end
end
