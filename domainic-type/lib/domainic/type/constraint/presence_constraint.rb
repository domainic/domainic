# frozen_string_literal: true

require_relative 'property_constraint'
require_relative 'with_access_qualification'

module Domainic
  module Type
    module Constraint
      # The `PresenceConstraint` checks if the subject is absent, or present. The valid conditions for this
      #  constraint are `:absent`, `:present`.
      #
      # @since 0.1.0
      class PresenceConstraint < PropertyConstraint
        include WithAccessQualification

        conditions :absent, :present

        private

        # Check if the subject is absent.
        #
        # @param subject [::Object] The subject to check.
        # @return [::Boolean] `true` if the subject is absent, `false` otherwise.
        def absent?(subject)
          subject.nil? || (subject.respond_to?(:empty?) && subject.empty?)
        end

        # Check if the subject is present.
        #
        # @param subject [::Object] The subject to check.
        # @return [::Boolean] `true` if the subject is present, `false` otherwise.
        def present?(subject)
          !subject.nil? && !(subject.respond_to?(:empty?) && subject.empty?)
        end
      end
    end
  end
end
