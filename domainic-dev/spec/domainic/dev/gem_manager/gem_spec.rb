# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Dev::GemManager::Gem do
  describe '#initialize' do
    subject(:new_instance) { described_class.new(root_directory) }

    before do
      allow(root_directory).to receive(:glob).with('*.gemspec').and_return([root_directory.join('test.gemspec')])
      allow(Gem::Specification).to receive(:load).with('fake/root/test/test.gemspec').and_return(mock_specification)
    end

    let(:root_directory) { Pathname.new('fake/root/test') }
    let(:mock_specification) { instance_double(Gem::Specification, dependencies: [mock_dependency], name: 'test') }
    let(:mock_dependency) { instance_double(Gem::Dependency) }

    it 'is expected to have the expected paths' do
      expect(new_instance.paths).to be_an_instance_of(described_class::Paths)
        .and(have_attributes(gemspec: root_directory.join('test.gemspec')))
    end

    it 'is expected to have the name defined in the gemspec' do
      expect(new_instance.name).to eq(mock_specification.name)
    end

    it 'is expected to have the dependencies defined in the gemspec' do
      expect(new_instance.dependencies).to eq(mock_specification.dependencies)
    end
  end

  describe '#build!' do
    subject(:build!) { gem.build! }

    before do
      allow(root_directory).to receive(:glob).with('*.gemspec').and_return([root_directory.join('test.gemspec')])
      allow(Gem::Specification).to receive(:load).with('fake/root/test/test.gemspec').and_return(mock_specification)
      allow(gem.paths.gemspec).to receive_messages(read: '', readlines: [], write: true)
      allow(gem).to receive(:system)
      allow(Dir).to receive(:glob).with('*.gem').and_return(['test-0.1.0.gem'])
      allow(FileUtils).to receive(:mkdir_p)
      allow(FileUtils).to receive(:mv)
    end

    let(:root_directory) { Pathname.new('fake/root/test') }
    let(:mock_specification) { instance_double(Gem::Specification, dependencies: [], name: 'test') }
    let(:gem) { described_class.new(root_directory) }

    it 'is expected to sync the gemspec' do
      build!

      expect(gem.paths.gemspec).to have_received(:write)
    end

    it 'is expected to build the gem' do
      build!

      expect(gem).to have_received(:system).with("gem build -V #{gem.paths.gemspec}")
    end

    it 'is expected to move the gem into the pkg directory' do
      build!

      expect(FileUtils).to have_received(:mv).with('test-0.1.0.gem', 'pkg')
    end
  end

  describe '#constant_name' do
    subject(:constant_name) { gem.constant_name }

    before do
      allow(root_directory).to receive(:glob).with('*.gemspec').and_return([root_directory.join('test.gemspec')])
      allow(Gem::Specification).to receive(:load).with('fake/root/test/test.gemspec').and_return(mock_specification)
    end

    let(:root_directory) { Pathname.new('fake/root/test') }
    let(:mock_specification) { instance_double(Gem::Specification, dependencies: [], name: 'test-TeSt_test') }
    let(:gem) { described_class.new(root_directory) }

    it 'is expected to return the name in a constant friendly format' do
      expect(constant_name).to eq('TEST_TEST_TEST')
    end
  end

  describe '#sync!' do
    subject(:sync!) { gem.sync! }

    before do
      allow(root_directory).to receive(:glob).with('*.gemspec').and_return([root_directory.join('test.gemspec')])
      allow(Gem::Specification).to receive(:load).with('fake/root/test/test.gemspec').and_return(mock_specification)
      allow(gem.paths.gemspec).to receive_messages(read: mock_gemspec, readlines: mock_gemspec.split("\n"), write: true)
    end

    let(:root_directory) { Pathname.new('fake/root/test') }
    let(:mock_specification) { instance_double(Gem::Specification, dependencies: [], name: 'test') }
    let(:mock_gemspec) do
      <<~GEMSPEC
        TEST_GEM_VERSION = '0.1.0'
        TEST_SEMVER = '0.1.0'
      GEMSPEC
    end
    let(:gem) { described_class.new(root_directory) }

    context 'when the gem version has not changed' do
      it 'is expected not to change the gemspec file' do
        sync!

        expect(gem.paths.gemspec).to have_received(:write).with(mock_gemspec)
      end
    end

    context 'when the gem version has changed' do
      before { gem.version.increment!(:minor) }

      it 'is expected to update the gemspec file' do
        sync!

        expect(gem.paths.gemspec).to have_received(:write).with(mock_gemspec.gsub('0.1.0', '0.2.0'))
      end
    end
  end

  describe '#version' do
    subject(:version) { gem.version }

    before do
      allow(root_directory).to receive(:glob).with('*.gemspec').and_return([root_directory.join('test.gemspec')])
      allow(Gem::Specification).to receive(:load).with('fake/root/test/test.gemspec').and_return(mock_specification)
      allow(gem.paths.gemspec).to receive_messages(read: mock_gemspec)
    end

    let(:root_directory) { Pathname.new('fake/root/test') }
    let(:mock_specification) { instance_double(Gem::Specification, dependencies: [], name: 'test') }
    let(:mock_gemspec) do
      <<~GEMSPEC
        TEST_GEM_VERSION = '0.1.0'
        TEST_SEMVER = '0.1.0'
      GEMSPEC
    end
    let(:gem) { described_class.new(root_directory) }

    it {
      expect(version).to be_an_instance_of(Domainic::Dev::GemManager::Version)
        .and(have_attributes(major: 0, minor: 1, patch: 0, pre: nil, build: nil))
    }

    context 'when the gemspec does not contain a SEMVER constant' do
      let(:mock_gemspec) do
        <<~GEMSPEC
          TEST_GEM_VERSION = '0.1.0'
        GEMSPEC
      end

      it { expect { version }.to raise_error(RuntimeError) }
    end
  end
end
