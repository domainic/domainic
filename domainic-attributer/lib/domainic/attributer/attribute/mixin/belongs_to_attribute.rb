# frozen_string_literal: true

module Domainic
  module Attributer
    class Attribute
      # A mixin providing common functionality for classes that belong to an Attribute.
      #
      # This module provides initialization and duplication behavior for classes that are owned
      # by and work in conjunction with an Attribute instance. These classes typically handle
      # specific aspects of attribute processing such as coercion, validation, or callbacks.
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      module BelongsToAttribute
        # @rbs @attribute: Attribute

        # Initialize a new instance that belongs to an attribute.
        #
        # @param attribute [Attribute] the attribute this instance belongs to
        #
        # @return [void]
        # @rbs (Attribute attribute, *untyped, **untyped) -> void
        def initialize(attribute, ...)
          validate_attribute!(attribute)
          @attribute = attribute
        end

        # Create a duplicate instance associated with a new attribute.
        #
        # @param new_attribute [Attribute] the new attribute to associate with
        #
        # @return [BelongsToAttribute] a duplicate instance
        # @rbs (Attribute attribute) -> BelongsToAttribute
        def dup_with_attribute(new_attribute)
          validate_attribute!(new_attribute)

          dup.tap { |duped| duped.instance_variable_set(:@attribute, new_attribute) }
        end

        private

        # Generate a method name for error messages.
        #
        # @return [String] the formatted method name
        # @rbs () -> String
        def attribute_method_name
          "#{@attribute.base}##{@attribute.name}"
        end

        # Ensure that an attribute is a valid {Attribute} instance.
        #
        # @param attribute [Attribute] the attribute to validate
        #
        # @raise [TypeError] if the attribute is not a valid {Attribute} instance
        # @return [void]
        # @rbs (Attribute attribute) -> void
        def validate_attribute!(attribute)
          return if attribute.is_a?(Attribute)
          return if defined?(RSpec::Mocks::TestDouble) && attribute.is_a?(RSpec::Mocks::TestDouble)

          raise TypeError,
                "invalid attribute: #{attribute.inspect}. Must be an Domainic::Attributer::Attribute instance"
        end
      end
      private_constant :BelongsToAttribute
    end
  end
end
