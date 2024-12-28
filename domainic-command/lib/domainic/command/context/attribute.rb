# frozen_string_literal: true

module Domainic
  module Command
    module Context
      # @since 0.1.0
      class Attribute
        # @rbs!
        #   interface _TypeValidator
        #     def validate!: (untyped value) -> bool
        #   end
        #
        #   type options = { default: untyped, required: bool }
        #
        #   type type_validator = Class | Module | Proc | (_TypeValidator & Object)

        Undefined = Object.new.tap do |undefined|
          def undefined.clone(...)
            self
          end

          def undefined.dup
            self
          end

          def undefined.inspect
            to_s
          end

          def undefined.to_s
            'Undefined'
          end
        end.freeze #: Object
        private_constant :Undefined

        # The default options for an attribute
        #
        # @return [Hash{Symbol => Object}]
        DEFAULT_OPTIONS = { default: Undefined, required: false }.freeze #: options
        private_constant :DEFAULT_OPTIONS

        # @rbs @description: String?
        # @rbs @name: Symbol
        # @rbs @options: options
        # @rbs @type_validator: type_validator?

        attr_reader :description #: String?
        attr_reader :name #: Symbol

        # @rbs (
        #   String | Symbol name,
        #   *(String | type_validator)? type_validator_and_description,
        #   ?default: untyped?,
        #   ?default_generator: untyped?,
        #   ?default_value: untyped?,
        #   ?desc: String?,
        #   ?description: String?,
        #   ?required: bool?,
        #   ?type: type_validator?
        #   ) -> void
        def initialize(name, *type_validator_and_description, **options)
          symbolized_options = options.transform_keys(&:to_sym)

          @name = name.to_sym

          initialize_description_and_type(type_validator_and_description, **symbolized_options)
          initialize_options(symbolized_options)
        end

        # @rbs () -> untyped
        def default
          return unless default?

          default = @options[:default]
          default.is_a?(Proc) ? default.call : default
        end

        # @rbs () -> bool
        def default?
          @options[:default] != Undefined
        end

        # @rbs () -> bool
        def required?
          @options[:required] == true
        end

        # @rbs (untyped value) -> bool
        def validate!(value)
          return false if value.nil? && required?
          return true if @type_validator.nil?

          validate_type!(value)
        end

        private

        # @rbs (
        #   Array[String? | type_validator?] arguments,
        #   ?desc: String?,
        #   ?description: String?,
        #   ?type: type_validator?,
        #   **untyped options
        #   ) -> void
        def initialize_description_and_type(arguments, **options)
          @description = arguments.compact.find { |argument| argument.is_a?(String) } ||
                         options[:desc] ||
                         options[:description] #: String?
          @type_validator = arguments.compact.find { |argument| !argument.is_a?(String) } ||
                            options[:type] #: type_validator?
        end

        # @rbs (Hash[Symbol, untyped] options) -> void
        def initialize_options(options)
          @options = options.slice(:default, :required)
          @options[:default] ||= options[:default_generator] || options[:default_value]
          @options = DEFAULT_OPTIONS.merge(@options) #: options
        end

        # @rbs (untyped value) -> bool
        def validate_type!(value)
          return @type_validator.validate!(value) if @type_validator.respond_to?(:validate!) # steep:ignore NoMethod
          return @type_validator.call(value) if @type_validator.is_a?(Proc) # steep:ignore NoMethod
          return true if value.is_a?(@type_validator)

          raise TypeError, "Expected #{@type_validator}, got #{value.class}(#{value.inspect})"
        end
      end
    end
  end
end
