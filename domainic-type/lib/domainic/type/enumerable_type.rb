# frozen_string_literal: true

require_relative 'base_type'

module Domainic
  module Type
    # The `EnumerableType` is a base type for all enumerable types.
    #
    # @!method initialize(**options)
    #  Initialize a new instance of the EnumerableType.
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
    #  @return [EnumerableType] the new EnumerableType instance
    #
    # @since 0.1.0
    class EnumerableType < BaseType # rubocop:disable Metrics/ClassLength
      # @!method being_duplicative
      #  Constrains the Enumerable to contain duplicate entries
      #  @!scope class
      #  @return [EnumerableType]
      #
      # @!method being_duplicative
      #  Constrains the Enumerable to contain duplicate entries
      #  @return [self]
      #
      # @!method being_empty
      #  Constrains the Enumerable to be empty
      #  @!scope class
      #  @return [EnumerableType]
      #
      # @!method being_empty
      #  Constrains the Enumerable to be empty
      #  @return [self]
      #
      # @!method being_populated
      #  Constrains the Enumerable to be populated
      #  @!scope class
      #  @return [EnumerableType]
      #
      # @!method being_populated
      #  Constrains the Enumerable to be populated
      #  @return [self]
      #
      # @!method being_ordered
      #  Constrains the Enumerable to be ordered
      #  @!scope class
      #  @return [EnumerableType]
      #
      # @!method being_ordered
      #  Constrains the Enumerable to be ordered
      #  @return [self]
      #
      # @!method being_unique
      #  Constrains the Enumerable to contain unique entries
      #  @!scope class
      #  @return [EnumerableType]
      #
      # @!method being_unique
      #  Constrains the Enumerable to contain unique entries
      #  @return [self]
      #
      # @!method being_unordered
      #  Constrains the Enumerable to be unordered
      #  @!scope class
      #  @return [EnumerableType]
      #
      # @!method being_unordered
      #  Constrains the Enumerable to be unordered
      #  @return [self]
      #
      # @!method containing(*entries)
      #  Constrains the Enumerable to contain certain entries
      #  @!scope class
      #  @param entries [Array] the entries that the Enumerable should contain
      #  @return [EnumerableType]
      #
      # @!method containing(*entries)
      #  Constrains the Enumerable to contain certain entries
      #  @param entries [Array] the entries that the Enumerable should contain
      #  @return [self]
      #
      # @!method excluding(*entries)
      #  Constrains the Enumerable not to contain certain entries
      #  @!scope class
      #  @param entries [Array] the entries that the Enumerable should not contain
      #  @return [EnumerableType]
      #
      # @!method excluding(*entries)
      #  Constrains the Enumerable not to contain certain entries
      #  @param entries [Array] the entries that the Enumerable should not contain
      #  @return [self]
      #
      # @!method of(type)
      #  Constrains the type of entries allowed in the Enumerable
      #  @!scope class
      #  @param type [Class] the type of entries allowed in the Enumerable
      #  @return [EnumerableType]
      #
      # @!method of(type)
      #  Constrains the type of entries allowed in the Enumerable
      #  @param type [Class] the type of entries allowed in the Enumerable
      #  @return [self]
      constrain :self do
        constraint :inclusion, name: :exclusion
        constraint :inclusion
        constraint :ordering
        constraint :population
        constraint :type, name: :entry_type
        constraint :uniqueness

        bind_method :being_duplicative do
          desc 'Constrains the Enumerable to contain duplicate entries'
          concerning :uniqueness
          aliases :being_non_unique, :duplicative, :having_duplicate_entries, :having_duplicate_elements,
                  :having_duplicate_members, :with_duplicate_entries, :with_duplicate_elements,
                  :with_duplicate_members

          configure { |boolean = true| { condition: :duplicative, negated: !boolean } }
        end

        bind_method :being_empty do
          desc 'Constrains the Enumerable to be empty'
          concerning :population
          aliases :empty

          configure { |boolean = true| { condition: :empty, negated: !boolean } }
        end

        bind_method :being_populated do
          desc 'Constrains the Enumerable to be populated'
          concerning :population
          aliases :populated

          configure { |boolean = true| { condition: :populated, negated: !boolean } }
        end

        bind_method :being_ordered do
          desc 'Constrains the Enumerable to be ordered'
          concerning :ordering
          aliases :having_ordered_entries, :having_ordered_elements, :having_ordered_members, :with_ordered_entries,
                  :with_ordered_elements, :with_ordered_members

          configure { |boolean = true| { condition: :ordered, negated: !boolean } }
        end

        bind_method :being_unique do
          desc 'Constrains the Enumerable to contain unique entries'
          concerning :uniqueness
          aliases :being_distinct, :having_unique_entries, :having_unique_elements, :having_unique_members,
                  :with_unique_entries, :with_unique_elements, :with_unique_members, :unique

          configure { |boolean = true| { condition: :unique, negated: !boolean } }
        end

        bind_method :being_unordered do
          desc 'Constrains the Enumerable to be unordered'
          concerning :ordering
          aliases :having_unordered_entries, :having_unordered_elements, :having_unordered_members,
                  :with_unordered_entries, :with_unordered_elements, :with_unordered_members

          configure { |boolean = true| { condition: :unordered, negated: !boolean } }
        end

        bind_method :containing do
          desc 'Constrains the Enumerable to contain certain entries'
          concerning :inclusion
          aliases :having_entries, :having_entries, :having_elements, :having_members, :with_entries, :with_elements,
                  :with_members

          configure { |*entries| { expected: (constraints.self&.inclusion&.expected || []).concat(entries).uniq } }
        end

        bind_method :excluding do
          desc 'Constrains the Enumerable not to contain certain entries'
          concerning :exclusion
          default_for_parameter :expectation_qualifier, :none
          aliases :not_having_entries, :not_having_elements, :not_having_members, :without_entries, :without_elements,
                  :without_members

          configure { |*entries| { expected: (constraints.self&.exclusion&.expected || []).concat(entries).uniq } }
        end

        bind_method :of do
          desc 'Constrains the type of entries allowed in the Enumerable'
          concerning :entry_type
          default_for_parameter :access_qualifier, :all
          aliases :having_entries_of, :having_elements_of, :having_members_of, :with_entries_of, :with_elements_of,
                  :with_members_of

          configure { |type| { expected: type } }
        end
      end

      # @!method having_exact_size(value)
      #  Constrains the minimum and maximum size of the Enumerable to a single value
      #  @!scope class
      #  @param value [Integer] the size of the Enumerable
      #  @return [EnumerableType]
      #
      # @!method having_exact_size(value)
      #  Constrains the minimum and maximum size of the Enumerable to a single value
      #  @param value [Integer] the size of the Enumerable
      #  @return [self]
      #
      # @!method having_maximum_size(value)
      #  Constrains the maximum size of the Enumerable
      #  @!scope class
      #  @param value [Integer] the maximum size of the Enumerable
      #  @return [EnumerableType]
      #
      # @!method having_maximum_size(value)
      #  Constrains the maximum size of the Enumerable
      #  @param value [Integer] the maximum size of the Enumerable
      #  @return [self]
      #
      # @!method having_minimum_size(value)
      #  Constrains the minimum size of the Enumerable
      #  @!scope class
      #  @param value [Integer] the minimum size of the Enumerable
      #  @return [EnumerableType]
      #
      # @!method having_minimum_size(value)
      #  Constrains the minimum size of the Enumerable
      #  @param value [Integer] the minimum size of the Enumerable
      #  @return [self]
      #
      # @!method having_size_between(minimum, maximum)
      #  Constrains the size of the Enumerable to be within a range
      #  @!scope class
      #  @param minimum [Integer] the minimum size of the Enumerable
      #  @param maximum [Integer] the maximum size of the Enumerable
      #  @return [EnumerableType]
      #
      # @!method having_size_between(minimum, maximum)
      #  Constrains the size of the Enumerable to be within a range
      #  @param minimum [Integer] the minimum size of the Enumerable
      #  @param maximum [Integer] the maximum size of the Enumerable
      #  @return [self]
      constrain :size do
        constraint :range

        bind_method :having_exact_size do
          desc 'Constrains the minimum and maximum size of the Enumerable to a single value'
          concerning :range
          aliases :having_count, :having_exact_count, :having_exact_length, :having_length, :having_size,
                  :with_count, :with_exact_count, :with_exact_length, :with_exact_size, :with_length, :with_size

          configure { |value| { minimum: value, maximum: value } }
        end

        bind_method :having_maximum_size do
          desc 'Constrains the maximum size of the Enumerable'
          concerning :range
          aliases :having_max_count, :having_max_length, :having_max_size, :having_maximum_count,
                  :having_maximum_length, :with_max_count, :with_max_length, :with_max_size, :with_maximum_count,
                  :with_maximum_length, :with_maximum_size

          configure { |value| { maximum: value } }
        end

        bind_method :having_minimum_size do
          desc 'Constrains the minimum size of the Enumerable'
          concerning :range
          aliases :having_min_count, :having_min_length, :having_min_size, :having_minimum_count,
                  :having_minimum_length, :with_min_count, :with_min_length, :with_min_size, :with_minimum_count,
                  :with_minimum_length, :with_minimum_size

          configure { |value| { minimum: value } }
        end

        bind_method :having_size_between do
          concerning :range
          default_for_parameter :inclusive, false
          aliases :having_count_between, :having_length_between, :with_count_between, :with_length_between,
                  :with_size_between

          configure do |minimum = nil, maximum = nil, **options|
            minimum = minimum || options[:minimum] || options[:min]
            maximum = maximum || options[:maximum] || options[:max]
            { minimum:, maximum: }
          end
        end
      end
    end
  end
end
