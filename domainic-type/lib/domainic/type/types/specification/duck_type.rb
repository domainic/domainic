# frozen_string_literal: true

require 'domainic/type/behavior'

module Domainic
  module Type
    # A type that validates objects based on their method interface
    #
    # This type implements duck typing validation by checking whether objects respond
    # to specific methods. It supports both positive validation (must respond to methods)
    # and negative validation (must not respond to methods).
    #
    # @example Validating a simple interface
    #   type = DuckType.responding_to(:to_s).not_responding_to(:to_h)
    #   type.validate("string")  # => true
    #   type.validate(Object.new)  # => true
    #   type.validate({})  # => false (responds to :to_h)
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class DuckType
      include Behavior

      # Add method exclusion constraints to the type
      #
      # @example
      #   type = DuckType.new.not_responding_to(:foo, :bar)
      #
      # @param methods [Array<String, Symbol>] the methods that must not be present
      #
      # @return [self] the type for method chaining
      # @rbs (*String | Symbol methods) -> self
      def not_responding_to(*methods)
        not_methods = methods.map do |method|
          @constraints.prepare(:self, :not, @constraints.prepare(:self, :method_presence, method))
        end
        constrain :self, :and, not_methods, concerning: :method_exclusion
      end

      # Add method presence constraints to the type
      #
      # @example
      #   type = DuckType.new.responding_to(:foo, :bar)
      #
      # @param methods [Array<String, Symbol>] the methods that must be present
      #
      # @return [self] the type for method chaining
      # @rbs (*String | Symbol methods) -> self
      def responding_to(*methods)
        methods = methods.map { |method| @constraints.prepare :self, :method_presence, method }
        constrain :self, :and, methods, concerning: :method_presence
      end
    end
  end
end
