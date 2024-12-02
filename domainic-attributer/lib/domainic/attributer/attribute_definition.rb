# frozen_string_literal: true

module Domainic
  module Attributer
    # An AttributeDefinition combines an Attribute with its accessor method visibility settings.
    # This allows the builder to generate appropriately scoped reader and writer methods
    # for each attribute.
    #
    # @since 0.1.0
    class AttributeDefinition
      # @rbs @attribute: Attribute
      # @rbs @read_access: :public | :private
      # @rbs @write_access: :public | :private

      # The Attribute being defined.
      #
      # @return [Attribute] the underlying attribute.
      attr_reader :attribute #: Attribute

      # rubocop:disable Yard/TagTypeSyntax

      # The visibility level for the reader method.
      #
      # @return [:public, :private] the reader method visibility.
      attr_reader :read_access #: :public | :private

      # The visibility level for the writer method.
      #
      # @return [:public, :private] the writer method visibility.
      attr_reader :write_access #: :public | :private

      # Initializes a new AttributeDefinition.
      #
      # @param attribute [Attribute] The attribute to define.
      # @param reader [:public, :private] The visibility level for the reader method.
      # @param writer [:public, :private] The visibility level for the writer method.
      # @return [AttributeDefinition] the new instance of AttributeDefinition.
      # @rbs (Attribute attribute, ?reader: :public | :private, ?writer: :public | :private) -> void
      def initialize(attribute, reader: :public, writer: :public)
        valid_accessors = %i[public private]
        raise ArgumentError, "Invalid reader access: #{reader}" unless valid_accessors.include?(reader)
        raise ArgumentError, "Invalid writer access: #{writer}" unless valid_accessors.include?(writer)

        @attribute = attribute
        @read_access = reader
        @write_access = writer
      end

      # rubocop:enable Yard/TagTypeSyntax
    end
  end
end
