# frozen_string_literal: true

module Domainic
  module Attributer
    # Provides class-level functionality for attribute definition and management.
    # When Attributer is included in a class, these methods become class methods
    # allowing for attribute definition using the option DSL.
    #
    # The module manages a builder instance per class, allowing for inherited
    # attribute definitions while preventing cross-class contamination.
    #
    # @since 0.1.0
    module ClassMethods
      # @rbs @__builder__: Builder
      # @rbs @__attribute_definitions__: Hash[Symbol, AttributeDefinition]

      # Defines a new attribute with optional type validation.
      #
      # @example Simple attribute
      #   option :name, String
      #
      # @example Attribute with configuration
      #   option :age, Integer do
      #     validates { |value| value >= 0 }
      #     default 0
      #   end
      #
      # @example Attribute with custom visibility
      #   option :secret_key, String, reader: :private do
      #     required
      #   end
      #
      # @see Builder#define
      #
      # @param option_name [String, Symbol] The name of the attribute
      # @yield Block for additional attribute configuration
      # @return [Builder] the builder instance for method chaining
      # @rbs (
      #   String | Symbol option_name,
      #   Class | Module | ^(untyped value) -> bool type_validator,
      #   **untyped options,
      #   ) ?{ (?) [self: Builder] -> void } -> Builder
      def option(option_name, ...)
        __builder__.define(option_name, ...).build!
      end

      private

      # Handles attribute inheritance when a class is subclassed.
      # Ensures the subclass gets its own builder and copies of parent's attributes.
      #
      # @param subclass [Class] The class inheriting from this one
      # @return [void]
      # @rbs (untyped subclass) -> void
      def inherited(subclass)
        super
        subclass.instance_variable_set(:@__builder__, __builder__.dup_with_base(subclass))
        subclass.send(:__builder__).build!
      end

      # Gets the attribute definitions hash, creating it if needed.
      #
      # @return [Hash{Symbol => AttributeDefinition}] hash of attribute definitions
      # @rbs () -> Hash[Symbol, AttributeDefinition]
      def __attribute_definitions__
        @__attribute_definitions__ ||= {}
      end

      # Gets the builder instance for this class, creating it if needed.
      #
      # @return [Builder] the builder instance for this class
      # @rbs () -> Builder
      def __builder__
        @__builder__ ||= Builder.new(self)
      end
    end
  end
end
