# frozen_string_literal: true

require_relative 'property_constraint'
require_relative 'specification/with_access_qualification'

module Domainic
  module Type
    module Constraint
      # The `PolarityConstraint` checks if the subject is positive, negative. The valid conditions for this constraint
      #  are `:positive` or `:negative`.
      #
      # @since 0.1.0
      class PolarityConstraint < PropertyConstraint
        include Specification::WithAccessQualification

        conditions :positive, :negative
      end
    end
  end
end
