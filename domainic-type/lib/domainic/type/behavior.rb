# frozen_string_literal: true

require 'domainic/type/constraint/resolver'

module Domainic
  module Type
    # @since 0.1.0
    module Behavior
      # @rbs @constraints: Hash[Symbol, Hash[Symbol, Constraint::Behavior]]

      # @rbs (Class | Module base) -> void
      def self.included(base)
        base.extend(ClassMethods)
      end

      # @since 0.1.0
      # @rbs module-self Behavior
      module ClassMethods
        # @rbs @intrinsic_constraints: Hash[Symbol, Hash[Symbol, Constraint::Behavior]]

        # @rbs (untyped value) -> bool
        def validate(value)
          new.validate(value)
        end
        alias === validate

        # @rbs (untyped value) -> bool
        def validate!(value)
          new.validate!(value)
        end

        private

        # @rbs (
        #   Symbol constrained,
        #   Symbol constraint_name,
        #   Symbol constraint_type,
        #   ?untyped? expectation,
        #   ?abort_on_failure: bool
        #   ) -> void
        def intrinsic(constrained, constraint_name, constraint_type, expectation = nil, **options)
          intrinsic_constraints[constrained] ||= {}
          intrinsic_constraints[constrained][constraint_name] ||=
            Constraint::Resolver.new(constraint_type).resolve!.new(constrained)
          intrinsic_constraints[constrained][constraint_name].expecting(expectation).with_options(**options)
        end

        # @rbs () -> Hash[Symbol, Hash[Symbol, Constraint::Behavior]]
        def intrinsic_constraints
          @intrinsic_constraints ||= {}
        end

        # @rbs (Symbol method_name, *untyped arguments, **untyped keyword_arguments) -> Behavior
        def method_missing(method_name, *arguments, **keyword_arguments)
          return super unless respond_to_missing?(method_name)

          if !arguments.empty? || !keyword_arguments.empty?
            new.public_send(method_name, *arguments, **keyword_arguments)
          else
            new.public_send(method_name)
          end
        end

        # @rbs override
        def respond_to_missing?(method_name, ...)
          instance_methods.include?(method_name) || super
        end
      end

      # @rbs (**untyped options) -> void
      def initialize(**options)
        @constraints = self.class.send(:intrinsic_constraints).transform_values { |hash| hash.transform_values(&:dup) }

        options.each_pair do |method_name, arguments|
          if arguments.is_a?(Hash)
            public_send(method_name, **arguments)
          else
            public_send(method_name, *arguments)
          end
        end
      end

      # @rbs () -> String
      def type
        (self.class.name || '').split('::').last.delete_suffix('Type')
      end

      # @rbs (untyped value) -> bool
      def validate(value)
        @constraints.all? do |_, accessors|
          accessors.all? do |_, constraint|
            result = constraint.satisfied?(value)
            break result unless result # fail fast to be more performant we aren't returning errors here.

            result
          end
        end
      end
      alias === validate

      # @rbs (untyped value) -> bool
      def validate!(value)
        failures = []
        type_failure = false

        @constraints.each_value do |accessors|
          accessors.each_value do |constraint|
            result = constraint.satisfied?(value)
            failures << constraint unless result
            type_failure = constraint.type_failure? unless result
            break result if !result && constraint.abort_on_failure?
          end
        end

        return true if failures.empty?

        raise_type_error!(failures, value, type_failure:) #: bool
      end

      private

      # @rbs (
      #   Symbol constrained,
      #   Symbol constraint_name,
      #   Symbol constraint_type,
      #   ?untyped? expectation,
      #   ?abort_on_failure: bool
      #   ) -> self
      def add_constraint(constrained, constraint_name, constraint_type, expectation = nil, **options)
        @constraints[constrained] ||= {}
        @constraints[constrained][constraint_name] ||=
          Constraint::Resolver.new(constraint_type).resolve!.new(constrained)
        @constraints[constrained][constraint_name].expecting(expectation).with_options(**options)
        self
      end

      # @rbs (Array[Constraint::Behavior], untyped value, type_failure: bool) -> void
      def raise_type_error!(failures, value, type_failure:)
        message = if type_failure
                    "Expected #{failures.map(&:description).join(', ')}, " \
                      "but got #{failures.map(&:failure_description).join(', ')} " \
                  else
                    "Expected a #{type} (#{failures.map(&:description).join(', ')}), " \
                      "but got a #{value.class} (#{failures.map(&:failure_description).join(', ')}) " \
                  end

        error = TypeError.new(message)
        error.set_backtrace(caller)
        raise error
      end
    end
  end
end