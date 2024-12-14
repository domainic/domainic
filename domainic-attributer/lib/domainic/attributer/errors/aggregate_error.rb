# frozen_string_literal: true

require 'domainic/attributer/errors/error'

module Domainic
  module Attributer
    # A specialized error class that combines multiple errors into a single error.
    #
    # This error class is used when multiple errors occur during a single operation and
    # need to be reported together. It maintains a list of individual errors while providing
    # a formatted message that includes details from all errors.
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.2.0
    class AggregateError < Error
      # @return [Array<StandardError>] the collection of errors that were aggregated
      attr_reader :errors #: Array[StandardError]

      # Initialize a new AggregateError instance.
      #
      # @param message [String] the main error message
      # @param errors [Array<StandardError>] the collection of errors to aggregate
      #
      # @return [void]
      # @rbs (String message, Array[StandardError] errors) -> void
      def initialize(message, errors)
        @errors = errors
        super("#{message}\n#{errors.map { |error| "  - #{error.message}" }.join("\n")}")
      end
    end
  end
end
