# frozen_string_literal: true

require 'yaml'

module Domainic
  module Type
    module Constraint
      # @rbs!
      #  interface _ConstraintClass
      #    def new: (Type::accessor accessor, ?untyped expectation, **untyped options) -> Behavior
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
        # @rbs!
        #  type registry_constraint = { constant: String, require_path: String }

        # @rbs self.@registry: Hash[Symbol, Hash[Symbol, registry_constraint]]
        # @rbs @constant_name: String
        # @rbs @constraint_type: Symbol
        # @rbs @file_name: String

        class << self
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
          def resolve!(constraint_type)
            new(constraint_type).resolve!
          end

          # Register a new constraint with the resolver.
          #
          # @param lookup_key [String, Symbol] The lookup key for the constraint. This is how types should reference
          #   the constraint when constraining themselves.
          # @param constant_name [String] The name of the constraint class constant.
          # @param require_path [String] The path to the constraint class file.
          #
          # @raise [ArgumentError] if the constraint is already registered
          # @return [void]
          # @rbs (String | Symbol lookup_key, String constant_name, String require_path) -> void
          def register_constraint(lookup_key, constant_name, require_path)
            raise ArgumentError, "Constraint already registered: #{lookup_key}" if registry.key?(lookup_key.to_sym)

            registry[lookup_key.to_sym] = { constant: constant_name, require_path: require_path }
          end

          private

          # The registry of known constraints
          #
          # @return [Hash{Symbol => Hash{Symbol => String}}] The constraint registry
          # @rbs () -> Hash[Symbol, registry_constraint]
          def registry
            @registry ||= begin
              config_file = File.expand_path('../config/registry.yml', File.dirname(__FILE__))
              raw_config = YAML.load_file(config_file, symbolize_names: true)
              raw_config[:constraints].transform_values do |value|
                value.is_a?(Hash) ? value.transform_keys(&:to_sym) : value #: Hash[Symbol, registry_constraint]
              end
            end
          end
        end

        # Initialize a new Resolver instance.
        #
        # @param constraint_type [Symbol] The type of constraint to resolve
        #
        # @return [void]
        # @rbs (String | Symbol constraint_type) -> void
        def initialize(constraint_type)
          @constraint_type = constraint_type.to_sym
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

        # Get the constraint class constant.
        #
        # Attempts to find the constraint class constant in the Domainic::Type::Constraint
        # namespace.
        #
        # @raise [ArgumentError] if the constant cannot be found
        # @return [Class] The constraint class constant
        # @rbs () -> _ConstraintClass
        def constraint_class
          registry_constraint = registered
          raise ArgumentError, "Unknown constraint: #{@constraint_type}" if registry_constraint.nil?

          # @type var registry_constraint: registry_constraint
          Object.const_get(registry_constraint[:constant])
        rescue NameError
          raise ArgumentError, "Unknown constraint: #{@constraint_type}"
        end

        # Load the constraint class file.
        #
        # Attempts to require the constraint class file from the constraints directory.
        #
        # @raise [ArgumentError] if the constraint file cannot be loaded
        # @return [void]
        # @rbs () -> void
        def load_constraint!
          registry_constraint = registered
          raise ArgumentError, "Unknown constraint: #{@constraint_type}" if registry_constraint.nil?

          # @type var registry_constraint: registry_constraint
          require registry_constraint[:require_path]
        rescue LoadError
          raise ArgumentError, "Constraint require path doesn't exist: #{@constraint_type}"
        end

        # Fetch the registered constraint from the registry
        #
        # @return [Hash{Symbol => String}] The registered constraint
        # @rbs () -> registry_constraint?
        def registered
          registry = self.class.send(:registry)
          return unless registry.key?(@constraint_type)

          registry[@constraint_type]
        end
      end
    end
  end
end
