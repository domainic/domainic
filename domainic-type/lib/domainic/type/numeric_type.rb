# frozen_string_literal: true

require_relative 'base_type'

module Domainic
  module Type
    # @since 0.1.0
    class NumericType < BaseType
      constrain :self do
        constraint :divisibility
        constraint :equality
        constraint :finiteness
        constraint :polarity
        constraint :range

        bind_method :being_divisible_by do
          desc 'Constrains the value to be divisible by the given number.'
          concerning :divisibility
          aliases :being_multiple_of

          configure { |value| { expected: value } }
        end

        bind_method :being_equal_to do
          desc 'Constrains the value to be equal to the given number.'
          concerning :equality

          configure { |value| { expected: value } }
        end

        bind_method :being_finite do
          desc 'Constrains the value to be finite.'
          concerning :finiteness

          configure { |boolean = true| { condition: :finite, negated: !boolean } }
        end

        bind_method :being_infinite do
          desc 'Constrains the value to be infinite.'
          concerning :finiteness

          configure { |boolean = true| { condition: :infinite, negated: !boolean } }
        end

        bind_method :being_greater_than do
          desc 'Constrains the value to be greater than the given number.'
          concerning :range
          aliases :being_more_than, :gt, :greater_than

          configure { |value| { minimum: value, inclusive: false } }
        end

        bind_method :being_greater_than_or_equal_to do
          desc 'Constrains the value to be greater than or equal to the given number.'
          concerning :range
          aliases :being_more_than_or_equal_to, :gte, :gteq, :greater_than_or_equal_to

          configure { |value| { minimum: value, inclusive: true } }
        end

        bind_method :being_less_than do
          desc 'Constrains the value to be less than the given number.'
          concerning :range
          aliases :being_less_than, :lt, :less_than

          configure { |value| { maximum: value, inclusive: false } }
        end

        bind_method :being_less_than_or_equal_to do
          desc 'Constrains the value to be less than or equal to the given number.'
          concerning :range
          aliases :being_less_than_or_equal_to, :lte, :lteq, :less_than_or_equal_to

          configure { |value| { maximum: value, inclusive: true } }
        end

        bind_method :being_positive do
          desc 'Constrains the value to be positive.'
          concerning :polarity

          configure { |boolean = true| { condition: :positive, negated: !boolean } }
        end

        bind_method :being_negative do
          desc 'Constrains the value to be negative.'
          concerning :polarity

          configure { |boolean = true| { condition: :negative, negated: !boolean } }
        end
      end
    end
  end
end
