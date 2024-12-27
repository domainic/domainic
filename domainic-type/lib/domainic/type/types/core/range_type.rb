# frozen_string_literal: true

require 'domainic/type/behavior'
require 'domainic/type/behavior/enumerable_behavior'

module Domainic
  module Type
    # A type for validating `Range` objects with comprehensive constraints.
    #
    # This class allows flexible validation of ranges, supporting type checks,
    # inclusion/exclusion of values, and range-specific behaviors such as bounds validation.
    # It integrates with `EnumerableBehavior` for enumerable-style validations
    # (e.g., size constraints, element presence).
    #
    # Key features:
    # - Ensures the value is a `Range`.
    # - Supports constraints for range boundaries (`begin` and `end`).
    # - Provides validations for inclusion and exclusion of values.
    # - Leverages `EnumerableBehavior` for size and collection-style constraints.
    #
    # @example Basic usage
    #   type = RangeType.new
    #   type.having_bounds(1, 10)         # Validates range bounds (inclusive or exclusive).
    #   type.containing(5)               # Ensures value is within the range.
    #   type.not_containing(15)          # Ensures value is not within the range.
    #
    # @example Integration with EnumerableBehavior
    #   type = RangeType.new
    #   type.having_size(10)             # Validates size (total elements in the range).
    #   type.containing_exactly(3, 7)    # Validates specific values within the range.
    #
    # @example Flexible boundaries
    #   type = RangeType.new
    #   type.having_bounds(1, 10, exclusive: true)  # Upper and lower bounds are exclusive.
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class RangeType
      # @rbs! extend Behavior::ClassMethods

      include Behavior
      include Behavior::EnumerableBehavior

      intrinsically_constrain :self, :type, Range, abort_on_failure: true, description: :not_described
    end
  end
end
