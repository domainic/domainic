# frozen_string_literal: true

require 'domainic/command/context/attribute'
require 'domainic/command/context/attribute_set'

module Domainic
  module Command
    module Context
      # @since 0.1.0
      module Behavior
        def self.included(base)
          base.extend(ClassMethods)
        end

        # @since 0.1.0
        module ClassMethods
          # @rbs @attributes: AttributeSet

          private

          # @rbs (
          #   String | Symbol name,
          #   ?(String | Attribute::type_validator)? type_validator_or_description,
          #   ?(String | Attribute::type_validator)? description_or_type_validator,
          #   ?default: untyped?,
          #   ?default_generator: untyped?,
          #   ?default_value: untyped?,
          #   ?desc: String?,
          #   ?description: String?,
          #   ?required: bool?,
          #   ?type: type_validator?
          #   ) -> void
          def attribute(...)
            # @type self: Class & Behavior::ClassMethods
            attribute = Attribute.new(...)
            attributes.add(attribute)
            attr_reader attribute.name
          end

          # @rbs () -> AttributeSet
          def attributes
            @attributes ||= AttributeSet.new
          end

          # @rbs (Class subclass) -> void
          def inherited(subclass)
            super
            subclass.instance_variable_set(:@attributes, attributes.dup)
          end
        end

        # @rbs (**untyped options) -> void
        def initialize(**options)
          options = options.transform_keys(&:to_sym)

          self.class.send(:attributes).each do |attribute|
            value = options.fetch(attribute.name) { attribute.default if attribute.default? }
            attribute.validate!(value)

            instance_variable_set(:"@#{attribute.name}", value)
          end
        end

        # @rbs () -> Hash[Symbol, untyped]
        def to_hash
          self.class.send(:attributes).each_with_object({}) do |attribute, hash|
            hash[attribute.name] = instance_variable_get(:"@#{attribute.name}")
          end
        end
        alias to_h to_hash
      end
    end
  end
end
