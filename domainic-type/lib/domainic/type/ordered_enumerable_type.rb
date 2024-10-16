# frozen_string_literal: true

require_relative 'enumerable_type'

module Domainic
  module Type
    # The `OrderedEnumerableType` is the base class for all ordered enumerable types.
    #
    # @!method initialize(**options)
    #  Initialize a new instance of the OrderedEnumerableType.
    #  @param options [Hash] the options to configure the EnumerableType
    #  @option options [Boolean] :being_duplicative whether the Enumerable should contain duplicate entries.
    #  @option options [Boolean] :being_empty whether the Enumerable should be empty.
    #  @option options [Boolean] :being_populated whether the Enumerable should be populated.
    #  @option options [Boolean] :being_ordered whether the Enumerable should be ordered.
    #  @option options [Boolean] :being_unique whether the Enumerable should contain unique entries.
    #  @option options [Array<Object>] :containing the entries that the Enumerable should contain.
    #  @option options [Array<Object>] :excluding the entries that the Enumerable should not contain.
    #  @option options [Class, BaseType] :of the type of entries allowed in the Enumerable.
    #  @option options [Integer] :having_exact_size the size of the Enumerable.
    #  @option options [Integer] :having_maximum_size the maximum size of the Enumerable.
    #  @option options [Integer] :having_minimum_size the minimum size of the Enumerable.
    #  @option options [Hash{Symbol => Integer}] :having_size_between the minimum and maximum size of the Enumerable.
    #  @option options [Object] :having_first_entry the first entry of the Enumerable.
    #  @option options [Object] :having_last_entry the last entry of the Enumerable.
    #  @return [OrderedEnumerableType] the new EnumerableType instance
    #
    # @since 0.1.0
    class OrderedEnumerableType < EnumerableType
      # @!method having_first_entry(entry)
      #  Constrains the Enumerable to have the first entry
      #  @!scope class
      #  @param entry [Object] the expected first entry
      #  @return [OrderedEnumerableType]
      #
      # @!method having_first_entry(entry)
      #  Constrains the Enumerable to have the first entry
      #  @param entry [Object] the expected first entry
      #  @return [self]
      constrain :first do
        constraint :equality

        bind_method :having_first_entry do
          desc 'Constrains the Enumerable to have the first entry'
          concerning :equality
          aliases :having_first_element, :having_head, :having_first_member,
                  :with_first_element, :with_first_entry, :with_head, :with_first_member

          configure { |entry| { expected: entry } }
        end
      end

      # @!method having_last_entry(entry)
      #  Constrains the Enumerable to have the last entry
      #  @!scope class
      #  @param entry [Object] the expected last entry
      #  @return [OrderedEnumerableType]
      #
      # @!method having_last_entry(entry)
      #  Constrains the Enumerable to have the last entry
      #  @param entry [Object] the expected last entry
      #  @return [self]
      constrain :last do
        constraint :equality

        bind_method :having_last_entry do
          desc 'Constrains the Enumerable to have the last entry'
          concerning :equality
          aliases :having_last_element, :having_tail, :having_last_member,
                  :with_last_element, :with_last_entry, :with_tail, :with_last_member

          configure { |entry| { expected: entry } }
        end
      end
    end
  end
end
