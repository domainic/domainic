# frozen_string_literal: true

require 'domainic/command/errors/error'

module Domainic
  module Command
    # Error class raised when a command encounters an execution failure. This class provides access to
    # both the error message and the {Result} object containing detailed information about the failure.
    #
    # @example Handling execution errors
    #   begin
    #     command.call!
    #   rescue Domainic::Command::ExecutionError => e
    #     puts e.message           # Access the error message
    #     puts e.result.errors     # Access the detailed errors
    #     puts e.result.status_code # Access the status code
    #   end
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class ExecutionError < Error
      # The {Result} object containing detailed information about the execution failure
      #
      # @return [Result] The result object associated with the failure
      attr_reader :result #: Result

      # Creates a new execution error with the given message and result
      #
      # @param message [String] The error message describing what went wrong
      # @param result [Result] The result object containing detailed failure information
      #
      # @return [void]
      # @rbs (String message, Result result) -> void
      def initialize(message, result)
        @result = result
        super(message)
      end
    end
  end
end
