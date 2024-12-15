# frozen_string_literal: true

module Domainic
  module Type
    module Behavior
      # @since 0.1.0
      # @rbs module-self Behavior
      module NumericBehavior
        # @todo: We need to grab the default tolerance off the DivisibilityConstraint
        #   without loading the constraint itself. We should probably move constants into
        #   a shared module called Domainic::Type::Defaults or something...
        # @rbs (Numeric divisor, ?tolerance: Float) -> NumericBehavior
        def being_divisible_by(divisor, tolerance: 1e-10)
          add_constraint :self, :divisibility, :divisibility, divisor, tolerance:
        end
        alias being_multiple_of being_divisible_by

        def being_greater_than(minimum)
          add_constraint :self, :size, :range, { minimum: minimum }
        end

        def being_less_than(maximum)
          add_constraint :self, :size, :range, { maximum: maximum }
        end
      end
    end
  end
end
