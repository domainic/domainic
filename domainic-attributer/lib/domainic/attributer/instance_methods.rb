# frozen_string_literal: true

module Domainic
  module Attributer
    # Provides instance-level functionality for objects with attributes.
    # When Attributer is included in a class, these methods become instance methods
    # that handle initialization and attribute value management.
    #
    # Each instance maintains its own attribute state while sharing the attribute
    # definitions from its class.
    #
    # @since 0.1.0
    module InstanceMethods
      # @rbs @__attributes__: Hash[Symbol, Attribute]

      # Initializes a new instance with attribute values.
      # This method sets up attribute storage and assigns any initial values provided.
      # For each declared attribute:
      # - If a value is provided, it's assigned (with coercion and validation)
      # - If no value is provided, it remains undefined or uses its default
      #
      # @example Initialize with attributes
      #   person = Person.new(name: "Alice", age: 30)
      #
      # @example Initialize with no attributes
      #   person = Person.new  # Attributes use defaults or remain undefined
      #
      # @param attributes [Hash{Symbol => Object}] Initial attribute values
      # @return [void]
      # @raise [ArgumentError] If any provided values fail validation
      # @rbs (**untyped attribute) -> void
      def initialize(**attributes)
        @__attributes__ = self.class.send(:__attribute_definitions__).transform_values do |definition|
          definition.attribute.dup_with_base(self)
        end
        attributes = attributes.transform_keys(&:to_sym)
        @__attributes__.each_key do |attribute_name|
          send(:"#{attribute_name}=", attributes[attribute_name])
        end
      end

      # Compares this instance to another object for equality.
      #
      # @param other [Object] The object to compare
      # @return [Boolean] `true` if the objects are equal, `false` otherwise
      # @rbs (untyped other) -> bool
      def ==(other)
        other.is_a?(self.class) && to_hash == other.to_hash
      end

      # Generates a hash code for this instance. The hash code is based on the class and attribute values.
      #
      # @return [Integer] A hash code for this instance
      # @rbs () -> Integer
      def hash
        [self.class, *to_hash.to_a.flatten].hash
      end

      # Returns a hash of attribute names and values.
      #
      # @return [Hash{Symbol => Object}] A hash of attribute names and values
      # @rbs () -> Hash[Symbol, untyped]
      def to_hash
        @__attributes__.transform_values(&:value)
      end
      alias to_h to_hash
    end
  end
end
