# frozen_string_literal: true

require 'domainic/type/description/interpolator'
require 'domainic/type/description/store'

module Domainic
  module Type
    # @since 0.1.0
    class Description
      # @rbs @type: Behavior

      # @rbs (Behavior type) -> void
      def initialize(type)
        @type = type
      end

      # @rbs () -> String
      def describe
        constraints.all.map do |constraint|
          context = constraint.description_context
          message_for(context)
        end.uniq.join(" #{Store.template('support.and_join')} ")
      end

      # @rbs () -> String
      def violation
        return '' unless constraints.failures?

        constraints.all.filter_map do |constraint|
          next unless constraint.failed?

          context = constraint.violation_context
          message_for(context, violation: true)
        end.uniq.join(" #{Store.template('support.and_join')} ")
      end

      private

      # @rbs () -> Constraint::Set
      def constraints
        @type.instance_variable_get(:@constraints)
      end

      # @rbs (Hash[Symbol, untyped] context, ?violation: bool) -> String
      def message_for(context, violation: false)
        code = context[:code] || (context[:negated] ? :negated : :default)
        key_parts =
          ['types', @type.class.to_s.downcase, context[:concerning], violation ? 'violation' : nil, code].compact
        template = Store.template(key_parts.join('.'))
        Interpolator.interpolate(template, **context).strip
      end
    end
  end
end
