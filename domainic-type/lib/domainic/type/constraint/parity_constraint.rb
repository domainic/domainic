# frozen_string_literal: true

require_relative 'property_constraint'
require_relative 'specification/with_access_qualification'

module Domainic
  module Type
    module Constraint
      # The `ParityConstraint` checks if the subject is even or odd. The valid conditions for this
      # constraint are `:even` and `:odd`.
      #
      # @since 0.1.0
      class ParityConstraint < PropertyConstraint
        include Specification::WithAccessQualification

        conditions :even, :odd
      end
    end
  end
end
