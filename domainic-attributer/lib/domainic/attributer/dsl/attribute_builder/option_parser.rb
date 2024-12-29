# frozen_string_literal: true

require 'domainic/attributer/undefined'

module Domainic
  module Attributer
    module DSL
      class AttributeBuilder
        # A class responsible for parsing and normalizing attribute options
        #
        # This class handles the conversion of flexible DSL options into a normalized
        # format for attribute creation. It supports multiple ways of specifying common
        # options (like visibility, nullability, validation) and consolidates them
        # into a consistent internal representation
        #
        # @!visibility private
        # @api private
        #
        # @author {https://aaronmallen.me Aaron Allen}
        # @since 0.1.0
        class OptionParser
          # @rbs!
          #   type options = {
          #     ?callbacks: Array[Attribute::Callback::handler] | Attribute::Callback::handler,
          #     ?callback: Array[Attribute::Callback::handler] | Attribute::Callback::handler,
          #     ?coerce: Array[Attribute::Coercer::handler] | Attribute::Coercer::handler,
          #     ?coercers: Array[Attribute::Coercer::handler],
          #     ?coerce_with: [Attribute::Coercer::handler] | Attribute::Coercer::handler,
          #     ?default: untyped,
          #     ?default_generator: untyped,
          #     ?default_value: untyped,
          #     ?desc: String?,
          #     ?description: String,
          #     ?non_nil: bool,
          #     ?non_null: bool,
          #     ?non_nullable: bool,
          #     ?not_nil: bool,
          #     ?not_nilable: bool,
          #     ?not_null: bool,
          #     ?not_nullable: bool,
          #     ?null: bool,
          #     ?on_change: Array[Attribute::Callback::handler] | Attribute::Callback::handler,
          #     ?optional: bool,
          #     ?position: Integer?,
          #     ?read: Attribute::Signature::visibility_symbol,
          #     ?read_access: Attribute::Signature::visibility_symbol,
          #     ?reader: Attribute::Signature::visibility_symbol,
          #     ?required: bool,
          #     ?validate: Array[Attribute::Validator::handler] | Attribute::Validator::handler,
          #     ?validate_with: Array[Attribute::Validator::handler] | Attribute::Validator::handler,
          #     ?validators: Array[Attribute::Validator::handler] | Attribute::Validator::handler,
          #     ?write_access: Attribute::Signature::visibility_symbol,
          #     ?writer: Attribute::Signature::visibility_symbol,
          #   } & Hash[Symbol, untyped]
          #
          #   type result = {
          #     callbacks: Array[Attribute::Callback::handler],
          #     coercers: Array[Attribute::Coercer::handler],
          #     ?default: untyped,
          #     ?description: String,
          #     name: Symbol,
          #     ?nilable: bool,
          #     ?position: Integer?,
          #     ?required: bool,
          #     ?read: Attribute::Signature::visibility_symbol,
          #     type: Attribute::Signature::type_symbol,
          #     validators: Array[Attribute::Validator::handler],
          #     ?write: Attribute::Signature::visibility_symbol,
          #   }

          # Alternative keys for reader visibility settings
          ACCESSOR_READER_KEYS = %i[read read_access reader].freeze #: Array[Symbol]
          private_constant :ACCESSOR_READER_KEYS

          # Alternative keys for writer visibility settings
          ACCESSOR_WRITER_KEYS = %i[write write_access writer].freeze #: Array[Symbol]
          private_constant :ACCESSOR_WRITER_KEYS

          # Alternative keys for change callbacks
          CALLBACK_KEYS = %i[callback on_change callbacks].freeze #: Array[Symbol]
          private_constant :CALLBACK_KEYS

          # Alternative keys for coercion handlers
          COERCER_KEYS = %i[coerce coercers coerce_with].freeze #: Array[Symbol]
          private_constant :COERCER_KEYS

          # Alternative keys for default value settings
          DEFAULT_KEYS = %i[default_value default_generator default].freeze #: Array[Symbol]
          private_constant :DEFAULT_KEYS

          # Alternative keys for description
          DESCRIPTION_KEYS = %i[desc description].freeze #: Array[Symbol]
          private_constant :DESCRIPTION_KEYS

          # Pattern for matching nilability-related keys
          NILABLE_PATTERN = /\A(?:not_|non_)?(?:nil|null)\z/ #: Regexp
          private_constant :NILABLE_PATTERN

          # Keys that indicate non-nilable requirement
          NON_NILABLE_KEYS = %i[
            non_nil non_nilable not_nil not_nilable
            non_null non_nullable not_null not_nullable
          ].freeze #: Array[Symbol]
          private_constant :NON_NILABLE_KEYS

          # Alternative keys for validators
          VALIDATOR_KEYS = %i[validate validate_with validators].freeze #: Array[Symbol]
          private_constant :VALIDATOR_KEYS

          # @rbs @options: options
          # @rbs @result: result

          # Parse attribute options into a normalized format
          #
          # @param attribute_name [String, Symbol] the name of the attribute
          # @param attribute_type [String, Symbol] the type of attribute
          # @param options [Hash{String, Symbol => Object}] the options to parse. See {#initialize} for details.
          #
          # @return [Hash{Symbol => Object}] normalized options suitable for attribute creation
          # @rbs (String | Symbol attribute_name, String | Symbol attribute_type, options options) -> void
          def self.parse!(attribute_name, attribute_type, options)
            new(attribute_name, attribute_type, options).parse!
          end

          # Initialize a new OptionParser instance
          #
          # @param attribute_name [String, Symbol] the name of the attribute
          # @param attribute_type [String, Symbol] the type of attribute
          # @param options [Hash{String, Symbol => Object}] the options to parse
          #
          # @option options [Array<Proc>, Proc] :callbacks handlers for attribute change events (priority over
          #   :callback, :on_change)
          # @option options [Array<Proc>, Proc] :callback alias for :callbacks
          # @option options [Array<Proc, Symbol>, Proc, Symbol] :coerce handlers for value coercion (priority over
          #   :coercers, :coerce_with)
          # @option options [Array<Proc, Symbol>, Proc, Symbol] :coercers alias for :coerce
          # @option options [Array<Proc, Symbol>, Proc, Symbol] :coerce_with alias for :coerce
          # @option options [Object] :default the default value (priority over :default_generator, :default_value)
          # @option options [Object] :default_generator alias for :default
          # @option options [Object] :default_value alias for :default
          # @option options [String] :desc short description (overridden by :description)
          # @option options [String] :description description text
          # @option options [Boolean] :non_nil require non-nil values (priority over :non_null, :non_nullable, :not_nil,
          #   :not_nilable, :not_null, :not_nullable)
          # @option options [Boolean] :non_null alias for :non_nil
          # @option options [Boolean] :non_nullable alias for :non_nil
          # @option options [Boolean] :not_nil alias for :non_nil
          # @option options [Boolean] :not_nilable alias for :non_nil
          # @option options [Boolean] :not_null alias for :non_nil
          # @option options [Boolean] :not_nullable alias for :non_nil
          # @option options [Boolean] :null inverse of :non_nil
          # @option options [Array<Proc>, Proc] :on_change alias for :callbacks
          # @option options [Boolean] :optional whether attribute is optional (overridden by :required)
          # @option options [Integer] :position specify order position
          # @option options [Symbol] :read read visibility (:public, :protected, :private) (priority over :read_access,
          #   :reader)
          # @option options [Symbol] :read_access alias for :read
          # @option options [Symbol] :reader alias for :read
          # @option options [Boolean] :required whether attribute is required
          # @option options [Array<Object>, Object] :validate validators for the attribute (priority over
          #   :validate_with, :validators)
          # @option options [Array<Object>, Object] :validate_with alias for :validate
          # @option options [Array<Object>, Object] :validators alias for :validate
          # @option options [Symbol] :write_access write visibility (:public, :protected, :private) (priority over
          #   :writer)
          # @option options [Symbol] :writer alias for :write_access
          #
          # @return [OptionParser] the new OptionParser instance
          # @rbs (String | Symbol attribute_name, String | Symbol attribute_type, options options) -> void
          def initialize(attribute_name, attribute_type, options)
            @options = options.transform_keys(&:to_sym)
            @result = { callbacks: [], coercers: [], validators: [] }
            @result[:name] = attribute_name.to_sym
            @result[:type] = attribute_type.to_sym
            @result[:position] = @options[:position] if @options.key?(:position)
          end

          # Parse the options into a normalized format
          #
          # @return [Hash{Symbol => Object}] normalized options suitable for attribute creation
          # @rbs () -> result
          def parse!
            parse_options!
            @result
          end

          private

          # Find the last set value among multiple option keys
          #
          # @param keys [Array<Symbol>] the keys to check
          #
          # @return [Object] the last set value or {Undefined}
          # @rbs (Array[Symbol]) -> untyped
          def find_last_option(keys)
            keys.reverse_each do |key|
              value = @options[key]
              return value if value
            end
            Undefined
          end

          # Parse accessor (reader/writer) visibility options
          #
          # @return [void]
          # @rbs () -> void
          def parse_accessor_options!
            @result[:read] = find_last_option(ACCESSOR_READER_KEYS)
            @result[:write] = find_last_option(ACCESSOR_WRITER_KEYS)
          end

          # Parse callback handler options
          #
          # @return [void]
          # @rbs () -> void
          def parse_callbacks_options!
            CALLBACK_KEYS.each do |key|
              @result[:callbacks].concat(Array(@options[key])) if @options[key]
            end
          end

          # Parse coercion handler options
          #
          # @return [void]
          # @rbs () -> void
          def parse_coercers_options!
            COERCER_KEYS.each do |key|
              @result[:coercers].concat(Array(@options[key])) if @options[key]
            end
          end

          # Parse default value options
          #
          # @return [void]
          # @rbs () -> void
          def parse_default_options!
            @result[:default] = find_last_option(DEFAULT_KEYS)
          end

          # Parse description options
          #
          # @return [void]
          # @rbs () -> void
          def parse_description_options!
            @result[:description] = find_last_option(DESCRIPTION_KEYS)
          end

          # Parse nilability options
          #
          # @return [void]
          # @rbs () -> void
          def parse_nilable_options!
            return unless @options.keys.any? { |key| key.match?(NILABLE_PATTERN) }

            @result[:nilable] = !(NON_NILABLE_KEYS.any? { |k| @options[k] == true } || @options[:null] == false)
          end

          # Parse all option types
          #
          # @return [void]
          # @rbs () -> void
          def parse_options!
            private_methods.grep(/\Aparse_.*_options!\z/).each { |method| send(method) }
          end

          # Parse required/optional options
          #
          # @return [void]
          # @rbs () -> void
          def parse_required_options!
            return unless @options.key?(:optional) || @options.key?(:required)

            @result[:required] = @options[:optional] == false || @options[:required] == true
          end

          # Parse validator options
          #
          # @return [void]
          # @rbs () -> void
          def parse_validator_options!
            VALIDATOR_KEYS.each do |key|
              @result[:validators].concat(Array(@options.fetch(key, [])))
            end
          end
        end
      end
    end
  end
end
