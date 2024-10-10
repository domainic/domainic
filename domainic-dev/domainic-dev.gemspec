# frozen_string_literal: true

DOMAINIC_DEV_GEM_VERSION = '0.1.0'
DOMAINIC_DEV_SEMVER = '0.1.0'
DOMAINIC_DEV_REPO_URL = 'https://github.com/domainic/domainic'
DOMAINIC_DEV_HOME_URL = "#{DOMAINIC_DEV_REPO_URL}/tree/domainic-dev".freeze

Gem::Specification.new do |spec|
  spec.name     = 'domainic-dev'
  spec.version  = DOMAINIC_DEV_GEM_VERSION
  spec.homepage = DOMAINIC_DEV_HOME_URL
  spec.authors  = ['Aaron Allen']
  spec.email    = ['hello@aaronmallen.me']
  spec.summary  = 'Domainic Development Tools'
  spec.license  = 'MIT'

  spec.required_ruby_version = '>= 3.1'

  spec.files         = Dir['LICENSE', 'README.md', 'lib/**/*', 'sig/**/*']
  spec.require_paths = ['lib']

  spec.metadata = {
    'bug_tracker_uri' => "#{DOMAINIC_DEV_REPO_URL}/issues",
    'homepage_uri' => spec.homepage,
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => DOMAINIC_DEV_HOME_URL
  }

  spec.add_dependency 'semantic', '>= 1.6', '< 2'
end
