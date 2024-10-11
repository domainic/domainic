# frozen_string_literal: true

require_relative 'property_constraint'

module Domainic
  module Type
    module Constraint
      # The `PopulationConstraint` checks if the subject is empty, or  populated. The valid conditions for this
      #  constraint are `:empty`, `:populated`.
      #
      # @since 0.1.0
      class PopulationConstraint < PropertyConstraint
        conditions :empty, :populated

        private

        def populated?(subject)
          !subject.empty?
        end
      end
    end
  end
end
