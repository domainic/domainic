# frozen_string_literal: true

module Domainic
  module Type
    module Constraint
      # A mixin to add the `access_qualifier` parameter to a constraint.
      #
      # @!method access_qualifier
      #  The access qualifier for the constraint. Determines how the constraint is applied to a collection returned by
      #  the accessor.
      #  @return [Symbol]
      #
      # @!method access_qualifier=(value)
      #  @see VALID_ACCESS_QUALIFIERS
      #  Set the access qualifier for the constraint.
      #  @param value [Symbol] The access qualifier for the constraint.
      #  @return [void]
      #
      # @!method access_qualifier_default
      #  The default access qualifier for the constraint.
      #  @return [nil] there is no default access qualifier.
      #
      # @since 0.1.0
      module WithAccessQualification
        # Valid access qualifiers for the constraint.
        #
        # @see #access_qualifier
        #
        # @return [Array<Symbol>]
        VALID_ACCESS_QUALIFIERS = %i[all? any? none? one?].freeze

        class << self
          private

          # Inject the `access_qualifier` parameter into the base class.
          #
          # @param base [Class] The base class to include the parameter in.
          # @return [void]
          def included(base) # rubocop:disable Metrics/MethodLength
            base.parameter :access_qualifier do
              desc 'Determines how the constraint is applied to a collection returned by the accessor. ' \
                   'Valid values are :all, :any, :none, or :one.'

              coercer do |value|
                if value.nil?
                  value
                else
                  value.to_s.end_with?('?') ? value.to_sym : :"#{value}?"
                end
              end

              validator ->(value) { value.nil? || VALID_ACCESS_QUALIFIERS.include?(value) }
            end
          end
        end
      end
    end
  end
end
