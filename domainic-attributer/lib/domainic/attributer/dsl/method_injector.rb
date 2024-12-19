# frozen_string_literal: true

module Domainic
  module Attributer
    module DSL
      # A class responsible for injecting attribute methods into classes
      #
      # This class handles the creation of reader and writer methods for attributes,
      # ensuring they are injected safely without overwriting existing methods. It
      # respects visibility settings and properly handles value assignment through
      # the attribute system
      #
      # @api private
      # @!visibility private
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class MethodInjector
        # @rbs @attribute: Attribute
        # @rbs @base: __todo__

        # Inject methods for an attribute into a class
        #
        # @param base [Class, Module] the class to inject methods into
        # @param attribute [Attribute] the {Attribute} to create methods for
        #
        # @return [void]
        # @rbs (__todo__ base, Attribute attribute) -> void
        def self.inject!(base, attribute)
          new(base, attribute).inject!
        end

        # Initialize a new MethodInjector
        #
        # @param base [Class, Module] the class to inject methods into
        # @param attribute [Attribute] the {Attribute} to create methods for
        #
        # @return [MethodInjector] the new MethodInjector instance
        # @rbs (__todo__ base, Attribute attribute) -> void
        def initialize(base, attribute)
          @attribute = attribute
          @base = base
        end

        # Inject reader and writer methods
        #
        # @return [void]
        # @rbs () -> void
        def inject!
          inject_reader!
          inject_writer!
        end

        private

        # Define a method if it doesn't already exist
        #
        # @param method_name [Symbol] the name of the method to define
        #
        # @yield the method body to define
        # @return [void]
        # @rbs (Symbol method_name) { (?) [self: untyped] -> void } -> void
        def define_safe_method(method_name, &)
          return if @base.method_defined?(method_name) || @base.private_method_defined?(method_name)

          @base.define_method(method_name, &)
        end

        # Inject the attribute reader method
        #
        # Creates a reader method with the configured visibility
        #
        # @return [void]
        # @rbs () -> void
        def inject_reader!
          @base.attr_reader @attribute.name
          @base.send(@attribute.signature.read_visibility, @attribute.name)
        end

        # Inject the attribute writer method
        #
        # Creates a writer method that processes values through the attribute
        # system before assignment. Sets the configured visibility
        #
        # @return [void]
        # @rbs () -> void
        def inject_writer!
          attribute_name = @attribute.name

          define_safe_method(:"#{attribute_name}=") do |value|
            attribute = self.class.send(:__attributes__)[attribute_name] # steep:ignore NoMethod
            attribute.apply!(self, value)
          end

          @base.send(@attribute.signature.write_visibility, :"#{attribute_name}=")
        end
      end
    end
  end
end
