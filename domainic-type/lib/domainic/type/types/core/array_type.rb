# frozen_string_literal: true

require 'domainic/type/behavior'
require 'domainic/type/behavior/enumerable_behavior'

module Domainic
  module Type
    # A type for validating Array objects with flexible element and size constraints
    #
    # This class provides a comprehensive set of validations specifically designed for Array
    # objects, including element type checking, value inclusion/exclusion, ordering, and all
    # standard enumerable validations.
    #
    # Key features:
    # - Element type validation
    # - Element presence/absence validation
    # - Uniqueness constraints
    # - Order constraints
    # - Size constraints (via EnumerableBehavior)
    # - Standard collection validations (via EnumerableBehavior)
    #
    # @example Basic usage
    #   type = ArrayType.new
    #   type.of(String)                # enforce element type
    #   type.containing(1, 2)          # require specific elements
    #   type.having_size(3)            # exact size constraint
    #   type.being_distinct            # unique elements
    #
    # @example Complex constraints
    #   type = ArrayType.new
    #   type
    #     .of(Integer)                 # type constraints
    #     .being_ordered               # must be sorted
    #     .having_size_between(2, 5)   # size range
    #     .starting_with(1)            # first element
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class ArrayType
      # @rbs! extend Behavior::ClassMethods

      include Behavior
      include Behavior::EnumerableBehavior

      intrinsically_constrain :self, :type, Array, abort_on_failure: true, description: :not_described
    end
  end
end
