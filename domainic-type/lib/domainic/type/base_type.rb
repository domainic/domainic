# frozen_string_literal: true

require_relative 'constraint/provisioning/constraint_set'

module Domainic
  module Type
    # The base class for all Domainic types.
    #
    # @!attribute [r] constraints
    #  The constraints for the type.
    #  @return [Constraint::Provisioning::ConstraintSet]
    #
    # @abstract
    # @since 0.1.0
    class BaseType
      attr_reader :constraints

      class << self
        # The constraints for the type.
        #
        # @return [Constraint::Provisioning::ConstraintSet]
        def constraints
          @constraints ||= Constraint::Provisioning::ConstraintSet.new(self)
        end
      end

      # Initialize a new instance of BaseType.
      #
      # @return [BaseType] the new instance of BaseType.
      def initialize
        @constraints = self.class.constraints.dup_with_base(self)
      end
    end
  end
end
