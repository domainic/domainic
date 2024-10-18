# frozen_string_literal: true

require_relative 'base_type'

module Domainic
  module Type
    # @since 0.1.0
    class EnumType < BaseType
      constrain :self do
        constraint :equality

        bind_method :having_values do
          desc 'Constrains the value to be one of the given values.'
          concerning :equality
          default_for_parameter :expectation_qualifier, :any
          aliases :with_values

          configure { |*values| { expected: (constraints.self&.equality&.expected || []).concat(values).uniq } }
        end
      end

      def initialize(*values, **options)
        super(expected: values, **options)
      end
    end
  end
end
