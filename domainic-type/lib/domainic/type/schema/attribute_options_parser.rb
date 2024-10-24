# frozen_string_literal: true

require_relative '../errors'

module Domainic
  module Type
    module Schema
      # @since 0.1.0
      class AttributeOptionsParser
        def initialize(base, attributes, options)
          @base = base
          @attributes = attributes
          @options = options.transform_keys(&:to_sym)
          @invalid_attributes = []
          @missing_attributes = []
          @unknown_attributes = @options.keys
          @result = {}
        end

        def parse!
          parse_attributes
          aggregate_and_raise_errors!
          @result
        end

        private

        def aggregate_and_raise_errors!
          return if @invalid_attributes.empty? && @missing_attributes.empty? && @unknown_attributes.empty?

          raise InvalidObjectError, build_error_message
        end

        def build_error_message
          message = "Invalid #{@base.class.name}\n#{@base.class.name} was given invalid attributes and has the " \
                    "following errors:\n"
          build_error_message_lists(message)
        end

        def build_error_message_lists(message)
          error_sections = {
            'Invalid attributes' => @invalid_attributes,
            'Missing attributes' => @missing_attributes,
            'Unknown attributes' => @unknown_attributes
          }
          error_sections.each do |section_title, attributes|
            next if attributes.empty?

            message += "#{section_title}:\n  - #{attributes.join("\n  - ")}\n"
          end
          message
        end

        def parse_attribute(attribute)
          value = @options[attribute.name]
          value = attribute.default if value.nil? && attribute.default?
          if value.nil? && attribute.required?
            @missing_attributes << attribute.name
          elsif !attribute.validate(value)
            @invalid_attributes << attribute.name
          else
            @result[attribute.name] = value
          end
        end

        def parse_attributes
          @attributes.each_pair do |attribute_name, attribute|
            if @unknown_attributes.delete(attribute_name)
              parse_attribute(attribute)
            elsif attribute.required?
              @missing_attributes << attribute_name
            end
          end
        end
      end
    end
  end
end
