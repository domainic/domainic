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
          # For type failures, we want a simple message since the type check failed immediately
          "Expected #{@type.type}, got #{value_description}"
        else
          # For constraint failures, we want a header plus indented failure details
          [
            "Expected #{@type.type}, got #{value_description}:",
            build_constraint_messages
          ].join("\n")
        end
      end

      private

      # @rbs () -> String
      def build_constraint_messages
        @result.failures.map do |failure|
          "  - Expected #{failure.description}, but got #{failure.failure_description}"
        end.join("\n")
      end

      # @rbs () -> String
      def value_description
        article = @value.class.to_s.match?(/^[AEIOU]/i) ? 'an' : 'a'
        "#{article} #{@value.class}"
      end
    end
  end
end
