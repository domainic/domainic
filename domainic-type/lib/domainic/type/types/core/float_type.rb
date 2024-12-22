# frozen_string_literal: true

require 'domainic/type/behavior'
require 'domainic/type/behavior/numeric_behavior'

module Domainic
  module Type
    # A type for validating Float objects with extensive numeric validation capabilities.
    #
    # This class provides a comprehensive set of validations specifically designed for
    # floating-point values, including basic type checking and all numeric validations
    # like finiteness, polarity, and range constraints. It properly handles floating-point
    # arithmetic by using appropriate tolerances in comparisons.
    #
    # @example Basic usage
    #   type = FloatType.new
    #   type.validate(3.14)   # => true
    #   type.validate(42)     # => false
    #   type.validate("3.14") # => false
    #
    # @example With numeric constraints
    #   type = FloatType.new
    #   type
    #     .being_positive
    #     .being_finite
    #     .being_less_than(10.0)
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class FloatType
      # @rbs! extend Behavior::ClassMethods

      include Behavior
      include Behavior::NumericBehavior

      intrinsic :self, :type, Float, abort_on_failure: true, description: :not_described
    end
  end
end
