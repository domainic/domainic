# frozen_string_literal: true

require_relative '../dsl/parameter_builder'
require_relative 'parameter_set'

module Domainic
  module Type
    module Constraint
      # The base class for all constraints.
      #
      # @abstract Subclass and override {#validate} to implement a new constraint.
      #
      # @!attribute [r] description
      #  The description of the constraint.
      #  @return [String, nil]
      #
      # @!attribute [r] name
      #  The name of the constraint.
      #  @return [Symbol]
      #
      # @!attribute [r] parameters
      #  The parameters of the constraint.
      #  @return [ParameterSet]
      #
      # @since 0.1.0
      class BaseConstraint
        # Valid accessors for the constraint.
        #
        # @see #accessor
        #
        # @return [Array<Symbol>]
        VALID_ACCESSORS = %i[begin count end first keys last length self size values].freeze

        attr_reader :description, :name, :parameters

        class << self
          # Define a parameter for the constraint.
          #
          # @example Define a parameter for the constraint.
          #  class MyConstraint < BaseConstraint
          #    parameter :my_parameter do |parameter|
          #      desc 'My parameter description.'
          #      coercer lambda(&:to_s)
          #      default 'default value'
          #      required
          #      validator ->(value) { value.is_a?(String) }
          #      on_change do
          #        some_other_parameter = my_parameter
          #      end
          #    end
          #  end
          #
          # @param parameter_name [Symbol] The name of the parameter.
          # @yield [DSL::ParameterBuilder] The block to build the parameter.
          # @return [void]
          def parameter(parameter_name, &)
            parameter_builder.define(parameter_name, &).build!
          end

          # The parameters of the constraint.
          #
          # @return [ParameterSet]
          def parameters
            @parameters ||= ParameterSet.new(self)
          end

          private

          # Ensure the {.parameters} are properly inherited.
          #
          # @param subclass [Class<BaseConstraint>] The subclass inheriting from the constraint.
          # @return [void]
          def inherited(subclass)
            super
            subclass.instance_variable_set(:@parameter_builder, parameter_builder.dup_with_base(subclass))
            subclass.send(:parameter_builder).build!
          end

          # The {DSL::ParameterBuilder} for the constraint.
          #
          # @return [DSL::ParameterBuilder]
          def parameter_builder
            @parameter_builder ||= DSL::ParameterBuilder.new(self)
          end
        end

        # @!method accessor
        #  The accessor for the constraint. The method used to access the constrained value.
        #  @return [Symbol]
        #
        # @!method accessor=(value)
        #  Set the accessor for the constraint.
        #  @see VALID_ACCESSORS
        #  @param value [Symbol] The accessor for the constraint.
        #  @return [void]
        #
        # @!method accessor_default
        #  The default accessor for the constraint.
        #  @return [Symbol] the default accessor is `:self`.
        parameter :accessor do
          desc 'The method used to access the constrained value'
          coercer lambda(&:to_sym)
          default :self
          validator ->(value) { VALID_ACCESSORS.include?(value) }
          required
        end

        # @!method negated
        #  Indicates whether to negate the constraint.
        #  @return [Boolean]
        #
        # @!method negated=(value)
        #  Set the constraint to be negated.
        #  @param value [Boolean] The value to negate the constraint.
        #  @return [void]
        #
        # @!method negated_default
        #  The default value for the negated constraint.
        #  @return [false] the default value is `false`.
        parameter :negated do
          desc 'Negate the constraint'
          default false
          validator ->(value) { true.equal?(value) || false.equal?(value) }
          required
        end

        # Initialize a new instance of BaseConstraint.
        #
        # @param base [BaseType] The type the constraint is belongs to.
        # @param description [String, nil] The {#description} of the constraint.
        # @param name [String, Symbol] The {#name} of the constraint.
        # @param parameters [Hash{Symbol => Object}] The parameters of the constraint.
        #
        # @return [BaseConstraint] the new instance of BaseConstraint.
        def initialize(base, description: nil, name: '', **parameters)
          @base = base
          @description = description
          @name = name.empty? ? parse_name(self.class.name) : name.to_sym
          @parameters = self.class.parameters.dup_with_base(self)

          parameters.each do |parameter, value|
            self.parameters.public_send(parameter)&.value = value
          end
        end

        # Validate the subject against the constraint.
        #
        # @param subject [Object] The subject to validate.
        # @return [Boolean] true if the subject is valid, otherwise false.
        def validate(subject)
          raise NotImplementedError, "#{self.class} does not implement #{__method__}"
        end

        private

        # Parse the class name into a symbol.
        #
        # @param name [String, Symbol] The name of the class.
        # @return [Symbol] the parsed name.
        def parse_name(name)
          name.to_s.split('::').last
              .delete_suffix('Constraint')
              .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
              .gsub(/([a-z\d])([A-Z])/, '\1_\2')
              .downcase
              .to_sym
        end
      end
    end
  end
end
