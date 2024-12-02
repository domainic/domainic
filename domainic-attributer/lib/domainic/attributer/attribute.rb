# frozen_string_literal: true

require 'domainic/attributer/undefined'

module Domainic
  module Attributer
    # An Attribute represents a single attribute within a class that includes the Attributer module.
    # Each Attribute manages its own value storage, type coercion, validation, and change callbacks.
    #
    # Each Attribute has:
    # - A name that identifies it
    # - An optional description for documentation
    # - A value that can be undefined, nil, or set
    # - Optional coercion rules for transforming input values
    # - Optional validation rules for ensuring value correctness
    # - Optional callbacks that execute when the value changes
    # - Optional default value or default value generator
    #
    # @since 0.1.0
    class Attribute
      # Default configuration options for all Attributes. These options can be
      # overridden during Attribute definition.
      #
      # @api private
      # @return [Hash{Symbol => Object}]
      DEFAULT_OPTIONS = {
        callbacks: [], # Array of procs to call when value changes
        coercers: [], # Array of coercion rules
        default: Undefined, # Default value or proc
        required: false,  # Whether the Attribute must have a non-nil value
        validators: []    # Array of validation rules
      }.freeze #: Hash[Symbol, untyped]

      # @rbs @base: untyped
      # @rbs @description: String?
      # @rbs @name: Symbol
      # @rbs @options: Hash[Symbol, untyped]
      # @rbs @value: untyped

      # Optional documentation describing the purpose of this Attribute.
      #
      # @return [String, nil] the Attribute's description if set
      attr_reader :description #: String?

      # The name of this Attribute, used for generating accessor methods.
      #
      # @return [Symbol] the Attribute's name
      attr_reader :name #: Symbol

      # Initializes a new Attribute.
      #
      # @param base [Class, Object] The class or instance this Attribute belongs to
      # @param options [Hash] Configuration options for the Attribute
      #
      # @option options [Array<Proc, Symbol>] :callbacks Callbacks to execute on change
      # @option options [Array<Proc, Symbol, true>] :coercers A list of coercers that transform the input value.
      #   Coercers are applied in order and can be:
      #   - A `Proc` that receives the value and returns the coerced result
      #   - A `Symbol` referencing a method on the base object that accepts a value and returns the coerced result
      #   - `true` to use a method named coerce_{#name} on the base object
      # @option options [Object, Proc] :default Default value or generator
      # @option options [String] :description Optional documentation
      # @option options [Symbol] :name Required Attribute name
      # @option options [Boolean] :required Whether a non-nil value is required
      # @option options [Array<Object>] :validators Validation rules
      #
      # @raise [ArgumentError] If name is missing or options are invalid
      # @return [Attribute] the new instance of Attribute
      # @rbs (untyped base, **untyped options) -> void
      def initialize(base, **options)
        raise ArgumentError, '`initialize`: missing keyword: :name' unless options.key?(:name)

        @base = base

        options = DEFAULT_OPTIONS.transform_values(&:dup).merge(options.transform_keys(&:to_sym))
        @description = options.fetch(:description, nil)
        @name = options.fetch(:name).to_sym

        validate_options!(options)
        @options = options.except(:description, :name)

        @value = Undefined
      end

      # Returns the default value for this Attribute.
      #
      # @note If the default is a Proc, it is evaluated in the context of @base.
      #
      # @return [Object, nil] The default value, or nil if no default is set
      # @rbs () -> untyped?
      def default
        return unless default?

        default = @options[:default]
        default.is_a?(Proc) ? @base.instance_exec(&default) : default
      end

      # Checks if this Attribute has a default value set.
      #
      # @return [Boolean] true if a default value is configured
      # @rbs () -> bool
      def default?
        @options[:default] != Undefined
      end

      # Creates a duplicate of this Attribute with a new base object.
      #
      # @param new_base [Class, Object] The new base class or instance
      # @return [Attribute] A duplicated Attribute instance
      # @rbs (untyped new_base) -> instance
      def dup_with_base(new_base)
        dup.tap { |duped| duped.instance_variable_set(:@base, new_base) }
      end

      # Checks if this Attribute is optional (not required).
      #
      # @return [Boolean] true if the Attribute is optional
      # @rbs () -> bool
      def optional?
        !required?
      end

      # Checks if this Attribute requires a non-nil value.
      #
      # @return [Boolean] true if the Attribute requires a non-nil value
      # @rbs () -> bool
      def required?
        @options[:required] == true
      end

      # Checks if this Attribute's value is undefined.
      #
      # @return [Boolean] true if the Attribute's value has never been set
      # @rbs () -> bool
      def undefined?
        @value == Undefined
      end

      # Returns the current value of this Attribute.
      #
      # @return [Object] The current value or the default value if undefined
      # @rbs () -> untyped?
      def value
        return @value unless undefined?

        default
      end

      # Sets the value of this Attribute, applying coercions and validations.
      #
      # @param new_value [Object] The value to set
      # @raise [ArgumentError] If the value fails validation
      # @return [void]
      # @rbs (untyped new_value) -> void
      def value=(new_value)
        coerced_value = new_value.nil? && required? ? default : new_value
        coerced_value = apply_coercers(coerced_value)
        validate_value!(coerced_value)

        @value = coerced_value
        @options[:callbacks].each { |callback| @base.instance_exec(value, &callback) }
      end

      private

      # Applies all coercers to a value in sequence.
      #
      # @param value [Object] The value to coerce
      # @return [Object] The coerced value
      # @rbs (untyped value) -> untyped
      def apply_coercers(value)
        @options[:coercers].reduce(value) { |accumulator, coercer| coerce_value(coercer, accumulator) }
      end

      # Returns all methods available on the base object.
      #
      # @return [Array<Symbol>] List of available method names
      # @rbs () -> Array[Symbol]
      def base_methods
        base = @base.is_a?(Class) ? @base : @base.class
        base.instance_methods + base.private_instance_methods
      end

      # Applies a single coercer to a value.
      #
      # @param coercer [Proc, Symbol, true] The coercer to apply
      # @param value [Object] The value to coerce
      # @return [Object] The coerced value
      # @rbs (^(untyped value) -> untyped | Symbol | true coercer, untyped value) -> untyped
      def coerce_value(coercer, value)
        case coercer
        when Proc
          @base.instance_exec(value, &coercer)
        when Symbol
          @base.send(coercer, value)
        when true
          @base.send(:"coerce_#{@name}", value)
        else
          value
        end
      end

      # Returns a qualified name for error messages.
      #
      # @return [String] The qualified name
      # @rbs () -> String
      def qualified_name
        base_name = @base.is_a?(Class) ? @base.name : @base.class.name
        "#{base_name}##{@name}"
      end

      # Validates the callback options during initialization.
      #
      # @param options [Hash] The options to validate
      # @raise [ArgumentError] If any callbacks are invalid
      # @return [void]
      # @rbs (Hash[Symbol, untyped] options) -> void
      def validate_callback_options!(options)
        return if options[:callbacks].empty?

        options[:callbacks].each do |callback|
          next if callback.is_a?(Proc)

          raise ArgumentError, "`#{qualified_name}` has an invalid callback: #{callback.inspect}"
        end
      end

      # Validates a single coercer during initialization.
      #
      # @param coercer [Object] The coercer to validate
      # @raise [ArgumentError] If the coercer is invalid
      # @return [void]
      # @rbs (^(untyped value) -> untyped | Symbol | true coercer) -> void
      def validate_coercer!(coercer)
        return if coercer.is_a?(Proc)
        return if coercer.is_a?(Symbol) && base_methods.include?(coercer)
        return if coercer.equal?(true) && base_methods.include?(:"coerce_#{name}")

        raise ArgumentError, "`#{qualified_name}` has an invalid coercer: #{coercer.inspect}"
      end

      # Validates the coercer options during initialization.
      #
      # @param options [Hash] The options to validate
      # @raise [ArgumentError] If any coercers are invalid
      # @return [void]
      # @rbs (Hash[Symbol, untyped] options) -> void
      def validate_coercer_options!(options)
        return if options[:coercers].empty?

        options[:coercers].each { |coercer| validate_coercer!(coercer) }
      end

      # Validates all options during initialization.
      #
      # @param options [Hash] The options to validate
      # @raise [ArgumentError] If any options are invalid
      # @return [void]
      # @rbs (Hash[Symbol, untyped] options) -> void
      def validate_options!(options)
        validate_callback_options!(options)
        validate_coercer_options!(options)
        validate_validator_options!(options)
      end

      # Validates the validator options during initialization.
      #
      # @param options [Hash] The options to validate
      # @raise [ArgumentError] If any validators are invalid
      # @return [void]
      # @rbs (Hash[Symbol, untyped] options) -> void
      def validate_validator_options!(options)
        return if options[:validators].empty?

        options[:validators].each do |validator|
          next if validator.is_a?(Proc) || validator.respond_to?(:===)

          raise ArgumentError, "`#{qualified_name}` has an invalid validator: #{validator.inspect}"
        end
      end

      # Validates a value against all validators.
      #
      # @param value [Object] The value to validate
      # @raise [ArgumentError] If the value is invalid
      # @return [void]
      # @rbs (untyped value) -> void
      def validate_value!(value)
        raise ArgumentError, "`#{qualified_name}` is required" if value.nil? && required?

        return if @options[:validators].all? do |validator|
          if validator.is_a?(Proc)
            @base.instance_exec(value, &validator)
          else
            validator === value # rubocop:disable Style/CaseEquality
          end
        end

        raise ArgumentError, "`#{qualified_name}` has an invalid value: #{value.inspect}"
      end
    end
  end
end
