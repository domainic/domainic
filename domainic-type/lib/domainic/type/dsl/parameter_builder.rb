# frozen_string_literal: true

require_relative '../constants'

module Domainic
  module Type
    module DSL
      # A DSL for defining {Constraint::Parameter parameters} on a {Constraint::BaseConstraint constraint}.
      #
      # @see Constraint::Parameter#initialize
      #
      # @since 0.1.0
      class ParameterBuilder
        # default values for {Constraint::Parameter parameters}
        #
        # @return [Hash{Symbol => Object}]
        PARAMETER_DEFAULTS = {
          callbacks: [],
          coercers: [],
          default: UNSPECIFIED,
          description: UNSPECIFIED,
          required: false,
          validator: UNSPECIFIED
        }.freeze

        # Initialize a new instance of ParameterBuilder.
        #
        # @param base [Class<Constraint::BaseConstraint>] The constraint to build parameters for.
        # @return [ParameterBuilder] The new instance of ParameterBuilder.
        def initialize(base)
          @base = base
          @data = {}
        end

        # Inject the defined parameters into the base {Constraint::BaseConstraint constraint} and define
        #  getter and setter methods for each parameter.
        #
        # @return [void]
        def build!
          inject_parameters
          inject_parameter_methods!
        end

        # Add a coercer to the current {Constraint::Parameter parameter}.
        #
        # @param proc_symbol_or_true [Symbol, Proc, true, nil] The proc, symbol, or true to add as a coercer.
        # @yield the block to add as a coercer.
        # @raise [ArgumentError] If no parameter is currently being defined.
        # @return [self]
        def coercer(proc_symbol_or_true = nil, &block)
          validate_current_parameter!

          @current_parameter[:coercers] << (proc_symbol_or_true || block)
          self
        end
        alias coerce coercer

        # Add a default value to the current {Constraint::Parameter parameter}.
        #
        # @param value [Object] The default value to add.
        # @raise [ArgumentError] If no parameter is currently being defined.
        # @return [self]
        def default(value)
          validate_current_parameter!

          @current_parameter[:default] = value
          self
        end

        # Define a new {Constraint::Parameter parameter} on the {Constraint::BaseConstraint constraint}.
        #
        # @param name [String, Symbol] The name of the parameter.
        # @yield [self] The block to define the parameter.
        # @return [self]
        def define(name, &)
          @current_parameter = @data[name.to_sym] ||=
            PARAMETER_DEFAULTS.transform_values { |value| value == UNSPECIFIED ? value : value.dup }
                              .merge(name: name.to_sym)
          instance_exec(&) if block_given?
          self
        end

        # Add a description to the current {Constraint::Parameter parameter}.
        #
        # @param value [String] The description to add.
        # @raise [ArgumentError] If no parameter is currently being defined.
        # @return [self]
        def description(value)
          validate_current_parameter!

          @current_parameter[:description] = value
          self
        end
        alias desc description

        # Duplicate the current ParameterBuilder with a new base {Constraint::BaseConstraint constraint}.
        #
        # @param new_base [Class<Constraint::BaseConstraint>] The new base constraint.
        # @return [ParameterBuilder] The new instance of ParameterBuilder.
        def dup_with_base(new_base)
          dup.tap { |duped| duped.instance_variable_set(:@base, new_base) }
        end

        # Add a callback to the current {Constraint::Parameter parameter}.
        #
        # @yield the block to add as a callback.
        # @raise [ArgumentError] If no parameter is currently being defined.
        # @return [self]
        def on_change(&block)
          validate_current_parameter!

          @current_parameter[:callbacks] << block
          self
        end

        # Mark the current {Constraint::Parameter parameter} as required.
        #
        # @raise [ArgumentError] If no parameter is currently being defined.
        # @return [self]
        def required
          validate_current_parameter!

          @current_parameter[:required] = true
          self
        end

        # Add a validator to the current {Constraint::Parameter parameter}.
        #
        # @param proc_or_symbol [Symbol, Proc, nil] The proc or symbol to add as a validator.
        # @yield the block to add as a validator.
        # @raise [ArgumentError] If no parameter is currently being defined.
        # @return [self]
        def validator(proc_or_symbol = nil, &block)
          validate_current_parameter!

          @current_parameter[:validator] = proc_or_symbol || block
          self
        end

        private

        # Inject the defined parameter methods into the base {Constraint::BaseConstraint constraint}.
        #
        # @return [void]
        def inject_parameter_methods!
          @data.each_key do |parameter_name|
            next if @base.instance_methods.include?(parameter_name)

            @base.define_method(parameter_name) { parameters.public_send(parameter_name).value }
            @base.define_method(:"#{parameter_name}=") { |value| parameters.public_send(parameter_name).value = value }
            @base.define_method(:"#{parameter_name}_default") { parameters.public_send(parameter_name).default }
          end
        end

        # Inject the defined parameters into the base {Constraint::BaseConstraint constraint}.
        #
        # @return [void]
        def inject_parameters
          @data.each_value do |parameter_options|
            next if @base.parameters.respond_to?(parameter_options[:name])

            @base.parameters.add(parameter_options.reject { |_, value| value == UNSPECIFIED })
          end
        end

        # Validate that a parameter is currently being defined.
        #
        # @raise [ArgumentError] If no parameter is currently being defined.
        # @return [void]
        def validate_current_parameter!
          return if @current_parameter

          raise "No parameter is currently being defined for #{@base}"
        end
      end
    end
  end
end
