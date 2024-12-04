# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Dev::Gem do
  describe '.all' do
    subject(:all_gems) { described_class.all }

    it 'is expected to return all gems in the Domainic mono-repo' do
      expect(all_gems).to all(be_an_instance_of(described_class))
    end
  end

  describe '.find' do
    subject(:find) { described_class.find(gem_name) }

    context 'when the gem exists' do
      before do
        allow(Domainic::Dev.root).to receive(:glob)
          .with('{*/*.gemspec,domainic.gemspec}')
          .and_return([Domainic::Dev.root.join('domainic-test/domainic-test.gemspec')])

        mock_gemspec = <<~GEMSPEC.strip
          DOMAINIC_TEST_GEM_VERSION = '0.1.0'
          DOMAINIC_TEST_SEMVER = '0.1.0'
        GEMSPEC

        mock_gemspec_pathname = instance_double(
          Pathname,
          read: mock_gemspec,
          to_s: 'domainic-test/domainic-test.gemspec'
        )

        mock_paths = instance_double(
          Domainic::Dev::Gem::PathSet,
          gemspec: mock_gemspec_pathname
        )

        allow(Domainic::Dev::Gem::PathSet).to receive(:new).and_return(mock_paths)

        mock_specification = instance_double(
          Gem::Specification,
          dependencies: [],
          name: 'domainic-test'
        )

        allow(Gem::Specification).to receive(:load)
          .with('domainic-test/domainic-test.gemspec')
          .and_return(mock_specification)
      end

      let(:gem_name) { 'domainic-test' }

      it 'is expected to find the gem' do
        expect(find).to be_an_instance_of(described_class).and(
          have_attributes(name: 'domainic-test')
        )
      end
    end

    context 'when the gem does not exist' do
      let(:gem_name) { 'non-existent' }

      it { is_expected.to be_nil }
    end
  end

  describe '.new' do
    subject(:gem) { described_class.new(root_directory) }

    before do
      mock_gemspec = <<~GEMSPEC.strip
        DOMAINIC_TEST_GEM_VERSION = '0.1.0'
        DOMAINIC_TEST_SEMVER      = '0.1.0'
      GEMSPEC

      mock_gemspec_pathname = root_directory.join('domainic-test.gemspec')
      allow(mock_gemspec_pathname).to receive(:read).and_return(mock_gemspec)

      allow(root_directory).to receive(:glob).with('*.gemspec').and_return([mock_gemspec_pathname])

      mock_specification = instance_double(
        Gem::Specification,
        dependencies: [],
        name: 'domainic-test'
      )
      allow(Gem::Specification).to receive(:load).with(mock_gemspec_pathname.to_s).and_return(mock_specification)
    end

    let(:root_directory) { Pathname.new('fake/root/domainic-test') }

    it 'is expected to initialize a new instance of Gem' do
      expect(gem).to have_attributes(name: 'domainic-test')
    end
  end

  describe '#constant_name' do
    subject(:constant_name) { gem.constant_name }

    before do
      mock_gemspec = <<~GEMSPEC.strip
        DOMAINIC_TEST_GEM_VERSION = '0.1.0'
        DOMAINIC_TEST_SEMVER      = '0.1.0'
      GEMSPEC

      mock_gemspec_pathname = root_directory.join('domainic-test.gemspec')
      allow(mock_gemspec_pathname).to receive(:read).and_return(mock_gemspec)

      allow(root_directory).to receive(:glob).with('*.gemspec').and_return([mock_gemspec_pathname])

      mock_specification = instance_double(
        Gem::Specification,
        dependencies: [],
        name: 'domainic-test'
      )
      allow(Gem::Specification).to receive(:load).with(mock_gemspec_pathname.to_s).and_return(mock_specification)
    end

    let(:root_directory) { Pathname.new('fake/root/domainic-test') }
    let(:gem) { described_class.new(root_directory) }

    it 'is expected to be a constant friendly string' do
      expect(constant_name).to eq('DOMAINIC_TEST')
    end
  end

  describe '#module_name' do
    subject(:module_name) { gem.module_name }

    before do
      mock_gemspec = <<~GEMSPEC.strip
        DOMAINIC_TEST_GEM_GEM_VERSION = '0.1.0'
        DOMAINIC_TEST_GEM_SEMVER      = '0.1.0'
      GEMSPEC

      mock_gemspec_pathname = root_directory.join('domainic-test_gem.gemspec')
      allow(mock_gemspec_pathname).to receive(:read).and_return(mock_gemspec)

      allow(root_directory).to receive(:glob).with('*.gemspec').and_return([mock_gemspec_pathname])

      mock_specification = instance_double(
        Gem::Specification,
        dependencies: [],
        name: 'domainic-test_gem'
      )
      allow(Gem::Specification).to receive(:load).with(mock_gemspec_pathname.to_s).and_return(mock_specification)
    end

    let(:root_directory) { Pathname.new('fake/root/domainic-test_gem') }
    let(:gem) { described_class.new(root_directory) }

    it 'is expected to be a module friendly string' do
      expect(module_name).to eq('Domainic::TestGem')
    end
  end
end
