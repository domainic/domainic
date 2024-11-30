# frozen_string_literal: true

require 'domainic/dev/gem'
require 'pathname'

module Domainic
  # Tools and utilities for developing Domainic.
  #
  # @since 0.1.0
  module Dev
    # The root directory of the Domainic monorepo.
    #
    # @return [Pathname] the root directory.
    # @rbs () -> Pathname
    def self.root
      Pathname.new(File.expand_path('../../../', File.dirname(__FILE__)))
    end
  end
end
