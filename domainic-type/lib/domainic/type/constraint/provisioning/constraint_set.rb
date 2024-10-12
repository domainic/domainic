# frozen_string_literal: true

require_relative 'provisioner'

module Domainic
  module Type
    module Constraint
      module Provisioning
        # A collection of constraints belonging to a {BaseType type}.
        #
        # @since 0.1.0
        class ConstraintSet
          # Initialize a new instance of ConstraintSet.
          #
          # @param base [Class<BaseType>, BaseType] the base type.
          # @return [ConstraintSet] the new instance of ConstraintSet.
          def initialize(base)
            @base = base
            @entries = {}
          end

          # Duplicate the constraint set with a new base.
          #
          # @param new_base [BaseType] the new base for the constraint set.
          # @return [ConstraintSet] the duplicated constraint set.
          def dup_with_base(new_base)
            dup.tap do |duped|
              duped.instance_variable_set(:@base, new_base)
              duped.instance_variable_set(
                :@entries,
                @entries.transform_values { |provisioner| provisioner.dup_with_base(new_base) }
              )
            end
          end

          # Stage a constraint for provisioning.
          #
          # @param accessor_name [String, Symbol] the name of the accessor.
          # @param constraint_name [String, Symbol] the name of the constraint.
          # @param options [Hash{String, Symbol => Object}] the options for the provisioned constraint.
          #
          # @option options [Hash{String, Symbol => Object}] defaults ({}) the default parameter values for the
          #  constraint.
          # @option options [String] description (nil) the description of the constraint.
          # @option options [String, Symbol] name (nil) the name of the constraint.
          # @option options [String, Symbol] type the type of the constraint.
          # @option options [Hash{String, Symbol => Object}] validation_options ({}) the validation options for the
          #  constraint.
          #
          # @return [self] the ConstraintSet.
          def stage(accessor_name, constraint_name, **options)
            accessor_key = accessor_name.to_sym
            constraint_key = constraint_name.to_sym
            @entries[accessor_key] ||= Provisioner.new(@base, accessor_key)
            @entries[accessor_key].stage(name: constraint_key, **options)
            self
          end

          # Convert the set to an array of provisioned constraints.
          #
          # @return [Array<ProvisionedConstraint>] the array of provisioned constraints.
          def to_array
            @entries.values.flat_map(&:to_array)
          end
          alias to_a to_array

          private

          # Delegate all entries hash.
          #
          # @param method [Symbol] the method to delegate.
          # @return [Object] the result of the delegated method.
          def method_missing(method, ...)
            return super unless respond_to_missing?(method)

            @entries.fetch(method)
          end

          # Check if the entries hash responds to the method.
          #
          # @param method [Symbol] the method to check.
          # @param _include_private [Boolean]
          # @return [Boolean] `true` if the entries hash responds to the method, otherwise `false`.
          def respond_to_missing?(method, _include_private = false)
            @entries.key?(method) || super
          end
        end
      end
    end
  end
end
