# frozen_string_literal: true

require 'domainic/type/behavior'
require 'domainic/type/behavior/sizable_behavior'

module Domainic
  module Type
    module Behavior
      # A module providing enumerable-specific validation behaviors for types.
      #
      # This module extends the base Type::Behavior with methods specifically designed for validating enumerable
      # collections. It provides a fluent interface for common enumerable validations such as uniqueness, emptiness,
      # ordering, and size constraints.
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
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      module EnumerableBehavior
        include SizableBehavior

        def being_distinct
          # @type self: Object & Behavior
          constrain :entries, :uniqueness, description: 'being'
        end
        alias being_unique being_distinct
        alias distinct being_distinct
        alias unique being_distinct

        # Validate that the enumerable contains duplicate elements.
        #
        # Creates an inverse uniqueness constraint that ensures the collection has at least one duplicate element.
        #
        # @example
        #   type.being_duplicative
        #   type.validate([1, 1, 2])   # => true
        #   type.validate([1, 2, 3])   # => false
        #
        # @return [self] self for method chaining
        # @rbs ()-> Behavior
        def being_duplicative
          # @type self: Object & Behavior
          unique = @constraints.prepare :self, :uniqueness
          constrain :entries, :not, unique, concerning: :uniqueness, description: 'being'
        end
        alias being_redundant being_duplicative
        alias being_repetitive being_duplicative
        alias duplicative being_duplicative
        alias redundant being_duplicative
        alias repetitive being_duplicative

        # Validate that the enumerable is empty.
        #
        # Creates a constraint that ensures the collection has no elements.
        #
        # @example
        #   type.being_empty
        #   type.validate([])     # => true
        #   type.validate([1])    # => false
        #
        # @return [self] self for method chaining
        # @rbs ()-> Behavior
        def being_empty
          # @type self: Object & Behavior
          constrain :entries, :emptiness, description: 'being'
        end
        alias being_vacant being_empty
        alias empty being_empty
        alias vacant being_empty

        # Validate that the enumerable contains elements.
        #
        # Creates an inverse emptiness constraint that ensures the collection has at least one element.
        #
        # @example
        #   type.being_populated
        #   type.validate([1])    # => true
        #   type.validate([])     # => false
        #
        # @return [self] self for method chaining
        # @rbs ()-> Behavior
        def being_populated
          # @type self: Object & Behavior
          empty = @constraints.prepare :self, :emptiness
          constrain :entries, :not, empty, concerning: :emptiness, description: 'being'
        end
        alias being_inhabited being_populated
        alias being_occupied being_populated
        alias populated being_populated
        alias inhabited being_populated
        alias occupied being_populated

        # Validate that the enumerable elements are in sorted order.
        #
        # Creates a constraint that ensures the collection's elements are in ascending order based on their natural
        # comparison methods.
        #
        # @example
        #   type.being_ordered
        #   type.validate([1, 2, 3])   # => true
        #   type.validate([3, 1, 2])   # => false
        #
        # @return [self] self for method chaining
        # @rbs ()-> Behavior
        def being_sorted
          # @type self: Object & Behavior
          constrain :entries, :ordering, description: 'being'
        end
        alias being_aranged being_sorted
        alias being_ordered being_sorted
        alias being_sequential being_sorted
        alias aranged being_sorted
        alias ordered being_sorted
        alias sorted being_sorted
        alias sequential being_sorted

        # Validate that the enumerable elements are not in sorted order.
        #
        # Creates an inverse ordering constraint that ensures the collection's elements are not in ascending order.
        #
        # @example
        #   type.being_unordered
        #   type.validate([3, 1, 2])   # => true
        #   type.validate([1, 2, 3])   # => false
        #
        # @return [self] self for method chaining
        # @rbs ()-> Behavior
        def being_unsorted
          # @type self: Object & Behavior
          ordered = @constraints.prepare :self, :ordering
          constrain :entries, :not, ordered, concerning: :ordering, description: 'being'
        end
        alias being_disordered being_unsorted
        alias being_unordered being_unsorted
        alias disordered being_unsorted
        alias unsorted being_unsorted
        alias unordered being_unsorted

        # Validate that the enumerable contains specific entries.
        #
        # Creates a series of inclusion constraints ensuring the collection contains all specified elements.
        #
        # @example
        #   type.containing(1, 2)
        #   type.validate([1, 2, 3])   # => true
        #   type.validate([1, 3])      # => false
        #
        # @param entries [Array<Object>] the elements that must be present
        # @return [self] self for method chaining
        # @rbs (*untyped entries)-> Behavior
        def containing(*entries)
          # @type self: Object & Behavior
          including = entries.map do |entry|
            @constraints.prepare :entries, :inclusion, entry
          end
          constrain :entries, :and, including, concerning: :entry_inclusion
        end
        alias including containing

        # Validate that the enumerable contains a specific last entry.
        #
        # Creates an equality constraint on the collection's last entry ensuring it is equal to the specified value.
        #
        # @example
        #   type.having_last_entry(3)
        #   type.validate([1, 2, 3])   # => true
        #   type.validate([1, 3, 2])   # => false
        #
        # @param literal [Object] the value that must be the last entry
        # @return [self] self for method chaining
        # @rbs (untyped literal)-> Behavior
        def ending_with(literal)
          # @type self: Object & Behavior
          constrain :last, :equality, literal, concerning: :last_entry_value, description: 'with last entry'
        end
        alias closing_with ending_with
        alias finishing_with ending_with

        # Validate that the enumerable does not contain specific entries.
        #
        # Creates a series of exclusion constraints ensuring the collection does not contain any of the specified
        # elements.
        #
        # @example
        #   type.excluding(1, 2)
        #   type.validate([3, 4, 5])   # => true
        #   type.validate([1, 2, 3])   # => false
        #
        # @param entries [Array<Object>] the elements that must not be present
        # @return [self] self for method chaining
        # @rbs (*untyped entries)-> Behavior
        def excluding(*entries)
          # @type self: Object & Behavior
          including = entries.map do |entry|
            @constraints.prepare :entries, :inclusion, entry
          end
          constrain :entries, :nor, including, concerning: :entry_exclusion
        end
        alias omitting excluding

        # Validate that the enumerable contains elements of a specific type.
        #
        # Creates a type constraint on the collection's elements ensuring they are all of the specified type.
        #
        # @example
        #   type.of(String)
        #   type.validate(['a', 'b', 'c'])   # => true
        #   type.validate(['a', 1, 'c'])     # => false
        #
        # @param type [Class, Module, Behavior] the type that all elements must be
        # @return [self] self for method chaining
        # @rbs (Class | Module | Behavior type)-> Behavior
        def of(type)
          # @type self: Object & Behavior
          type = @constraints.prepare :self, :type, type
          constrain :entries, :all, type, concerning: :entry_type
        end

        # Validate that the enumerable contains a specific first entry.
        #
        # Creates an equality constraint on the collection's first entry ensuring it is equal to the specified value.
        #
        # @example
        #   type.having_first_entry(1)
        #   type.validate([1, 2, 3])   # => true
        #   type.validate([2, 3, 1])   # => false
        #
        # @param literal [Object] the value that must be the first entry
        # @return [self] self for method chaining
        # @rbs (untyped literal)-> Behavior
        def starting_with(literal)
          # @type self: Object & Behavior
          constrain :first, :equality, literal, concerning: :first_entry_value, description: 'with first entry'
        end
        alias beginning_with starting_with
        alias leading_with starting_with
      end
    end
  end
end
