# frozen_string_literal: true

require_relative 'base_type'

module Domainic
  module Type
    # The `BooleanType` class represents the boolean type in Domainic.
    #
    # @since 0.1.0
    class BooleanType < BaseType
      constrain :self do
        intrinsic_constraint :type, expected: [TrueClass, FalseClass], expectation_qualifier: :any
      end
    end
  end
end
