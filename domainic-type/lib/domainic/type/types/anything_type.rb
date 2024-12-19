# frozen_string_literal: true

require 'domainic/type/behavior'

module Domainic
  module Type
    # @since 0.1.0
    class AnythingType
      include Behavior

      def but(*types)
        not_types = types.map do |type|
          @constraints.prepare(:self, :not, @constraints.prepare(:self, :type, type))
        end
        constrain :self, :and, not_types, concerning: :exclusion
      end
      alias except but
      alias excluding but
    end
  end
end
