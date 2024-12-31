# frozen_string_literal: true

require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # A constraint for validating string case formatting.
      #
      # This constraint verifies that string values conform to specific case formats:
      # - upper: all characters are uppercase
      # - lower: all characters are lowercase
      # - mixed: contains both uppercase and lowercase characters
      # - title: words are capitalized (first letter uppercase, rest lowercase)
      #
      # @example Uppercase validation
      #   constraint = CaseConstraint.new(:self, :upper)
      #   constraint.satisfied?("HELLO")  # => true
      #   constraint.satisfied?("Hello")  # => false
      #
      # @example Title case validation
      #   constraint = CaseConstraint.new(:self, :title)
      #   constraint.satisfied?("Hello World")  # => true
      #   constraint.satisfied?("hello world")  # => false
      #
      # @example Mixed case validation
      #   constraint = CaseConstraint.new(:self, :mixed)
      #   constraint.satisfied?("helloWORLD")  # => true
      #   constraint.satisfied?("HELLO")      # => false
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class CaseConstraint
        # @rbs!
        #   type expected = :upper | :lower | :mixed | :title

        include Behavior #[expected, untyped, {}]

        # Valid case format options
        #
        # @return [Array<Symbol>] List of valid case formats
        VALID_CASES = %i[upper lower mixed title].freeze #: Array[expected]

        # Get a human-readable description of the case requirement.
        #
        # @deprecated this method will be removed in version 0.1.0
        #
        # @example
        #   constraint = CaseConstraint.new(:self, :upper)
        #   constraint.short_description # => "upper case"
        #
        # @return [String] A description of the case requirement
        # @rbs override
        def short_description
          "#{@expected} case"
        end

        # Get a human-readable description of why case validation failed.
        #
        # @deprecated this method will be removed in version 0.1.0
        #
        # @example
        #   constraint = CaseConstraint.new(:self, :upper)
        #   constraint.satisfied?("Hello")
        #   constraint.short_violation_description # => "not upper case"
        #
        # @return [String] A description of the case mismatch
        # @rbs override
        def short_violation_description
          "not #{@expected} case"
        end

        protected

        # Check if the string matches the expected case format.
        #
        # @return [Boolean] true if the string matches the expected case
        # @rbs override
        def satisfies_constraint?
          case @expected
          when :upper
            @actual == @actual.upcase
          when :lower
            @actual == @actual.downcase
          when :title
            # Use map and join to preserve original whitespace
            @actual == @actual.scan(/[^\s]+/).map(&:capitalize).join(
              @actual.match(/\s+/).to_s
            )
          when :mixed
            !(@actual == @actual.upcase || @actual == @actual.downcase)
          end
        end

        # Validate that the expectation is a valid case format.
        #
        # @param expectation [Object] The case format to validate
        #
        # @raise [ArgumentError] if the expectation is not a valid case format
        # @return [void]
        # @rbs override
        def validate_expectation!(expectation)
          raise ArgumentError, "case must be one of: #{VALID_CASES.join(', ')}" unless VALID_CASES.include?(expectation)
        end
      end
    end
  end
end
