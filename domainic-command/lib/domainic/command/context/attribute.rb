# frozen_string_literal: true

module Domainic
  module Command
    module Context
      # Represents an attribute within a command context. This class manages the lifecycle of an attribute, including
      # its validation, default values, and metadata such as descriptions
      #
      # The `Attribute` class supports a variety of configuration options, such as marking an attribute as required,
      # defining static or dynamic default values, and specifying custom validators. These features ensure that
      # attributes conform to expected rules and provide useful metadata for documentation or runtime behavior
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class Attribute
        # Represents an undefined default value for an attribute. This is used internally to distinguish between
        # an attribute with no default and one with a defined default
        #
        # @return [Object] A frozen object representing an undefined default value
        UNDEFINED_DEFAULT = Object.new.freeze #: Object
        private_constant :UNDEFINED_DEFAULT

        # @rbs @default: untyped
        # @rbs @description: String?
        # @rbs @name: Symbol
        # @rbs @required: bool
        # @rbs @type_validator: Class | Module | Object | Proc

        # The textual description of the attribute, providing metadata about its purpose or usage
        #
        # @return [String, nil] A description of the attribute
        attr_reader :description #: String?

        # The name of the attribute, uniquely identifying it within a command context
        #
        # @return [Symbol] The name of the attribute
        attr_reader :name #: Symbol

        # Create a new attribute instance
        #
        # @overload initialize(
        #   name, type_validator_or_description = nil, description_or_type_validator = nil, **options
        #   )
        #   @param name [String, Symbol] The {#name} of the attribute
        #   @param type_validator_or_description [Class, Module, Object, Proc, String, nil] A type validator or the
        #     {#description} of the attribute
        #   @param description_or_type_validator [Class, Module, Object, Proc, String, nil] The {#description} or a
        #     type_validator of the attribute
        #   @param options [Hash] Configuration options for the attribute
        #   @option options [Object] :default The {#default} of the attribute
        #   @option options [Proc] :default_generator An alias for :default
        #   @option options [Object] :default_value An alias for :default
        #   @option options [String, nil] :desc An alias for :description
        #   @option options [String, nil] :description The {#description} of the attribute
        #   @option options [Boolean] :required Whether the attribute is {#required?}
        #   @option options [Class, Module, Object, Proc] :type A type validator for the attribute value
        #
        #   @return [Attribute] the new Attribute instance
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
        def initialize(name, *type_validator_and_description, **options)
          symbolized_options = options.transform_keys(&:to_sym)

          @name = name.to_sym
          @required = symbolized_options[:required] == true

          initialize_default(symbolized_options)
          initialize_description_and_type_validator(type_validator_and_description, symbolized_options)
        end

        # Retrieves the default value of the attribute. If a default generator is specified, it evaluates the generator
        # and returns the result
        #
        # @return [Object, nil] The default value or the result of the generator
        # @rbs () -> untyped
        def default
          return unless default?

          @default.is_a?(Proc) ? @default.call : @default
        end

        # Determines whether the attribute has a default value defined
        #
        # @return [Boolean] `true` if a default is set; otherwise, `false`
        # @rbs () -> bool
        def default?
          @default != UNDEFINED_DEFAULT
        end

        # Determines whether the attribute is marked as required
        #
        # @return [Boolean] `true` if the attribute is required; otherwise, `false`
        # @rbs () -> bool
        def required?
          @required
        end

        # Validates the given value against the attribute's type validator
        #
        # @param value [Object] The value to validate
        #
        # @return [Boolean] `true` if the value is valid; otherwise, `false`
        # @rbs (untyped value) -> bool
        def valid?(value)
          return false if value.nil? && required?
          return true if @type_validator.nil?

          validator = @type_validator
          return validator.call(value) if validator.is_a?(Proc)

          validator === value || value.is_a?(validator) # rubocop:disable Style/CaseEquality
        end

        private

        # Initializes the {#default} value for the attribute, using the provided options
        #
        # @param options [Hash] Configuration options containing default-related keys
        #
        # @return [void]
        # @rbs (Hash[Symbol, untyped] options) -> void
        def initialize_default(options)
          @default = if %i[default default_generator default_value].any? { |key| options.key?(key) }
                       options.values_at(:default, :default_generator, :default_value).compact.first
                     else
                       UNDEFINED_DEFAULT
                     end
        end

        # Initializes the description and type validator for the attribute based on the given arguments and options
        #
        # @param arguments [Array<Class, Module, Object, Proc, String, nil>] Arguments for validators or description
        # @param options [Hash] Configuration options
        #
        # @return [void]
        # @rbs (Array[(Class | Module | Object | Proc | String)?] arguments, Hash[Symbol, untyped] options) -> void
        def initialize_description_and_type_validator(arguments, options)
          @description = arguments.compact.find { |argument| argument.is_a?(String) } ||
                         options[:description] ||
                         options[:desc]

          @type_validator = arguments.compact.find { |argument| !argument.is_a?(String) } ||
                            options[:type]
        end
      end
    end
  end
end
