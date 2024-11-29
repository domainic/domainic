# frozen_string_literal: true

# Setup coverage reporting
require 'simplecov'

SimpleCov.start do
  enable_coverage :branch
  coverage_dir File.expand_path('../coverage', __dir__)
  add_filter '/spec/'
  track_files File.expand_path('../**/*.rb', __dir__)
end

# require bundle gems
require 'bundler/setup'
require 'pathname'

# Setup RBS testing
ENV['RBS_TEST_TARGET'] = 'Domainic::*'
ENV['RBS_TEST_DOUBLE_SUITE'] = 'rspec'
ENV['RBS_TEST_LOGLEVEL'] = 'error'
signature_args = "-I #{Dir.glob(File.expand_path('../*/*.gemspec', __dir__))
                          .map { |gemspec_file| File.dirname(gemspec_file) }
                          .join('-I ')}"
required_library_args = "-r #{%w[forwardable pathname].join(' -r ')}"
ENV['RBS_TEST_OPT'] = "#{required_library_args} #{signature_args}"
require 'rbs/test/setup'

# Configure RSpec
RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.order = :random
  Kernel.srand config.seed
end

# Load all gemspec files in the mono-repo for testing
directories_with_gemspec = Dir.glob('*').select do |directory|
  File.directory?(directory) && Dir.glob("#{directory}/*.gemspec").any?
end

gem_paths = directories_with_gemspec.select do |gem_directory|
  ARGV.any? do |argument|
    argument.start_with?(gem_directory) ||
      argument.start_with?(File.join(Dir.getwd, gem_directory)) ||
      argument.start_with?(File.join('.', gem_directory))
  end
end

gem_paths.each do |gem_path|
  spec_directory = Pathname.new(gem_path).join('spec')
  $LOAD_PATH << spec_directory.to_s if spec_directory.exist? && !$LOAD_PATH.include?(spec_directory.to_s)

  spec_helper = spec_directory.join('spec_helper.rb')
  load spec_helper.to_s if spec_helper.exist?
end
