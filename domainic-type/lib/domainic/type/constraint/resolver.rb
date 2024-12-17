# frozen_string_literal: true

module Domainic
  module Type
    module Constraint
      # @rbs!
      #  interface _ConstraintClass
      #    def new: (Behavior::accessor_symbol accessor, ?untyped expectation, **untyped options) -> Behavior
      #  end

      # A factory class responsible for dynamically loading and resolving constraint types.
      #
      # The Resolver handles the dynamic loading and instantiation of constraint classes based on
      # their type symbols. It manages the conversion of constraint type symbols (like :string or
      # :numeric) into their corresponding constraint classes (like StringConstraint or
      # NumericConstraint).
      #
      # Key responsibilities:
      # - Converting constraint type symbols into file paths
      # - Loading constraint class files dynamically
      # - Resolving constraint class constants
      # - Providing clear error messages for unknown constraints
      #
      # @example Resolving a string constraint
      #   resolver = Resolver.new(:string)
      #   string_constraint_class = resolver.resolve! # => StringConstraint
      #
      # @example Resolving an unknown constraint
      #   resolver = Resolver.new(:unknown)
      #   resolver.resolve! # raises ArgumentError: Unknown constraint: unknown
      #
      # @api private
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class Resolver
        # @rbs @constant_name: String
        # @rbs @constraint_type: Symbol
        # @rbs @file_name: String

        # Resolve a constraint type to its corresponding class.
        #
        # This is a convenience method that creates a new Resolver instance and
        # immediately resolves the constraint class.
        #
        # @param constraint_type [Symbol] The type of constraint to resolve
        #
        # @raise [ArgumentError] if the constraint type is unknown
        # @return [Class] The resolved constraint class
        # @rbs (Symbol constraint_type) -> _ConstraintClass
        def self.resolve!(constraint_type)
          new(constraint_type).resolve!
        end

        # Initialize a new Resolver instance.
        #
        # @param constraint_type [Symbol] The type of constraint to resolve
        #
        # @return [void]
        # @rbs (Symbol constraint_type) -> void
        def initialize(constraint_type)
          @constraint_type = constraint_type
        end

        # Resolve the constraint type to its corresponding class.
        #
        # This method attempts to load and resolve the constraint class file based on
        # the constraint type. The constraint class must be defined under the
        # Domainic::Type::Constraint namespace and follow the naming convention:
        # "{type}_constraint.rb".
        #
        # @example File naming convention
        #   :string -> string_constraint.rb -> StringConstraint
        #   :numeric -> numeric_constraint.rb -> NumericConstraint
        #
        # @raise [ArgumentError] if the constraint type is unknown
        # @return [Class] The resolved constraint class
        # @rbs () -> _ConstraintClass
        def resolve!
          load_constraint!
          constraint_class
        end

        private

        # Generate the constraint class constant name.
        #
        # Converts the file name into a camelized constant name following Ruby
        # naming conventions.
        #
        # @example Constant name generation
        #   file_name: "string_constraint" -> constant_name: "StringConstraint"
        #
        # @return [String] The generated constant name
        # @rbs () -> String
        def constant_name
          @constant_name ||= file_name.split('_').map(&:capitalize).join
        end

        # Get the constraint class constant.
        #
        # Attempts to find the constraint class constant in the Domainic::Type::Constraint
        # namespace.
        #
        # @raise [ArgumentError] if the constant cannot be found
        # @return [Class] The constraint class constant
        # @rbs () -> _ConstraintClass
        def constraint_class
          Domainic::Type::Constraint.const_get(constant_name)
        rescue NameError
          raise ArgumentError, "Unknown constraint: #{@constraint_type}"
        end

        # Generate the constraint file name.
        #
        # Converts the constraint type symbol into a file name following Ruby
        # naming conventions, removing any trailing '?' or '!' characters.
        #
        # @example File name generation
        #   constraint_type: :string -> file_name: "string_constraint"
        #   constraint_type: :numeric? -> file_name: "numeric_constraint"
        #
        # @return [String] The generated file name
        # @rbs () -> String
        def file_name
          @file_name ||= "#{@constraint_type.to_s.delete_suffix('?').delete_suffix('!')}_constraint"
        end

        # Load the constraint class file.
        #
        # Attempts to require the constraint class file from the constraints directory.
        #
        # @raise [ArgumentError] if the constraint file cannot be loaded
        # @return [void]
        # @rbs () -> void
        def load_constraint!
          require "domainic/type/constraint/constraints/#{file_name}"
        rescue LoadError
          raise ArgumentError, "Unknown constraint: #{@constraint_type}"
        end
      end
    end
  end
end
