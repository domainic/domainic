# frozen_string_literal: true

require 'domainic/attributer/errors/aggregate_error'

module Domainic
  module Attributer
    # A specialized error class for callback execution failures.
    #
    # This error class is used when one or more callbacks fail during attribute value
    # changes. It aggregates all callback-related errors into a single error with a
    # descriptive message listing each individual failure.
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.2.0
    class CallbackExecutionError < AggregateError
      # Initialize a new CallbackExecutionError instance.
      #
      # @param errors [Array<StandardError>] the collection of callback errors to aggregate
      #
      # @return [void]
      # @rbs (Array[StandardError] errors) -> void
      def initialize(errors)
        super('The following errors occurred during callback execution:', errors)
      end
    end
  end
end
