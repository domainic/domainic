# frozen_string_literal: true

module Domainic
  module Type
    module Schema
      # @since 0.1.0
      class Attribute
        attr_reader :description, :name

        def initialize(base, name, type_or_description = nil, description_or_type = nil, **options)
          @base = base
          @coercer = options.fetch(:coercer, ->(value) { value })
          @default = options.fetch(:default, UNSPECIFIED)
          @description = initialize_description(type_or_description, description_or_type, **options)
          @name = name.to_sym
          @required = options.fetch(:required, false)
          @type = initialize_type(type_or_description, description_or_type, **options)
        end

        def default
          @default == UNSPECIFIED ? nil : @default
        end

        def default?
          @default != UNSPECIFIED
        end

        def dup_with_base(new_base)
          dup.tap { |duped| duped.instance_variable_set(:@base, new_base) }
        end

        def required?
          @required
        end

        def validate(subject)
          value = coerce_value(subject)

          @type.is_a?(Domainic::Type::BaseType) ? @type.validate(value) : value.is_a?(@type)
        end

        private

        def coerce_value(value)
          return @coercer.call(value) if @coercer.is_a?(Proc)
          return @base.send(@coercer, value) if @coercer.is_a?(Symbol) && @base.respond_to?(@coercer, true)
          if true.equal?(@coercer) && @base.respond_to?(:"coerce_#{name}", true)
            return @base.send(:"coerce_#{name}", value)
          end

          value
        end

        def initialize_description(*arguments, **options)
          arguments.find { |arg| arg.is_a?(String) } || options[:description] || options[:desc] || ''
        end

        def initialize_type(*arguments, **options)
          arguments.find { |arg| arg.is_a?(Class) || arg.is_a?(Domainic::Type::BaseType) } || options[:type]
        end
      end
    end
  end
end
