# frozen_string_literal: true

require 'domainic/dev/cli/command/base_task_runner_command'
require 'thor'

module Domainic
  module Dev
    class CLI < Thor
      module Command
        # A command to run the complete CI pipeline for the Domainic monorepo.
        #
        # This class extends {BaseTaskRunnerCommand} to define and execute the sequence of tasks that make up
        # the CI pipeline, including dependency installation, type checking, linting, testing, and packaging.
        #
        # @author {https://aaronmallen.me Aaron Allen}
        # @since 0.1.0
        class RunCICommand < BaseTaskRunnerCommand
          runner_name 'CI'

          long_desc <<~DESC
            Run the entire CI pipeline for the Domainic monorepo.
          DESC

          task(
            'setup/dependencies',
            'Installing dependencies',
            'bundle', 'install'
          )

          task(
            'setup/signatures',
            'Generating signatures',
            'bin/dev', 'generate', 'signatures'
          )

          task(
            'setup/rbs_collection',
            'Installing RBS collection',
            'bundle', 'exec', 'rbs', 'collection', 'install'
          )

          task(
            'lint/ruby',
            'Linting ruby files',
            'bin/dev lint ruby'
          )

          task(
            'lint/markdown',
            'Linting markdown files',
            'bin/dev', 'lint', 'markdown'
          )

          task(
            'lint/types',
            'Linting ruby types',
            'bin/dev', 'lint', 'types'
          )

          task(
            'test/ruby',
            'Running ruby tests',
            'bin/dev', 'test'
          )

          task(
            'test/types',
            'Running ruby tests with RBS',
            'bin/dev', 'test', '--rbs'
          )

          task(
            'package/gems',
            'Packaging gems',
            'bin/dev', 'package'
          )
        end
      end
    end
  end
end
