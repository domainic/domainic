# frozen_string_literal: true

require_relative 'base_constraint'

module Domainic
  module Type
    module Constraint
      # The base class for all Property based constraints.
      #
      # Property based constraints are used to enforce a condition on the subject.  The condition is typically a
      # predicate method that takes no arguments (i.e. `frozen?`). The constraint will enforce that the condition is met
      # by the validation subject. Child classes may either define conditions the subject will respond to, or define
      # custom methods to check the condition.
      #
      # @abstract subclasses must define the conditions the constraint supports using the {.conditions .conditions}
      #  class method.
      #
      # @!attribute [r] valid_conditions
      #  @!scope class
      #  The conditions the constraint supports.
      #  @return [Array<Symbol>]
      #
      # @since 0.1.0
      class PropertyConstraint < BaseConstraint
        class << self
          attr_reader :valid_conditions

          # Define what conditions the constraint supports
          #
          # @param conditions [Array<Symbol>] The predicate methods (ending with `?`) to check.
          # @return [void]
          def conditions(*conditions)
            @valid_conditions = conditions.map do |condition|
              condition.to_s.end_with?('?') ? condition.to_sym : :"#{condition}?"
            end.freeze
          end
        end

        # @!method condition
        #  The condition to enforce
        #  @return [Symbol]
        #
        # @!method condition=(value)
        #  Sets the condition to enforce
        #  @param value [Symbol] The condition to enforce
        #  @return [Symbol]
        #
        # @!method default_condition
        #  The default condition to enforce
        #  @return [nil]
        parameter :condition do
          desc 'The condition to enforce'
          coercer ->(value) { value.to_s.end_with?('?') ? value.to_sym : :"#{value}?" }
          validator ->(value) { self.class.valid_conditions.include?(value) }
          required
        end

        # Validate the subject against the constraint
        #
        # @param subject [Object] The subject to validate
        # @return [Boolean]
        def validate(subject)
          constrained_value = accessor == :self ? subject : subject.public_send(accessor)

          result = if respond_to?(:access_qualifier) && !access_qualifier.nil? && constrained_value.is_a?(Enumerable)
                     constrained_value.public_send(access_qualifier) do |qualified_subject|
                       check_condition(qualified_subject)
                     end
                   else
                     check_condition(constrained_value)
                   end

          interpret_result(result) ^ negated
        end

        protected

        # Interpret the result of the condition check
        # This is a hook method for subclasses to override to ensure the result is interpreted correctly as a boolean.
        #
        # @param result [Object] The result of the condition check
        # @return [Boolean]
        def interpret_result(result)
          !!result
        end

        private

        # Check the condition against the subject
        #
        # @param subject [Object] The subject to check the condition against.
        # @return [Boolean]
        def check_condition(subject)
          if subject.respond_to?(condition)
            subject.send(condition)
          else
            send(condition, subject)
          end
        end
      end
    end
  end
end
