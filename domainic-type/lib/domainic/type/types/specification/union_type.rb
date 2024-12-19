# frozen_string_literal: true

require 'domainic/type/behavior'

module Domainic
  module Type
    # @since 0.1.0
    class UnionType
      include Behavior

      # @rbs (*Class | Module | Behavior[untyped, untyped, untyped] types, **untyped options) -> void
      def initialize(*types, **options)
        super(**options.merge(type: types))
      end

      # @rbs (*Class | Module | Behavior[untyped, untyped, untyped] types) -> self
      def type(*types)
        types = types.map do |type|
          @constraints.prepare :self, :type, type
        end
        constrain :self, :or, types, concerning: :inclusion
      end
      alias or type
    end
  end
end
