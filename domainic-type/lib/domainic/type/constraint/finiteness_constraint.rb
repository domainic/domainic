# frozen_string_literal: true

require_relative 'property_constraint'
require_relative 'with_access_qualification'

module Domainic
  module Type
    module Constraint
      # The `FinitenessConstraint` checks if the subject is infinite or finite. The valid conditions for this
      # constraint are `:finite` and `:infinite`.
      #
      # @since 0.1.0
      class FinitenessConstraint < PropertyConstraint
        include WithAccessQualification

        conditions :finite, :infinite

        protected

        def interpret_result(result)
          !result.nil? && !!result
        end
      end
    end
  end
end
