# frozen_string_literal: true

module Domainic
  module Type
    # Used to indicate that a value is not specified which is different from `nil`.
    #
    # @since 0.1.0
    # @return [Object]
    UNSPECIFIED = Object.new.freeze
  end
end
