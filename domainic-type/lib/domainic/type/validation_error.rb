# frozen_string_literal: true

module Domainic
  module Type
    # A class for formatting detailed type validation error messages.
    #
    # This class helps create clear, descriptive error messages when type validation
    # fails. It formats both type mismatches and constraint validation failures into
    # a readable multi-line message.
    #
    # @example Basic usage
    #   type = StringType.new
    #   failures = [LengthConstraint, FormatConstraint]
    #   actual = 123
    #
    #   ValidationError.details_for(type, failures, actual)
    #   # => "Expected a StringType got a Integer
    #   #     - Expected length >= 5, but got length of 3
    #   #     - Expected to match /\w+/, but got '123'"
    #
    # The error message format follows these principles:
    # - First line shows the expected type vs actual type
    # - Each constraint failure is listed with expected vs actual values
    # - Type failures are prioritized over constraint failures
    #
    # @api private
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class ValidationError
      # Format a validation error message.
      #
      # @overload details_for(type, failures, actual)
      #   @param type [Behavior] The type that validation failed for
      #   @param failures [Array<Constraint::Behavior>] The constraints that failed
      #   @param actual [Object] The actual value that failed validation
      #
      # @return [String] The formatted error message
      # @rbs (Behavior type, Array[Constraint::Behavior] failures, untyped actual) -> String
      def self.details_for(...)
        new(...).details
      end

      # Initialize a new validation error formatter.
      #
      # @param type [Behavior] The type that validation failed for
      # @param failures [Array<Constraint::Behavior>] The constraints that failed
      # @param actual [Object] The actual value that failed validation
      #
      # @return [void]
      # @rbs (Behavior type, Array[Constraint::Behavior] failures, untyped actual) -> void
      def initialize(type, failures, actual)
        @type = type
        @failures = failures
        @actual = actual
      end

      # Format the validation error message.
      #
      # @return [String] The formatted error message
      # @rbs () -> String
      def details
        [type_mismatch_message, *constraint_failure_messages].join("\n")
      end

      private

      # Format the type mismatch message.
      #
      # @return [String] The type mismatch message
      # @rbs () -> String
      def type_mismatch_message
        "Expected #{article_for(@type.inspect)} #{@type.inspect} " \
          "got #{article_for(@actual.class)} #{@actual.class}"
      end

      # Format the constraint failure messages.
      #
      # @return [Array<String>] The constraint failure messages
      # @rbs () -> Array[String]
      def constraint_failure_messages
        @failures.reject(&:type_failure?).map do |failure|
          "  - Expected #{failure.description}, but got #{failure.failure_description}"
        end
      end

      # Get the appropriate article (a/an) for a word.
      #
      # @param word [Class, Module, Object, String] The word to get an article for
      #
      # @return [String] The appropriate article
      # @rbs (Class | Module | Object | String word) -> String
      def article_for(word)
        word.to_s.match?(/^[AEIOU]/i) ? 'an' : 'a'
      end
    end
  end
end
