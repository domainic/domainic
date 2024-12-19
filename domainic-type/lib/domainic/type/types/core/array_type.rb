# frozen_string_literal: true

require 'domainic/type/behavior'
require 'domainic/type/behavior/enumerable_behavior'

module Domainic
  module Type
    # @since 0.1.0
    class ArrayType
      # @rbs! extend Behavior::ClassMethods

      include Behavior
      include Behavior::EnumerableBehavior

      intrinsic :self, :type, Array, abort_on_failure: true, description: :not_described
    end
  end
end
