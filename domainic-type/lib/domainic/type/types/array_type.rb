# frozen_string_literal: true

require 'domainic/type/behavior'
require 'domainic/type/behavior/enumerable_behavior'

module Domainic
  module Type
    # @since 0.1.0
    class ArrayType
      include Behavior
      include EnumerableBehavior

      intrinsic :self, :type, :type, Array, abort_on_failure: true
    end
  end
end
