# frozen_string_literal: true

require 'domainic/type/behavior'
require 'domainic/type/behavior/numeric_behavior'

module Domainic
  module Type
    # A type for validating and constraining `Complex` numbers.
    #
    # This type extends `NumericBehavior` to provide a fluent interface for numeric-specific validations such as
    # polarity and divisibility checks.
    #
    # @example Validating a `Complex` value
    #   type = Domainic::Type::ComplexType.new
    #   type.validate!(Complex(3, 4)) # => true
    #
    # @example Enforcing constraints
    #   type = Domainic::Type::ComplexType.new
    #   type.being_positive.validate!(Complex(42, 0)) # => raises TypeError
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class ComplexType
      # @rbs! extend Behavior::ClassMethods

      include Behavior
      include Behavior::NumericBehavior

      intrinsically_constrain :self, :type, Complex, abort_on_failure: true, description: :not_described

      # Constrain the Complex real to be divisible by a given divisor.
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

        divisor = arguments.first || options[:divisor]
        constrain :real, :divisibility, divisor, description: 'being', **options.except(:divisor)
      end
      alias being_multiple_of being_divisible_by
      alias divisible_by being_divisible_by
      alias multiple_of being_divisible_by

      # Constrain the Complex real to be even.
      #
      # @return [self] the current instance for chaining
      # @rbs () -> Behavior
      def being_even
        # @type self: Object & Behavior
        constrain :real, :parity, :even, description: 'being'
      end
      alias even being_even
      alias not_being_odd being_even

      # Constrain the Complex real to be negative.
      #
      # @return [self] the current instance for chaining
      # @rbs () -> Behavior
      def being_negative
        # @type self: Object & Behavior
        constrain :real, :polarity, :negative, description: 'being'
      end
      alias negative being_negative
      alias not_being_positive being_negative

      # Constrain the Complex real value to be odd.
      #
      # @return [self] the current instance for chaining
      # @rbs () -> Behavior
      def being_odd
        # @type self: Object & Behavior
        constrain :real, :parity, :odd, description: 'being'
      end
      alias odd being_odd
      alias not_being_even being_odd

      # Constrain the Complex real to be positive.
      #
      # @return [self] the current instance for chaining
      # @rbs () -> Behavior
      def being_positive
        # @type self: Object & Behavior
        constrain :real, :polarity, :positive, description: 'being'
      end
      alias positive being_positive
      alias not_being_negative being_positive

      # Constrain the Complex real to not be divisible by a specific divisor.
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
        constrain :real, :not, divisible_by, concerning: :divisibility, description: 'being'
      end
      alias not_being_multiple_of not_being_divisible_by
      alias not_divisible_by not_being_divisible_by
      alias not_multiple_of not_being_divisible_by
    end
  end
end
