# frozen_string_literal: true

require_relative 'enumerable_type'

module Domainic
  module Type
    # @since 0.1.0
    class HashType < EnumerableType
      constrain :keys do
        constraint :type
        constraint :inclusion
        constraint :inclusion, name: :exclusion

        bind_method :having_keys do
          desc 'Constrains the hash to have the given keys.'
          concerning :inclusion
          aliases :with_keys

          configure { |*keys| { expected: (constraints.keys&.inclusion&.expected || []).concat(keys).uniq } }
        end

        bind_method :having_keys_of do
          desc 'Constrains the hash to have keys of the given type.'
          concerning :type
          aliases :with_keys_of

          configure { |type| { expected: type } }
        end

        bind_method :not_having_keys do
          desc 'Constrains the hash to not have the given keys.'
          concerning :exclusion
          aliases :without_keys

          configure { |*keys| { expected: (constraints.keys&.exclusion&.expected || []).concat(keys).uniq } }
        end
      end

      constrain :values do
        constraint :type
        constraint :inclusion
        constraint :inclusion, name: :exclusion

        bind_method :having_values do
          desc 'Constrains the hash to have the given values.'
          concerning :inclusion
          aliases :with_values

          configure { |*values| { expected: (constraints.values&.inclusion&.expected || []).concat(values).uniq } }
        end

        bind_method :having_values_of do
          desc 'Constrains the hash to have values of the given type.'
          concerning :type
          aliases :with_values_of

          configure { |type| { expected: type } }
        end

        bind_method :not_having_values do
          desc 'Constrains the hash to not have the given values.'
          concerning :exclusion
          aliases :without_values

          configure { |*values| { expected: (constraints.values&.exclusion&.expected || []).concat(values).uniq } }
        end
      end
    end
  end
end
