# frozen_string_literal: true

DOMAINIC_COMMAND_GEM_VERSION = '0.1.0'
DOMAINIC_COMMAND_SEMVER = '0.1.0'
DOMAINIC_COMMAND_REPO_URL = 'https://github.com/domainic/domainic'
DOMAINIC_COMMAND_HOME_URL = "#{DOMAINIC_COMMAND_REPO_URL}/tree/domainic-command-v#{DOMAINIC_COMMAND_SEMVER}/" \
                            'domainic-command'.freeze

Gem::Specification.new do |spec|
  spec.name     = 'domainic-command'
  spec.version  = DOMAINIC_COMMAND_GEM_VERSION
  spec.authors  = ['Aaron Allen']
  spec.email    = ['hello@aaronmallen.me']
  spec.homepage = DOMAINIC_COMMAND_HOME_URL
  spec.summary  = 'An implementation of the Command Pattern for Ruby'
  spec.license  = 'MIT'

  spec.required_ruby_version = '>= 3.1'

  spec.files         = Dir['CHANGELOG.md', 'LICENSE', 'README.md', 'lib/**/*']
  spec.require_paths = ['lib']

  spec.metadata = {
    'bug_tracker_uri' => "#{DOMAINIC_COMMAND_REPO_URL}/issues",
    'changelog_uri' => "#{DOMAINIC_COMMAND_REPO_URL}/releases/tag/domainic-command-v#{DOMAINIC_COMMAND_SEMVER}",
    'homepage_uri' => DOMAINIC_COMMAND_HOME_URL,
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => "#{DOMAINIC_COMMAND_REPO_URL}/tree/domainic-command-v#{DOMAINIC_COMMAND_SEMVER}/" \
                         'domainic-command',
    'wiki_uri' => "#{DOMAINIC_COMMAND_REPO_URL}/wiki"
  }

  spec.add_dependency 'domainic-type', '>= 0.1.0', '< 1'
end
