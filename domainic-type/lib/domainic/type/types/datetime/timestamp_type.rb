# frozen_string_literal: true

require 'domainic/type/behavior'
require 'domainic/type/behavior/date_time_behavior'

module Domainic
  module Type
    # A type for validating Unix timestamps (seconds since the Unix epoch).
    #
    # This type ensures the value is an `Integer` representing a valid Unix
    # timestamp. It integrates with `DateTimeBehavior` to provide a rich set of
    # validation capabilities, including chronological constraints and range checks.
    #
    # Key features:
    # - Ensures the value is an `Integer` representing a Unix timestamp.
    # - Supports chronological relationship constraints (e.g., before, after).
    # - Provides range, equality, and nilable checks.
    #
    # @example Basic usage
    #   type = TimestampType.new
    #   type.validate(Time.now.to_i)             # => true
    #   type.validate(Date.today.to_time.to_i)   # => true
    #   type.validate('invalid')                 # => false
    #
    # @example Range validation
    #   type = TimestampType.new
    #     .being_between(Time.now.to_i, (Time.now + 3600).to_i)
    #   type.validate((Time.now + 1800).to_i)    # => true
    #   type.validate((Time.now + 7200).to_i)    # => false
    #
    # @example Historical timestamps
    #   type = TimestampType.new
    #   type.validate(-1234567890)               # => true (date before 1970-01-01)
    #
    # @example Nilable timestamp
    #   nilable_type = _Nilable(TimestampType.new)
    #   nilable_type.validate(nil)               # => true
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class TimestampType
      # @rbs! extend Behavior::ClassMethods

      include Behavior
      include Behavior::DateTimeBehavior

      intrinsically_constrain :self, :type, Integer, abort_on_failure: true, description: :not_described
    end
  end
end
