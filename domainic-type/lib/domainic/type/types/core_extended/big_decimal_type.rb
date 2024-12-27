# frozen_string_literal: true

require 'bigdecimal'
require 'domainic/type/behavior'
require 'domainic/type/behavior/numeric_behavior'

module Domainic
  module Type
    # A type for validating and constraining `BigDecimal` objects.
    #
    # This type extends `NumericBehavior` to provide a fluent interface for numeric-specific validations such as being
    # positive, being within a range, or satisfying divisibility rules.
    #
    # @example Validating a `BigDecimal` value
    #   type = Domainic::Type::BigDecimalType.new
    #   type.validate!(BigDecimal('3.14')) # => true
    #
    # @example Enforcing constraints
    #   type = Domainic::Type::BigDecimalType.new
    #   type.being_positive.validate!(BigDecimal('42')) # => true
    #   type.being_positive.validate!(BigDecimal('-42')) # raises TypeError
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class BigDecimalType
      # @rbs! extend Behavior::ClassMethods

      include Behavior
      include Behavior::NumericBehavior

      intrinsically_constrain :self, :type, BigDecimal, abort_on_failure: true, description: :not_described
    end
  end
end
