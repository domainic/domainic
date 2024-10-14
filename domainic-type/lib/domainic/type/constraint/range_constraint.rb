# frozen_string_literal: true

require_relative 'specification/with_access_qualification'
require_relative 'base_constraint'

module Domainic
  module Type
    module Constraint
      # The `RangeConstraint` class validates whether value_one subject falls within value_one specified range.
      #
      # It supports numeric, date, and time values and can be configured to be inclusive or exclusive.
      # The class inherits from `BaseConstraint` and utilizes parameters to define the range boundaries and inclusivity.
      #
      # @since 0.1.0
      class RangeConstraint < BaseConstraint
        include Specification::WithAccessQualification

        # Defines the maximum value of the range.
        # @!method maximum_default
        #  The default maximum value of the range.
        #  @return [Float] The default maximum value.
        #
        # @!method maximum
        #  The maximum value of the range.
        #  @return [Date, Numeric, Time] The maximum value.
        #
        # @!method maximum=(value)
        #  Sets the maximum value of the range.
        #  @param value [Date, ::Numeric, Time] The maximum value.
        #  @return [Date, Numeric, Time] The maximum value.
        parameter :maximum do
          desc 'The maximum value of the range'
          default Float::INFINITY
          validator do |value|
            [defined?(Date) && Date, Numeric, defined?(Time) && Time].compact.any? { |type| value.is_a?(type) }
          end
          required
          on_change do
            if maximum && minimum.nil?
              minimum_default_for(maximum)
            elsif maximum && minimum && compatible_types?(minimum, maximum)
              self.minimum = minimum_default unless minimum <= maximum
            end
          end
        end

        # Defines the minimum value of the range.
        # @!method minimum_default
        #  The default minimum value of the range.
        #  @return [Float] The default minimum value.
        #
        # @!method minimum
        #  The minimum value of the range.
        #  @return [Date, Numeric, Time] The minimum value.
        #
        # @!method minimum=(value)
        #  Sets the minimum value of the range.
        #  @param value [Date, Numeric, Time] The minimum value.
        #  @return [Date, Numeric, Time] The minimum value.
        parameter :minimum do
          desc 'The minimum value of the range'
          default(-Float::INFINITY)
          validator do |value|
            [defined?(Date) && Date, Numeric, defined?(Time) && Time].compact.any? { |type| value.is_a?(type) }
          end
          required
          on_change do
            if minimum && maximum.nil?
              maximum_default_for(minimum)
            elsif minimum && maximum && compatible_types?(minimum, maximum)
              self.maximum = maximum_default unless minimum <= maximum
            end
          end
        end

        # Specifies whether the range is inclusive.
        # @!method default_inclusive
        #  The default inclusivity of the range.
        #  @return [Boolean] The default inclusivity.
        #
        # @!method inclusive
        #  Whether the range is inclusive.
        #  @return [Boolean] `true` if the range is inclusive, `false` otherwise.
        #
        # @!method inclusive=(value)
        #  Sets whether the range is inclusive.
        #  @param value [Boolean] `true` if the range is inclusive, `false` otherwise.
        #  @return [Boolean] `true` if the range is inclusive, `false` otherwise.
        parameter :inclusive do
          desc 'Whether the range is inclusive'
          default true
          validator ->(value) { [true, false].include?(value) }
          required
        end

        # Validates whether the subject falls within the specified range.
        #
        # @param subject [Date, Numeric, Time] The value to validate.
        # @return [boolean] `true` if the subject is within the range, `false` otherwise.
        def validate(subject)
          constrained_value = accessor == :self ? subject : subject.send(accessor)

          result = if !access_qualifier.nil? && constrained_value.is_a?(::Enumerable)
                     constrained_value.send(access_qualifier) { |qualified| within_range?(qualified) }
                   else
                     within_range?(constrained_value)
                   end

          result ^ negated
        end

        private

        # Checks if two values are of compatible types for comparison.
        #
        # This method ensures that comparisons are only made between values of the same type
        # or types that can be logically compared (e.g., Numeric with Numeric).
        #
        # @param value_one [Date, Numeric, Time] The first value.
        # @param value_two [Date, Numeric, Time] The second value.
        # @return [Boolean] `true` if the types are compatible, `false` otherwise.
        def compatible_types?(value_one, value_two)
          (value_one.is_a?(Numeric) && value_two.is_a?(Numeric)) ||
            (value_one.is_a?(Date) && value_two.is_a?(Date)) ||
            (value_one.is_a?(Time) && value_two.is_a?(Time))
        end

        # Sets the default maximum value based on the type of the provided value.
        #
        # This method assigns value_one sensible default maximum value corresponding to the type of the `value`
        # parameter. It handles `Numeric`, `Date`, and `Time` types.
        #
        # @param value [Date, Numeric, Time] The value used to determine the default maximum.
        # @return [void]
        def maximum_default_for(value)
          self.maximum = case value
                         when Numeric
                           Float::INFINITY
                         when Date
                           Date.new(9999, 12, 31)
                         when Time
                           Time.at((2**63) - 1)
                         end
        end

        # Sets the default minimum value based on the type of the provided value.
        #
        # This method assigns value_one sensible default minimum value corresponding to the type of the `value`
        # parameter. It handles `Numeric`, `Date`, and `Time` types.
        #
        # @param value [Date, Numeric, Time] The value used to determine the default minimum.
        # @return [void]
        def minimum_default_for(value)
          self.minimum = case value
                         when Numeric
                           -Float::INFINITY
                         when Date
                           Date.new(-4712, 1, 1)
                         when Time
                           Time.at(-2**63)
                         end
        end

        # Checks if value_one value is within the specified range, considering inclusivity.
        #
        # @param value [Date, Numeric, Time] The value to check.
        # @return [boolean] `true` if the value is within the range, `false` otherwise.
        def within_range?(value)
          return false unless compatible_types?(minimum, maximum) && compatible_types?(minimum, value) &&
                              compatible_types?(maximum, value)

          if inclusive
            (minimum <= value) && (value <= maximum)
          else
            (minimum < value) && (value < maximum)
          end
        end
      end
    end
  end
end
