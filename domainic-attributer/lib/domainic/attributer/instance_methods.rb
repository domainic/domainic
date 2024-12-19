# frozen_string_literal: true

require 'domainic/attributer/dsl/initializer'

module Domainic
  module Attributer
    # A module providing instance-level attribute functionality
    #
    # This module defines instance methods for objects that include {Domainic::Attributer}.
    # It provides initialization handling and attribute serialization capabilities, making
    # it easy to work with attribute values in a consistent way
    #
    # @example Basic usage
    #   class Person
    #     include Domainic::Attributer
    #
    #     argument :name
    #     option :age, default: nil
    #     option :role, default: 'user', private_read: true
    #   end
    #
    #   person = Person.new('Alice', age: 30)
    #   person.to_h  # => { name: 'Alice', age: 30 }  # role is private, not included
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    module InstanceMethods
      # Initialize a new instance with attribute values
      #
      # Handles both positional arguments and keyword options, applying them to their
      # corresponding attributes. This process includes:
      # 1. Validating required arguments
      # 2. Applying default values
      # 3. Type validation and coercion
      # 4. Change notifications
      #
      # @example
      #   person = Person.new('Alice', age: 30)
      #
      # @raise [ArgumentError] if required arguments are missing
      # @return [InstanceMethods] the new InstanceMethods instance
      # @rbs (*untyped arguments, **untyped keyword_arguments) -> void
      def initialize(...)
        DSL::Initializer.new(self).assign!(...)
      end

      # Convert public attribute values to a hash
      #
      # Creates a hash containing all public readable attributes and their current values.
      # Any attributes marked as private or protected for reading are excluded from
      # the result
      #
      # @example
      #   person = Person.new('Alice', age: 30)
      #   person.to_h  # => { name: 'Alice', age: 30 }
      #
      # @return [Hash{Symbol => Object}] hash of attribute names to values
      # @rbs () -> Hash[Symbol, untyped]
      def to_hash
        public = self.class.send(:__attributes__).select { |_, attribute| attribute.signature.public_read? }
        public.attributes.each_with_object({}) do |attribute, result|
          result[attribute.name] = public_send(attribute.name)
        end
      end
      alias to_h to_hash
    end
  end
end
