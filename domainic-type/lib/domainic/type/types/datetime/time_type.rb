# frozen_string_literal: true

require 'date'
require 'domainic/type/behavior'
require 'domainic/type/behavior/date_time_behavior'

module Domainic
  module Type
    # A type for validating Time objects
    #
    # This type ensures the value is a `Time` object and integrates with
    # `DateTimeBehavior` to provide a rich set of time-based validation capabilities.
    #
    # Key features:
    # - Ensures the value is a `Time` object
    # - Supports chronological relationship constraints (e.g., before, after)
    # - Provides range and equality checks
    #
    # @example Basic usage
    #   type = TimeType.new
    #   type.validate(Time.now)                 # => true
    #   type.validate(Date.today)               # => false
    #
    # @example Range validation
    #   type = TimeType.new
    #     .being_between(Time.now, Time.now + 3600)
    #   type.validate(Time.now + 1800)          # => true
    #   type.validate(Time.now + 7200)          # => false
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class TimeType
      # @rbs! extend Behavior::ClassMethods

      include Behavior
      include Behavior::DateTimeBehavior

      intrinsically_constrain :self, :type, Time, abort_on_failure: true, description: :not_described
    end
  end
end