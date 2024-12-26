# frozen_string_literal: true

require 'domainic/type/behavior'

module Domainic
  module Type
    module Behavior
      # A module providing size-based validation behaviors for types.
      #
      # This module extends the base Type::Behavior with methods specifically designed for validating
      # the size or length of objects. It provides a consistent interface for size-based validations
      # across different types (collections, strings, etc) with support for exact, minimum, maximum,
      # and range-based size constraints.
      #
      # Key features:
      # - Exact size validation
      # - Minimum/maximum bounds
      # - Range-based size constraints
      # - Consistent interface across different types
      # - Multiple method aliases for intuitive use
      #
      # @example Basic usage
      #   class MyType
      #     include Domainic::Type::Behavior::SizableBehavior
      #
      #     def initialize
      #       super
      #       having_size(5)           # exactly 5 elements
      #       having_minimum_size(3)   # at least 3 elements
      #       having_maximum_size(10)  # at most 10 elements
      #     end
      #   end
      #
      # @example Using size ranges
      #   class MyType
      #     include Domainic::Type::Behavior::SizableBehavior
      #
      #     def initialize
      #       super
      #       having_size_between(5, 10)  # between 5 and 10 elements
      #       # Or with keywords
      #       having_size_between(minimum: 5, maximum: 10)
      #     end
      #   end
      #
      # @example Method aliases
      #   type.having_size(5)          # exact size
      #   type.size(5)                 # same as above
      #   type.length(5)               # same as above
      #   type.count(5)                # same as above
      #
      #   type.having_min_size(3)      # minimum size
      #   type.minimum_size(3)         # same as above
      #   type.min_length(3)           # same as above
      #
      #   type.having_max_size(10)     # maximum size
      #   type.maximum_size(10)        # same as above
      #   type.max_length(10)          # same as above
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      module SizableBehavior
        class << self
          private

          # Parse arguments for having_size_between
          #
          # @note this in my opinion is better than polluting the namespace of the including class even with a private
          #   method. This way, the method is only available within the module itself. See {#having_size_between}.
          #
          # @param minimum [Integer, nil] minimum size value from positional args
          # @param maximum [Integer, nil] maximum size value from positional args
          # @param options [Hash] keyword arguments containing min/max values
          #
          # @raise [ArgumentError] if minimum or maximum value can't be determined
          # @return [Array<Integer>] parsed [minimum, maximum] values
          # @rbs (Integer? minimum, Integer? maximum, Hash[Symbol, Integer?] options) -> Array[Integer]
          def parse_having_between_arguments!(minimum, maximum, options)
            min = minimum || options[:min] || options[:minimum]
            max = maximum || options[:max] || options[:maximum]
            raise_having_between_argument_error!(caller, min, max, options) if min.nil? || max.nil?

            [min, max] #: Array[Integer]
          end

          # Raise appropriate ArgumentError for having_size_between
          #
          # @param original_caller [Array<String>] caller stack for error
          # @param minimum [Integer, nil] attempted minimum value
          # @param maximum [Integer, nil] attempted maximum value
          # @param options [Hash] keyword arguments that were provided
          #
          # @raise [ArgumentError] with appropriate message
          # @return [void]
          # @rbs (
          #   Array[String] original_caller,
          #   Integer? minimum,
          #   Integer? maximum,
          #   Hash[Symbol, Integer?] options
          #   ) -> void
          def raise_having_between_argument_error!(original_caller, minimum, maximum, options)
            message = if options.empty?
                        "wrong number of arguments (given #{[minimum, maximum].compact.count}, expected 2)"
                      else
                        "missing keyword: :#{%i[minimum maximum].find { |key| !options.key?(key) }}"
                      end

            error = ArgumentError.new(message)
            error.set_backtrace(original_caller)
            raise error
          end
        end

        # Set a maximum size constraint
        #
        # Creates a constraint ensuring the size of the validated object does not exceed
        # the specified value.
        #
        # @example
        #   type.having_maximum_size(10)   # size must be <= 10
        #   type.max_size(10)              # same as above
        #   type.maximum_count(10)         # same as above
        #
        # @param size [Integer] the maximum allowed size
        # @return [self] for method chaining
        # @rbs (Integer size) -> Behavior
        def having_maximum_size(size)
          # @type self: Object & Behavior
          constrain :size, :range, { maximum: size },
                    concerning: :size, description: "having #{__callee__.to_s.split('_').last}"
        end
        alias having_max_count having_maximum_size
        alias having_max_length having_maximum_size
        alias having_max_size having_maximum_size
        alias having_maximum_count having_maximum_size
        alias having_maximum_length having_maximum_size
        alias max_count having_maximum_size
        alias max_length having_maximum_size
        alias max_size having_maximum_size
        alias maximum_count having_maximum_size
        alias maximum_length having_maximum_size
        alias maximum_size having_maximum_size

        # Set a minimum size constraint
        #
        # Creates a constraint ensuring the size of the validated object is at least
        # the specified value.
        #
        # @example
        #   type.having_minimum_size(5)   # size must be >= 5
        #   type.min_size(5)              # same as above
        #   type.minimum_count(5)         # same as above
        #
        # @param size [Integer] the minimum required size
        # @return [self] for method chaining
        # @rbs (Integer size) -> Behavior
        def having_minimum_size(size)
          # @type self: Object & Behavior
          constrain :size, :range, { minimum: size },
                    concerning: :size, description: "having #{__callee__.to_s.split('_').last}"
        end
        alias having_min_count having_minimum_size
        alias having_min_length having_minimum_size
        alias having_min_size having_minimum_size
        alias having_minimum_count having_minimum_size
        alias having_minimum_length having_minimum_size
        alias min_count having_minimum_size
        alias min_length having_minimum_size
        alias min_size having_minimum_size
        alias minimum_count having_minimum_size
        alias minimum_length having_minimum_size
        alias minimum_size having_minimum_size

        # Set an exact size constraint
        #
        # Creates a constraint ensuring the size of the validated object equals
        # the specified value.
        #
        # @example
        #   type.having_size(7)   # size must be exactly 7
        #   type.size(7)          # same as above
        #   type.count(7)         # same as above
        #
        # @param size [Integer] the required size
        # @return [self] for method chaining
        # @rbs (Integer size) -> Behavior
        def having_size(size)
          # @type self: Object & Behavior
          constrain :size, :range, { minimum: size, maximum: size },
                    concerning: :size, description: "having #{__callee__.to_s.split('_').last}"
        end
        alias count having_size
        alias having_count having_size
        alias having_length having_size
        alias length having_size
        alias size having_size

        # Set a size range constraint
        #
        # Creates a constraint ensuring the size of the validated object falls within
        # the specified range. The range is exclusive of the minimum and maximum values.
        #
        # @example With positional arguments
        #   type.having_size_between(5, 10)  # 5 < size < 10
        #
        # @example With keyword arguments
        #   type.having_size_between(minimum: 5, maximum: 10)
        #   type.having_size_between(min: 5, max: 10)
        #
        # @example With mixed arguments
        #   type.having_size_between(5, max: 10)
        #
        # @param minimum [Integer, nil] minimum size value (exclusive)
        # @param maximum [Integer, nil] maximum size value (exclusive)
        # @param options [Hash] alternate way to specify min/max
        # @option options [Integer] :min minimum size (exclusive)
        # @option options [Integer] :minimum same as :min
        # @option options [Integer] :max maximum size (exclusive)
        # @option options [Integer] :maximum same as :max
        #
        # @raise [ArgumentError] if minimum or maximum value can't be determined
        # @return [self] for method chaining
        # @rbs (
        #   ?Integer? minimum,
        #   ?Integer? maximum,
        #   ?max: Integer?,
        #   ?maximum: Integer?,
        #   ?min: Integer?,
        #   ?minimum: Integer?
        #   ) -> Behavior
        def having_size_between(minimum = nil, maximum = nil, **options)
          # @type self: Object & Behavior
          min, max =
            SizableBehavior.send(:parse_having_between_arguments!, minimum, maximum, options.transform_keys(&:to_sym))
          constrain :size, :range, { minimum: min, maximum: max },
                    concerning: :size, description: "having #{__callee__.to_s.split('_').[](1)}", inclusive: false
        end
        alias count_between having_size_between
        alias having_count_between having_size_between
        alias having_length_between having_size_between
        alias length_between having_size_between
        alias size_between having_size_between
      end
    end
  end
end
