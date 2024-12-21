# frozen_string_literal: true

require 'domainic/type/behavior'
require 'domainic/type/behavior/enumerable_behavior'

module Domainic
  module Type
    # A type for validating Hash objects with flexible key and value constraints
    #
    # This class provides a comprehensive set of validations specifically designed
    # for Hash objects, including key/value type checking, inclusion/exclusion of
    # specific keys or values, and all standard enumerable validations.
    #
    # Key features:
    # - Key type validation
    # - Value type validation
    # - Key presence/absence checking
    # - Value presence/absence checking
    # - Size constraints (via EnumerableBehavior)
    # - Standard collection validations (via EnumerableBehavior)
    #
    # @example Basic usage
    #   type = HashType.new
    #   type.of(String => Integer)          # enforce key/value types
    #   type.containing_keys('a', 'b')      # require specific keys
    #   type.containing_values(1, 2)        # require specific values
    #   type.having_size(2)                 # exact size constraint
    #
    # @example Complex constraints
    #   type = HashType.new
    #   type
    #     .of(Symbol => String)             # type constraints
    #     .containing_keys(:name, :email)   # required keys
    #     .excluding_values(nil, '')        # no empty values
    #     .having_size_between(2, 5)        # size range
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class HashType
      # @rbs! extend Behavior::ClassMethods

      include Behavior
      include Behavior::EnumerableBehavior

      intrinsic :self, :type, Hash, abort_on_failure: true, description: :not_described

      # Validate that the hash contains specific keys
      #
      # @example
      #   type.containing_keys(:name, :email)
      #   type.validate({ name: 'John', email: 'john@example.com' })  # => true
      #   type.validate({ name: 'John' })                            # => false
      #
      # @param keys [Array<Object>] the keys that must be present
      # @return [self] self for method chaining
      # @rbs (*untyped keys) -> self
      def containing_keys(*keys)
        constrain :keys, :inclusion, keys, concerning: :key_inclusion, description: 'keys'
      end
      alias including_keys containing_keys

      # Validate that the hash contains specific values
      #
      # @example
      #   type.containing_values('active', 'pending')
      #   type.validate({ status: 'active' })   # => true
      #   type.validate({ status: 'inactive' }) # => false
      #
      # @param values [Array<Object>] the values that must be present
      # @return [self] self for method chaining
      # @rbs (*untyped values) -> self
      def containing_values(*values)
        constrain :values, :inclusion, values, concerning: :value_inclusion, description: 'values'
      end
      alias including_values containing_values

      # Validate that the hash does not contain specific keys
      #
      # @example
      #   type.excluding_keys(:admin, :superuser)
      #   type.validate({ user: 'John' })           # => true
      #   type.validate({ admin: true })            # => false
      #
      # @param keys [Array<Object>] the keys that must not be present
      # @return [self] self for method chaining
      # @rbs (*untyped keys) -> self
      def excluding_keys(*keys)
        including = @constraints.prepare :self, :inclusion, keys
        constrain :keys, :not, including, concerning: :key_exclusion
      end
      alias omitting_keys excluding_keys

      # Validate that the hash does not contain specific values
      #
      # @example
      #   type.excluding_values(nil, '')
      #   type.validate({ name: 'John' })   # => true
      #   type.validate({ name: nil })      # => false
      #
      # @param values [Array<Object>] the values that must not be present
      # @return [self] self for method chaining
      # @rbs (*untyped values) -> self
      def excluding_values(*values)
        including = @constraints.prepare :self, :inclusion, values
        constrain :values, :not, including, concerning: :value_exclusion
      end
      alias omitting_values excluding_values

      # Validate the hash to have the given key type and value type.
      #
      # @example
      #   type.of(String => Integer)
      #   type.validate({ 'a' => 1 })   # => true
      #   type.validate({ 1 => 'a' })   # => false
      #
      # @param key_to_value_type [Hash{Object => Object}] the key type and value type that the hash must have
      #
      # @raise [ArgumentError] if the key_to_value_type pair is not a Hash or does not have exactly one entry
      # @return [self] self for method chaining
      # @rbs (Hash[untyped, untyped] key_to_value_type) -> self
      def of(key_to_value_type)
        raise ArgumentError, 'The key_to_value_type pair must be a Hash' unless key_to_value_type.is_a?(Hash)
        raise ArgumentError, 'The key_to_value_type pair must have exactly one entry' unless key_to_value_type.size == 1

        key_type = @constraints.prepare :self, :type, key_to_value_type.keys.first
        value_type = @constraints.prepare :self, :type, key_to_value_type.values.first

        constrain :keys, :all, key_type, concerning: :key_type, description: 'having keys of'
        constrain :values, :all, value_type, concerning: :value_type, description: 'having values of'
      end
    end
  end
end
