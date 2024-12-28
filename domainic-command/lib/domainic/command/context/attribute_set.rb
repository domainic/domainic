# frozen_string_literal: true

module Domainic
  module Command
    module Context
      # @since 0.1.0
      class AttributeSet
        # @rbs @lookup: Hash[Symbol, Attribute]

        # @rbs (?Array[Attribute] attributes) -> void
        def initialize(attributes = [])
          @lookup = {}
          attributes.each { |attribute| add(attribute) }
        end

        # @rbs (String | Symbol attribute_name) -> Attribute?
        def [](attribute_name)
          @lookup[attribute_name.to_sym]
        end

        # @rbs (Attribute attribute) -> void
        def add(attribute)
          raise ArgumentError, "Invalid attribute: #{attribute.inspect}" unless attribute.is_a?(Attribute)

          @lookup[attribute.name] = attribute
        end

        # @rbs -> Array[Attribute]
        def all
          @lookup.values
        end

        # @rbs () { (Attribute) -> untyped } -> self
        def each(...)
          all.each(...)
          self
        end

        # @rbs [U] (U object) { (Attribute, U object) -> untyped } -> U
        #    | [U] (U object) -> Enumerator[[Attribute, U], U]
        def each_with_object(...)
          all.each_with_object(...) # steep:ignore UnresolvedOverloading
        end

        private

        # @rbs (AttributeSet source) -> self
        def initialize_copy(source)
          @lookup = source.instance_variable_get(:@lookup).transform_values(&:dup)
          super
        end
      end
    end
  end
end
