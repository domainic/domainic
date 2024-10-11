# frozen_string_literal: true

require_relative '../errors'
require_relative 'property_constraint'

module Domainic
  module Type
    module Constraint
      # The `UniquenessConstraint` checks if the subject is unique or duplicative. The valid conditions for this
      # constraint are `:duplicative` and `:unique`.
      #
      # @since 0.1.0
      class UniquenessConstraint < PropertyConstraint
        conditions :duplicative, :unique

        private

        # Check if the subject has duplicative elements.
        #
        # @param subject [::Object] The subject to check.
        # @return [::Boolean] `true` if the subject has any duplicate elements, `false` otherwise.
        def duplicative?(subject)
          elements = unique_elements(subject)
          elements.size != elements.uniq.size
        rescue InvalidSubjectError
          false
        end

        # Check if the subject has unique elements.
        #
        # @param subject [::Object] The subject to check.
        # @return [::Boolean] `true` if the subject has all unique elements, `false` otherwise.
        def unique?(subject)
          elements = unique_elements(subject)
          elements.size == elements.uniq.size
        rescue InvalidSubjectError
          false
        end

        # Converts the subject to an array if it's a string; otherwise, returns the subject itself.
        #
        # @param subject [::Object] The subject to check.
        # @return [::Array<::Object>] The elements of the subject as an array, or raises InvalidSubjectError if not
        #  applicable.
        def unique_elements(subject)
          if subject.is_a?(::String)
            subject.chars
          elsif subject.is_a?(::Enumerable)
            subject.to_a
          else
            raise InvalidSubjectError
          end
        end
      end
    end
  end
end
