# frozen_string_literal: true

require 'domainic/type/behavior'

module Domainic
  module Type
    # @since 0.1.0
    class EnumType
      include Behavior

      # @rbs (*untyped literals, **untyped options) -> void
      def initialize(*literals, **options)
        super(**options.merge(literal: literals))
      end

      # @rbs (*untyped literals) -> void
      def literal(*literals)
        literals = literals.map do |literal|
          @constraints.prepare :self, :equality, literal
        end
        constrain :self, :or, literals
      end
      alias value literal
    end
  end
end
