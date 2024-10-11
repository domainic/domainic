# frozen_string_literal: true

require_relative '../../constants'
require_relative '../../errors'

module Domainic
  module Type
    module Constraint
      module Specification
        # A constraint parameter.
        #
        # @!attribute [r] description
        #  The description of the Parameter.
        #  @return [String, nil]
        #
        # @!attribute [r] name
        #  The name of the Parameter.
        #  @return [Symbol]
        #
        # @since 0.1.0
        class Parameter
          attr_reader :description, :name

          # Initialize a new instance of Parameter.
          #
          # @param base [Class<BaseConstraint>, BaseConstraint] The constraint that the Parameter belongs to.
          # @param options [Hash{Symbol => untyped}] The options for configuring the Parameter.
          #
          # @option options [Array<::Proc>] :callbacks ([]) callbacks to execute when the Parameter value changes.
          # @option options [Array<Boolean, Proc, ::Symbol>] :coercers ([->(value) { value }])
          #  An array of Booleans, Procs, or Symbols representing methods to coerce the Parameter value before
          #  validation.
          #  - When the coercer is `true` and the base constraint responds to `coerce_<name>`, that method will be
          #    called to coerce the value.
          #  - When the coercer is a `Proc`, the Proc will be called to coerce the value.
          #  - When the coercer is a `Symbol` and the base constraint responds to a method matching that symbol, the
          #    method will be called to coerce the value.
          # @option options [Object, nil] :default (UNSPECIFIED) The default value for the Parameter.
          # @option options [String, nil] :description (nil) A description of the Parameter.
          # @option options [String, Symbol] :name The name of the Parameter.
          # @option options [Boolean] :required (false) true if the Parameter is required, otherwise false.
          # @option options [Proc, Symbol] :validator (->(_) { true }) A Proc or Symbol representing a method to
          #  validate the Parameter value.
          #  - When the validator is a `Proc`, the Proc will be called to validate the value.
          #  - When the validator is a `Symbol` and the base constraint responds to a method matching that symbol, the
          #    method will be called to validate the value.
          #
          # @return [Parameter] The new instance of Parameter.
          def initialize(base, options)
            @base = base
            @callbacks = options.fetch(:callbacks, [])
            @coercers = options.fetch(:coercers, [])
            @default = options.fetch(:default, UNSPECIFIED)
            @description = options[:description]
            @name = options.fetch(:name).to_sym
            @required = options.fetch(:required, false)
            @validator = options.fetch(:validator, ->(_) { true })
            @value = UNSPECIFIED
          end

          # Get the default value for the Parameter.
          #
          # @return [Object, nil] The default value for the Parameter, or nil if no default is provided.
          def default
            @default if default?
          end

          # Check if the Parameter has a default value.
          #
          # @return [Boolean] true if the Parameter has a default value, otherwise false.
          def default?
            @default != UNSPECIFIED
          end

          # Duplicate the Parameter with a new base class.
          #
          # @param new_base [Class<BaseConstraint>, BaseConstraint] The new base class for the duplicated Parameter.
          # @return [Parameter] The duplicated Parameter.
          def dup_with_base(new_base)
            dup.tap { |duped| duped.instance_variable_set(:@base, new_base) }
          end

          # Check if the Parameter is required.
          #
          # @return [Boolean] true if the Parameter is required, otherwise false.
          def required?
            @required
          end

          # Get the value of the Parameter.
          #
          # @return [Object, nil] The value of the Parameter, or nil if the value is not set.
          def value
            return @value unless @value == UNSPECIFIED

            default if default?
          end

          # Set the value of the Parameter.
          #
          # @param value [Object, nil] The value to set for the Parameter.
          # @return [void]
          def value=(value)
            coerced_value = coerce_value(value)
            ensure_value_is_valid!(coerced_value)

            @value = coerced_value
            callbacks.each { |callback| @base.instance_exec(@value, &callback) }
          end

          private

          attr_reader :base, :callbacks, :coercers, :validator

          # Validate the value of the Parameter and raise an error if the value is invalid.
          #
          # @param value [Object, nil] The value to validate.
          # @raise [InvalidParameterError] An error if the value is invalid.
          # @return [Boolean] true if the value is valid, otherwise false.
          def ensure_value_is_valid!(value)
            raise_validation_error!(value) if value.nil? && required?

            valid = validate_value(value)

            raise_validation_error!(value) unless valid
            valid
          end

          # Coerce the value using the provided coercers.
          #
          # @param result [Object, nil] The result of the previous coercion.
          # @param coercer [Boolean, Proc, Symbol] The coercer to use.
          # @return [Object, nil] The coerced value.
          def coerce_reduced(result, coercer)
            return base.instance_exec(result, &coercer) if coercer.is_a?(Proc)
            return base.send(coercer, result) if coercer.is_a?(Symbol) && base.respond_to?(coercer, true)
            return base.send(:"coerce_#{name}", result) if coercer && base.respond_to?(:"coerce_#{name}", true)

            result
          end

          # Coerce the value of the Parameter using the provided coercers.
          #
          # @param value [Object, nil] The value to coerce.
          # @return [Object, nil] The coerced value.
          def coerce_value(value)
            coercers.reduce(value) { |result, coercer| coerce_reduced(result, coercer) }
          end

          # Raise an error for an invalid value.
          #
          # @param value [Object, nil] The value that is invalid.
          # @raise [InvalidParameterError] An error for the invalid value.
          # @return [void]
          def raise_validation_error!(value)
            base_name = base.is_a?(Class) ? base.name : base.class.name
            raise InvalidParameterError, "`#{base_name}`:`#{name}` is required" if value.nil? && required?

            raise InvalidParameterError, "Invalid value `#{value.inspect}` for parameter `#{base_name}:#{name}`"
          end

          # Validate the value of the Parameter.
          #
          # @param value [Object, nil] The value to validate.
          # @return [Boolean] true if the value is valid, otherwise false.
          def validate_value(value)
            return base.instance_exec(value, &validator) if validator.is_a?(Proc)
            return base.send(validator, value) if validator.is_a?(Symbol) && base.respond_to?(validator, true)

            true
          end
        end
      end
    end
  end
end
