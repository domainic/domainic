# frozen_string_literal: true

module Domainic
  module Command
    module Context
      # A flexible context class for managing command state during execution. This class provides a dynamic
      # storage mechanism for command data, allowing both hash-style and method-style access to values.
      #
      # The RuntimeContext serves as a mutable workspace during command execution, bridging the gap between
      # input parameters and output values. It automatically handles type coercion of keys to symbols and
      # provides safe value duplication when converting to a hash.
      #
      # @example Hash-style access
      #   context = RuntimeContext.new(count: 1)
      #   context[:count] #=> 1
      #   context[:count] = 2
      #   context[:count] #=> 2
      #
      # @example Method-style access
      #   context = RuntimeContext.new(name: "test")
      #   context.name #=> "test"
      #   context.name = "new test"
      #   context.name #=> "new test"
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class RuntimeContext
        # @rbs @data: Hash[Symbol, untyped]

        # Creates a new RuntimeContext with the given options
        #
        # @param options [Hash] Initial values for the context
        #
        # @return [RuntimeContext]
        # @rbs (**untyped options) -> void
        def initialize(**options)
          @data = options.transform_keys(&:to_sym)
        end

        # Retrieves a value by its attribute name
        #
        # @param attribute_name [String, Symbol] The name of the attribute to retrieve
        #
        # @return [Object, nil] The value associated with the attribute name
        # @rbs (String | Symbol attribute_name) -> untyped
        def [](attribute_name)
          read_from_attribute(attribute_name)
        end

        # Sets a value for the given attribute name
        #
        # @param attribute_name [String, Symbol] The name of the attribute to set
        # @param value [Object] The value to store
        #
        # @return [Object] The stored value
        # @rbs (String | Symbol attribute_name, untyped value) -> untyped
        def []=(attribute_name, value)
          write_to_attribute(attribute_name, value)
        end

        # Converts the context to a hash, duplicating values where appropriate
        #
        # @note Class and Module values are not duplicated to prevent potential issues
        #
        # @return [Hash{Symbol => Object}] A hash containing all stored values
        # @rbs () -> Hash[Symbol, untyped]
        def to_hash
          @data.transform_values do |value|
            value.is_a?(Class) || value.is_a?(Module) ? value : value.dup
          end
        end
        alias to_h to_hash

        private

        # Handles dynamic method calls for reading and writing attributes
        #
        # @return [Object, nil]
        # @rbs override
        def method_missing(method_name, ...)
          return super unless respond_to_missing?(method_name)

          if method_name.to_s.end_with?('=')
            write_to_attribute(method_name.to_s.delete_suffix('=').to_sym, ...)
          else
            @data[method_name]
          end
        end

        # Reads a value from the internal storage
        #
        # @param attribute_name [String, Symbol] The name of the attribute to read
        #
        # @return [Object, nil] The stored value
        # @rbs (String | Symbol attribute_name) -> untyped
        def read_from_attribute(attribute_name)
          @data[attribute_name.to_sym]
        end

        # Determines if a method name can be handled dynamically
        #
        # @param method_name [Symbol] The name of the method to check
        # @param _include_private [Boolean] Whether to include private methods
        #
        # @return [Boolean] Whether the method can be handled
        # @rbs (String | Symbol method_name, ?bool _include_private) -> bool
        def respond_to_missing?(method_name, _include_private = false)
          return true if method_name.to_s.end_with?('=')
          return true if @data.key?(method_name.to_sym)

          super
        end

        # Writes a value to the internal storage
        #
        # @param attribute_name [String, Symbol] The name of the attribute to write
        # @param value [Object] The value to store
        # @return [Object] The stored value
        # @rbs (String | Symbol attribute_name, untyped value) -> untyped
        def write_to_attribute(attribute_name, value)
          @data[attribute_name.to_sym] = value
        end
      end
    end
  end
end
