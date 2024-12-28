# frozen_string_literal: true

module Domainic
  module Command
    module Result
      # @since 0.1.0
      class Success
        # @rbs @data: Struct

        attr_reader :data #: Struct

        # @rbs (Context::OutputContext context) -> void
        def initialize(context)
          hashed_context = context.to_hash
          @data = Struct.new(*hashed_context.keys, keyword_init: true).new(**hashed_context).freeze
        end

        # @rbs () -> bool
        def failure?
          false
        end
        alias failed? failure?

        # @rbs () -> bool
        def successful?
          true
        end
        alias success? successful?

        private

        # @rbs (Symbol method_name, *untyped arguments, **untyped keyword_arguments) ?{ (?) -> untyped } -> untyped
        def method_missing(method_name, ...)
          return super unless respond_to_missing?(method_name)

          data.public_send(method_name, ...)
        end

        # @rbs (Symbol method_name, ?bool include_private) -> bool
        def respond_to_missing?(method_name, _include_private = false)
          data.respond_to?(method_name) || super #: bool
        end
      end
    end
  end
end
