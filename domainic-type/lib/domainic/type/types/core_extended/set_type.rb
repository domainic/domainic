# frozen_string_literal: true

require 'domainic/type/behavior'
require 'domainic/type/behavior/enumerable_behavior'
require 'set'

module Domainic
  module Type
    # A type for validating and constraining `Set` objects.
    #
    # This type extends `EnumerableBehavior` to support validations and constraints
    # such as being empty, containing specific elements, or having a minimum or maximum count.
    #
    # @example Validating a `Set` object
    #   type = Domainic::Type::SetType.new
    #   type.validate!(Set.new([1, 2, 3])) # => true
    #
    # @example Enforcing constraints
    #   type = Domainic::Type::SetType.new
    #   type.being_empty.validate!(Set.new) # => true
    #   type.being_empty.validate!(Set.new([1])) # raises TypeError
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class SetType
      # @rbs! extend Behavior::ClassMethods

      include Behavior
      include Behavior::EnumerableBehavior

      intrinsically_constrain :self, :type, Set, abort_on_failure: true, description: :not_described
    end
  end
end
