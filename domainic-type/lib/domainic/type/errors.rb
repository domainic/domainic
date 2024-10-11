# frozen_string_literal: true

module Domainic
  module Type
    # The base class for all {Domainic::Type} errors.
    #
    # @since 0.1.0
    class Error < StandardError; end

    # Raised when a {Constraint::Parameter} is given an invalid value.
    #
    # @since 0.1.0
    class InvalidParameterError < Error; end

    # Raised when the subject of a constraint cannot be constrained by the constraint.
    #
    # @since 0.1.0
    class InvalidSubjectError < Error; end
  end
end
