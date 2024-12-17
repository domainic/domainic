# frozen_string_literal: true

require 'domainic/type/accessors'
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
      #   set.add(:self, :string, 'being a')
      #   set.add(:length, :range, 'having length', minimum: 5)
      #
      #   set.constraint?(:self, 'being a')  # => true
      #   set.constraints  # => [StringConstraint, RangeConstraint]
      #   set.count       # => 2
      #
      # @api private
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class Set
        extend Forwardable

        # @rbs @lookup: Hash[Type::accessor, Hash[String | Symbol, Behavior]]

        # Initialize a new empty constraint set.
        #
        # @return [void]
        # @rbs () -> void
        def initialize
          @lookup = Type::ACCESSORS.each_with_object({}) do |accessor, lookup|
            lookup[accessor] = {}
          end
        end

        # Add a new constraint to the set.
        #
        # Creates and configures a new constraint instance based on the provided type
        # and configuration. If a constraint with the same accessor and name already
        # exists, it will be replaced.
        #
        # @param accessor [String, Symbol] The accessor method for the constraint
        # @param constraint_type [String, Symbol] The type of constraint to create
        # @param quantifier_description [String, Symbol] The quantifier description of the constraint when given a
        #   string that ends with "not_described" it will not be included in the constraint set description.
        # @param expectation [Object, nil] The expected value for the constraint
        # @param options [Hash] Additional options for the constraint
        # @option options [Boolean] :abort_on_failure Whether to stop on failure
        # @option options [Boolean] :is_type_failure Whether this is a type check
        #
        # @return [void]
        # @rbs (
        #   String | Type::accessor accessor,
        #   String | Symbol constraint_type,
        #   String | Symbol quantifier_description,
        #   ?untyped expectation,
        #   **__todo__ options
        #   ) -> void
        def add(accessor, constraint_type, quantifier_description, expectation = nil, **options)
          accessor, constraint_type = [accessor, constraint_type].map(&:to_sym)
          # @type var accessor: Type::accessor
          # @type var constraint_type: Symbol
          @lookup[accessor] ||= {}
          @lookup[accessor][quantifier_description] ||= Resolver.resolve!(constraint_type).new(accessor)
          @lookup[accessor][quantifier_description].expecting(expectation).with_options(**options) # steep:ignore
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

        # The aggregate description of all constraints in the set.
        #
        # @return [String] The description of all constraints
        # @rbs () -> String
        def description
          Type::ACCESSORS.flat_map do |accessor|
            described_accessor_constraints(accessor).map do |quantifier_description, constraint|
              constraint_description(quantifier_description, constraint.description)
            end
          end.join(', ').strip
        end

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
        # @param quantifier_description [String, Symbol] The quantifier description of the constraint
        #
        # @return [Boolean] true if the constraint exists
        # @rbs (Type::accessor accessor, Symbol | String quantifier_description) -> bool
        def exist?(accessor, quantifier_description)
          accessor = accessor.to_sym
          # @type var accessor: Type::accessor
          @lookup.key?(accessor) && @lookup[accessor].key?(quantifier_description)
        end
        alias has_constraint? exist?

        # Whether any constraints in the set have failed satisfaction.
        #
        # @return [Boolean] true if any constraints have failed
        # @rbs () -> bool
        def failures?
          all.any?(&:failure?)
        end

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
        # @param quantifier_description [String, Symbol] The quantifier description of the constraint.
        #
        # @return [Behavior, nil] The constraint if found, nil otherwise
        # @rbs (Type::accessor accessor, String | Symbol quantifier_description) -> Behavior?
        def find(accessor, quantifier_description)
          # @type var accessor: Type::accessor
          @lookup.dig(accessor.to_sym, quantifier_description)
        end

        # The aggregate violation description of all constraints in the set.
        #
        # @return [String] The description of all constraints
        # @rbs () -> String
        def violation_description
          Type::ACCESSORS.flat_map do |accessor|
            described_accessor_constraints(accessor).map do |quantifier_description, constraint|
              constraint_description(quantifier_description, constraint.violation_description)
            end
          end.join(', ').strip
        end

        private

        # Generate a description for a specific constraint.
        #
        # @param quantifier_description [String, Symbol] The quantifier description of the constraint
        # @param constraint_description [String] The description of the constraint
        #
        # @return [String] The description of the constraint
        # @rbs (String | Symbol quantifier_description, String constraint_description) -> String
        def constraint_description(quantifier_description, constraint_description)
          if quantifier_description.is_a?(Symbol)
            "#{quantifier_description.to_s.split('_').join(' ')} #{constraint_description}"
          else
            "#{quantifier_description} #{constraint_description}"
          end.strip
        end

        # The described constraints for a specific accessor.
        #
        # @param accessor [Symbol] The accessor method for the constraint
        #
        # @return [Hash{String, Symbol => Behavior}] The constraints for the accessor
        # @rbs (Type::accessor accessor) -> Hash[String | Symbol, Behavior]
        def described_accessor_constraints(accessor)
          @lookup[accessor].reject do |quantifier_description, _|
            quantifier_description.to_s.end_with?('not_described')
          end
        end

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
