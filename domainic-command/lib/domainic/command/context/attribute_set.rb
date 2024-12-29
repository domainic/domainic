# frozen_string_literal: true

module Domainic
  module Command
    module Context
      # A collection class for managing a set of command context attributes. This class provides a simple interface
      # for storing, accessing, and iterating over {Attribute} instances.
      #
      # @example
      #   set = AttributeSet.new
      #   set.add(Attribute.new(:name))
      #   set[:name] # => #<Attribute name=:name>
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class AttributeSet
        # @rbs @lookup: Hash[Symbol, Attribute]

        # Creates a new AttributeSet instance
        #
        # @return [AttributeSet]
        # @rbs () -> void
        def initialize
          @lookup = {}
        end

        # Retrieves an attribute by name
        #
        # @param attribute_name [String, Symbol] The name of the attribute to retrieve
        #
        # @return [Attribute, nil] The attribute with the given name, or nil if not found
        # @rbs (String | Symbol attribute_name) -> Attribute?
        def [](attribute_name)
          @lookup[attribute_name.to_sym]
        end

        # Adds an attribute to the set
        #
        # @param attribute [Attribute] The attribute to add
        #
        # @raise [ArgumentError] If the provided attribute is not an {Attribute} instance
        # @return [void]
        # @rbs (Attribute attribute) -> void
        def add(attribute)
          unless attribute.is_a?(Attribute)
            raise ArgumentError, 'Attribute must be an instance of Domainic::Command::Context::Attribute'
          end

          @lookup[attribute.name] = attribute
        end

        # Returns all attributes in the set
        #
        # @return [Array<Attribute>] An array of all attributes
        # @rbs () -> Array[Attribute]
        def all
          @lookup.values
        end

        # Iterates over each attribute in the set
        #
        # @yield [Attribute] Each attribute in the set
        #
        # @return [void]
        # @rbs () { (Attribute) -> untyped } -> void
        def each(...)
          all.each(...)
        end

        # Iterates over each attribute in the set with an object
        #
        # @overload each_with_object(object)
        #   @param object [Object] The object to pass to the block
        #   @yield [Attribute, Object] Each attribute and the object
        #
        #   @return [Object] The final state of the object
        # @rbs [U] (U object) { (Attribute, U) -> untyped } -> U
        def each_with_object(...)
          all.each_with_object(...) # steep:ignore UnresolvedOverloading
        end

        private

        # Ensure that Attributes are duplicated when the AttributeSet is duplicated
        #
        # @param source [AttributeSet] The source AttributeSet to copy
        #
        # @return [AttributeSet]
        def initialize_copy(source)
          @lookup = source.instance_variable_get(:@lookup).transform_values(&:dup)
          super
        end
      end
    end
  end
end
