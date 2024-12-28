# frozen_string_literal: true

module Domainic
  module Command
    module Result
      # @since 0.1.0
      class Failure
        # @rbs @errors: __todo__

        attr_reader :errors # __todo__

        # @rbs (__todo__ errors) -> void
        def initialize(errors)
          # TODO: we need to figure out a way to handle both StandardError, Strings, and ActiveModel::Errors
          #   without explicitly adding ActiveModel as a dependency here. The command should be allowed to fail with:
          #     * fail!("Error message")
          #     * fail!(StandardError.new("Error message"))
          #     * fail!(my_model.errors)
          @errors = errors
        end

        # @rbs () -> bool
        def failure?
          true
        end
        alias failed? failure?

        # @rbs () -> bool
        def successful?
          false
        end
        alias success? successful?
      end
    end
  end
end
