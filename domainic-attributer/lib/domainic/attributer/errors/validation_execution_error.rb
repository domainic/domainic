# frozen_string_literal: true

require 'domainic/attributer/errors/aggregate_error'

module Domainic
  module Attributer
    # A specialized error class for validation execution failures.
    #
    # This error class is used when one or more validations encounter errors during
    # their execution. It aggregates all validation-related errors into a single
    # error with a descriptive message listing each individual failure.
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.2.0
    class ValidationExecutionError < AggregateError
      # Initialize a new ValidationExecutionError instance.
      #
      # @param errors [Array<StandardError>] the collection of validation errors to aggregate
      #
      # @return [void]
      # @rbs (Array[StandardError] errors) -> void
      def initialize(errors)
        super('The following errors occurred during validation execution:', errors)
      end
    end
  end
end
