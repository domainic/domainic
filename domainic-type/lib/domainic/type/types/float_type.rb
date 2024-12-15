# frozen_string_literal: true

require 'domainic/type/behavior'
require 'domainic/type/behavior/numeric_behavior'

module Domainic
  module Type
    # @since 0.1.0
    class FloatType
      include Behavior
      include NumericBehavior

      intrinsic :self, :type, :type, Float, abort_on_failure: true
    end
  end
end
