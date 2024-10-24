# frozen_string_literal: true

require_relative '../../type'
require_relative 'attribute'
require_relative 'attribute_options_parser'

unless Domainic::Type.config.global_prefix_enabled?
  Domainic::Type.configure { |config| config.eager_load_type_group(:ruby_core) }
  require_relative '../definition'
end

module Domainic
  module Type
    module Schema
      # @since 0.1.0
      class Object
        extend Definition unless Domainic::Type.config.global_prefix_enabled?

        class << self
          def attribute(name, type_or_description = nil, description_or_type = nil, **options)
            attribute = Attribute.new(self, name, type_or_description, description_or_type, **options)
            @attributes = attributes.merge(attribute.name => attribute)
            attr_reader attribute.name
          end

          def attributes
            @attributes ||= {}.freeze
          end
        end

        def initialize(**options)
          attributes = self.class.attributes.transform_values { |attribute| attribute.dup_with_base(self) }
          AttributeOptionsParser.new(self, attributes, options).parse!.each_pair do |name, value|
            instance_variable_set(:"@#{name}", value)
          end
        end
      end
    end
  end
end
