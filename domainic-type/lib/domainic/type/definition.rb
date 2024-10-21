# frozen_string_literal: true

require_relative 'load/registrar'

module Domainic
  module Type
    # @since 0.1.0
    module Definition
      extend self

      private

      def const_missing(symbol)
        return super unless respond_to?(symbol)

        public_send(symbol)
      end

      def inject_type!(loader)
        loader.load

        type = Object.const_get(loader.constant)
        define_method(loader.name) { |*arguments, **keyword_arguments| type.new(*arguments, **keyword_arguments) }
        loader.aliases.each do |alias_name|
          next if respond_to?(alias_name)

          alias_method(alias_name, loader.name)
        end
      end

      def method_missing(method, ...)
        loader = registry.find(method)
        return super if loader.nil?

        inject_type!(loader)
        public_send(method, ...)
      end

      def registry
        @registry ||= Load::Registrar.new
      end

      def respond_to_missing?(method, include_private = false)
        registry.find(method) || super
      end
    end
  end
end
