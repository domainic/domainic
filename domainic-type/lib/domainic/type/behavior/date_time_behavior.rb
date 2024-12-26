# frozen_string_literal: true

require 'date'

module Domainic
  module Type
    module Behavior
      # A module providing date/time validation constraint methods
      #
      # This module extends types with methods for constraining date/time values based on
      # chronological relationships. It provides a fluent interface for building complex
      # date/time validation constraints using natural language methods.
      #
      # @example Basic date comparisons
      #   type = DateType.new
      #     .being_after(Date.new(2024, 1, 1))
      #     .being_before(Date.new(2024, 12, 31))
      #
      # @example Range-based validation
      #   type = DateType.new
      #     .being_between(Date.new(2024, 1, 1), Date.new(2024, 12, 31))
      #
      # @example Inclusive/exclusive bounds
      #   type = DateType.new
      #     .being_on_or_after(Date.new(2024, 1, 1))
      #     .being_on_or_before(Date.new(2024, 12, 31))
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      module DateTimeBehavior
        TO_DATETIME_COERCER = lambda { |value|
          if [Date, DateTime, Time].any? { |type| value.is_a?(type) }
            value
          else
            DateTime.parse(value.to_s)
          end
        } #: Proc

        class << self
          private

          # Parse arguments for being_between
          #
          # @note this in my opinion is better than polluting the namespace of the including class even with a private
          #   method. This way, the method is only available within the module itself. See {#being_between}.
          #
          # @param after [Date, DateTime, String, Time, nil] minimum size value from positional args
          # @param before [Date, DateTime, String, Time, nil] maximum size value from positional args
          # @param options [Hash] keyword arguments containing after/before values
          #
          # @raise [ArgumentError] if minimum or maximum value can't be determined
          # @return [Array<Date, DateTime, String, Time, nil>] parsed [after, before] values
          # @rbs (
          #   (Date | DateTime | String | Time)? after,
          #   (Date | DateTime | String | Time)? before,
          #   Hash[Symbol, (Date | DateTime | String | Time)?] options
          #   ) -> Array[(Date | DateTime | String | Time)?]
          def parse_being_between_arguments!(after, before, options)
            after ||= options[:after]
            before ||= options[:before]
            raise_being_between_argument_error!(caller, after, before, options) if after.nil? || before.nil?

            [after, before] #: Array[(Date | DateTime | String | Time)?]
          end

          # Raise appropriate ArgumentError for being_between
          #
          # @param original_caller [Array<String>] caller stack for error
          # @param after [Date, DateTime, String, Time, nil] after value from positional args
          # @param before [Date, DateTime, String, Time, nil] before value from positional args
          # @param options [Hash] keyword arguments containing after/before values
          #
          # @raise [ArgumentError] with appropriate message
          # @return [void]
          # @rbs (
          #   Array[String] original_caller,
          #   (Date | DateTime | String | Time)? after,
          #   (Date | DateTime | String | Time)? before,
          #   Hash[Symbol, (Date | DateTime | String | Time)?] options
          #   ) -> void
          def raise_being_between_argument_error!(original_caller, after, before, options)
            message = if options.empty?
                        "wrong number of arguments (given #{[after, before].compact.count}, expected 2)"
                      else
                        "missing keyword: :#{%i[after before].find { |key| !options.key?(key) }}"
                      end

            error = ArgumentError.new(message)
            error.set_backtrace(original_caller)
            raise error
          end
        end

        # Constrain the value to be chronologically after a given date/time
        #
        # @param other [Date, DateTime, String, Time] the date/time to compare against
        # @return [self] self for method chaining
        # @rbs (Date | DateTime | String | Time other) -> Behavior
        def being_after(other)
          # @type self: Object & Behavior
          constrain :self, :range, { minimum: other },
                    coerce_with: TO_DATETIME_COERCER, description: 'being', inclusive: false
        end
        alias after being_after

        # Constrain the value to be chronologically before a given date/time
        #
        # @param other [Date, DateTime, String, Time] the date/time to compare against
        # @return [self] self for method chaining
        # @rbs (Date | DateTime | String | Time other) -> Behavior
        def being_before(other)
          # @type self: Object & Behavior
          constrain :self, :range, { maximum: other },
                    coerce_with: TO_DATETIME_COERCER, description: 'being', inclusive: false
        end
        alias before being_before

        # Constrain the value to be chronologically between two date/times
        #
        # @param after [Date, DateTime, String, Time] the earliest allowed date/time
        # @param before [Date, DateTime, String, Time] the latest allowed date/time
        # @param options [Hash] alternative way to specify after/before via keywords
        # @option options [Date, DateTime, String, Time] :after earliest allowed date/time
        # @option options [Date, DateTime, String, Time] :before latest allowed date/time
        # @return [self] self for method chaining
        # @rbs (Date | DateTime | String | Time after, Date | DateTime | String | Time before) -> Behavior
        def being_between(after = nil, before = nil, **options)
          # @type self: Object & Behavior
          after, before =
            DateTimeBehavior.send(:parse_being_between_arguments!, after, before, options.transform_keys(&:to_sym))
          constrain :self, :range, { minimum: after, maximum: before },
                    coerce_with: TO_DATETIME_COERCER, description: 'being', inclusive: false
        end
        alias between being_between

        # Constrain the value to be exactly equal to a given date/time
        #
        # @param other [Date, DateTime, String, Time] the date/time to compare against
        # @return [self] self for method chaining
        # @rbs (Date | DateTime | String | Time other) -> Behavior
        def being_equal_to(other)
          # @type self: Object & Behavior
          constrain :self, :equality, other,
                    coerce_with: TO_DATETIME_COERCER, description: 'being'
        end
        alias at being_equal_to

        # Constrain the value to be chronologically on or after a given date/time
        #
        # @param other [Date, DateTime, String, Time] the date/time to compare against
        # @return [self] self for method chaining
        # @rbs (Date | DateTime | String | Time other) -> Behavior
        def being_on_or_after(other)
          # @type self: Object & Behavior
          constrain :self, :range, { minimum: other },
                    coerce_with: TO_DATETIME_COERCER, description: 'being'
        end
        alias at_or_after being_on_or_after
        alias being_at_or_after being_on_or_after
        alias on_or_after being_on_or_after

        # Constrain the value to be chronologically on or before a given date/time
        #
        # @param other [Date, DateTime, String, Time] the date/time to compare against
        # @return [self] self for method chaining
        # @rbs (Date | DateTime | String | Time other) -> Behavior
        def being_on_or_before(other)
          # @type self: Object & Behavior
          constrain :self, :range, { maximum: other },
                    coerce_with: TO_DATETIME_COERCER, description: 'being'
        end
        alias at_or_before being_on_or_before
        alias being_at_or_before being_on_or_before
        alias on_or_before being_on_or_before
      end
    end
  end
end
