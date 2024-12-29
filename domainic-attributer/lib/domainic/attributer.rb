# frozen_string_literal: true

require 'domainic/attributer/attribute'
require 'domainic/attributer/attribute_set'
require 'domainic/attributer/class_methods'
require 'domainic/attributer/dsl'
require 'domainic/attributer/instance_methods'
require 'domainic/attributer/undefined'

module Domainic
  # `Domainic::Attributer` is a powerful toolkit that brings clarity and safety to your Ruby class attributes.
  # Ever wished your class attributes could:
  #
  # * Validate themselves to ensure they only accept correct values?
  # * Transform input data automatically into the right format?
  # * Have clear, enforced visibility rules?
  # * Handle their own default values intelligently?
  # * Tell you when they change?
  # * Distinguish between required arguments and optional settings?
  #
  # That's exactly what `Domainic::Attributer` does! It provides a declarative way to define and manage attributes
  # in your Ruby classes, ensuring data integrity and clear interfaces. It's particularly valuable for:
  #
  # * Domain models and value objects
  # * Service objects and command patterns
  # * Configuration objects
  # * Any class where attribute behavior matters
  #
  # Think of it as giving your attributes a brain - they know what they want, how they should behave, and
  # they're not afraid to speak up when something's not right!
  #
  # @see file:docs/USAGE.md Usage Guide
  # @abstract Can be included directly with default method names or customized via {.Attributer}
  #
  # @example Basic usage
  #   class SuperDev
  #     include Domainic::Attributer
  #
  #     argument :code_name, String
  #
  #     option :power_level, Integer, default: 9000
  #     option :favorite_gem do
  #       validate_with ->(val) { val.to_s.end_with?('ruby') }
  #       coerce_with ->(val) { val.to_s.downcase }
  #       non_nilable
  #     end
  #   end
  #
  #   dev = SuperDev.new('RubyNinja', favorite_gem: 'RAILS_RUBY')
  #   # => #<SuperDev:0x00000001083aeb58 @code_name="RubyNinja", @favorite_gem="rails_ruby", @power_level=9000>
  #
  #   dev.favorite_gem # => "rails_ruby"
  #   dev.power_level = 9001 # => 9001
  #   dev.power_level = 'over 9000'
  #   # `SuperDev#power_level`: has invalid value: "over 9000" (ArgumentError)
  #
  # @author {https://aaronmallen.me Aaron Allen}
  # @since 0.1.0
  module Attributer
    class << self
      # Create a customized Attributer module
      #
      # @!visibility private
      # @api private
      #
      # @param argument [Symbol, String] custom name for the argument method
      # @param option [Symbol, String] custom name for the option method
      #
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

      # Handle direct module inclusion
      #
      # @!visibility private
      # @api private
      #
      # @param base [Class, Module] the including class/module
      #
      # @return [void]
      # @rbs (untyped base) -> void
      def included(base)
        super
        base.include(call)
      end

      private

      # Configure base class with Attributer functionality
      #
      # @param base [Class, Module] the target class/module
      # @param options [Hash{Symbol => String, Symbol}] method name customization options
      #
      # @return [void]
      # @rbs (untyped base, ?argument: (String | Symbol)?, ?option: (String | Symbol)?) -> void
      def include_attributer(base, **options)
        base.extend(ClassMethods)
        base.include(InstanceMethods)
        inject_custom_methods!(base, **options)
      end

      # Set up custom method names
      #
      # @param base [Class, Module] the target class/module
      # @param options [Hash{Symbol => String, Symbol}] method name customization options
      #
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

  # Provides a convenient way to include {Attributer} with customized method names
  #
  # @example Customizing method names
  #   class Person
  #     include Domainic.Attributer(argument: :param, option: :opt)
  #
  #     param :name, String
  #     opt :age, Integer
  #   end
  #
  #   Person.respond_to?(:argument) # => false
  #   Person.respond_to?(:param)  # => true
  #   Person.respond_to?(:option) # => false
  #   Person.respond_to?(:opt)  # => true
  #
  #   person = Person.new('Alice', age: 30)
  #   # => #<Person:0x000000010865d188 @age=30, @name="Alice">
  #
  # @example Turning off a method
  #
  #   class Person
  #     include Domainic.Attributer(argument: nil)
  #
  #     option :name, String
  #     option :age, Integer
  #   end
  #
  #   Person.respond_to?(:argument)  # => false
  #   Person.respond_to?(:option) # => true
  #
  #   person = Person.new(name: 'Alice', age: 30)
  #   # => #<Person:0x000000010865d188 @age=30, @name="Alice">
  #
  # @param options [Hash{Symbol => String, Symbol, nil}] method name customization options
  # @option options [String, Symbol, nil] :argument custom name for the {Attributer::ClassMethods#argument argument}
  #   method. Set to `nil` to disable the method entirely
  # @option options [String, Symbol, nil] :option custom name for the {Attributer::ClassMethods#option option}
  #   method. Set to `nil` to disable the method entirely
  #
  # @return [Module] the configured {Attributer} module
  # @rbs (?argument: (String | Symbol)?, ?option: (String | Symbol)?) -> Module
  def self.Attributer(**options) # rubocop:disable Naming/MethodName
    Domainic::Attributer.call(**options)
  end
end
