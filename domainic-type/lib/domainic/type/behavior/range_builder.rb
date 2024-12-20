# frozen_string_literal: true

module Domainic
  module Type
    module Behavior
      # A builder for constructing range-based constraints with a fluent interface.
      #
      # {RangeBuilder} provides methods for specifying range constraints in a readable manner.
      # It supports setting minimum and maximum bounds, either separately or together, as well
      # as specifying exact values.
      #
      # The builder maintains method chaining capability with the parent type system by
      # delegating unknown methods back to the originating type.
      #
      # @example Building count constraints
      #   type.having_count.at_least(5)            # minimum of 5 elements
      #   type.having_count.at_most(10)            # maximum of 10 elements
      #   type.having_count.between(min: 5, max: 10) # between 5 and 10 elements
      #   type.having_count.exactly(7)             # exactly 7 elements
      #
      # @api private
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class RangeBuilder
        # @rbs @constraining: Type::Accessor
        # @rbs @options: Hash[Symbol, untyped]
        # @rbs @type: Behavior

        # Initialize a new RangeBuilder.
        #
        # @param type [Behavior] the type instance to build constraints for
        # @param constraining [Symbol] the accessor to constrain (:size, :length, etc)
        # @param options [Hash] additional options for the constraints
        #
        # @return [void]
        # @rbs (Behavior type, Type::accessor, **untyped options) -> void
        def initialize(type, constraining, **options)
          @constraining = constraining
          @options = options.transform_keys(&:to_sym)
          @type = type
        end

        # Set a minimum bound for the range.
        #
        # @example
        #   type.having_count.at_least(5) # => minimum of 5 elements
        #
        # @param value [Integer] the minimum value
        # @return [self] for method chaining
        # @rbs (Integer value) -> self
        def at_least(value)
          @type.send(:constrain, @constraining, :range, { minimum: value }, **@options)
          self
        end

        # Set a maximum bound for the range.
        #
        # @example
        #   type.having_count.at_most(10) # => maximum of 10 elements
        #
        # @param value [Integer] the maximum value
        # @return [self] for method chaining
        # @rbs (Integer value) -> self
        def at_most(value)
          @type.send(:constrain, @constraining, :range, { maximum: value }, **@options)
          self
        end

        # Set both minimum and maximum bounds for the range.
        #
        # @example
        #   type.having_count.between(min: 5, max: 10)
        #   type.having_count.between(minimum: 5, maximum: 10)
        #
        # @param min [Integer, nil] the minimum value
        # @param maximum [Integer, nil] the maximum value (alias for max)
        # @param minimum [Integer, nil] the minimum value (alias for min)
        # @param max [Integer, nil] the maximum value
        # @return [self] for method chaining
        # @rbs (?max: Integer?, ?maximum: Integer?, ?min: Integer?, ?minimum: Integer?) -> self
        def between(max: nil, maximum: nil, min: nil, minimum: nil)
          min ||= minimum
          max ||= maximum
          raise ArgumentError, 'minimum and maximum values must be provided' unless min && max

          constraint_options = @options.merge(inclusive: false)
          @type.send(:constrain, @constraining, :range, { minimum: min, maximum: max }, **constraint_options)
          self
        end

        # Set an exact value for the range (min == max).
        #
        # @example
        #   type.having_count.exactly(7) # => exactly 7 elements
        #
        # @param value [Integer] the exact value
        # @return [self] for method chaining
        # @rbs (Integer value) -> self
        def exactly(value)
          @type.send(:constrain, @constraining, :range, { minimum: value, maximum: value }, **@options)
          self
        end

        private

        # Delegate unknown methods to the parent type.
        #
        # This enables method chaining with the parent type system.
        #
        # @return [Behavior] for continued type constraints
        # @rbs(Symbol method_name, *untyped arguments, **untyped keyword_arguments) -> Behavior
        def method_missing(method_name, ...)
          return super unless @type.respond_to?(method_name)

          @type.send(method_name, ...)
        end

        # Check if the builder can respond to a method.
        #
        # @return [Boolean] true if the method can be handled
        # @rbs (Symbol method_name, ?bool _include_private) -> bool
        def respond_to_missing?(method_name, _include_private = false)
          @type.respond_to?(method_name) || super
        end
      end
    end
  end
end
