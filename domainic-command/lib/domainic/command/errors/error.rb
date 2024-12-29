# frozen_string_literal: true

module Domainic
  module Command
    # Base error class for command-related errors. This class serves as the root of the command error
    # hierarchy, allowing for specific error handling of command-related issues.
    #
    # @note This is an abstract class and should not be instantiated directly. Instead, use one of its
    #   subclasses for specific error cases.
    #
    # @example Rescuing command errors
    #   begin
    #     # Command execution code
    #   rescue Domainic::Command::Error => e
    #     # Handle any command-related error
    #   end
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class Error < StandardError
    end
  end
end
