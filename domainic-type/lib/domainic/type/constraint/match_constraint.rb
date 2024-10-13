# frozen_string_literal: true

require_relative 'relational_constraint'

module Domainic
  module Type
    module Constraint
      # The `MatchConstraint` checks if the subject matches one or more expected patterns.
      # You can apply expectation qualifiers to control how the matching check is performed when comparing against
      # multiple values. Valid qualifiers include `:all?`, `:any?`, `:none?`, and `:one?`.
      #
      # @since 0.1.0
      class MatchConstraint < RelationalConstraint
        expectation :match?

        private

        # Override the check_expectation method to handle pattern matching.
        #
        # @param subject [Object] The value to check.
        # @return [Boolean] The result of the expectation check.
        def check_expectation(subject)
          expected.send(expectation_qualifier) do |qualified_expected|
            return false if subject.nil? || qualified_expected.nil?

            match_expectation(subject, qualified_expected)
          end
        end

        # Helper method to handle the match expectation logic.
        #
        # @param subject [Object] The subject value.
        # @param expected [Object] The expected pattern.
        # @return [Boolean] True if the subject matches the pattern, false otherwise.
        def match_expectation(subject, expected)
          if expected.is_a?(Regexp) && subject.respond_to?(:to_s)
            expected.match?(subject.to_s)
          elsif subject.is_a?(Regexp) && expected.respond_to?(:to_s)
            subject.match?(expected.to_s)
          else
            false
          end
        end
      end
    end
  end
end
