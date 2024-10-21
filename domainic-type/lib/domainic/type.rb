# frozen_string_literal: true

require_relative 'type/configuration'

module Domainic
  # Stupidly granular type validation for Ruby.
  #
  # @since 0.1.0
  module Type
    class << self
      def configuration
        @configuration ||= Configuration.new
      end
      alias config configuration

      def configure
        yield configuration if block_given?
      ensure
        setup_global_prefix
      end

      private

      def ensure_safe_global_prefix!
        if Kernel.const_defined?(config.global_prefix) && Kernel.const_get(config.global_prefix) != Definition
          raise NameError, "cannot define #{config.global_prefix} as a global prefix for Domainic::Type" \
                           'because it is already defined as a constant. Please choose another prefix with ' \
                           '`prefix_global_with`.'
        end
      end

      def setup_global_prefix
        return unless config.global_prefix_enabled?

        require_relative 'type/definition'
        ensure_safe_global_prefix!

        Kernel.const_set(config.global_prefix, Definition) unless Kernel.const_defined?(config.global_prefix)
      end
    end
  end
end
