# frozen_string_literal: true

require_relative 'provisioned_constraint'

module Domainic
  module Type
    module Constraint
      module Provisioning
        # Provision staged {BaseConstraint constraints} for a {BaseType type}.
        #
        # @since 0.1.0
        class Provisioner
          # Initialize a new instance of Provisioner.
          #
          # @param base [BaseType] the base type.
          # @param accessor_name [String, Symbol] the name of the accessor.
          # @return [Provisioner] the new instance of Provisioner.
          def initialize(base, accessor_name)
            @accessor_name = accessor_name.to_sym
            @base = base
            @provisioned = {}
            @staged = {}
          end

          # Duplicate the provisioner with a new base.
          #
          # @param new_base [BaseType] the new base for the provisioner.
          # @return [Provisioner] the duplicated provisioner.
          def dup_with_base(new_base)
            dup.tap do |duped|
              duped.instance_variable_set(:@base, new_base)
              duped.instance_variable_set(
                :@provisioned,
                @provisioned.transform_values { |provisioned| provisioned.dup_with_base(new_base) }
              )
              duped.send(:provision_intrinsic_constraints)
            end
          end

          # Provision a constraint.
          #
          # @param name [String, Symbol] the name of the constraint.
          # @param options [Hash{String, Symbol => Object}] the parameters options for the constraint.
          # @return [ProvisionedConstraint] the provisioned constraint.
          def provision(name, **options)
            key = name.to_sym

            if @provisioned.key?(key)
              constraint = @provisioned[key]
              options.each_pair { |parameter, value| constraint.public_send(:"#{parameter}=", value) }
              return constraint
            end

            unless @staged.key?(key)
              raise ArgumentError, "#{@base.class} does not constrain `#{key}` on `#{@accessor_name}`"
            end

            provision_constraint(name, options)
          end

          # Stage a constraint that can later be provisioned.
          #
          # @param options [Hash{Symbol => Object}] the options for the constraint.
          # @option options [Hash{Symbol => Object}] :defaults ({ accessor: @accessor_name }) the default options for
          #  the constraint.
          # @option options [Boolean] :intrinsic (false) whether the constraint is intrinsic. Intrinsic constraints
          #  are not automatically provisioned when the type is instantiated.
          # @option options [String, Symbol] :name the name of the constraint. If this is not provided, it will default
          #  to the `:type` option.
          # @option options [String, Symbol] :type the type of the constraint.
          # @option options [Hash{Symbol => Object}] :validation_options ({}) the options for the validation.
          #
          # @return [void]
          def stage(**options)
            name = (options[:name] || options.fetch(:type)).to_sym
            @staged[name] = {
              defaults: { accessor: @accessor_name }.merge(options.fetch(:defaults, {})),
              intrinsic: options.fetch(:intrinsic, false),
              name:,
              type: options.fetch(:type),
              validation_options: options.fetch(:validation_options, {})
            }
          end

          # Convert the provisioner to an array of provisioned constraints.
          #
          # @return [Array<ProvisionedConstraint>] the provisioned constraints.
          def to_array
            @provisioned.values
          end
          alias to_a to_array

          private

          # Automatically provision constraints just by calling them.
          #
          # @param method [Symbol] the method to call.
          # @param arguments [Array<Object>] the arguments to pass to the method.
          # @param keyword_arguments [Hash{Symbol => Object}] the keyword arguments to pass to the method.
          # @return [ProvisionedConstraint] the provisioned constraint.
          def method_missing(method, *arguments, **keyword_arguments, &)
            return super unless respond_to_missing?(method)

            options = arguments.first.is_a?(Hash) ? arguments.first : keyword_arguments
            provision(method, **options)
          end

          # Provision the given constraint by name
          #
          # @param name [String, Symbol] the name of the constraint.
          # @param options [Hash{String, Symbol => Object}] the parameters options for the constraint.
          # @return [ProvisionedConstraint] the provisioned constraint.
          def provision_constraint(name, options)
            staged = @staged[name]
            constraint_class = resolve_constraint_class!(staged[:type])
            constraint_options = staged[:defaults].merge(options).merge(name: staged[:name])
            constraint = constraint_class.new(@base, **constraint_options)
            @provisioned[constraint.name] = ProvisionedConstraint.new(constraint, **staged[:validation_options])
          end

          # Provision intrinsic constraints.
          #
          # @return [void]
          def provision_intrinsic_constraints
            return if @base.is_a?(Class)

            @staged.select { |_, staged| staged[:intrinsic] }.each_key { |name| provision(name) }
          end

          # Resolve the constraint class by name
          #
          # @param name [String, Symbol] the name of the constraint.
          # @return [Class<Constraint::BaseConstraint>] the constraint class.
          def resolve_constraint_class!(name)
            constraint_classname =
              "Domainic::Type::Constraint::#{name.to_s.split(/[_\-\s]+/).map(&:capitalize).join}Constraint"
            unless Object.const_defined?(constraint_classname)
              filepath = Dir.glob(File.expand_path("../#{name}_constraint.rb", __dir__)).first
              raise ArgumentError, "Invalid constraint type `#{name}` for `#{@base}`" if filepath.nil?

              require filepath
            end

            Object.const_get(constraint_classname)
          end

          # Check if the provisioner responds to the method.
          #
          # @param method [Symbol] the method to check.
          # @param _include_private [Boolean]
          # @return [Boolean] `true` if the provisioner responds to the method, otherwise `false`.
          def respond_to_missing?(method, _include_private = false)
            @staged.key?(method) || @provisioned.key?(method) || super
          end
        end
      end
    end
  end
end
