# frozen_string_literal: true

require_relative 'ordered_enumerable_type'

module Domainic
  module Type
    # The `ArrayType` is a type that represents an array.
    #
    # @since 0.1.0
    class ArrayType < OrderedEnumerableType
      constrain :self do
        intrinsic_constraint :type, expected: Array, fail_fast: true
      end
    end
  end
end
