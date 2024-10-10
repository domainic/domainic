# frozen_string_literal: true

require_relative 'gem_manager/version'
require_relative 'gem_manager/publisher'
require_relative 'gem_manager/gem'

module Domainic
  module Dev
    # The `GemManager` module is responsible for managing, versioning, building and publishing Domainic gems.
    #
    # @since 0.1.0
    module GemManager
      # Find a gem by name.
      #
      # @param gem_name [String] The name of the gem to find.
      # @return [Gem, nil] The gem object if found, otherwise nil.
      def self.gem(gem_name)
        gems.find { |gem| gem.name == gem_name }
      end

      # Find all gems in the Domainic repository.
      #
      # @return [Array<Gem>] An array of gem objects.
      def self.gems
        Dev.root.glob('{*/*.gemspec,domainic.gemspec}').map(&:dirname).map { |path| Gem.new(path) }
      end
    end
  end
end
