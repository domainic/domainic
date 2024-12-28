# frozen_string_literal: true

require 'domainic/command/errors/error'
require 'domainic/command/errors/execution_error'
require 'domainic/command/result/failure'
require 'domainic/command/result/success'

module Domainic
  module Command
    # @since 0.1.0
    module InstanceMethods
      # @rbs (**untyped) -> void

      # @rbs (**untyped context) -> (Result::Success | Result::Failure)
      def call(**context)
        call!(**context)
      rescue Error => e
        e.result
      end

      # @rbs (**untyped context) -> (Result::Success | Result::Failure)
      def call!(**context)
        input_context = self.class.send(:input_context_class).new(**context)
        @context = self.class.send(:runtime_context_class).new(**input_context.to_hash)
        execute
        output_context = self.class.send(:output_context_class).new(**@context.to_hash)
        Result::Success.new(output_context)
      rescue StandardError => e
        raise ExecutionError.new(self, result: Result::Failure.new(e))
      end

      # @rbs () -> void
      def execute
        raise NotImplementedError, "`#{self.class}` does not implement `#execute`"
      end

      private

      attr_reader :context #: Context::RunTimeContext

      # @rbs (?untyped? errors) -> void
      def fail!(errors = nil)
        raise ExecutionError.new(self, result: Result::Failure.new(errors))
      end
    end
  end
end
