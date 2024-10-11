# frozen_string_literal: true

require_relative 'property_constraint'
require_relative 'specification/with_access_qualification'

module Domainic
  module Type
    module Constraint
      # The `MutabilityConstraint` checks if the subject is frozen or mutable. The valid conditions for this
      # constraint are `:immutable` and `:mutable`.
      #
      # @since 0.1.0
      class MutabilityConstraint < PropertyConstraint
        include Specification::WithAccessQualification

        conditions :immutable, :mutable

        private

        def immutable?(subject)
          subject.frozen?
        end

        def mutable?(subject)
          !subject.frozen?
        end
      end
    end
  end
end
