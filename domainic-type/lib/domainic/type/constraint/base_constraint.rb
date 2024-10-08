# frozen_string_literal: true

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
        # @dynamic description, name, parameters
        attr_reader :description, :name, :parameters

        class << self
          # The parameters of the constraint.
          #
          # @return [ParameterSet]
          def parameters
            @parameters ||= ParameterSet.new(self)
          end
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
