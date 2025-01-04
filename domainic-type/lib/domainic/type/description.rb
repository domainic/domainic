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
        constraints.all.filter_map do |constraint|
          context = constraint.description_context
          puts context.inspect
          message_for(context)
        rescue StandardError
          next
        end.reject(&:empty?).uniq.join(', ')
      end

      # @rbs () -> String
      def violation
        return '' unless constraints.failures?

        constraints.all.filter_map do |constraint|
          next unless constraint.failed?

          context = constraint.violation_context
          message_for(context, violation: true)
        rescue KeyError
          next
        end.uniq.join(', ')
      end

      private

      # @rbs () -> Constraint::Set
      def constraints
        @type.instance_variable_get(:@constraints)
      end

      # @rbs (Hash[Symbol, untyped] context, ?violation: bool) -> String
      def message_for(context, violation: false)
        code = context[:code]&.to_s || (context[:negated] ? 'negated' : 'default')
        key_parts =
          ['types', @type.class.to_s.downcase, context[:concerning], violation ? 'violation' : nil, code].compact
        template = Store.template(key_parts.map(&:to_s).join('.'))
        Interpolator.interpolate(template, **context).strip
      end
    end
  end
end
