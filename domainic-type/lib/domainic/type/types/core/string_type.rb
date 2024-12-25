# frozen_string_literal: true

require 'domainic/type/behavior'
require 'domainic/type/behavior/string_behavior'

module Domainic
  module Type
    # A type for validating String objects with comprehensive string-specific constraints
    #
    # This type provides a complete set of string validation capabilities including case
    # formatting, character set validation, pattern matching, and size constraints. It
    # combines core string type checking with rich string-specific behaviors.
    #
    # Key features:
    # - Basic string type validation
    # - Case checking (upper, lower, mixed, title)
    # - Character set validation (ASCII, alphanumeric, etc.)
    # - Pattern matching with regular expressions
    # - Size/length constraints
    # - String content validation
    #
    # @example Basic usage
    #   type = StringType.new
    #   type.validate("hello")   # => true
    #   type.validate(123)       # => false
    #
    # @example Complex string validation
    #   type = StringType.new
    #     .being_ascii
    #     .being_alphanumeric
    #     .having_size_between(3, 20)
    #     .not_matching(/[^a-z0-9]/)
    #
    # @example Case validation
    #   type = StringType.new
    #     .being_titlecase
    #     .matching(/^[A-Z]/)
    #     .having_minimum_size(2)
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class StringType
      # @rbs! extend Behavior::ClassMethods

      include Behavior
      include Behavior::StringBehavior

      intrinsically_constrain :self, :type, String, abort_on_failure: true, description: :not_described
    end
  end
end
