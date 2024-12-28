# frozen_string_literal: true

module Domainic
  module Command
    module Context
      # @since 0.1.0
      class RuntimeContext
        # @rbs @data: Hash[Symbol, untyped]

        # @rbs (**untyped options) -> void
        def initialize(**options)
          @data = options.transform_keys(&:to_sym)
        end

        # @rbs (String | Symbol attribute_name) -> untyped
        def [](attribute_name)
          read_from_attribute(attribute_name)
        end

        # @rbs (String | Symbol attribute_name, untyped value) -> untyped
        def []=(attribute_name, value)
          write_to_attribute(attribute_name, value)
        end

        # @rbs () -> Hash[Symbol, untyped]
        def to_hash
          @data.transform_values do |value|
            value.is_a?(Class) || value.is_a?(Module) ? value : value.dup
          end
        end
        alias to_h to_hash

        private

        # @rbs (Symbol method_name, *untyped arguments, **untyped keyword_arguments) ?{ (?) -> untyped } -> untyped
        def method_missing(method_name, ...)
          return super unless respond_to_missing?(method_name)

          if method_name.to_s.end_with?('=')
            write_to_attribute(method_name.to_s.delete_suffix('=').to_sym, ...)
          else
            @data[method_name]
          end
        end

        # @rbs (String | Symbol attribute_name) -> untyped
        def read_from_attribute(attribute_name)
          @data[attribute_name.to_sym]
        end

        # @rbs (Symbol method_name, ?bool include_private) -> bool
        def respond_to_missing?(method_name, _include_private = false)
          return true if method_name.to_s.end_with?('=')
          return true if @date.key?(method_name)

          super
        end

        # @rbs (String | Symbol attribute_name, untyped value) -> untyped
        def write_to_attribute(attribute_name, value)
          @data[attribute_name.to_sym] = value
        end
      end
    end
  end
end
