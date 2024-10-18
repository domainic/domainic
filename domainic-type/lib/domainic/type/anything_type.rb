# frozen_string_literal: true

require_relative 'base_type'

module Domainic
  module Type
    # The `AnythingType` is a type that can be anything excluding the given types.
    #
    # @since 0.1.0
    class AnythingType < BaseType
      constrain :self do
        constraint :type, fail_fast: true

        bind_method :excluding do
          desc 'Constrains the given types from being considered valid'
          concerning :type
          aliases :but, :except
          default_for_parameter :negated, true

          configure { |*types| { expected: (constraints.self&.type&.expected || []).concat(types).uniq } }
        end
      end
    end
  end
end
