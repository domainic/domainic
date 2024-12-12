# frozen_string_literal: true

require 'domainic/dev/cli'
require 'domainic/dev/gem'
require 'pathname'

module Domainic
  # Development utilities for the Domainic.
  #
  # This module provides access to development tools and configurations used in the development of the Domainic.
  #
  # @!visibility private
  # @author {https://aaronmallen.me Aaron Allen}
  # @since 0.1.0
  module Dev
    # Get the root directory of the Domainic monorepo.
    #
    # @example
    #   Domainic::Dev.root #=> #<Pathname:/path/to/domainic>
    #
    # @return [Pathname] the root directory of the Domainic monorepo.
    # @rbs () -> Pathname
    def self.root
      Pathname.new(File.expand_path('../../../', File.dirname(__FILE__)))
    end
  end
end
