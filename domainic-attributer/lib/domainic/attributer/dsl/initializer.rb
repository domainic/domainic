# frozen_string_literal: true

require 'domainic/attributer/undefined'

module Domainic
  module Attributer
    module DSL
      # A class responsible for handling object initialization with attributes
      #
      # This class manages the process of setting attribute values during object
      # initialization. It handles both positional arguments and keyword options,
      # applying them to their corresponding attributes while respecting default
      # values and required attributes
      #
      # @api private
      # @!visibility private
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class Initializer
        # @rbs @argument_attributes: Array[Attribute]
        # @rbs @attributes: AttributeSet
        # @rbs @base: Object
        # @rbs @option_attributes: Array[Attribute]

        # Initialize a new Initializer
        #
        # @param base [Object] the instance being initialized
        #
        # @return [Initializer] the new Initializer instance
        # @rbs (Object base) -> void
        def initialize(base)
          @base = base
          @attributes ||= @base.class.send(:__attributes__)
        end

        # Assign values to attributes
        #
        # Validates and applies both positional arguments and keyword options to
        # their corresponding attributes. Raises an error if required arguments
        # are missing
        #
        # @param arguments [Array<Object>] positional arguments to assign
        # @param keyword_arguments [Hash{Symbol => Object}] keyword arguments to assign
        #
        # @raise [ArgumentError] if required arguments are missing
        # @return [void]
        # @rbs (*untyped arguments, **untyped keyword_arguments) -> void
        def assign!(*arguments, **keyword_arguments)
          validate_positional_arguments!(arguments)
          apply_arguments(arguments)
          apply_options!(keyword_arguments)
        end

        private

        # Access to the current attribute set
        #
        # @return [AttributeSet] the attribute set for this instance
        attr_reader :attributes #: AttributeSet

        # Apply positional arguments to their attributes
        #
        # @param arguments [Array<Object>] the positional arguments to apply
        #
        # @return [void]
        # @rbs (Array[untyped]) -> void
        def apply_arguments(arguments)
          argument_attributes.each_with_index do |attribute, index|
            value = arguments.length > index ? arguments[index] : Undefined
            assign_value(attribute.name, value)
          end
        end

        # Apply keyword arguments to their attributes
        #
        # @param options [Hash{Symbol => Object}] the keyword options to apply
        #
        # @return [void]
        # @rbs (Hash[String | Symbol, untyped]) -> void
        def apply_options!(options)
          options = options.transform_keys(&:to_sym)

          option_attributes.each do |attribute|
            if options.key?(attribute.name)
              assign_value(attribute.name, options[attribute.name])
            else
              assign_value(attribute.name, Undefined)
            end
          end
        end

        # Get all argument attributes
        #
        # @return [Array<Attribute>] the argument attributes
        # @rbs () -> Array[Attribute]
        def argument_attributes
          @argument_attributes ||= attributes.select { |_, attribute| attribute.signature.argument? }.attributes
        end

        # Assign a value to an attribute
        #
        # @param attribute_name [Symbol] the name of the attribute
        # @param value [Object] the value to assign
        #
        # @return [void]
        # @rbs (String | Symbol attribute_name, untyped value) -> void
        def assign_value(attribute_name, value)
          @base.send(:"#{attribute_name}=", value)
        end

        # Get all option attributes
        #
        # @return [Array<Attribute>] the option attributes
        # @rbs () -> Array[Attribute]
        def option_attributes
          @option_attributes ||= attributes.select { |_, attribute| attribute.signature.option? }.attributes
        end

        # Validate that all required positional arguments are provided
        #
        # @param arguments [Array<Object>] the arguments to validate
        #
        # @raise [ArgumentError] if required arguments are missing
        # @return [void]
        # @rbs (Array[untyped]) -> void
        def validate_positional_arguments!(arguments)
          required = argument_attributes.reject(&:default?)
          return unless arguments.length < required.length

          raise ArgumentError, "wrong number of arguments (given #{arguments.length}, expected #{required.length}+)"
        end
      end
    end
  end
end
