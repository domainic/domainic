# frozen_string_literal: true

require 'domainic/dev/cli/command/base_command'
require 'domainic/dev/cli/command/mixin/gem_names_argument'
require 'thor'

module Domainic
  module Dev
    class CLI < Thor
      module Command
        # A command to run RSpec tests for one or more Domainic gems.
        #
        # This command extends {BaseCommand} and includes {Mixin::GemNamesArgument} to provide functionality for running
        # tests on specified gems. If no gem names are provided, tests will be run for all gems in the project.
        #
        # @author {https://aaronmallen.me Aaron Allen}
        # @since 0.1.0
        class RunTestsCommand < BaseCommand
          include Mixin::GemNamesArgument

          # @rbs @rbs_env: Hash[String, String]?

          class_option :rbs, type: :boolean, default: false, desc: 'Run tests with RBS enabled' # steep:ignore

          long_desc <<~DESC
            Run tests for one or more domainic gems. If no gem names are provided all gems are tested.

            Options:
            --rbs                                                # Run tests with RBS enabled

            Example:

            $ dev test                                           # Run all tests
            $ dev test --rbs                                     # Run all tests with RBS enabled
            $ dev test domainic-dev                              # Run tests for domainic-dev
            $ dev test domainic-dev domainic-attributer          # Run tests for domainic-dev and domainic-attributer
          DESC

          # Run RSpec tests for the specified gems.
          #
          # @return [void]
          # @rbs () -> void
          def execute
            result = system(build_env, *build_command) # steep:ignore UnresolvedOverloading
            exit 1 unless result
          end

          private

          # Build the command to run RSpec tests for the specified gems.
          #
          # @return [Array<Hash{String => String}, String>]
          # @rbs () -> Array[Hash[String, String] | String]
          def build_command
            command = ['bundle', 'exec', 'rspec', *gems.map { |gem| gem.paths.test.to_s }]

            if options[:rbs] # steep:ignore NoMethod
              command << '--tag'
              command << '~rbs:skip'
            end

            command
          end

          # Build the environment variables for running RSpec tests.
          #
          # @return [Hash{String => String}]
          # @rbs () -> Hash[String, String]
          def build_env
            {}.merge(rbs_env)
          end

          # The rbs environment variables to use when running tests.
          #
          # @return [Hash{String => String}]
          # @rbs () -> Hash[String, String]
          def rbs_env
            return {} unless options[:rbs] # steep:ignore NoMethod

            @rbs_env ||= {
              'RUBYOPT' => '-r bundler/setup -r rbs/test/setup',
              'RBS_TEST_TARGET' => 'Domainic::*',
              'RBS_TEST_LOGLEVEL' => 'error',
              'RBS_TEST_DOUBLE_SUITE' => 'rspec'
            }
          end
        end
      end
    end
  end
end
