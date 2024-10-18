# frozen_string_literal: true

require_relative 'constraint/provisioning/constraint_set'
require_relative 'dsl/constraint_builder'

module Domainic
  module Type
    # The base class for all Domainic types.
    #
    # @!attribute [r] constraints
    #  The constraints for the type.
    #  @return [Constraint::Provisioning::ConstraintSet]
    #
    # @abstract
    # @since 0.1.0
    class BaseType
      attr_reader :constraints

      class << self
        # Provision a constraint for the type.
        #
        # @param accessor_name [String, Symbol] the name of the accessor.
        # @yield [DSL::ConstraintBuilder] the block to define constraints.
        # @return [void]
        def constrain(accessor_name, &)
          constraint_builder.define(accessor_name, &).build
        end

        # The constraints for the type.
        #
        # @return [Constraint::Provisioning::ConstraintSet]
        def constraints
          @constraints ||= Constraint::Provisioning::ConstraintSet.new(self)
        end

        private

        # The constraint builder for the type.
        #
        # @return [DSL::ConstraintBuilder]
        def constraint_builder
          @constraint_builder ||= DSL::ConstraintBuilder.new(self)
        end

        # Ensure constraints are properly inherited.
        #
        # @param subclass [Class<BaseType>] the subclass inheriting from BaseType.
        # @return [void]
        def inherited(subclass)
          super
          subclass.instance_variable_set(:@constraint_builder, constraint_builder.dup_with_base(subclass))
          subclass.send(:constraint_builder).build
        end
      end

      # Initialize a new instance of BaseType.
      #
      # @param options [Hash{String, Symbol => Object}] the options to initialize the type with.
      # @return [BaseType] the new instance of BaseType.
      def initialize(**options)
        @constraints = self.class.constraints.dup_with_base(self)
        options.transform_keys(&:to_sym).each_pair do |method, arguments|
          if arguments.is_a?(Hash)
            public_send(method, **arguments)
          else
            public_send(method, *arguments)
          end
        end
      end

      # Validate the subject against the constraints.
      #
      # @param subject [Object] the subject to validate.
      # @return [Boolean] true if the subject satisfies the constraints, false otherwise.
      def validate(subject)
        constraints.to_array.all? do |constraint|
          valid = constraint.validate(subject)
          break false if !valid && constraint.validation_options.fail_fast?

          valid
        end
      end
    end
  end
end
