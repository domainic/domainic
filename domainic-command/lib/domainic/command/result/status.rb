# frozen_string_literal: true

module Domainic
  module Command
    class Result
      # Defines status codes for command execution results. These codes follow Unix exit code conventions,
      # making them suitable for CLI applications while remaining useful for other contexts.
      #
      # The status codes are specifically chosen to provide meaningful feedback about where in the command
      # lifecycle a failure occurred:
      # * 0 (SUCCESS) - The command completed successfully
      # * 1 (FAILED_AT_RUNTIME) - The command failed during execution
      # * 2 (FAILED_AT_INPUT) - The command failed during input validation
      # * 3 (FAILED_AT_OUTPUT) - The command failed during output validation
      #
      # @example Using with CLI
      #   class MyCLI
      #     def self.run
      #       result = MyCommand.call(args)
      #       exit(result.status_code)
      #     end
      #   end
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      module STATUS
        # Indicates successful command execution
        #
        # @return [Integer] status code 0
        SUCCESS = 0 #: Integer

        # Indicates a failure during command execution
        #
        # @return [Integer] status code 1
        FAILED_AT_RUNTIME = 1 #: Integer

        # Indicates a failure during input validation
        #
        # @return [Integer] status code 2
        FAILED_AT_INPUT = 2 #: Integer

        # Indicates a failure during output validation
        #
        # @return [Integer] status code 3
        FAILED_AT_OUTPUT = 3 #: Integer
      end
    end
  end
end
