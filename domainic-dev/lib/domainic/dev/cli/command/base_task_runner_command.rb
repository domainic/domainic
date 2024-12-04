# frozen_string_literal: true

require 'domainic/dev/cli/command/base_command'
require 'open3'
require 'thor'

module Domainic
  module Dev
    class CLI < Thor
      module Command
        # Base class for CLI commands that run a series of tasks with progress tracking.
        #
        # This class extends {BaseCommand} to provide functionality for running and monitoring multiple tasks in
        # sequence. It handles task execution, console output formatting, progress tracking, and error reporting.
        #
        # @abstract Subclass and define tasks using the {task} method
        # @author {https://aaronmallen.me Aaron Allen}
        # @since 0.1.0
        class BaseTaskRunnerCommand < BaseCommand
          # The width of the console output in characters.
          #
          # @return [Integer] the console width
          CONSOLE_LENGTH = 61 #: Integer

          # A struct representing a task to be executed.
          #
          # @!attribute banner
          #   @return [String] the display text for the task
          # @!attribute commands
          #   @return [Array<String>] the shell commands to execute
          # @!attribute executed?
          #   @return [Boolean] whether the task has been executed
          # @!attribute name
          #   @return [String] the task name
          # @!attribute result
          #   @return [TaskResult] the execution result
          Task = Struct.new(
            :banner, #: String
            :commands, #: Array[String]
            :executed?, #: bool
            :name, #: String
            :result, #: TaskResult
            keyword_init: true
          )

          # A struct representing the result of a task execution.
          #
          # @!attribute stderr
          #   @return [String] standard error output
          # @!attribute stdout
          #   @return [String] standard output
          # @!attribute success?
          #   @return [Boolean] whether the task succeeded
          TaskResult = Struct.new(
            :stderr, #: String
            :stdout, #: String
            :success?, #: bool
            keyword_init: true
          )

          # @rbs self.@runner_name: String
          # @rbs @tasks: Array[Task]

          class << self
            # Get or set the name of the task runner.
            #
            # @param name [String, nil] the name to set
            # @return [String] the runner name
            # @rbs (?String? name) -> String
            def runner_name(name = nil)
              return @runner_name || self.name if name.nil?

              @runner_name = name
            end

            # Define a task for the runner.
            #
            # @param name [String] the task name
            # @param banner [String] the display text for the task
            # @param commands [Array<String>] the shell commands to execute
            # @return [void]
            # @rbs (String name, String banner, *String commands) -> void
            def task(name, banner, *commands)
              result = TaskResult.new(stderr: '', stdout: '', success?: false)
              task = Task.new(banner:, commands:, executed?: false, name:, result:)
              tasks << task
            end

            # Get all defined tasks.
            #
            # @return [Array<Task>] the defined tasks
            # @rbs () -> Array[Task]
            def tasks
              @tasks ||= []
            end
          end

          # Execute all defined tasks in sequence.
          #
          # @return [void]
          # @rbs () -> void
          def execute
            tasks.each do |task|
              run_task(task)
              render_console
            end
          end

          private

          # Clear the console screen.
          #
          # @return [void]
          # @rbs () -> void
          def clear_console
            system('clear') || system('cls')
          end

          # Check if all tasks have been executed.
          #
          # @return [Boolean] true if all tasks are complete
          # @rbs () -> bool
          def complete?
            tasks.all?(&:executed?)
          end

          # Get all completed tasks.
          #
          # @return [Array<Task>] completed tasks
          # @rbs () -> Array[Task]
          def completed_tasks
            tasks.select(&:executed?)
          end

          # Generate a status report string for a task.
          #
          # @param task [Task] the task to report on
          # @return [String] the formatted status report
          # @rbs (Task task) -> String
          def generate_task_status_report(task)
            banner_length = "==> #{task.banner}".length
            status_length = 9 # this is the max length of the available status strings
            indent_size = CONSOLE_LENGTH - banner_length - status_length
            status_message = if task.result.success?
                               "#{icon(:check, :green)} #{colorize('Success', :green)}"
                             else
                               "#{icon(:x, :red)} #{colorize('Failed', :red)}"
                             end
            "#{colorize('==>', :cyan)} #{task.banner}#{' ' * indent_size}#{status_message}"
          end

          # Render the console output.
          #
          # @return [void]
          # @rbs () -> void
          def render_console
            clear_console
            render_progress_bar
            render_task_status_report
            render_status_report
            render_task_error_report
          end

          # Render the progress bar.
          #
          # @return [void]
          # @rbs () -> void
          def render_progress_bar
            percent = (completed_tasks.count.to_f / tasks.count * 100).round(1)
            bar_length = 40
            filled_length = (percent / 100 * bar_length).round
            bar = ('#' * filled_length) + ('-' * (bar_length - filled_length))
            puts "Progress: [#{bar}] #{percent}%\n\n"
          end

          # Render the overall status report.
          #
          # @return [void]
          # @rbs () -> void
          def render_status_report
            return unless complete?

            status_string = if tasks.all? { |task| task.result.success? }
                              "#{icon(:check, :green)} #{colorize("#{self.class.runner_name} Success", :green)}"
                            else
                              "#{icon(:x, :red)} #{colorize("#{self.class.runner_name} Failure", :red)}"
                            end
            puts "\n#{embolden(status_string)}"
          end

          # Render the error report for failed tasks.
          #
          # @return [void]
          # @rbs () -> void
          def render_task_error_report
            return unless complete?

            tasks.reject { |task| task.result.success? }.each do |task|
              puts "\n#{embolden("#{colorize('==>', :red)} #{task.name}")}"
              puts "\n#{task.result.stdout + task.result.stderr}"
            end
          end

          # Render the status report for completed tasks.
          #
          # @return [void]
          # @rbs () -> void
          def render_task_status_report
            completed_tasks.each { |task| puts generate_task_status_report(task) }
          end

          # Run a single task.
          #
          # @param task [Task] the task to run
          # @return [void]
          # @rbs (Task task) -> void
          def run_task(task)
            Open3.popen3(*task.commands) do |stdin, stdout, stderr, wait_thread| # steep:ignore
              stdin.close
              task.result.stdout = stdout.read
              task.result.stderr = stderr.read
              task.result[:success?] = wait_thread.value.success?
            end
            task[:executed?] = true
          end

          # Get all tasks for this runner instance.
          #
          # @return [Array<Task>] the tasks
          # @rbs () -> Array[Task]
          def tasks
            @tasks ||= self.class.tasks.map(&:dup)
          end
        end
      end
    end
  end
end
