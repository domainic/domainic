# frozen_string_literal: true

require 'date'
require 'domainic/type/behavior'
require 'domainic/type/behavior/date_time_behavior'

module Domainic
  module Type
    # A type for validating Date objects
    #
    # This type provides robust validation for `Date` objects, ensuring values conform
    # to specified chronological constraints. It supports the full range of date-based
    # constraints provided by `DateTimeBehavior`.
    #
    # Key features:
    # - Ensures the value is a `Date` object
    # - Supports validation for chronological relationships (e.g., before, after)
    # - Full integration with `DateTimeBehavior` for range and equality checks
    #
    # @example Basic usage
    #   type = DateType.new
    #   type.validate(Date.today)               # => true
    #   type.validate(DateTime.now)             # => false
    #
    # @example With range constraints
    #   type = DateType.new
    #     .being_between(Date.new(2024, 1, 1), Date.new(2024, 12, 31))
    #   type.validate(Date.new(2024, 6, 15))    # => true
    #   type.validate(Date.new(2023, 12, 31))   # => false
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class DateType
      # @rbs! extend Behavior::ClassMethods

      include Behavior
      include Behavior::DateTimeBehavior

      intrinsically_constrain :self, :type, Date, abort_on_failure: true, description: :not_described
    end
  end
end
