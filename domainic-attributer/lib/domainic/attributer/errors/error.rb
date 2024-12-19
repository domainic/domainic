# frozen_string_literal: true

module Domainic
  module Attributer
    # Base error class for all Attributer-related errors
    #
    # This class serves as the foundation for Attributer's error hierarchy, allowing
    # for specific error types to be caught and handled appropriately. All custom
    # errors within the Attributer system should inherit from this class to maintain
    # a consistent error handling pattern
    #
    # @api private
    # @!visibility private
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.2.0
    class Error < StandardError
    end
  end
end
