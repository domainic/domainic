# frozen_string_literal: true

require 'forwardable'

require_relative 'load/registrar'

module Domainic
  module Type
    # @since 0.1.0
    class Configuration
      extend Forwardable
      def_delegators :registry, :register_alias_for_type, :register_group_for_type, :register_type,
                     :remove_alias_for_type, :remove_group_for_type, :remove_type

      DEFAULTS = { global_prefix: :T, global_prefix_enabled: false }.freeze

      attr_reader :global_prefix

      def initialize(**options)
        DEFAULTS.merge(options).each_pair { |key, value| instance_variable_set(:"@#{key}", value) }
      end

      def eager_load_type_group(group_name)
        group_symbol = group_name.to_sym
        group_symbol == :all ? registry.all.all?(&:load) : registry.group(group_name).all?(&:load)
      end

      def eager_load_types(*types)
        types.all? { |type| registry.find(type)&.load }
      end

      def enable_global_prefix
        @global_prefix_enabled = true
      end

      def global_prefix_enabled?
        @global_prefix_enabled
      end

      def prefix_global_with(prefix)
        @global_prefix_enabled = true
        @global_prefix = prefix.to_sym
      end

      private

      def registry
        @registry ||= Load::Registrar.new
      end
    end
  end
end
