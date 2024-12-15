# frozen_string_literal: true

module Domainic
  module Type
    # @since 0.1.0
    class TypeErrorMessageBuilder
      # @rbs (Behavior type, Behavior::ValidationResult result, untyped value) -> String
      def self.build(...)
        new(...).build
      end

      # @rbs (Behavior type, Behavior::ValidationResult result, untyped value) -> void
      def initialize(type, result, value)
        @type = type
        @result = result
        @value = value
      end

      # @rbs () -> String
      def build
        if @result.type_failure
          build_type_failure_message
        else
          build_constraint_failure_message
        end
      end

      private

      # @rbs () -> String
      def build_type_failure_message
        @result.failures.map do |failure|
          "  - Expected #{failure.description}, but got #{failure.failure_description}"
        end.join("\n")
      end

      # @rbs () -> String
      def build_constraint_failure_message
        lines = ["Expected a #{@type.type}, got a #{@value.class}:"]

        @result.failures.each do |failure|
          lines << "  - Expected #{failure.description}, but got #{failure.failure_description}"
        end

        lines.join("\n")
      end
    end
  end
end
