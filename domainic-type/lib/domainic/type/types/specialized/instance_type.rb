# frozen_string_literal: true

require 'domainic/type/behavior'

module Domainic
  module Type
    # A type for validation that an object is an instance of a specific class or module.
    #
    # This class provides flexible constraints for ensuring objects conform to
    # expected types, including specific class or module checks, as well as
    # constraints on attributes within those objects.
    #
    # Key features:
    # - Instance type constraints for classes and modules
    # - Attribute presence constraints
    # - Extensible through the Domainic type system
    #
    # @example Basic usage
    #   type = InstanceType.new
    #   type.of(String)                    # enforce instance of String
    #   type.constrain("example")          # => true
    #   type.constrain(123)                # => false
    #
    # @example Attribute constraints
    #   type = InstanceType.new
    #   type.having_attributes(name: String, age: Integer) # enforce attribute presence and types
    #   type.constrain(OpenStruct.new(name: "John", age: 30)) # => true
    #   type.constrain(OpenStruct.new(name: "John"))          # => false
    #
    # @example Combined constraints
    #   type = InstanceType.new
    #   type
    #     .of(User)                          # enforce instance of User
    #     .having_attributes(:email => String, :admin => Symbol) # attribute constraints
    #   type.validate(User.new(email: "admin@example.com", admin: :admin)) # => true
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class InstanceType
      # @rbs! extend Behavior::ClassMethods

      include Behavior

      # Constrain that the object has specific attributes.
      #
      # @example
      #   type.having_attributes(name: String, age: Integer)
      #   type.constrain(OpenStruct.new(name: "John", age: 30)) # => true
      #   type.constrain(OpenStruct.new(name: "John"))          # => false
      #
      # @param attributes [Hash{String, Symbol => Class, Module, Behavior}] the attributes and their expected types
      # @return [self] self for method chaining
      # @rbs (Hash[String | Symbol, Class | Module | Behavior] attributes) -> self
      def having_attributes(attributes)
        constrain :self, :attribute_presence, attributes, description: 'having'
      end

      # Constrain that the object is an instance of the specified class or module.
      #
      # @example
      #   type.of(String)
      #   type.constrain("example")       # => true
      #   type.constrain(123)             # => false
      #
      # @param type [Class, Module, Behavior] the expected class, module, or behavior
      # @return [self] self for method chaining
      # @rbs (Class | Module | Behavior type) -> self
      def of(type)
        constrain :self, :instance_of, type, description: 'of'
      end
    end
  end
end
