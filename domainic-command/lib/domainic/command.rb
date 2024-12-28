# frozen_string_literal: true

require 'domainic/command/class_methods'
require 'domainic/command/instance_methods'

module Domainic
  # @since 0.1.0
  module Command
    # @rbs! extend ClassMethods
    # @rbs! include InstanceMethods

    # @rbs (Class | Module base) -> void
    def self.included(base)
      base.extend(ClassMethods)
      base.include(InstanceMethods)
    end
  end
end
