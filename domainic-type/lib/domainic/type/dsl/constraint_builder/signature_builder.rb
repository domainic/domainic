# frozen_string_literal: true

module Domainic
  module Type
    module DSL
      class ConstraintBuilder
        # A DSL for defining method signatures on a {BaseType type}.
        #
        # @since 0.1.0
        class SignatureBuilder
          # Initialize a new instance of SignatureBuilder.
          #
          # @return [SignatureBuilder] the new instance of SignatureBuilder.
          def initialize
            @data = {}
          end

          # Define aliases for the current signature.
          #
          # @param alias_names [Array<String, Symbol>] the aliases to define.
          # @raise [ArgumentError] if no signature is currently being defined.
          # @return [self] the SignatureBuilder.
          def aliases(alias_names)
            ensure_current_signature!

            @current_signature[:aliases] ||= [@current_signature_name]
            @current_signature[:aliases] = @current_signature[:aliases].concat(alias_names).map(&:to_sym).uniq
            self
          end

          # Build the signatures.
          #
          # @return [Hash{Symbol => Hash{Symbol => Hash{Symbol => Object}}}] the signatures.
          def build
            @data.each_with_object({}) do |(accessor_name, signatures), result|
              result[accessor_name] ||= {}
              signatures.each_pair do |signature_name, signature_data|
                result[accessor_name][signature_data[:constraint]] = { name: signature_name }.merge(
                  signature_data.slice(:aliases, :defaults, :definition, :description)
                )
              end
            end
          end

          # Associate a constraint with the current signature.
          #
          # @param constraint_name [String, Symbol] the name of the constraint.
          # @raise [ArgumentError] if no signature is currently being defined.
          # @return [self] the SignatureBuilder.
          def concerning(constraint_name)
            ensure_current_signature!

            @current_signature[:constraint] = constraint_name.to_sym
            self
          end

          # Define the method that returns the configuration for the constraint.
          #
          # @param proc_or_symbol [Proc, Symbol] the method that returns the configuration.
          # @param block [Proc] the method that returns the configuration.
          # @raise [ArgumentError] if no signature is currently being defined.
          # @return [self] the SignatureBuilder.
          def configure(proc_or_symbol = nil, &block)
            ensure_current_signature!

            @current_signature[:definition] = (proc_or_symbol || block)
            self
          end

          # Define a signature.
          #
          # @param accessor_name [String, Symbol] the name of the accessor.
          # @param method_name [String, Symbol] the name of the method.
          # @yield [self] the block to define the signature.
          # @return [self] the SignatureBuilder.
          def define(accessor_name, method_name, &)
            @current_signature_name = method_name.to_sym
            @data[accessor_name.to_sym] = {}
            @current_signature = @data[accessor_name.to_sym][@current_signature_name] ||= {}
            instance_exec(&) if block_given?
            self
          end

          # Define a default parameter value for the current signature.
          #
          # @param parameter_name [String, Symbol] the name of the parameter.
          # @param default_value [Object] the default value for the parameter.
          # @raise [ArgumentError] if no signature is currently being defined.
          # @return [self] the SignatureBuilder.
          def default_for_parameter(parameter_name, default_value)
            ensure_current_signature!

            @current_signature[:defaults] ||= {}
            @current_signature[:defaults][parameter_name.to_sym] = default_value
            self
          end

          # Define a description for the current signature.
          #
          # @param description_string [String] the description for the signature.
          # @raise [ArgumentError] if no signature is currently being defined.
          # @return [self] the SignatureBuilder.
          def description(description_string)
            ensure_current_signature!

            @current_signature[:description] = description_string
            self
          end
          alias desc description

          private

          # Ensure that a signature is currently being defined.
          #
          # @raise [ArgumentError] if no signature is currently being defined.
          # @return [void]
          def ensure_current_signature!
            return if @current_signature

            raise ArgumentError, 'No signature currently being defined.'
          end
        end
      end
    end
  end
end
