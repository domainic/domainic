# frozen_string_literal: true

require 'domainic/command/errors/error'

module Domainic
  module Command
    # @since 0.1.0
    class ExecutionError < Error
      # @rbs @command: Command
      # @rbs @result: Result::Failure

      attr_reader :command #: Command
      attr_reader :result #: Result::Failure

      def initialize(command, result)
        @command = command
        @result = result
        super("#{command.class} failed!")
      end
    end
  end
end
