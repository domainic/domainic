# frozen_string_literal: true

module Domainic
  module Attributer
    # Handles the injection of attribute accessor methods into a class.
    # For each AttributeDefinition, it creates reader, writer, and helper methods
    # with the appropriate visibility (public or private).
    #
    # The injector ensures methods are only defined once and handles method
    # name conflicts safely.
    #
    # @since 0.1.0
    class MethodInjector
      # @rbs @base: untyped

      # Creates a new MethodInjector for the given base object.
      #
      # @param base [Class, Object] The class or instance to inject methods into
      # @return [void]
      # @rbs (untyped base) -> void
      def initialize(base)
        @base = base
      end

      # Creates a copy of this injector for a new base object.
      #
      # @param new_base [Class, Object] The new base class or instance
      # @return [MethodInjector] A new injector instance
      # @rbs (untyped new_base) -> instance
      def dup_with_base(new_base)
        dup.tap { |duped| duped.instance_variable_set(:@base, new_base) }
      end

      # Injects accessor methods for an attribute definition.
      # Creates reader, writer, and undefined check methods with the specified visibility.
      #
      # @param attribute_definition [AttributeDefinition] The attribute to create methods for
      # @return [void]
      # @rbs (AttributeDefinition attribute_definition) -> void
      def inject!(attribute_definition)
        inject_reader_method!(attribute_definition)
        inject_undefined_method!(attribute_definition)
        inject_writer_method!(attribute_definition)
      end

      private

      # Safely defines a method if it doesn't already exist.
      #
      # @param method_name [Symbol] The name of the method to define
      # @yield The method body
      # @return [void]
      # @rbs (Symbol method_name) { (?) [self: untyped] -> void } -> void
      def define_safe_method(method_name, &)
        return if (@base.instance_methods + @base.private_instance_methods).include?(method_name)

        @base.define_method(method_name, &)
      end

      # Injects the reader method for an attribute.
      #
      # @param attribute_definition [AttributeDefinition] The attribute to create the reader for
      # @return [void]
      # @rbs (AttributeDefinition attribute_definition) -> void
      def inject_reader_method!(attribute_definition)
        define_safe_method(attribute_definition.attribute.name) do
          @__attributes__[attribute_definition.attribute.name].value
        end
        @base.send(attribute_definition.read_access, attribute_definition.attribute.name)
      end

      # Injects the undefined check method for an attribute.
      #
      # @param attribute_definition [AttributeDefinition] The attribute to create the check for
      # @return [void]
      # @rbs (AttributeDefinition attribute_definition) -> void
      def inject_undefined_method!(attribute_definition)
        define_safe_method(:"#{attribute_definition.attribute.name}_undefined?") do
          @__attributes__[attribute_definition.attribute.name].undefined?
        end
        @base.send(attribute_definition.read_access, :"#{attribute_definition.attribute.name}_undefined?")
      end

      # Injects the writer method for an attribute.
      #
      # @param attribute_definition [AttributeDefinition] The attribute to create the writer for
      # @return [void]
      # @rbs (AttributeDefinition attribute_definition) -> void
      def inject_writer_method!(attribute_definition)
        define_safe_method(:"#{attribute_definition.attribute.name}=") do |value|
          @__attributes__[attribute_definition.attribute.name].value = value
        end
        @base.send(attribute_definition.write_access, :"#{attribute_definition.attribute.name}=")
      end
    end
  end
end
