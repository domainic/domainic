# frozen_string_literal: true

require_relative 'validation_options'

module Domainic
  module Type
    module Constraint
      module Provisioning
        # A provisioned or activated constraint for a {BaseType type}.
        #
        # @!attribute [r] validation_options
        #  The validation options for the constraint.
        #  @return [ValidationOptions] the validation options for the constraint.
        #
        # @since 0.1.0
        class ProvisionedConstraint
          attr_reader :validation_options

          # Initialize a new instance of ProvisionedConstraint.
          #
          # @param constraint [BaseConstraint] the constraint instance.
          # @param validation_options [Hash{String, Symbol => Object}] the validation options for the constraint.
          # @return [ProvisionedConstraint] the new instance of ProvisionedConstraint.
          def initialize(constraint, **validation_options)
            @constraint = constraint
            @validation_options = ValidationOptions.new(**validation_options)
          end

          # Duplicate the constraint with a new base.
          #
          # @param new_base [BaseType] the new base for the constraint.
          # @return [ProvisionedConstraint] the duplicated constraint.
          def dup_with_base(new_base)
            dup.tap do |duped|
              duped.instance_variable_set(:@constraint, @constraint.dup_with_base(new_base))
            end
          end

          private

          # Delegate all missing methods to the constraint.
          #
          # @param method [Symbol] the method to delegate.
          # @return [Object] the result of the delegated method.
          def method_missing(method, ...)
            return super unless respond_to_missing?(method)

            @constraint.public_send(method, ...)
          end

          # Check if the constraint responds to the method.
          #
          # @param method [Symbol] the method to check.
          # @param _include_private [Object]
          # @return [Boolean] `true` if the constraint responds to the method, otherwise `false`.
          def respond_to_missing?(method, _include_private = false)
            @constraint.respond_to?(method) || super
          end
        end
      end
    end
  end
end
