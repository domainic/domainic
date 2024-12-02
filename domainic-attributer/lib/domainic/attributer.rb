# frozen_string_literal: true

require 'domainic/attributer/attribute'
require 'domainic/attributer/attribute_definition'
require 'domainic/attributer/builder'
require 'domainic/attributer/class_methods'
require 'domainic/attributer/instance_methods'
require 'domainic/attributer/method_injector'
require 'domainic/attributer/undefined'

module Domainic
  # Creates a new module that provides attribute functionality with custom method naming.
  #
  # @see Domainic::Attributer
  #
  # @example Using a custom name for the option method
  #   class Person
  #     include Domainic::Attributer(:property)
  #
  #     property :name, String do
  #       required
  #     end
  #   end
  #
  # @param aliased_name [String, Symbol] The name to use instead of 'option'
  # @return [Module] a new module that behaves like Attributer but uses the provided method name
  # @rbs (String | Symbol aliased_name) -> Module
  def self.Attributer(aliased_name) # rubocop:disable Naming/MethodName
    Module.new.tap do |mod|
      mod.define_singleton_method(:included) do |base|
        base.extend(Domainic::Attributer::ClassMethods)
        base.include(Domainic::Attributer::InstanceMethods)
        base.singleton_class.send(:alias_method, aliased_name.to_sym, :option)
      end
    end
  end

  # A module that adds typed, validated attributes to Ruby classes.
  # When included, it provides a simple DSL for defining attributes with
  # coercion, validation, and change notification.
  #
  # Each attribute can have:
  # - Type validation
  # - Custom validations
  # - Value coercion
  # - Default values
  # - Change callbacks
  #
  # @example Basic usage with type validation
  #   class Person
  #     include Domainic::Attributer
  #
  #     option :name, String
  #     option :age, Integer do
  #       validates { |value| value >= 0 }
  #     end
  #   end
  #
  #   Person.new(name: 'Aaron', age: 39)
  #   #=> <#Person:0x00007f9b1b8b3b10 @name="Aaron", @age=39>
  #
  # @example Advanced usage with coercion and defaults using the DSL.
  #   class Temperature
  #     include Domainic::Attributer
  #
  #     option :celsius, Float do
  #       desc "The temperature in degrees Celsius"
  #       coerce { |value| value.to_f }
  #       default 20.0
  #       on_change { |value| update_display(value) }
  #       required
  #       validates { |value| value >= -273.15 }
  #     end
  #
  #     private
  #
  #     def update_display(value)
  #       # Update the temperature display
  #     end
  #   end
  #
  # @example Advanced usage with coercion and defaults using the options API.
  #   class Temperature
  #     include Domainic::Attributer
  #
  #     option :celsius, Float,
  #            callbacks: [->(value) { update_display(value) }],
  #            coercers: [->(value) { value.to_f }],
  #            default: 20.0,
  #            description: "The temperature in degrees Celsius",
  #            required: true,
  #            validators: [->(value) { value >= -273.15 }]
  #
  #     private
  #
  #     def update_display(value)
  #       # Update the temperature display
  #     end
  #   end
  #
  # @since 0.1.0
  module Attributer
    class << self
      private

      # Extends a class with attribute functionality when the module is included.
      #
      # @param base [Class] The class including the module
      # @return [void]
      # @api private
      # @rbs (untyped base) -> void
      def included(base)
        base.extend(ClassMethods)
        base.include(InstanceMethods)
      end
    end
  end
end
