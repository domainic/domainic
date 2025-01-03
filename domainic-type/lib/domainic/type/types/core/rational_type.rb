# frozen_string_literal: true

require 'domainic/type/behavior'
require 'domainic/type/behavior/numeric_behavior'

module Domainic
  module Type
    # A type for validating Rational numbers.
    #
    # This type ensures values are of type `Rational` and supports a range of
    # constraints for numerical validation, such as positivity, negativity,
    # and divisibility. It integrates with `NumericBehavior` to provide a
    # consistent and fluent interface for numeric constraints.
    #
    # @example Validating a positive Rational number
    #   type = Domainic::Type::RationalType.new
    #   type.being_positive.validate!(Rational(3, 4)) # => true
    #
    # @example Validating divisibility
    #   type = Domainic::Type::RationalType.new
    #   type.being_divisible_by(1).validate!(Rational(3, 1)) # => true
    #
    # @example Using constraints with chaining
    #   type = Domainic::Type::RationalType.new
    #   type.being_greater_than(0).being_less_than(1).validate!(Rational(1, 2)) # => true
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class RationalType
      # @rbs! extend Behavior::ClassMethods

      include Behavior
      include Behavior::NumericBehavior

      intrinsically_constrain :self, :type, Rational, abort_on_failure: true, description: :not_described
    end
  end
end
