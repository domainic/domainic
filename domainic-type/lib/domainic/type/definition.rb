# frozen_string_literal: true

require_relative 'load/registrar'

module Domainic
  module Type
    # @since 0.1.0
    module Definition
      extend self

      private

      def const_missing(symbol)
        super unless respond_to_missing?(symbol)

        send(symbol)
      end

      def inject_type!(loader)
        loader.load
        inject_type_constants!(loader)
        inject_type_methods!(loader)
      end

      def inject_type_constants!(loader)
        type = Object.const_get(loader.constant)
        const_set(loader.name, type) unless const_defined?(loader.name) && !loader.in_group?(:ruby_core)
        loader.aliases.select { |name| name.to_s.match?(/\A[A-Z]/) }.each do |name|
          next if const_defined?(name)

          const_set(name, type)
        end
      end

      def inject_type_methods!(loader)
        type = Object.const_get(loader.constant)

        unless method_defined?(loader.name)
          define_method(loader.name) do |*arguments, **keyword_arguments|
            type.new(*arguments, **keyword_arguments)
          end
        end

        loader.aliases.each do |name|
          next if method_defined?(name)

          alias_method(name, loader.name)
        end
      end

      def method_missing(method, ...)
        return super unless respond_to_missing?(method)

        loader = registry.find(method)
        return super unless loader

        inject_type!(loader)
        type = Object.const_get(loader.constant)
        type.new(...)
      end

      def registry
        @registry ||= Load::Registrar.new
      end

      def respond_to_missing?(method, include_private = false)
        registry.find(method) || super
      end

      registry.all.select(&:loaded?).each { |loader| inject_type!(loader) }
    end
  end
end
