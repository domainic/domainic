# frozen_string_literal: true

require_relative 'relational_constraint'

module Domainic
  module Type
    module Constraint
      # The `EqualityConstraint` checks if the subject matches one or more expected values based on
      # the provided `expectation_qualifier`. This is used when comparing a subject to a predefined list
      # of expected values.
      #
      # @since 0.1.0
      class EqualityConstraint < RelationalConstraint
        expectation :==
      end
    end
  end
end
