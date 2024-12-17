# frozen_string_literal: true

require 'domainic/type/constraint/resolver'
require 'forwardable'

module Domainic
  module Type
    module Constraint
      # A class managing collections of type constraints.
      #
      # The Set class provides a structured way to manage multiple constraints,
      # organizing them by their accessor method and constraint name. It handles
      # the creation, storage, and retrieval of constraints while maintaining
      # their relationships and configuration.
      #
      # Key features:
      # - Organized storage by accessor and constraint name
      # - Dynamic constraint resolution and creation
      # - Flexible constraint lookup and enumeration
      # - Support for both symbol and string identifiers
      #
      # @example Creating and managing constraints
      #   set = Set.new
      #   set.add(:self, :type_check, :string)
      #   set.add(:length, :minimum, :range, minimum: 5)
      #
      #   set.constraint?(:self, :type_check)  # => true
      #   set.constraints  # => [StringConstraint, RangeConstraint]
      #   set.count       # => 2
      #
      # @api private
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class Set
        extend Forwardable

        # @rbs @lookup: Hash[Type::accessor, Hash[Symbol, Behavior]]

        # Initialize a new empty constraint set.
        #
        # @return [void]
        # @rbs () -> void
        def initialize
          @lookup = {}
        end

        # Add a new constraint to the set.
        #
        # Creates and configures a new constraint instance based on the provided type
        # and configuration. If a constraint with the same accessor and name already
        # exists, it will be replaced.
        #
        # @param accessor [String, Symbol] The accessor method for the constraint
        # @param constraint_name [String, Symbol] The name for this constraint
        # @param constraint_type [String, Symbol] The type of constraint to create
        # @param expectation [Object, nil] The expected value for the constraint
        # @param options [Hash] Additional options for the constraint
        # @option options [Boolean] :abort_on_failure Whether to stop on failure
        # @option options [Boolean] :is_type_failure Whether this is a type check
        #
        # @return [void]
        # @rbs (
        #   String | Type::accessor accessor,
        #   String | Symbol constraint_name,
        #   String | Symbol constraint_type,
        #   ?untyped expectation,
        #   **__todo__ options
        #   ) -> void
        def add(accessor, constraint_name, constraint_type, expectation = nil, **options)
          accessor, constraint_name, constraint_type = [accessor, constraint_name, constraint_type].map(&:to_sym)
          # @type var accessor: Type::accessor
          # @type var constraint_name: Symbol
          # @type var constraint_type: Symbol
          @lookup[accessor] ||= {}
          @lookup[accessor][constraint_name] ||= Resolver.resolve!(constraint_type).new(accessor)
          @lookup[accessor][constraint_name].expecting(expectation).with_options(**options) # steep:ignore
        end

        # Get all constraints in the set.
        #
        # @return [Array<Behavior>] Array of all constraints
        # @rbs () -> Array[Behavior]
        def all
          @lookup.values.flat_map(&:values)
        end

        # @!method all?
        #   Check if all constraints match the provided block.
        #
        #   @yield [Behavior] The constraint to check
        #   @return [Boolean] true if all constraints match.
        def_delegators :all, :all?

        # @rbs!
        #   # Check if all constraints match the provided block.
        #
        #   # @yield [Behavior] The constraint to check
        #   # @return [Boolean] true if all constraints match.
        #   def all?: () -> bool
        #           | (Class | Module) -> bool
        #           | () { (Behavior) -> boolish } -> bool

        # Get the total number of constraints.
        #
        # @return [Integer] The number of constraints
        # @rbs () -> Integer
        def count
          @lookup.values.sum(&:count)
        end
        alias length count
        alias size count

        # @!method each
        #   Iterate over each constraint in the set.
        #
        #   @yield [Behavior] The constraint to process
        #   @return [void]
        def_delegators :all, :each

        # @rbs!
        #   # Iterate over each constraint in the set.
        #
        #   # @yield [Behavior] The constraint to process
        #   # @return [void]
        #   def each: () { (Behavior) -> void } -> void

        # Check if a specific constraint exists.
        #
        # @param accessor [Symbol] The accessor method for the constraint
        # @param constraint_name [String, Symbol] The name of the constraint
        #
        # @return [Boolean] true if the constraint exists
        # @rbs (Type::accessor accessor, Symbol constraint_name) -> bool
        def exist?(accessor, constraint_name)
          accessor, constraint_name = [accessor, constraint_name].map(&:to_sym)
          # @type var accessor: Type::accessor
          # @type var constraint_name: Symbol
          @lookup.key?(accessor) && @lookup[accessor].key?(constraint_name)
        end
        alias has_constraint? exist?

        # @!method filter_map
        #   Iterate over each constraint in the set, returning the results of the block excluding nil values.
        #
        #   @yield [Behavior] The constraint to process
        #   @return [Array] The results of the block.
        def_delegators :all, :filter_map

        # @rbs!
        #   # Iterate over each constraint in the set, returning the results of the block excluding nil values.
        #
        #   # @yield [Behavior] The constraint to process
        #   # @return [Array] The results of the block.
        #   def filter_map: () { (Behavior) -> untyped } -> Array[Behavior]

        # Get a specific constraint by its accessor and name.
        #
        # @param accessor [Symbol] The accessor method for the constraint
        # @param constraint_name [String, Symbol] The name of the constraint
        #
        # @return [Behavior, nil] The constraint if found, nil otherwise
        # @rbs (Type::accessor accessor, Symbol constraint_name) -> Behavior?
        def find(accessor, constraint_name)
          # @type var accessor: Type::accessor
          # @type var constraint_name: String | Symbol
          @lookup.dig(accessor.to_sym, constraint_name.to_sym)
        end

        private

        # Ensure that the lookup hash is deep copied when duplicating.
        #
        # @param source [Set] The source object to copy
        #
        # @return [void]
        # @rbs override
        def initialize_copy(source)
          @lookup = source.instance_variable_get(:@lookup).transform_values do |accessor|
            accessor.transform_values(&:dup)
          end
          super
        end
      end
    end
  end
end
