# frozen_string_literal: true

require 'domainic/attributer/attribute'
require 'domainic/attributer/dsl/attribute_builder/option_parser'
require 'domainic/attributer/undefined'

module Domainic
  module Attributer
    module DSL
      # A class responsible for configuring attributes through a fluent interface
      #
      # This class provides a rich DSL for configuring attributes with support for
      # default values, coercion, validation, visibility controls, and change tracking.
      # It uses method chaining to allow natural, declarative attribute definitions
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class AttributeBuilder
        # @rbs @base: __todo__
        # @rbs @options: OptionParser::result

        # Initialize a new AttributeBuilder
        #
        # @param base [Class, Module] the class or module to build the attribute in
        # @param attribute_name [String, Symbol] the name of the attribute
        # @param attribute_type [String, Symbol] the type of attribute
        # @param type_validator [Proc, Object, nil] optional type validator
        # @param options [Hash{Symbol => Object}] additional options for attribute configuration. See
        #   {OptionParser#initialize} for details
        #
        # @return [AttributeBuilder] the new AttributeBuilder instance
        # @rbs (
        #   __todo__ base,
        #   String | Symbol attribute_name,
        #   String | Symbol attribute_type,
        #   ?Attribute::Validator::handler? type_validator,
        #   OptionParser::options options,
        #   ) ? { (?) [self: AttributeBuilder] -> void } -> void
        def initialize(base, attribute_name, attribute_type, type_validator = Undefined, **options, &block)
          @base = base
          # @type var options: OptionParser::options
          @options = OptionParser.parse!(attribute_name, attribute_type, options)
          @options[:validators] << type_validator if type_validator != Undefined
          instance_exec(&block) if block
        end

        # Build and finalize the {Attribute}
        #
        # @return [Attribute] the configured attribute
        # @rbs () -> Attribute
        def build!
          options = @options.compact
                            .reject { |_, value| value == Undefined || (value.respond_to?(:empty?) && value.empty?) }
          Attribute.new(@base, **options) # steep:ignore InsufficientKeywordArguments
        end

        # Configure value coercion
        #
        # @param proc_symbol [Proc, Symbol, nil] optional coercion handler
        # @yield optional coercion block
        #
        # @return [self] the builder for method chaining
        # @rbs (?(Attribute::Coercer::proc | Object)? proc_symbol) ?{ (untyped value) -> untyped } -> self
        def coerce_with(proc_symbol = Undefined, &block)
          handler = proc_symbol == Undefined ? block : proc_symbol #: Attribute::Coercer::handler
          @options[:coercers] << handler
          self
        end
        alias coerce coerce_with

        # Configure default value
        #
        # @param value_or_proc [Object, Proc, nil] optional default value or generator
        # @yield optional default value generator block
        #
        # @return [self] the builder for method chaining
        # @rbs (?untyped? value_or_proc) ?{ (?) -> untyped } -> self
        def default(value_or_proc = Undefined, &block)
          @options[:default] = value_or_proc == Undefined ? block : value_or_proc
          self
        end
        alias default_generator default
        alias default_value default

        # Set attribute description
        #
        # @param text [String] the description text
        #
        # @return [self] the builder for method chaining
        # @rbs (String? text) -> self
        def description(text)
          @options[:description] = text
          self
        end
        alias desc description

        # Mark attribute as non-nilable
        #
        # @return [self] the builder for method chaining
        # @rbs () -> self
        def non_nilable
          @options[:nilable] = false
          self
        end
        alias non_nil non_nilable
        alias non_null non_nilable
        alias non_nullable non_nilable
        alias not_nil non_nilable
        alias not_nilable non_nilable
        alias not_null non_nilable
        alias not_nullable non_nilable

        # Configure change callback
        #
        # @param proc [Proc, nil] optional callback handler
        # @yield optional callback block
        #
        # @return [self] the builder for method chaining
        # @rbs (?Attribute::Callback::handler? proc) ?{ (untyped old_value, untyped new_value) -> void } -> self
        def on_change(proc = Undefined, &block)
          handler = proc == Undefined ? block : proc #: Attribute::Callback::handler
          @options[:callbacks] << handler
          self
        end

        # Set private visibility for both read and write
        #
        # @return [self] the builder for method chaining
        # @rbs () -> self
        def private
          private_read
          private_write
        end

        # Set private visibility for read
        #
        # @return [self] the builder for method chaining
        # @rbs () -> self
        def private_read
          @options[:read] = :private
          self
        end

        # Set private visibility for write
        #
        # @return [self] the builder for method chaining
        # @rbs () -> self
        def private_write
          @options[:write] = :private
          self
        end

        # Set protected visibility for both read and write
        #
        # @return [self] the builder for method chaining
        # @rbs () -> self
        def protected
          protected_read
          protected_write
        end

        # Set protected visibility for read
        #
        # @return [self] the builder for method chaining
        # @rbs () -> self
        def protected_read
          @options[:read] = :protected
          self
        end

        # Set protected visibility for write
        #
        # @return [self] the builder for method chaining
        # @rbs () -> self
        def protected_write
          @options[:write] = :protected
          self
        end

        # Set public visibility for both read and write
        #
        # @return [self] the builder for method chaining
        # @rbs () -> self
        def public
          public_read
          public_write
        end

        # Set public visibility for read
        #
        # @return [self] the builder for method chaining
        # @rbs () -> self
        def public_read
          @options[:read] = :public
          self
        end

        # Set public visibility for write
        #
        # @return [self] the builder for method chaining
        # @rbs () -> self
        def public_write
          @options[:write] = :public
          self
        end

        # Mark attribute as required
        #
        # @return [self] the builder for method chaining
        # @rbs () -> self
        def required
          @options[:required] = true
          self
        end

        # Configure value validation
        #
        # @param object_or_proc [Object, Proc, nil] optional validation handler
        # @yield optional validation block
        #
        # @return [self] the builder for method chaining
        # @rbs (?Attribute::Validator::handler? object_or_proc) ?{ (untyped value) -> boolish } -> self
        def validate_with(object_or_proc = Undefined, &block)
          handler = object_or_proc == Undefined ? block : object_or_proc #: Attribute::Validator::handler
          @options[:validators] << handler
          self
        end
        alias validate validate_with
        alias validates validate_with
      end
    end
  end
end
