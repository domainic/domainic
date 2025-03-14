# frozen_string_literal: true

require 'domainic/type/behavior'
require 'domainic/type/behavior/string_behavior'

module Domainic
  module Type
    # A type for validating Symbol objects with string-like constraints
    #
    # This type provides symbol validation capabilities by leveraging string validation
    # behaviors. It enables validation of symbols using string-based constraints while
    # maintaining proper type checking for Symbol objects.
    #
    # Key features:
    # - Basic symbol type validation
    # - Case checking for symbol names
    # - Character set validation for symbol names
    # - Pattern matching against symbol names
    # - Length constraints for symbol names
    # - String content validation for symbol names
    #
    # @example Basic usage
    #   type = SymbolType.new
    #   type.validate(:hello)   # => true
    #   type.validate("hello")  # => false
    #
    # @example Complex symbol validation
    #   type = SymbolType.new
    #     .being_ascii
    #     .being_lowercase
    #     .having_size_between(2, 30)
    #     .matching(/^[a-z]/)
    #
    # @example Symbol name validation
    #   type = SymbolType.new
    #     .being_alphanumeric
    #     .not_matching(/\W/)
    #     .having_minimum_size(1)
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class SymbolType
      # @rbs! extend Behavior::ClassMethods

      include Behavior
      include Behavior::StringBehavior

      intrinsically_constrain :self, :type, Symbol, abort_on_failure: true, description: :not_described
    end
  end
end
