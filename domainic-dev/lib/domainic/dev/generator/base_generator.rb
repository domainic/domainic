# frozen_string_literal: true

require 'thor'

module Domainic
  module Dev
    module Generator
      # Base class for all Domainic::Dev generators.
      #
      # This class extends Thor::Group and includes Thor::Actions to provide common functionality for generators.
      # All generator classes should inherit from this class to ensure consistent behavior and interface.
      #
      # @abstract Subclass and implement generator behavior
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class BaseGenerator < Thor::Group
        include Thor::Actions

        # Get the source root directory for templates.
        #
        # @return [String] path to the template directory
        # @rbs () -> String
        def self.source_root
          template_dir = (name || '').split('::')
                                     .last
                                     .gsub(/([A-Z])/, '_\1')
                                     .downcase
                                     .sub(/^_/, '')
                                     .delete_suffix('_generator')
          File.expand_path("templates/#{template_dir}", File.dirname(__FILE__))
        end
      end
    end
  end
end
