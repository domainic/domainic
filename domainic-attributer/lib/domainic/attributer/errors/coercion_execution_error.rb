# frozen_string_literal: true

require 'domainic/attributer/errors/error'

module Domainic
  module Attributer
    # A specialized error class for coercion execution failures
    #
    # This error class is used when a coercion fails during attribute value
    # processing. It captures the failing coercer to provide context about which
    # step in the coercion chain caused the failure
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.2.0
    class CoercionExecutionError < Error
      # Get the coercer that failed
      #
      # @return [Proc, Symbol] the coercer that failed
      attr_reader :coercer #: Attribute::Coercer::handler

      # Initialize a new CoercionExecutionError instance
      #
      # @api private
      # @!visibility private
      #
      # @param message [String] the error message
      # @param coercer [Proc, Symbol] the coercer that failed
      #
      # @return [CoercionExecutionError] the new CoercionExecutionError instance
      # @rbs (String message, Attribute::Coercer::handler coercer) -> void
      def initialize(message, coercer)
        @coercer = coercer
        super(message)
      end
    end
  end
end
