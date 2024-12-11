# frozen_string_literal: true

require 'domainic/attributer/attribute/mixin/belongs_to_attribute'

module Domainic
  module Attributer
    class Attribute
      # A class responsible for managing attribute signature information.
      #
      # This class encapsulates the type and visibility configuration for an attribute.
      # It validates and manages whether an attribute is an argument or option, as well
      # as controlling read and write visibility (public, protected, or private).
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class Signature
        # @rbs!
        #   type default_options = {
        #     nilable: bool,
        #     read: visibility_symbol,
        #     required: bool,
        #     write: visibility_symbol
        #   }
        #
        #   type initialize_options = {
        #     ?nilable: bool,
        #     ?position: Integer?,
        #     ?read: visibility_symbol,
        #     ?required: bool,
        #     type: type_symbol,
        #     ?write: visibility_symbol
        #   }
        #
        #   type type_symbol = :argument | :option
        #
        #   type visibility_symbol = :private | :protected | :public

        include BelongsToAttribute

        # @return [Hash{Symbol => Object}] Default options for a new Signature instance.
        DEFAULT_OPTIONS = { nilable: true, read: :public, required: false, write: :public }.freeze #: default_options

        # Constants defining valid attribute types.
        #
        # @author {https://aaronmallen.me Aaron Allen}
        # @since 0.1.0
        module TYPE
          # @return [Symbol] argument type designation
          ARGUMENT = :argument #: type_symbol

          # @return [Symbol] option type designation
          OPTION = :option #: type_symbol

          # @return [Array<Symbol>] all valid type values
          ALL = [ARGUMENT, OPTION].freeze #: Array[type_symbol]
        end

        # Constants defining valid visibility levels.
        #
        # @author {https://aaronmallen.me Aaron Allen}
        # @since 0.1.0
        module VISIBILITY
          # @return [Symbol] private visibility level
          PRIVATE = :private #: visibility_symbol

          # @return [Symbol] protected visibility level
          PROTECTED = :protected #: visibility_symbol

          # @return [Symbol] public visibility level
          PUBLIC = :public #: visibility_symbol

          # @return [Array<Symbol>] all valid visibility levels
          ALL = [PRIVATE, PROTECTED, PUBLIC].freeze #: Array[visibility_symbol]
        end

        # @rbs @nilable: bool
        # @rbs @position: Integer?
        # @rbs @read_visibility: visibility_symbol
        # @rbs @required: bool
        # @rbs @type: type_symbol
        # @rbs @write_visibility: visibility_symbol

        # @return [Integer, nil] the position of the attribute
        attr_reader :position #: Integer?

        # @return [Symbol] the visibility level for reading the attribute
        attr_reader :read_visibility #: visibility_symbol

        # @return [Symbol] the type of the attribute
        attr_reader :type #: type_symbol

        # @return [Symbol] the visibility level for writing the attribute
        attr_reader :write_visibility #: visibility_symbol

        # Initialize a new Signature instance.
        #
        # @param attribute [Attribute] the attribute this signature belongs to
        # @param options [Hash{Symbol => Object}] the signature options
        # @option options [Boolean] nilable (true) whether the attribute is allowed to be nil.
        # @option options [Integer, nil] position (nil) optional position for ordered attributes
        # @option options [Symbol] read (:public) the read visibility
        # @option options [Boolean] required (false) whether the attribute is required
        # @option options [Symbol] type the type of attribute
        # @option options [Symbol] write (:public) the write visibility
        #
        # @return [void]
        # @rbs (
        #   Attribute attribute,
        #   ?nilable: bool,
        #   ?position: Integer?,
        #   ?read: visibility_symbol,
        #   ?required: bool,
        #   type: type_symbol,
        #   ?write: visibility_symbol
        #   ) -> void
        def initialize(attribute, **options)
          super
          options = DEFAULT_OPTIONS.merge(options.transform_keys(&:to_sym))
          validate_initialize_options!(options)

          # @type var options: initialize_options
          @nilable = options.fetch(:nilable)
          @position = options[:position]
          @read_visibility = options.fetch(:read).to_sym
          @required = options.fetch(:required)
          @type = options.fetch(:type).to_sym
          @write_visibility = options.fetch(:write).to_sym
        end

        # Check if this signature is for an argument attribute.
        #
        # @return [Boolean] true if this is an argument attribute
        # @rbs () -> bool
        def argument?
          @type == TYPE::ARGUMENT
        end

        # Check if the attribute is allowed to be nil.
        #
        # @return [Boolean] true if the attribute is allowed to be nil
        # @rbs () -> bool
        def nilable?
          @nilable
        end

        # Check if this signature is for an option attribute.
        #
        # @return [Boolean] true if this is an option attribute
        # @rbs () -> bool
        def option?
          @type == TYPE::OPTION
        end

        # Check if this signature is for an optional attribute.
        #
        # @return [Boolean] true if this is an optional attribute
        # @rbs () -> bool
        def optional?
          !required?
        end

        # Check if both read and write operations are private.
        #
        # @return [Boolean] true if both read and write are private
        # @rbs () -> bool
        def private?
          private_read? && private_write?
        end

        # Check if read operations are private.
        #
        # @return [Boolean] true if read operations are private
        # @rbs () -> bool
        def private_read?
          [VISIBILITY::PRIVATE, VISIBILITY::PROTECTED].include?(@read_visibility)
        end

        # Check if write operations are private.
        #
        # @return [Boolean] true if write operations are private
        # @rbs () -> bool
        def private_write?
          [VISIBILITY::PRIVATE, VISIBILITY::PROTECTED].include?(@write_visibility)
        end

        # Check if both read and write operations are protected.
        #
        # @return [Boolean] true if both read and write are protected
        # @rbs () -> bool
        def protected?
          protected_read? && protected_write?
        end

        # Check if read operations are protected.
        #
        # @return [Boolean] true if read operations are protected
        # @rbs () -> bool
        def protected_read?
          @read_visibility == VISIBILITY::PROTECTED
        end

        # Check if write operations are protected.
        #
        # @return [Boolean] true if write operations are protected
        # @rbs () -> bool
        def protected_write?
          @write_visibility == VISIBILITY::PROTECTED
        end

        # Check if both read and write operations are public.
        #
        # @return [Boolean] true if both read and write are public
        # @rbs () -> bool
        def public?
          public_read? && public_write?
        end

        # Check if read operations are public.
        #
        # @return [Boolean] true if read operations are public
        # @rbs () -> bool
        def public_read?
          @read_visibility == VISIBILITY::PUBLIC
        end

        # Check if write operations are public.
        #
        # @return [Boolean] true if write operations are public
        # @rbs () -> bool
        def public_write?
          @write_visibility == VISIBILITY::PUBLIC
        end

        # Check if the attribute is required.
        #
        # @return [Boolean] true if the attribute is required
        # @rbs () -> bool
        def required?
          @required
        end

        private

        # Get signature options as a hash.
        #
        # @return [Hash] the signature options
        # @rbs () -> initialize_options
        def to_options
          {
            nilable: @nilable,
            position: @position,
            read: @read_visibility,
            required: @required,
            type: @type,
            write: @write_visibility
          }
        end

        # Validate that a value is a Boolean.
        #
        # @param name [String, Symbol] the name of the attribute being validated
        # @param value [Boolean] the value to validate
        #
        # @raise [ArgumentError] if the value is invalid
        # @return [void]
        # @rbs (String | Symbol name, bool value) -> void
        def validate_boolean!(name, value)
          return if [true, false].include?(value)

          raise ArgumentError, "`#{attribute_method_name}`: invalid #{name}: #{value}. Must be `true` or `false`."
        end

        # Validate all initialization options.
        #
        # @param options [Hash{Symbol => Object}] the options to validate
        # @option options [Boolean] nilable the nilable flag to validate
        # @option options [Integer, nil] position the position value to validate
        # @option options [Symbol] read the read visibility to validate
        # @option options [Boolean] required the required flag to validate
        # @option options [Symbol] type the type to validate
        # @option options [Symbol] write the write visibility to validate
        #
        # @return [void]
        # @rbs (Hash[Symbol, untyped] options) -> void
        def validate_initialize_options!(options)
          validate_position!(options[:position])
          validate_visibility!(:read, options[:read])
          validate_visibility!(:write, options[:write])
          validate_boolean!(:nilable, options[:nilable])
          validate_boolean!(:required, options[:required])
          validate_type!(options[:type])
        end

        # Validate that a position value is valid.
        #
        # @param position [Integer, nil] the position to validate
        #
        # @raise [ArgumentError] if the position is invalid
        # @return [void]
        # @rbs (Integer? position) -> void
        def validate_position!(position)
          return if position.nil? || position.is_a?(Integer)

          raise ArgumentError, "`#{attribute_method_name}`: invalid position: #{position}. Must be Integer or nil."
        end

        # Validate that a type value is valid.
        #
        # @param type [Symbol] the type to validate
        #
        # @raise [ArgumentError] if the type is invalid
        # @return [void]
        # @rbs (type_symbol type) -> void
        def validate_type!(type)
          return if TYPE::ALL.include?(type.to_sym)

          raise ArgumentError,
                "`#{attribute_method_name}`: invalid type: #{type}. Must be one of #{TYPE::ALL.join(', ')}"
        end

        # Validate that visibility values are valid.
        #
        # @param type [Symbol] which visibility setting to validate
        # @param value [Symbol] the visibility value to validate
        #
        # @raise [ArgumentError] if the visibility is invalid
        # @return [void]
        # @rbs (Symbol type, visibility_symbol value) -> void
        def validate_visibility!(type, value)
          return if VISIBILITY::ALL.include?(value.to_sym)

          raise ArgumentError, "`#{attribute_method_name}`: invalid #{type} visibility: #{value}. " \
                               "Must be one of #{VISIBILITY::ALL.join(', ')}"
        end
      end
    end
  end
end
