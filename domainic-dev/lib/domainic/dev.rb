# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require 'semantic'
require 'thor'

require_relative 'dev/gem_manager'
require_relative 'dev/cli'

module Domainic
  # Tools and utilities for developing the Domainic framework.
  #
  # @api development
  #
  # @since 0.1.0
  module Dev
    # The root path of the Domainic framework.
    #
    # @return [Pathname] the root path.
    def self.root
      Pathname.new(File.expand_path('../../../', File.dirname(__FILE__)))
    end
  end
end
