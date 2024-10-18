# frozen_string_literal: true

require_relative 'base_type'

module Domainic
  module Type
    # @since 0.1.0
    class UnionType < BaseType
      constrain :self do
        constraint :type

        bind_method :being do
          desc 'Constrains the type to be one of the given types.'
          concerning :type
          default_for_parameter :expectation_qualifier, :any

          configure { |*types| { expected: (consraints.self&.type&.expected || []).concat(types).uniq } }
        end
      end

      def initialize(*types, **options)
        super(being: types, **options)
      end
    end
  end
end
