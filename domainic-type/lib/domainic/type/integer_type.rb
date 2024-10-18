# frozen_string_literal: true

require_relative 'numeric_type'

module Domainic
  module Type
    # @since 0.1.0
    class IntegerType < NumericType
      constrain :self do
        intrinsic_constraint :type, expected: Integer, fail_fast: true

        constraint :parity
        constraint :polarity

        bind_method :being_even do
          desc 'Constrains the integer to be even.'
          concerning :parity

          configure { |boolean = true| { condition: :even, negated: !boolean } }
        end

        bind_method :being_odd do
          desc 'Constrains the integer to be odd.'
          concerning :parity

          configure { |boolean = true| { condition: :odd, negated: !boolean } }
        end
      end
    end
  end
end
