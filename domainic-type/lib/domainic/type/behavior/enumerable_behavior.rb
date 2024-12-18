# frozen_string_literal: true

require 'domainic/type/behavior'

module Domainic
  module Type
    module Behavior
      # A module providing enumerable-specific validation behaviors for types.
      #
      # This module extends the base Type::Behavior with methods specifically designed
      # for validating enumerable collections. It provides a fluent interface for
      # common enumerable validations such as uniqueness, emptiness, ordering,
      # and size constraints.
      #
      # @example Basic usage
      #   class ArrayType
      #     include Domainic::Type::Behavior::EnumerableBehavior
      #
      #     def initialize
      #       super
      #       being_empty                  # validates array is empty
      #       having_minimum_count(5)      # validates at least 5 elements
      #       containing(1, 2, 3)          # validates specific elements
      #     end
      #   end
      #
      # @example Combining constraints
      #   class OrderedArrayType
      #     include Domainic::Type::Behavior::EnumerableBehavior
      #
      #     def initialize
      #       super
      #       being_ordered
      #       being_populated
      #       having_maximum_count(10)
      #     end
      #   end
      #
      # @api private
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      module EnumerableBehavior
        include Behavior

        # Validate that the enumerable contains duplicate elements.
        #
        # Creates an inverse uniqueness constraint that ensures the collection
        # has at least one duplicate element.
        #
        # @example
        #   type.being_duplicative
        #   type.validate([1, 1, 2])   # => true
        #   type.validate([1, 2, 3])   # => false
        #
        # @return [EnumerableBehavior] self for method chaining
        # @rbs () -> EnumerableBehavior
        def being_duplicative
          unique = @constraints.prepare :self, :uniqueness
          constrain :self, :not, unique, concerning: :uniqueness, description: 'being'
        end

        # Validate that the enumerable is empty.
        #
        # Creates a constraint that ensures the collection has no elements.
        #
        # @example
        #   type.being_empty
        #   type.validate([])     # => true
        #   type.validate([1])    # => false
        #
        # @return [EnumerableBehavior] self for method chaining
        # @rbs () -> EnumerableBehavior
        def being_empty
          constrain :self, :emptiness, description: 'being'
        end

        # Validate that the enumerable contains elements.
        #
        # Creates an inverse emptiness constraint that ensures the collection
        # has at least one element.
        #
        # @example
        #   type.being_populated
        #   type.validate([1])    # => true
        #   type.validate([])     # => false
        #
        # @return [EnumerableBehavior] self for method chaining
        # @rbs () -> EnumerableBehavior
        def being_populated
          empty = @constraints.prepare :self, :emptiness
          constrain :self, :not, empty, concerning: :emptiness, description: 'being'
        end

        # Validate that the enumerable elements are in sorted order.
        #
        # Creates a constraint that ensures the collection's elements are
        # in ascending order based on their natural comparison methods.
        #
        # @example
        #   type.being_ordered
        #   type.validate([1, 2, 3])   # => true
        #   type.validate([3, 1, 2])   # => false
        #
        # @return [EnumerableBehavior] self for method chaining
        # @rbs () -> EnumerableBehavior
        def being_ordered
          constrain :self, :ordering, description: 'being'
        end

        # Validate that the enumerable elements are not in sorted order.
        #
        # Creates an inverse ordering constraint that ensures the collection's
        # elements are not in ascending order.
        #
        # @example
        #   type.being_unordered
        #   type.validate([3, 1, 2])   # => true
        #   type.validate([1, 2, 3])   # => false
        #
        # @return [EnumerableBehavior] self for method chaining
        # @rbs () -> EnumerableBehavior
        def being_unordered
          ordered = @constraints.prepare :self, :ordering
          constrain :self, :not, ordered, concerning: :ordering, description: 'being'
        end

        # Validate that the enumerable contains specific entries.
        #
        # Creates a series of inclusion constraints ensuring the collection
        # contains all specified elements.
        #
        # @example
        #   type.containing(1, 2)
        #   type.validate([1, 2, 3])   # => true
        #   type.validate([1, 3])      # => false
        #
        # @param entries [Array<Object>] the elements that must be present
        # @return [EnumerableBehavior] self for method chaining
        # @rbs (*untyped entries) -> EnumerableBehavior
        def containing(*entries)
          constrain :self, :inclusion, entries
        end

        # Validate that the enumerable's size is at most a given value.
        #
        # Creates a range constraint on the collection's size ensuring it
        # does not exceed the specified maximum.
        #
        # @example
        #   type.having_maximum_count(3)
        #   type.validate([1, 2, 3])   # => true
        #   type.validate([1, 2, 3, 4]) # => false
        #
        # @param maximum [Integer] the maximum allowed size
        # @return [EnumerableBehavior] self for method chaining
        # @rbs (Integer maximum) -> EnumerableBehavior
        def having_maximum_count(maximum)
          accessor = __method__.to_s.split('_').last.to_sym
          # @type var accessor: Type::accessor
          constrain accessor, :range, { maximum: maximum }, concerning: :size, description: 'having'
        end

        # Validate that the enumerable's size is at least a given value.
        #
        # Creates a range constraint on the collection's size ensuring it
        # has at least the specified minimum number of elements.
        #
        # @example
        #   type.having_minimum_count(2)
        #   type.validate([1, 2, 3])   # => true
        #   type.validate([1])         # => false
        #
        # @param minimum [Integer] the minimum required size
        # @return [EnumerableBehavior] self for method chaining
        # @rbs (Integer minimum) -> EnumerableBehavior
        def having_minimum_count(minimum)
          accessor = __method__.to_s.split('_').last.to_sym
          # @type var accessor: Type::accessor
          constrain accessor, :range, { minimum: minimum }, concerning: :size, description: 'having'
        end
      end
    end
  end
end
