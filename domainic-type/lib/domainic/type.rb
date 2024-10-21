# frozen_string_literal: true

require_relative 'type/configuration'

module Domainic
  # Stupidly granular type validation for Ruby.
  #
  # @since 0.1.0
  module Type
    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.configure
      yield configuration if block_given?
    end
  end
end
