# frozen_string_literal: true

require 'domainic/type/behavior'
require 'domainic/type/behavior/numeric_behavior'

module Domainic
  module Type
    # @since 0.1.0
    class IntegerType
      include Behavior
      include NumericBehavior

      intrinsic :self, :type, :type, Integer, abort_on_failure: true
    end
  end
end
