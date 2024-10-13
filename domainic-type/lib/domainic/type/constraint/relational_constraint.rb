# frozen_string_literal: true

require_relative 'specification/with_access_qualification'
require_relative 'base_constraint'

module Domainic
  module Type
    module Constraint
      # The base class for all Relational constraints.
      #
      # Relational based constraints are used to enforce an expectation or comparison on the subject.  The condition is
      # typically a predicate method that takes one argument (i.e. `include?`). The constraint will enforce that the
      # expectation is met by the validation subject. Child classes may either define an expectation the subject will
      # respond to, or define custom methods to check the expectation.
      #
      # @abstract subclasses must define an expectation the constraint supports using the {.expectation .expectation}
      #  class method.
      #
      # @!attribute [r] expectation
      #  The expectation the constraint supports.
      #  @return [Symbol] the expectation method.
      #
      # @since 0.1.0
      class RelationalConstraint < BaseConstraint
        VALID_EXPECTATION_QUALIFIERS = Specification::WithAccessQualification::VALID_ACCESS_QUALIFIERS

        attr_reader :expectation

        class << self
          # Define or retrieve the expectation method to be used by the constraint.
          #
          # @param expectation_method [Symbol, nil] The method to call on the subject or constraint. If no method is
          #   provided, the current expectation will be returned.
          # @raise [ArgumentError] if the expectation method is not a symbol.
          # @return [Symbol] The expectation method.
          def expectation(expectation_method)
            raise ArgumentError, 'Expectation method must be a symbol' unless expectation_method.is_a?(Symbol)

            @expectation = expectation_method
          end
        end

        # Determines how the expectation should be applied across multiple expected values.
        # Valid qualifiers are `:all?`, `:any?`, `:none?`, or `:one?`. This controls whether the subject must satisfy
        # all, any, none, or just one of the expected values.
        #
        # @!method expectation_qualifier
        #  @return [Symbol] The expectation qualifier.
        #
        # @!method expectation_qualifier=(value)
        #  Sets the expectation qualifier.
        #  @param value [Symbol] The expectation qualifier.
        #  @return [Symbol] The expectation qualifier.
        #
        # @!method default_expectation_qualifier
        #  The default expectation qualifier.
        #  @return [Symbol] The default expectation qualifier is `:all?`.
        parameter :expectation_qualifier do
          desc 'Determines how the expectation should be applied across multiple expected values. Valid qualifiers ' \
               'are `:all?`, `:any?`, `:none?`, or `:one?`.'
          default :all?
          coercer ->(value) { value.to_s.end_with?('?') ? value.to_sym : :"#{value}?" }
          validator ->(value) { value.nil? || VALID_EXPECTATION_QUALIFIERS.include?(value) }
          required
        end

        # The expected value(s) to compare the subject against. This can be an array of values or types that
        # the subject is expected to match.
        #
        # @!method expected
        #  @return [Array<Object>] The expected value(s).
        #
        # @!method expected=(value)
        #  Sets the expected value(s).
        #  @return [Array<Object>] The expected value(s).
        #
        # @!method default_expected
        #  The default expected values.
        #  @return [Array{Object>} The default expected values.
        parameter :expected do
          desc 'The expected value(s) to compare the subject against. This can be an array of values or types that ' \
               'the subject is expected to match.'
          default []

          coercer do |value|
            if value.is_a?(Array)
              value
            else
              value.nil? ? [nil] : [value]
            end
          end

          validator ->(value) { value.is_a?(Array) && !value.empty? }
          required
        end

        # Initialize a new instance of `RelationalConstraint`.
        #
        # @param base [Class<TypeBase>, TypeBaseType] The base type class.
        # @raise [NotImplementedError] if the subclass does not define an expectation.
        # @return [RelationalConstraint] The new constraint instance.
        def initialize(base)
          super
          @expectation = self.class.instance_variable_get(:@expectation)
          raise NotImplementedError, "#{self.class} must define an expectation" if @expectation.nil?
        end

        # Validate the subject against the current expectation.
        #
        # @param subject [Object] The value to validate.
        # @return [Boolean] true if the subject satisfies the expectation, false otherwise.
        def validate(subject)
          constrained_value = accessor == :self ? subject : subject.send(accessor)

          result = if respond_to?(:access_qualifier) && !access_qualifier.nil? && constrained_value.is_a?(Enumerable)
                     constrained_value.send(access_qualifier) { |qualified| check_expectation(qualified) }
                   else
                     check_expectation(constrained_value)
                   end

          interpret_result(result) ^ negated
        end

        protected

        # Hook to customize how the result of the expectation check is interpreted.
        #
        # @param result [Object] The result of the expectation check.
        # @return [Boolean] The interpreted result.
        def interpret_result(result)
          !!result
        end

        private

        # Checks the expectation on the subject. Calls the expectation method on the subject if it responds to it,
        # otherwise calls a method defined in the constraint class.
        #
        # @param subject [Object] The value to check.
        # @return [Boolean] The result of the expectation check.
        def check_expectation(subject)
          expected.send(expectation_qualifier) do |qualified_expected|
            if subject.respond_to?(expectation)
              subject.send(expectation, qualified_expected)
            elsif respond_to?(expectation, true)
              send(expectation, subject, qualified_expected)
            else
              raise NoMethodError, "Neither subject nor #{self.class} implements #{@expectation}"
            end
          end
        end
      end
    end
  end
end
