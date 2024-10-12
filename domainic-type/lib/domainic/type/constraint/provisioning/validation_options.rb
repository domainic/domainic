# frozen_string_literal: true

module Domainic
  module Type
    module Constraint
      module Provisioning
        # Validation options for a {ProvisionedConstraint}.
        #
        # @since 0.1.0
        class ValidationOptions
          # Initialize a new instance of ValidationOptions.
          #
          # @param options [Hash{String, Symbol => Object}]
          # @return [ValidationOptions] the new instance of ValidationOptions.
          def initialize(options = {})
            @fail_fast = options.fetch(:fail_fast, false)
          end

          # Whether validation should continue on constraint validation failure.
          #
          # @return [Boolean] `true` if validation should stop on failure, otherwise `false`.
          def fail_fast?
            @fail_fast
          end
        end
      end
    end
  end
end
