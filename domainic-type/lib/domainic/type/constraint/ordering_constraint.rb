# frozen_string_literal: true

require_relative '../errors'
require_relative 'property_constraint'

module Domainic
  module Type
    module Constraint
      # The `OrderingConstraint` checks if the subject is sorted or unsorted. The valid conditions for this
      # constraint are `:ordered` and `:unordered`.
      #
      # @since 0.1.0
      class OrderingConstraint < PropertyConstraint
        conditions :ordered, :unordered

        # @!method reversed
        #  Allows the constraint to be in reverse order.
        #  @return [Boolean] `true` if the constraint is reversed, `false` otherwise.
        #
        # @!method reversed=(value)
        #  Sets the constraint to be in reverse order.
        #  @param value [Boolean] `true` if the constraint is reversed, `false` otherwise.
        #  @return [void]
        #
        # @!method default_reversed
        #  Returns the default value for the reversed parameter.
        #  @return [false] the default value for the reversed parameter.
        parameter :reversed do
          desc 'Allows the constraint to be in reverse order'
          validator ->(value) { true.equal?(value) || false.equal?(value) }
          default false
          required
        end

        private

        # Check if the subject is ordered.
        #
        # @param subject [Object] The subject to check.
        # @return [Boolean] `true` if the subject is ordered, `false` otherwise.
        def ordered?(subject)
          sorted_subject = sorted_subject(subject)
          sorted_subject == subject || sorted_subject.join == subject
        rescue InvalidSubjectError
          false
        end

        # Converts the subject to an array if it's a string; otherwise, returns the subject itself.
        #
        # @param subject [Object] The subject to check.
        # @raise [InvalidSubjectError] if the subject is not sortable.
        # @return [Array<Object>] The subject converted to an array if it's a string, or the subject itself.
        def sortable_subject(subject)
          if subject.respond_to?(:sort)
            subject
          elsif subject.is_a?(String)
            subject.chars
          elsif subject.respond_to?(:to_a)
            subject.to_a
          else
            raise InvalidSubjectError
          end
        end

        # Ensure the subject is sorted.
        #
        # @param subject [Object] The subject to sort.
        # @return [Array<Object>] The sorted subject.
        def sorted_subject(subject)
          sorted = sortable_subject(subject).sort
          sorted = sorted.reverse if reversed
          sorted
        end

        # Check if the subject is unordered.
        #
        # @param subject [Object] The subject to check.
        # @return [Boolean] `true` if the subject is unordered, `false` otherwise.
        def unordered?(subject)
          sorted_subject = sorted_subject(subject)
          sorted_subject != subject && sorted_subject.join != subject
        rescue InvalidSubjectError
          false
        end
      end
    end
  end
end
