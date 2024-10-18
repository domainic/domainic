# frozen_string_literal: true

require_relative 'relational_constraint'

module Domainic
  module Type
    module Constraint
      # The `RespondsToConstraint` checks if the subject responds to a given method.
      #
      # @since 0.1.0
      class RespondsToConstraint < RelationalConstraint
        expectation :respond_to?
      end
    end
  end
end
