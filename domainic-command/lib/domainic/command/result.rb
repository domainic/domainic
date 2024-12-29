# frozen_string_literal: true

require 'domainic/command/result/error_set'
require 'domainic/command/result/status'

module Domainic
  module Command
    # A value object representing the outcome of a command execution. The Result class provides
    # a consistent interface for handling both successful and failed command executions, including
    # return data and error information.
    #
    # Results are created through factory methods rather than direct instantiation, making the
    # intent of the result clear:
    #
    # @example Creating a success result
    #   result = Result.success(value: 42)
    #   result.successful? #=> true
    #   result.value #=> 42
    #
    # @example Creating a failure result
    #   result = Result.failure_at_input(
    #     { name: "can't be blank" },
    #     context: { attempted_name: nil }
    #   )
    #   result.failure? #=> true
    #   result.errors[:name] #=> ["can't be blank"]
    #
    # Results use status codes that align with Unix exit codes, making them suitable for
    # CLI applications:
    # * 0 - Successful execution
    # * 1 - Runtime failure
    # * 2 - Input validation failure
    # * 3 - Output validation failure
    #
    # @example CLI usage
    #   def self.run
    #     result = MyCommand.call(args)
    #     puts result.errors.full_messages if result.failure?
    #     exit(result.status_code)
    #   end
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class Result
      # @rbs @data: Struct
      # @rbs @errors: ErrorSet
      # @rbs @status_code: Integer

      # The structured data returned by the command
      #
      # @return [Struct] A frozen struct containing the command's output data
      attr_reader :data #: Struct

      # The errors that occurred during command execution
      #
      # @return [ErrorSet] The set of errors from the command
      attr_reader :errors #: ErrorSet

      # The status code indicating the result of the command execution
      #
      # @return [Integer] The status code (0 for success, non-zero for failures)
      attr_reader :status_code #: Integer

      # Creates a new failure result with the given status
      #
      # @param errors [Object] The errors that caused the failure
      # @param context [Hash] Optional context data for the failure
      # @param status [Integer] The status code for the failure (defaults to FAILED_AT_RUNTIME)
      #
      # @return [Result] A new failure result
      # @rbs (untyped errors, ?Hash[String | Symbol, untyped] context, ?status: Integer) -> Result
      def self.failure(errors, context = {}, status: STATUS::FAILED_AT_RUNTIME)
        new(status, context:, errors:)
      end

      # Creates a new input validation failure result
      #
      # @param errors [Object] The validation errors
      # @param context [Hash] Optional context data for the failure
      #
      # @return [Result] A new input validation failure result
      # @rbs (untyped errors, ?Hash[String | Symbol, untyped] context) -> Result
      def self.failure_at_input(errors, context = {})
        new(STATUS::FAILED_AT_INPUT, context:, errors:)
      end

      # Creates a new output validation failure result
      #
      # @param errors [Object] The validation errors
      # @param context [Hash] Optional context data for the failure
      #
      # @return [Result] A new output validation failure result
      # @rbs (untyped errors, ?Hash[String | Symbol, untyped] context) -> Result
      def self.failure_at_output(errors, context = {})
        new(STATUS::FAILED_AT_OUTPUT, context:, errors:)
      end

      # Creates a new success result
      #
      # @param context [Hash] The successful result data
      #
      # @return [Result] A new success result
      # @rbs (Hash[String | Symbol, untyped] context) -> Result
      def self.success(context)
        new(STATUS::SUCCESS, context:)
      end

      # Creates a new result instance
      #
      # @param status_code [Integer] The status code for the result
      # @param context [Hash] The data context for the result
      # @param errors [Object, nil] Any errors that occurred
      #
      # @raise [ArgumentError] If status_code is invalid or context is not a Hash
      # @return [void]
      # @rbs (Integer status, ?context: Hash[String | Symbol, untyped], ?errors: untyped) -> void
      def initialize(status_code, context: {}, errors: nil)
        initialize_status_code(status_code)
        initialize_data(context)
        @errors = ErrorSet.new(errors)
      end
      private_class_method :new

      # Indicates whether the command failed
      #
      # @return [Boolean] true if the command failed; false otherwise
      # @rbs () -> bool
      def failure?
        status_code != STATUS::SUCCESS
      end
      alias failed? failure?

      # Indicates whether the command succeeded
      #
      # @return [Boolean] true if the command succeeded; false otherwise
      # @rbs () -> bool
      def successful?
        status_code == STATUS::SUCCESS
      end
      alias success? successful?

      private

      # Initializes the data struct from the context hash
      #
      # @param context [Hash] The context hash to convert to a struct
      # @raise [ArgumentError] If context is not a Hash
      # @return [void]
      def initialize_data(context)
        raise ArgumentError, ':context must be a Hash' unless context.is_a?(Hash)

        context = context.transform_keys(&:to_sym)
        @data = Struct.new(nil).new.freeze if context.empty?
        @data = Struct.new(*context.keys, keyword_init: true).new(**context).freeze unless context.empty?
      end

      # Validates and initializes the status code
      #
      # @param status_code [Integer] The status code to validate
      # @raise [ArgumentError] If the status code is not valid
      # @return [void]
      def initialize_status_code(status_code)
        unless STATUS.constants.map { |c| STATUS.const_get(c) }.include?(status_code)
          raise ArgumentError, "invalid status code: #{status_code}"
        end

        @status_code = status_code
      end

      # Delegate method calls to the data struct
      #
      # @param method_name [String, Symbol] The method name to call
      #
      # @return [Object] The result of the method call
      # @rbs override
      def method_missing(method_name, ...)
        return super unless respond_to_missing?(method_name)

        data.public_send(method_name.to_sym)
      end

      # Indicates whether the data struct responds to the given method
      #
      # @param method_name [String, Symbol] The method name to check
      # @param _include_private [Boolean] Whether to include private methods
      #
      # @return [Boolean] `true` if the data struct responds to the method; `false` otherwise
      # @rbs (String | Symbol method_name, ?bool include_private) -> bool
      def respond_to_missing?(method_name, _include_private = false)
        data.respond_to?(method_name.to_sym) || super
      end
    end
  end
end
