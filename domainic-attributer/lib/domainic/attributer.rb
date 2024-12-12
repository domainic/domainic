# frozen_string_literal: true

require 'domainic/attributer/attribute'
require 'domainic/attributer/attribute_set'
require 'domainic/attributer/class_methods'
require 'domainic/attributer/dsl'
require 'domainic/attributer/instance_methods'
require 'domainic/attributer/undefined'

module Domainic
  # Core functionality for defining and managing Ruby class attributes.
  #
  # This module provides a flexible attribute system for Ruby classes that supports
  # positional arguments and keyword options with features like type validation,
  # coercion, and visibility control.
  #
  # Can be included directly with default method names or customized via {Domainic.Attributer}.
  #
  # @example Basic usage with default method names
  #   class Person
  #     include Domainic::Attributer
  #
  #     argument :name
  #     option :age
  #   end
  #
  # @example Custom method names
  #   class Person
  #     include Domainic.Attributer(argument: :param, option: :opt)
  #
  #     param :name
  #     opt :age
  #   end
  #
  # @author {https://aaronmallen.me Aaron Allen}
  # @since 0.1.0
  module Attributer
    class << self
      # Create a customized Attributer module.
      #
      # @param argument [Symbol, String] custom name for the argument method
      # @param option [Symbol, String] custom name for the option method
      # @return [Module] configured Attributer module
      # @rbs (?argument: (String | Symbol)?, ?option: (String | Symbol)?) -> Module
      def call(argument: :argument, option: :option)
        Module.new do
          @argument = argument
          @option = option

          # @rbs (untyped base) -> void
          def self.included(base)
            super
            Domainic::Attributer.send(:include_attributer, base, argument: @argument, option: @option)
          end
        end
      end

      # Handle direct module inclusion.
      #
      # @param base [Class, Module] the including class/module
      # @return [void]
      # @rbs (untyped base) -> void
      def included(base)
        super
        base.include(call)
      end

      private

      # Configure base class with Attributer functionality.
      #
      # @param base [Class, Module] the target class/module
      # @param options [Hash] method name customization options
      # @return [void]
      # @rbs (untyped base, ?argument: (String | Symbol)?, ?option: (String | Symbol)?) -> void
      def include_attributer(base, **options)
        base.extend(ClassMethods)
        base.include(InstanceMethods)
        inject_custom_methods!(base, **options)
      end

      # Set up custom method names.
      #
      # @param base [Class, Module] the target class/module
      # @param options [Hash] method name customization options
      # @return [void]
      # @rbs (untyped base, ?argument: (String | Symbol)?, ?option: (String | Symbol)?) -> void
      def inject_custom_methods!(base, **options)
        options.each do |original, custom|
          base.singleton_class.alias_method(custom, original) unless custom.nil?
          if (custom.nil? || custom != original) && base.respond_to?(original)
            base.singleton_class.undef_method(original)
          end
        end
      end
    end
  end

  # Create a customized Attributer module.
  #
  # Provides a convenient way to include Attributer with customized method names.
  #
  # @example
  #   class Person
  #     include Domainic.Attributer(argument: :param, option: :opt)
  #   end
  #
  # @param options [Hash] method name customization options
  # @return [Module] configured Attributer module
  # @rbs (?argument: (String | Symbol)?, ?option: (String | Symbol)?) -> Module
  def self.Attributer(**options) # rubocop:disable Naming/MethodName
    Domainic::Attributer.call(**options)
  end
end
