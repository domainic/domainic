# frozen_string_literal: true

require 'domainic/type/behavior'
require 'domainic/type/behavior/numeric_behavior'

module Domainic
  module Type
    # A type for validating Integer objects with extensive numeric validation capabilities.
    #
    # This class provides a comprehensive set of validations specifically designed for
    # integer values, including basic type checking and all numeric validations like
    # divisibility, parity, polarity, and range constraints.
    #
    # @example Basic usage
    #   type = IntegerType.new
    #   type.validate(42)     # => true
    #   type.validate(3.14)   # => false
    #   type.validate("42")   # => false
    #
    # @example With numeric constraints
    #   type = IntegerType.new
    #   type
    #     .being_positive
    #     .being_even
    #     .being_less_than(100)
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class IntegerType
      # @rbs! extend Behavior::ClassMethods

      include Behavior
      include Behavior::NumericBehavior

      intrinsic :self, :type, Integer, abort_on_failure: true, description: :not_described
    end
  end
end
