# frozen_string_literal: true

require_relative 'relational_constraint'

module Domainic
  module Type
    module Constraint
      # The `InclusionConstraint` checks if the subject includes one or more expected values.
      # You can apply expectation qualifiers to control how the inclusion check is performed when comparing against
      # multiple values. Valid qualifiers include `:all?`, `:any?`, `:none?`, and `:one?`.
      #
      # @since 0.1.0
      class InclusionConstraint < RelationalConstraint
        expectation :include?
      end
    end
  end
end
