# frozen_string_literal: true

require 'domainic/type/description/store'

module Domainic
  module Type
    class Description
      module Interpolator
        # @since 0.1.0
        module Transformer
          # @rbs self.@registry: Hash[Symbol, Proc]

          AND_JOIN = ->(value) { LIST_JOIN.call(value, Store.template('support.and_join')) } #: Proc

          LIST_JOIN = lambda { |list, joiner|
            list = Array(list)
            return '' if list.empty?
            return list.first.to_s if list.size == 1
            return "#{list.first} #{joiner} #{list.last}" if list.size == 2

            *first, last = list
            [first.join(', '), last].join(" #{joiner} ")
          } #: Proc

          OR_JOIN = ->(value) { LIST_JOIN.call(value, Store.template('support.or_join')) } #: Proc

          class << self
            # @rbs (String | Symbol key) -> Proc
            def [](key)
              const_name = key.to_s.upcase.to_sym
              transformer = registry.fetch(key.to_sym) do
                const_get(const_name, false) if const_defined?(const_name, false)
              end
              raise ArgumentError, "Unknown transformer: #{key}" if transformer.nil?

              transformer
            end

            # @rbs (String | Symbol key, Proc transformer) -> void
            def register(name, transformer)
              key = name.to_sym
              raise ArgumentError, 'Transformer already registered' if registry.key?(key)

              registry[key] = transformer
            end

            private

            # @rbs () -> Hash[Symbol, Proc]
            def registry
              @registry ||= {}
            end
          end
        end
      end
    end
  end
end
