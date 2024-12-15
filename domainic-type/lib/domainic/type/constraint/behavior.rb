# frozen_string_literal: true

module Domainic
  module Type
    module Constraint
      # @since 0.1.0
      module Behavior
        VALID_ACCESSORS = %i[begin count end first keys last length self size values].freeze #: Array[Symbol]

        # @rbs @accessor: Symbol
        # @rbs @actual: untyped
        # @rbs @expected: untyped
        # @rbs @options: Hash[Symbol, untyped]

        # @rbs (Symbol accessor, ?untyped? expectation, **untyped) -> void
        def initialize(accessor, expectation = nil, **options)
          validate_accessor!(accessor)
          validate_expectation!(expectation) unless expectation.nil?

          @accessor = accessor
          @expected = expectation
          @options = options.transform_keys(&:to_sym)
        end

        # @rbs () -> bool
        def abort_on_failure?
          @options.fetch(:abort_on_failure, false)
        end

        # @rbs () -> String
        def description
          raise NotImplementedError
        end

        # @rbs (untyped expectation) -> self
        def expecting(expectation)
          validate_expectation!(expectation)

          if expectation.is_a?(Hash) && @expected.is_a?(Hash)
            @expected.merge!(expectation)
          else
            @expected = expectation
          end

          self
        end

        # @rbs () -> String
        def failure_description
          raise NotImplementedError
        end

        # @rbs (untyped value) -> bool
        def satisfied?(value)
          subject = @accessor == :self ? value : value.public_send(@accessor)
          validate_subject!(subject)
          @actual = subject

          satisfies_constraint?
        end

        # @rbs () -> bool
        def type_failure?
          @options.fetch(:is_type_failure, false)
        end

        # @rbs (**untyped options) -> self
        def with_options(**options)
          @options.merge!(options.transform_keys(&:to_sym))
          self
        end

        private

        # @rbs () -> bool
        def satisfies_constraint?
          raise NotImplementedError
        end

        # @rbs (Symbol accessor) -> void
        def validate_accessor!(accessor)
          return if VALID_ACCESSORS.include?(accessor)

          raise ArgumentError, "Invalid accessor: #{accessor} must be one of #{VALID_ACCESSORS.join(', ')}"
        end

        # @rbs (untyped expectation) -> void
        def validate_expectation!(expectation); end

        # @rbs (untyped value) -> void
        def validate_subject!(value); end
      end
    end
  end
end
