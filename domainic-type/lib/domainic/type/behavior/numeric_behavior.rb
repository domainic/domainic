# frozen_string_literal: true

module Domainic
  module Type
    module Behavior
      # A module providing numeric-specific validation behaviors for types.
      #
      # This module extends the base Type::Behavior with methods specifically designed for validating numeric values.
      # It provides a fluent interface for common numeric validations such as divisibility, equality, parity, polarity,
      # and range constraints. These methods support a variety of constraints and chaining for flexibility in validation
      # logic.
      #
      # @example Basic usage
      #   class NumericType
      #     include Domainic::Type::Behavior::NumericBehavior
      #
      #     def initialize
      #       super
      #       being_positive                  # validates that the value is positive
      #       being_divisible_by(5)          # validates that the value is divisible by 5
      #     end
      #   end
      #
      # @example Combining constraints
      #   class AdvancedNumericType
      #     include Domainic::Type::Behavior::NumericBehavior
      #
      #     def initialize
      #       super
      #       being_finite
      #       being_greater_than_or_equal_to(0)
      #       being_less_than(100)
      #     end
      #   end
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      module NumericBehavior
        # Constrain the numeric value to be divisible by a given divisor.
        #
        # @example
        #   type.being_divisible_by(3)
        #   type.validate(9)  # => true
        #   type.validate(10) # => false
        #
        # @note the divisor MUST be provided as an argument or in the options Hash.
        #
        # @param arguments [Array<Numeric>] a list of arguments, typically one divisor
        # @param options [Hash] additional options such as tolerance for floating-point checks
        # @option options [Numeric] :divisor the divisor to check for divisibility
        # @option options [Numeric] :tolerance the tolerance for floating-point checks
        #
        # @return [self] the current instance for chaining
        # @rbs (*Numeric arguments, ?divisor: Numeric, ?tolerance: Numeric) -> Behavior
        def being_divisible_by(*arguments, **options)
          if arguments.size > 1 || (arguments.empty? && !options.key?(:divisor))
            raise ArgumentError, "wrong number of arguments (given #{arguments.size}, expected 1)"
          end

          # @type self: Object & Behavior
          divisor = arguments.first || options[:divisor]
          constrain :self, :divisibility, divisor, description: 'being', **options.except(:divisor)
        end
        alias being_multiple_of being_divisible_by
        alias divisible_by being_divisible_by
        alias multiple_of being_divisible_by

        # Constrain the numeric value to equal a specific number.
        #
        # @example
        #   type.being_equal_to(42)
        #   type.validate(42) # => true
        #   type.validate(7)  # => false
        #
        # @param numeric [Numeric] the number to constrain equality to
        #
        # @return [self] the current instance for chaining
        # @rbs (Numeric numeric) -> Behavior
        def being_equal_to(numeric)
          # @type self: Object & Behavior
          constrain :self, :equality, numeric, description: 'being'
        end
        alias eql being_equal_to
        alias equal_to being_equal_to
        alias equaling being_equal_to

        # Constrain the numeric value to be even.
        #
        # @example
        #   type.being_even
        #   type.validate(4) # => true
        #   type.validate(3) # => false
        #
        # @return [self] the current instance for chaining
        # @rbs () -> Behavior
        def being_even
          # @type self: Object & Behavior
          constrain :self, :parity, :even, description: 'being'
        end
        alias even being_even
        alias not_being_odd being_even

        # Constrain the numeric value to be finite.
        #
        # @example
        #   type.being_finite
        #   type.validate(42)              # => true
        #   type.validate(Float::INFINITY) # => false
        #
        # @return [self] the current instance for chaining
        # @rbs () -> Behavior
        def being_finite
          # @type self: Object & Behavior
          constrain :self, :finiteness, :finite, description: 'being'
        end
        alias finite being_finite
        alias not_being_infinite being_finite

        # Constrain the numeric value to be greater than a specific number.
        #
        # @example
        #   type.being_greater_than(5)
        #   type.validate(10) # => true
        #   type.validate(3)  # => false
        #
        # @param numeric [Numeric] the minimum value (exclusive)
        #
        # @return [self] the current instance for chaining
        # @rbs (Numeric numeric) -> Behavior
        def being_greater_than(numeric)
          # @type self: Object & Behavior
          constrain :self, :range, { minimum: numeric }, inclusive: false, description: 'being'
        end
        alias gt being_greater_than
        alias greater_than being_greater_than

        # Constrain the numeric value to be greater than or equal to a specific number.
        #
        # @example
        #   type.being_greater_than_or_equal_to(5)
        #   type.validate(5)  # => true
        #   type.validate(3)  # => false
        #
        # @param numeric [Numeric] the minimum value (inclusive)
        #
        # @return [self] the current instance for chaining
        # @rbs (Numeric numeric) -> Behavior
        def being_greater_than_or_equal_to(numeric)
          # @type self: Object & Behavior
          constrain :self, :range, { minimum: numeric }, description: 'being'
        end
        alias gte being_greater_than_or_equal_to
        alias gteq being_greater_than_or_equal_to
        alias greater_than_or_equal_to being_greater_than_or_equal_to

        # Constrain the numeric value to be infinite.
        #
        # @example
        #   type.being_infinite
        #   type.validate(Float::INFINITY) # => true
        #   type.validate(42)             # => false
        #
        # @return [self] the current instance for chaining
        # @rbs () -> Behavior
        def being_infinite
          # @type self: Object & Behavior
          constrain :self, :finiteness, :infinite, description: 'being'
        end
        alias infinite being_infinite
        alias not_being_finite being_infinite

        # Constrain the numeric value to be less than a specific number.
        #
        # @example
        #   type.being_less_than(10)
        #   type.validate(5)  # => true
        #   type.validate(10) # => false
        #
        # @param numeric [Numeric] the maximum value (exclusive)
        #
        # @return [self] the current instance for chaining
        # @rbs (Numeric numeric) -> Behavior
        def being_less_than(numeric)
          # @type self: Object & Behavior
          constrain :self, :range, { maximum: numeric }, inclusive: false, description: 'being'
        end
        alias lt being_less_than
        alias less_than being_less_than

        # Constrain the numeric value to be less than or equal to a specific number.
        #
        # @example
        #   type.being_less_than_or_equal_to(10)
        #   type.validate(5)  # => true
        #   type.validate(15) # => false
        #
        # @param numeric [Numeric] the maximum value (inclusive)
        #
        # @return [self] the current instance for chaining
        # @rbs (Numeric numeric) -> Behavior
        def being_less_than_or_equal_to(numeric)
          # @type self: Object & Behavior
          constrain :self, :range, { maximum: numeric }, description: 'being'
        end
        alias lte being_less_than_or_equal_to
        alias lteq being_less_than_or_equal_to
        alias less_than_or_equal_to being_less_than_or_equal_to

        # Constrain the numeric value to be negative.
        #
        # @example
        #   type.being_negative
        #   type.validate(-5) # => true
        #   type.validate(5)  # => false
        #
        # @return [self] the current instance for chaining
        # @rbs () -> Behavior
        def being_negative
          # @type self: Object & Behavior
          constrain :self, :polarity, :negative, description: 'being'
        end
        alias negative being_negative
        alias not_being_positive being_negative

        # Constrain the numeric value to be odd.
        #
        # @example
        #   type.being_odd
        #   type.validate(3) # => true
        #   type.validate(4) # => false
        #
        # @return [self] the current instance for chaining
        # @rbs () -> Behavior
        def being_odd
          # @type self: Object & Behavior
          constrain :self, :parity, :odd, description: 'being'
        end
        alias odd being_odd
        alias not_being_even being_odd

        # Constrain the numeric value to be positive.
        #
        # @example
        #   type.being_positive
        #   type.validate(5)  # => true
        #   type.validate(-5) # => false
        #
        # @return [self] the current instance for chaining
        # @rbs () -> Behavior
        def being_positive
          # @type self: Object & Behavior
          constrain :self, :polarity, :positive, description: 'being'
        end
        alias positive being_positive
        alias not_being_negative being_positive

        # Constrain the numeric value to be zero.
        #
        # @example
        #   type.being_zero
        #   type.validate(0) # => true
        #   type.validate(5) # => false
        #
        # @return [self] the current instance for chaining
        # @rbs () -> Behavior
        def being_zero
          # @type self: Object & Behavior
          constrain :self, :polarity, :zero, description: 'being'
        end
        alias zero being_zero

        # Constrain the numeric value to not be divisible by a specific divisor.
        #
        # @example
        #   type.not_being_divisible_by(3)
        #   type.validate(5)  # => true
        #   type.validate(9)  # => false
        #
        # @note the divisor MUST be provided as an argument or in the options Hash.
        #
        # @param arguments [Array<Numeric>] a list of arguments, typically one divisor
        # @param options [Hash] additional options such as tolerance for floating-point checks
        # @option options [Numeric] :divisor the divisor to check for divisibility
        # @option options [Numeric] :tolerance the tolerance for floating-point checks
        #
        # @return [self] the current instance for chaining
        # @rbs (*Numeric arguments, ?divisor: Numeric, ?tolerance: Numeric) -> Behavior
        def not_being_divisible_by(*arguments, **options)
          if arguments.size > 1 || (arguments.empty? && !options.key?(:divisor))
            raise ArgumentError, "wrong number of arguments (given #{arguments.size}, expected 1)"
          end

          # @type self: Object & Behavior
          divisor = arguments.first || options[:divisor]
          divisible_by = @constraints.prepare :self, :divisibility, divisor, **options.except(:divisor)
          constrain :self, :not, divisible_by, concerning: :divisibility, description: 'being'
        end
        alias not_being_multiple_of not_being_divisible_by
        alias not_divisible_by not_being_divisible_by
        alias not_multiple_of not_being_divisible_by

        # Constrain the numeric value to not equal a specific number.
        #
        # @example
        #   type.not_being_equal_to(42)
        #   type.validate(7)  # => true
        #   type.validate(42) # => false
        #
        # @param numeric [Numeric] the number to constrain inequality to
        #
        # @return [self] the current instance for chaining
        # @rbs (Numeric numeric) -> Behavior
        def not_being_equal_to(numeric)
          # @type self: Object & Behavior
          equal_to = @constraints.prepare :self, :equality, numeric
          constrain :self, :not, equal_to, concerning: :inequality, description: 'being'
        end
        alias not_eql not_being_equal_to
        alias not_equal_to not_being_equal_to
        alias not_equaling not_being_equal_to

        # Constrain the numeric value to not be zero.
        #
        # @example
        #   type.not_being_zero
        #   type.validate(5)  # => true
        #   type.validate(0)  # => false
        #
        # @return [self] the current instance for chaining
        # @rbs () -> Behavior
        def not_being_zero
          # @type self: Object & Behavior
          constrain :self, :polarity, :nonzero, description: 'being'
        end
        alias nonzero not_being_zero
        alias not_zero not_being_zero
      end
    end
  end
end
