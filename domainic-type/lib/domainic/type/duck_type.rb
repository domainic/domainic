# frozen_string_literal: true

require_relative 'base_type'

module Domainic
  module Type
    # since 0.1.0
    class DuckType < BaseType
      constrain :self do
        constraint :responds_to, name: :inclusion
        constraint :responds_to, name: :exclusion

        bind_method :responding_to do
          desc 'Constrains the subject to respond to the given methods'
          concerning :inclusion
          aliases :implementing

          configure { |*methods| { expected: (constraints.self&.inclusion&.expected || []).concat(methods).uniq } }
        end

        bind_method :not_responding_to do
          desc 'Constrains the subject to not respond to the given methods'
          concerning :exclusion
          default_for_parameter :expectation_qualifier, :none
          aliases :not_implementing

          configure { |*methods| { excluded: (constraints.self&.exclusion&.excluded || []).concat(methods).uniq } }
        end
      end

      def initialize(*methods, **options)
        super(responding_to: methods, **options)
      end
    end
  end
end
