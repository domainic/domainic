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
  end
end
