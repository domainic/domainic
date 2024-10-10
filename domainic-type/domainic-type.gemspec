# frozen_string_literal: true

DOMAINIC_TYPE_GEM_VERSION = '0.1.0'
DOMAINIC_TYPE_SEMVER = '0.1.0'
DOMAINIC_TYPE_REPO_URL = 'https://github.com/domainic/domainic'
DOMAINIC_TYPE_HOME_URL = "#{DOMAINIC_TYPE_REPO_URL}/tree/domainic-type-v#{DOMAINIC_TYPE_SEMVER}/domainic-type".freeze

Gem::Specification.new do |spec|
  spec.name     = 'domainic-type'
  spec.version  = DOMAINIC_TYPE_GEM_VERSION
  spec.authors  = ['Aaron Allen']
  spec.email    = ['hello@aaronmallen.me']
  spec.homepage = DOMAINIC_TYPE_HOME_URL
  spec.summary  = 'Stupidly granular type validation for Ruby'
  spec.license  = 'MIT'

  spec.required_ruby_version = '>= 3.1'

  spec.files         = Dir['CHANGELOG.md', 'LICENSE', 'README.md', 'lib/**/*', 'sig/**/*']
  spec.require_paths = ['lib']

  spec.metadata = {
    'bug_tracker_uri' => "#{DOMAINIC_TYPE_REPO_URL}/issues",
    'changelog_uri' => "#{DOMAINIC_TYPE_REPO_URL}/releases/tag/domainic-type-v#{DOMAINIC_TYPE_SEMVER}",
    'homepage_uri' => DOMAINIC_TYPE_HOME_URL,
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => "#{DOMAINIC_TYPE_REPO_URL}/tree/domainic-type-v#{DOMAINIC_TYPE_SEMVER}/domainic-type",
    'wiki_uri' => "#{DOMAINIC_TYPE_REPO_URL}/wiki"
  }
end
