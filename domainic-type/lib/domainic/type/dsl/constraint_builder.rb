# frozen_string_literal: true

module Domainic
  module Type
    module DSL
      # A DSL for defining {Constraint::BaseConstraint constraints} on a {BaseType type}.
      #
      # @since 0.1.0
      class ConstraintBuilder
        # Defaults for a constraint.
        #
        # @return [Hash{Symbol => Hash{Symbol => Object}}]
        CONSTRAINT_DEFAULTS = { defaults: {}, validation_options: {} }.freeze

        # Initialize a new instance of ConstraintBuilder.
        #
        # @param base [Class<BaseType>] the {BaseType type} to define constraints for.
        # @return [ConstraintBuilder] the new instance of ConstraintBuilder.
        def initialize(base)
          @base = base
          @data = {}
        end

        # Provision the constraints onto the {BaseType type}.
        #
        # @return [void]
        def build
          @data.each_pair do |accessor_name, constraints|
            constraints.each_pair do |constraint_name, constraint_data|
              @base.constraints.stage(accessor_name, constraint_name, **constraint_data)
            end
          end
        end

        # Define a constraint.
        #
        # @param constraint_type [String, Symbol] the type of the constraint.
        # @param name [String, Symbol] the name of the constraint.
        # @param fail_fast [Boolean] whether to fail fast on validation.
        # @raise [ArgumentError] if no accessor is currently being defined.
        # @return [self] the ConstraintBuilder.
        def constraint(constraint_type, name: nil, fail_fast: false)
          ensure_current_accessor!

          name = (name || constraint_type).to_sym
          @current_accessor[name] =
            CONSTRAINT_DEFAULTS.transform_values(&:dup).merge(name:, type: constraint_type.to_sym)
          @current_accessor[name][:validation_options][:fail_fast] = fail_fast
          self
        end

        # Define an accessor.
        #
        # @param accessor_name [String, Symbol] the name of the accessor.
        # @yield [self] the block to define constraints.
        # @return [self] the ConstraintBuilder.
        def define(accessor_name, &)
          @current_accessor_name = accessor_name.to_sym
          @current_accessor = @data[@current_accessor_name] = {}
          instance_exec(&) if block_given?
          self
        end

        # Duplicate the constraint builder with a new base.
        #
        # @param new_base [Class<BaseType>] the new base for the constraint builder.
        # @return [ConstraintBuilder] the duplicated constraint builder.
        def dup_with_base(new_base)
          dup.tap { |duped| duped.instance_variable_set(:@base, new_base) }
        end

        # Define an intrinsic constraint.
        #
        # @param constraint_type [String, Symbol] the type of the constraint.
        # @param name [String, Symbol] the name of the constraint.
        # @param fail_fast [Boolean] whether to fail fast on validation.
        # @param options [Hash{String, Symbol => Object}] the options for the constraint.
        #  @see Constraint::Provisioning::Provisioner#stage
        # @raise [ArgumentError] if no accessor is currently being defined.
        # @return [self] the ConstraintBuilder.
        def intrinsic_constraint(constraint_type, name: nil, fail_fast: false, **options)
          ensure_current_accessor!

          name = (name || constraint_type).to_sym
          @current_accessor[name] =
            CONSTRAINT_DEFAULTS.transform_values(&:dup).merge(name:, type: constraint_type.to_sym, intrinsic: true)
          @current_accessor[name][:defaults].merge!(options)
          @current_accessor[name][:validation_options][:fail_fast] = fail_fast
          self
        end

        private

        # Ensure that an accessor is defined.
        #
        # @raise [ArgumentError] if no accessor is currently being defined.
        # @return [void]
        def ensure_current_accessor!
          return if @current_accessor

          raise ArgumentError, 'No accessor currently being defined.'
        end
      end
    end
  end
end
