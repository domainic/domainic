# frozen_string_literal: true

require 'domainic/attributer/attribute'
require 'forwardable'

module Domainic
  module Attributer
    # A class representing an ordered collection of attributes.
    #
    # This class manages a set of attributes for a given class or module. It maintains
    # attributes in a specific order determined by their type (argument vs option),
    # default values, and position. The collection supports standard operations like
    # adding, selecting, and merging attributes while maintaining proper ownership
    # relationships with their base class.
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class AttributeSet
      extend Forwardable

      # @rbs @base: __todo__
      # @rbs @lookup: Hash[Symbol, Attribute]

      # Initialize a new AttributeSet.
      #
      # @param base [Class, Module] the class or module this set belongs to
      # @param attributes [Array<Attribute>] initial attributes to add
      #
      # @return [void]
      # @rbs (__todo__ base, ?Array[Attribute] attributes) -> void
      def initialize(base, attributes = [])
        @base = base
        @lookup = {}
        attributes.each { |attribute| add(attribute) }
      end

      # Get an attribute by name.
      #
      # @param attribute_name [String, Symbol] the name of the attribute
      #
      # @return [Attribute, nil] the attribute if found
      # @rbs (String | Symbol attribute_name) -> Attribute?
      def [](attribute_name)
        @lookup[attribute_name.to_sym]
      end

      # Add an attribute to the set.
      #
      # If an attribute with the same name exists, the attributes are merged.
      # If the attribute belongs to a different base class, it is duplicated
      # with the correct base. After adding, attributes are sorted by type
      # and position.
      #
      # @param attribute [Attribute] the attribute to add
      #
      # @raise [ArgumentError] if attribute is invalid
      # @return [void]
      # @rbs (Attribute attribute) -> void
      def add(attribute)
        raise ArgumentError, "Invalid attribute: #{attribute.inspect}" unless attribute.is_a?(Attribute)

        @lookup[attribute.name] = if @lookup.key?(attribute.name)
                                    @lookup[attribute.name].merge(attribute).dup_with_base(@base)
                                  elsif attribute.base != @base
                                    attribute.dup_with_base(@base)
                                  else
                                    attribute
                                  end

        sort_lookup
        nil
      end

      # Check if an attribute exists in the set.
      #
      # @param attribute_name [String, Symbol] the name to check
      #
      # @return [Boolean] true if the attribute exists
      def attribute?(attribute_name)
        @lookup.key?(attribute_name.to_sym)
      end

      # Get all attribute names.
      #
      # @return [Array<Symbol>] the attribute names
      # @rbs () -> Array[Symbol]
      def attribute_names
        @lookup.keys
      end

      # Get all attributes.
      #
      # @return [Array<Attribute>] the attributes
      # @rbs () -> Array[Attribute]
      def attributes
        @lookup.values
      end

      # @rbs! def count: () ?{ (Symbol, Attribute) -> boolish } -> Integer
      def_delegators :@lookup, :count

      # Create a duplicate set for a new base class.
      #
      # @param new_base [Class, Module] the new base class
      #
      # @return [AttributeSet] the duplicated set
      # @rbs (__todo__ base) -> AttributeSet
      def dup_with_base(new_base)
        dup.tap do |duped|
          duped.instance_variable_set(:@base, new_base)
          duped.instance_variable_set(
            :@lookup,
            @lookup.transform_values { |attribute| attribute.dup_with_base(new_base) }
          )
        end
      end

      # Iterate over attribute name/value pairs.
      #
      # @yield [name, attribute] each name/attribute pair
      # @yieldparam name [Symbol] the attribute name
      # @yieldparam attribute [Attribute] the attribute
      #
      # @return [self]
      # @rbs () { ([Symbol, Attribute]) -> untyped } -> self
      def each(...)
        @lookup.each(...)
        self
      end
      alias each_pair each

      # @rbs! def empty?: () -> bool
      def_delegators :@lookup, :empty?

      # Create a new set excluding specified attributes.
      #
      # @param attribute_names [Array<String, Symbol>] names to exclude
      #
      # @return [AttributeSet] new set without specified attributes
      # @rbs (*String | Symbol attribute_names) -> AttributeSet
      def except(*attribute_names)
        self.class.new(@base, @lookup.except(*attribute_names.map(&:to_sym)).values)
      end

      # @rbs! def length: () -> Integer
      def_delegators :@lookup, :length

      # Merge another set into this one.
      #
      # @param other [AttributeSet] the set to merge
      #
      # @return [AttributeSet] new set with merged attributes
      # @rbs (AttributeSet other) -> AttributeSet
      def merge(other)
        self.class.new(other.instance_variable_get(:@base), attributes + other.attributes)
      end

      # Create a new set with rejected attributes.
      #
      # @yield [name, attribute] each name/attribute pair
      # @yieldparam name [Symbol] the attribute name
      # @yieldparam attribute [Attribute] the attribute
      #
      # @return [AttributeSet] new set without rejected attributes
      # @rbs () { (Symbol, Attribute) -> boolish } -> AttributeSet
      def reject(...)
        self.class.new(@base, @lookup.reject(...).values)
      end

      # Create a new set with selected attributes.
      #
      # @yield [name, attribute] each name/attribute pair
      # @yieldparam name [Symbol] the attribute name
      # @yieldparam attribute [Attribute] the attribute
      #
      # @return [AttributeSet] new set with selected attributes
      # @rbs () { (Symbol, Attribute) -> boolish } -> AttributeSet
      def select(...)
        self.class.new(@base, @lookup.select(...).values)
      end

      # @rbs! def size: () -> Integer
      def_delegators :@lookup, :size

      private

      # Sort attributes by type and position.
      #
      # Attributes are sorted first by type (required arguments, defaulted arguments,
      # then options), and then by their position within those groups.
      #
      # @return [void]
      # @rbs () -> void
      def sort_lookup
        @lookup = @lookup.sort_by do |_, attribute|
          [
            if attribute.signature.option?
              2
            else
              (attribute.default? ? 1 : 0)
            end,
            attribute.signature.position
          ]
        end.to_h
      end
    end
  end
end
