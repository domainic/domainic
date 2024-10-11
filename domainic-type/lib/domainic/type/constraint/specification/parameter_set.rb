# frozen_string_literal: true

require_relative 'parameter'

module Domainic
  module Type
    module Constraint
      module Specification
        # A collection of Parameters for a {BaseConstraint constraint}.

        # @since 0.1.0
        class ParameterSet
          # Initialize a new instance of ParameterSet.
          #
          # @param base [Class<BaseConstraint>, BaseConstraint] The {BaseConstraint constraint} that the ParameterSet
          #  belongs to.
          # @return [ParameterSet]
          def initialize(base)
            @base = base
            @entries = {}.freeze
          end

          # Get a parameter by name.
          #
          # @param parameter_name [String, Symbol] The name of the parameter to get.
          # @return [Parameter, nil]
          def [](parameter_name)
            @entries[parameter_name.to_sym]
          end

          # Add a new parameter to the set.
          #
          # @see Parameter#initialize
          #
          # @param parameter_options [Hash] The options for configuring the parameter.
          # @return [self]
          def add(parameter_options)
            parameter = Parameter.new(@base, parameter_options)
            @entries = @entries.merge(parameter.name => parameter).freeze
            self
          end

          # Duplicate the ParameterSet with a new base class.
          #
          # @param new_base [Class<BaseConstraint>, BaseConstraint] The new base class for the duplicated ParameterSet.
          # @return [ParameterSet]
          def dup_with_base(new_base)
            dup.tap do |duped|
              duped.instance_variable_set(:@base, new_base)
              duped.instance_variable_set(
                :@entries,
                @entries.transform_values { |parameter| parameter.dup_with_base(new_base) }.freeze
              )
            end
          end

          private

          # Define a method to access the parameter values.
          #
          # @param method [Symbol] The method name to define.
          # @return [void]
          def method_missing(method, ...)
            return super unless respond_to_missing?(method)

            @entries.fetch(method)
          end

          # Check if the method is a valid parameter name.
          #
          # @param method [Symbol] The method name to check.
          # @param include_private [Boolean] true if private methods should be included, otherwise false.
          # @return [Boolean]
          def respond_to_missing?(method, include_private = false)
            @entries.key?(method) || super
          end
        end
      end
    end
  end
end
