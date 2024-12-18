# frozen_string_literal: true

require 'domainic/type/constraint/set'

module Domainic
  module Type
    # A module providing core type validation behavior.
    #
    # The Behavior module provides the foundation for type validation in the Domainic
    # system. It manages a set of constraints that define what makes a value valid
    # for a particular type and provides methods to validate values against these
    # constraints.
    #
    # Key features:
    # - Intrinsic constraints defined at the class level
    # - Instance-level constraint customization
    # - Support for both silent and exception-raising validation
    # - Case equality operator integration (===)
    #
    # @example Defining a custom type
    #   class MyType
    #     include Domainic::Type::Behavior
    #
    #     private
    #
    #     def initialize(**options)
    #       super
    #       constrain(:self, :string_check, :string)
    #       constrain(:length, :minimum, :range, minimum: 5)
    #     end
    #   end
    #
    # @example Using a custom type
    #   type = MyType.new
    #   type.validate("hello")     # => true
    #   type.validate("hi")        # => false
    #   type.validate!(123)        # raises TypeError
    #
    #   case "hello"
    #   when MyType then puts "Valid!"
    #   end
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    module Behavior
      # @rbs @constraint_set: Constraint::Set

      # Configure class methods when module is included.
      #
      # @param base [Class] The class including this module
      #
      # @return [void]
      # @rbs (Class | Module base) -> void
      def self.included(base)
        super
        base.extend(ClassMethods)
      end

      # Class methods for types including the Behavior module.
      #
      # These methods provide class-level validation capabilities and constraint
      # management.
      #
      # @api private
      #
      # @since 0.1.0
      module ClassMethods
        # @rbs @intrinsic_constraints: Constraint::Set

        # Convert the type to a String representation.
        #
        # @return [String] The type as a String
        # @rbs () -> String
        def to_s
          # @type self: Class & Behavior
          (name || '').split('::').last&.delete_suffix('Type') #: String
        end
        alias inspect to_s

        # Validate a value against this type.
        #
        # @param value [Object] The value to validate
        #
        # @return [Boolean] true if the value is valid
        # @rbs (untyped value) -> bool
        def validate(value)
          # @type self: Class & Behavior
          new.validate(value)
        end
        alias === validate

        # Validate a value against this type, raising an error on failure.
        #
        # @param value [Object] The value to validate
        #
        # @raise [TypeError] if the value is invalid
        # @return [Boolean] true if the value is valid
        # @rbs (untyped value) -> bool
        def validate!(value)
          # @type self: Class & Behavior
          new.validate!(value)
        end

        private

        # Add an intrinsic constraint to this type.
        #
        # @see Constraint::Set#add
        #
        # @return [void]
        # @rbs (
        #   Type::accessor accessor,
        #   String | Symbol constraint_type,
        #   ?untyped expectation,
        #   ?abort_on_failure: bool,
        #   ?concerning: String | Symbol,
        #   ?description: String | Symbol
        #   ) -> void
        def intrinsic(...)
          intrinsic_constraints.add(...)
        end

        # Get the set of intrinsic constraints for this type.
        #
        # @return [Constraint::Set] The constraint set
        # @rbs () -> Constraint::Set
        def intrinsic_constraints
          @intrinsic_constraints ||= Constraint::Set.new
        end

        # Delegate unknown methods to a new instance.
        #
        # @return [Object] The result of calling the method on a new instance
        # @rbs (Symbol method_name, *untyped arguments, **untyped keyword_arguments) -> Behavior
        def method_missing(method_name, *arguments, **keyword_arguments)
          return super unless respond_to_missing?(method_name, false)

          # @type self: Class & Behavior
          new.public_send(method_name, *arguments, **keyword_arguments)
        end

        # Check if an unknown method can be delegated.
        #
        # @param method_name [Symbol] The name of the method
        # @param _include_private [Boolean] Whether to include private methods
        #
        # @return [Boolean] true if the method can be delegated
        # @rbs (Symbol method_name, ?bool _include_private) -> bool
        def respond_to_missing?(method_name, _include_private = false)
          # @type self: Class & Behavior
          instance_methods.include?(method_name) || super
        end
      end

      # Initialize a new type instance.
      #
      # @param options [Hash] Configuration options for constraints
      #
      # @return [void]
      # @rbs (**untyped) -> void
      def initialize(**options)
        @constraints = self.class.send(:intrinsic_constraints).dup

        options.each_pair do |method_name, arguments|
          if arguments.is_a?(Hash)
            public_send(method_name, **arguments)
          else
            public_send(method_name, *arguments)
          end
        end
      end

      # Convert the type to a String representation.
      #
      # @return [String] The type as a String
      # @rbs () -> String
      def to_s
        if @constraints.description.empty?
          self.class.to_s
        else
          "#{self.class}(#{@constraints.description})"
        end
      end
      alias inspect to_s

      # Validate a value against this type's constraints.
      #
      # @param value [Object] The value to validate
      #
      # @return [Boolean] true if the value satisfies all constraints
      # @rbs (untyped value) -> bool
      def validate(value)
        @constraints.all? do |constraint|
          break false unless constraint.satisfied?(value) # fail fast because we don't care WHY we failed.

          true
        end
      end
      alias === validate

      # Validate a value against this type's constraints, raising an error on failure.
      #
      # @param value [Object] The value to validate
      #
      # @raise [TypeError] if the value fails any constraints
      # @return [Boolean] true if the value satisfies all constraints
      # @rbs (untyped value) -> bool
      def validate!(value)
        @constraints.each do |constraint|
          break if !constraint.satisfied?(value) && constraint.abort_on_failure?
        end

        return true unless @constraints.failures?

        message = if @constraints.violation_description.empty?
                    "Expected #{self}, but got #{value.class}"
                  else
                    "Expected #{self}, but got #{value.class}(#{@constraints.violation_description})"
                  end

        raise TypeError, message
      end

      private

      # Add a constraint to this type instance.
      #
      # @see Constraint::Set#add
      #
      # @return [self]
      # @rbs (
      #   Type::accessor accessor,
      #   String | Symbol constraint_type,
      #   ?untyped expectation,
      #   ?abort_on_failure: bool,
      #   ?concerning: String | Symbol,
      #   ?description: String | Symbol
      #   ) -> self
      def constrain(...)
        @constraints.add(...)
        self
      end
    end
  end
end
