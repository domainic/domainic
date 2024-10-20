# frozen_string_literal: true

require_relative 'cli/lint'
require_relative 'cli/version'

module Domainic
  module Dev
    # The Domainic development command line interface.
    #
    # @since 0.1.0
    class CLI < Thor
      package_name 'Domainic Development'

      def self.exit_on_failure?
        true
      end

      desc 'lint [COMMAND]', 'Run the linters for the Domainic project.'
      subcommand 'lint', Lint

      desc 'version [COMMAND]', 'Manage gem versions through the Domainic Dev CLI.'
      subcommand 'version', Version

      desc 'build [GEM NAMES]', 'Build a Domainic gem.'
      long_desc <<~LONGDESC, wrap: false
        Build a Domainic gem by name. If no gem name is provided, all gems in the Domainic repository will be built instead.

        Example:
        $ dev build                                     Build all gems
        $ dev build domainic-dev                        Build a single gem
        $ dev build domainic-dev domainic-type          Build multiple gems
      LONGDESC
      def build(*gem_names)
        gems = gem_names.empty? ? GemManager.gems : gem_names.filter_map { |gem_name| GemManager.gem(gem_name) }
        gems.each(&:build!)
      end

      desc 'ci', 'Run the entire build pipeline for the Domainic project.'
      long_desc <<~LONGDESC, wrap: false
        Run the entire build pipeline for the Domainic project. This includes linting, testing, and building all Domainic gems.
      LONGDESC
      def ci
        invoke(:lint)
        invoke(:test)
        invoke(:build)
      end

      desc 'publish [GEM NAMES]', 'publish a Domainic gem to rubygems.org'
      long_desc <<~LONGDESC, wrap: false
        Publish a Domainic gem by name. If no gem name is provided, all gems in the Domainic repository will be published instead.

        Example:
        $ dev publish                                     Publish all gems
        $ dev publish domainic-dev                        Publish a single gem
        $ dev publish domainic-dev domainic-type          Publish multiple gems
      LONGDESC
      def publish(*gem_names)
        gems = gem_names.empty? ? GemManager.gems : gem_names.filter_map { |gem_name| GemManager.gem(gem_name) }
        gems.each(&:publish!)
      end

      desc 'test [GEM NAMES]', 'Run the tests for a Domainic gem.'
      long_desc <<~LONGDESC, wrap: false
        Run the tests for a Domainic gem by name. If no gem name is provided, all gems in the Domainic repository will be tested instead.

        Example:
        $ dev test                                     Test all gems
        $ dev test domainic-dev                        Test a single gem
        $ dev test domainic-dev domainic-type          Test multiple gems
      LONGDESC
      def test(*gem_names)
        gems = gem_names.empty? ? GemManager.gems : gem_names.filter_map { |gem_name| GemManager.gem(gem_name) }
        paths = gems.filter_map { |gem| gem.paths.test if gem.paths.test.exist? }
        system('bundle', 'exec', 'rspec', '--require', './config/rspec_client', *paths.map(&:to_s), exception: true)
      end
    end
  end
end
