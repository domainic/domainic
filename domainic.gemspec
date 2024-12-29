# frozen_string_literal: true

DOMAINIC_GEM_VERSION = '0.1.0'
DOMAINIC_SEMVER = '0.1.0'
DOMAINIC_REPO_URL = 'https://github.com/domainic/domainic'
DOMAINIC_HOME_URL = DOMAINIC_REPO_URL

Gem::Specification.new do |spec|
  spec.name     = 'domainic'
  spec.version  = DOMAINIC_GEM_VERSION
  spec.homepage = DOMAINIC_HOME_URL
  spec.authors  = ['Aaron Allen']
  spec.email    = ['hello@aaronmallen.me']
  spec.summary  = 'A suite of Ruby libraries crafted to arm engineers with the magic of domain-driven design.'
  spec.license  = 'MIT'

  spec.required_ruby_version = '>= 3.1'

  spec.files = Dir['LICENSE', 'README.md']

  spec.metadata = {
    'bug_tracker_uri' => "#{DOMAINIC_REPO_URL}/issues",
    'changelog_uri' => "#{DOMAINIC_REPO_URL}/releases/tag/v#{DOMAINIC_SEMVER}",
    'homepage_uri' => spec.homepage,
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => "#{DOMAINIC_REPO_URL}/tree/v#{DOMAINIC_SEMVER}",
    'wiki_uri' => "#{DOMAINIC_REPO_URL}/wiki"
  }

  spec.add_dependency 'domainic-attributer', '~> 0.1'
  spec.add_dependency 'domainic-command', '~> 0.1'
  spec.add_dependency 'domainic-type', '~> 0.1.0.alpha.3'
end
