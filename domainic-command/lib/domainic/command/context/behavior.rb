# frozen_string_literal: true

require 'domainic/command/context/attribute'
require 'domainic/command/context/attribute_set'

module Domainic
  module Command
    module Context
      # A module that provides attribute management for command contexts. When included in a class, it provides
      # a DSL for defining and managing typed attributes with validation, default values, and thread-safe access.
      #
      # ## Thread Safety
      # The attribute system is designed to be thread-safe during class definition and inheritance. A class-level
      # mutex protects the attribute registry during:
      # * Definition of new attributes via the DSL
      # * Inheritance of attributes to subclasses
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      module Behavior
        # @rbs (Class | Module base) -> void
        def self.included(base)
          super
          base.extend(ClassMethods)
        end

        # Provides class-level methods for defining and managing attributes. These methods are
        # automatically extended onto any class that includes {Behavior}.
        #
        # @since 0.1.0
        module ClassMethods
          # @rbs @attributes: AttributeSet
          # @rbs @attribute_lock: Mutex

          private

          # Defines a new attribute for the context.
          #
          # @overload attribute(name, *type_validator_and_description, **options)
          #   @param name [String, Symbol] The name of the attribute
          #   @param type_validator_and_description [Array<Class, Module, Object, Proc, String, nil>] Type validator or
          #     description arguments
          #   @param options [Hash] Configuration options for the attribute
          #   @option options [Object] :default A static default value
          #   @option options [Proc] :default_generator A proc that generates the default value
          #   @option options [Object] :default_value Alias for :default
          #   @option options [String, nil] :desc Short description of the attribute
          #   @option options [String, nil] :description Full description of the attribute
          #   @option options [Boolean] :required Whether the attribute is required
          #   @option options [Class, Module, Object, Proc] :type A type validator
          #
          #   @return [void]
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
          def attribute(...)
            # @type self: Class & Behavior & ClassMethods
            attribute = Attribute.new(...)
            attribute_lock.synchronize { attributes.add(attribute) }
            attr_reader attribute.name
          end

          # Returns the mutex used to synchronize attribute operations.
          #
          # @return [Mutex]
          # @rbs () -> Mutex
          def attribute_lock
            @attribute_lock ||= Mutex.new
          end

          # Returns the set of attributes defined for this context.
          #
          # @return [AttributeSet]
          # @rbs () -> AttributeSet
          def attributes
            @attributes ||= AttributeSet.new
          end

          # Handles inheritance of attributes to subclasses.
          #
          # @param subclass [Class, Module] The inheriting class
          #
          # @return [void]
          # @rbs (Class | Module subclass) -> void
          def inherited(subclass)
            super
            attribute_lock.synchronize do
              subclass.instance_variable_set(:@attributes, attributes.dup)
            end
          end
        end

        # Initializes a new context instance with the given attributes.
        #
        # @param options [Hash{String, Symbol => Object}] Attribute values for initialization
        #
        # @raise [ArgumentError] If any attribute values are invalid
        # @return [Behavior]
        # @rbs (**untyped options) -> void
        def initialize(**options)
          options = options.transform_keys(&:to_sym)

          self.class.send(:attributes).each do |attribute|
            value = options.fetch(attribute.name) { attribute.default if attribute.default? }
            raise ArgumentError, "Invalid value for #{attribute.name}: #{value.inspect}" unless attribute.valid?(value)

            instance_variable_set(:"@#{attribute.name}", value)
          end
        end

        # Returns a hash of all attribute names and their values.
        #
        # @return [Hash{Symbol => Object}] A hash of attribute values
        # @rbs () -> Hash[Symbol, untyped]
        def to_hash
          self.class.send(:attributes).each_with_object({}) do |attribute, hash|
            hash[attribute.name] = public_send(attribute.name)
          end
        end
        alias to_h to_hash
      end
    end
  end
end
