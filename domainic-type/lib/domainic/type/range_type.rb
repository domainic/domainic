# frozen_string_literal: true

require_relative 'ordered_enumerable_type'

module Domainic
  module Type
    # @since 0.1.0
    class RangeType < OrderedEnumerableType
      constrain :self do
        intrinsic_constraint :type, expected: Range, fail_fast: true
      end
    end
  end
end
