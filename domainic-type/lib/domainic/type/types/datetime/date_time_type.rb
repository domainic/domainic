# frozen_string_literal: true

require 'date'
require 'domainic/type/behavior'
require 'domainic/type/behavior/date_time_behavior'

module Domainic
  module Type
    # A type for validating DateTime objects
    #
    # This type ensures the value is a `DateTime` object and supports comprehensive
    # date-time validation through `DateTimeBehavior`. It is ideal for scenarios requiring
    # precise date-time constraints.
    #
    # Key features:
    # - Ensures the value is a `DateTime` object
    # - Supports chronological relationship validation (e.g., before, after)
    # - Provides range and equality checks
    #
    # @example Basic usage
    #   type = DateTimeType.new
    #   type.validate(DateTime.now)            # => true
    #   type.validate(Date.today)              # => false
    #
    # @example Range validation
    #   type = DateTimeType.new
    #     .being_between(DateTime.new(2024, 1, 1, 0, 0, 0), DateTime.new(2024, 12, 31, 23, 59, 59))
    #   type.validate(DateTime.new(2024, 6, 15, 12, 0, 0))  # => true
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class DateTimeType
      # @rbs! extend Behavior::ClassMethods

      include Behavior
      include Behavior::DateTimeBehavior

      intrinsically_constrain :self, :type, DateTime, abort_on_failure: true, description: :not_described
    end
  end
end
