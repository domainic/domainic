# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  enable_coverage :branch
  coverage_dir File.expand_path('../coverage', __dir__)
  add_filter '/config/'
  add_filter '/spec/'

  track_files File.expand_path('../**/*.rb', __dir__)
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!
  config.warnings = true
  config.order = :random
  Kernel.srand config.seed
end
