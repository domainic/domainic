# frozen_string_literal: true

module Domainic
  module Type
    module DSL
      class ConstraintBuilder
        # Inject methods onto a {BaseType type} class.
        #
        # @since 0.1.0
        class MethodInjector
          # Initialize a new instance of MethodInjector.
          #
          # @param base [Class<BaseType>] the {BaseType type} to inject methods onto.
          # @param signatures [Hash{Symbol => Hash{Symbol => Hash{Symbol => Object}}}] the signatures to inject.
          # @return [MethodInjector] the new instance of MethodInjector.
          def initialize(base, signatures)
            @base = base
            @signatures = signatures
          end

          # Duplicate the instance with a new base.
          #
          # @param new_base [Class<BaseType>] the new base to inject methods onto.
          # @return [MethodInjector] the new instance of MethodInjector.
          def dup_with_base(new_base)
            dup.tap { |duped| duped.instance_variable_set(:@base, new_base) }
          end

          # Inject the methods onto the {BaseType type}.
          #
          # @return [void]
          def inject!
            @signatures.each_pair do |accessor_name, signatures|
              signatures.each_pair do |primary_signature, signature_data|
                inject_singleton_method!(primary_signature)
                inject_instance_method!(accessor_name, signature_data[:constraint], primary_signature, signature_data)
                inject_aliases!(primary_signature, signature_data.fetch(:aliases, []))
              end
            end
          end

          private

          # Inject aliases onto the {BaseType type}.
          #
          # @param primary_signature [Symbol] the primary signature to alias.
          # @param aliases [Array<Symbol>] the aliases to inject.
          # @return [void]
          def inject_aliases!(primary_signature, aliases)
            aliases.each do |alias_name|
              @base.singleton_class.alias_method(alias_name, primary_signature) unless @base.respond_to?(alias_name)
              @base.alias_method(alias_name, primary_signature) unless @base.instance_methods.include?(alias_name)
            end
          end

          # Inject an instance method onto the {BaseType type}.
          #
          # @param accessor_name [Symbol] the accessor name.
          # @param constraint_name [Symbol] the constraint name.
          # @param signature_name [Symbol] the signature name.
          # @param signature_data [Hash{Symbol => Object}] the signature data.
          # @return [void]
          def inject_instance_method!(accessor_name, constraint_name, signature_name, signature_data)
            return if @base.instance_methods.include?(signature_name)

            @base.define_method(signature_name) do |*arguments, **keyword_arguments|
              options = instance_exec(*arguments, **keyword_arguments, &signature_data[:definition])
              options = signature_data.fetch(:defaults, {}).merge(options)
              constraints.public_send(accessor_name).public_send(constraint_name, **options)
              self
            end
          end

          # Inject a singleton method onto the {BaseType type}.
          #
          # @param signature_name [Symbol] the signature name.
          # @return [void]
          def inject_singleton_method!(signature_name)
            return if @base.respond_to?(signature_name)

            @base.define_singleton_method(signature_name) do |*arguments, **keyword_arguments|
              new.public_send(signature_name, *arguments, **keyword_arguments)
            end
          end
        end
      end
    end
  end
end
