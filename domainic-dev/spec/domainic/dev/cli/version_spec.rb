# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Dev::CLI::Version do
  before do
    allow(Thor).to receive(:puts) # suppress warnings
  end

  describe '#bump' do
    subject(:bump) { described_class.new.invoke(:bump, [gem_name], options) }

    before do
      allow(Domainic::Dev::GemManager).to receive(:gem).with(gem_name).and_return(gem)
      allow(gem).to receive(:version).and_return(version)
      allow(gem).to receive(:sync!)
    end

    let(:gem_name) { 'test' }
    let(:gem) { instance_double(Domainic::Dev::GemManager::Gem, name: gem_name) }
    let(:version) { instance_double(Domainic::Dev::GemManager::Version, increment!: true) }

    context 'when bumping the major version' do
      let(:options) { { major: true } }

      it 'is expected to increment the major version' do
        bump

        expect(version).to have_received(:increment!).with(:major)
      end
    end

    context 'when bumping the minor version' do
      let(:options) { { minor: true } }

      it 'is expected to increment minor version' do
        bump

        expect(version).to have_received(:increment!).with(:minor)
      end
    end

    context 'when bumping the patch version' do
      let(:options) { { patch: true } }

      it 'is expected to increment the patch version' do
        bump

        expect(version).to have_received(:increment!).with(:patch)
      end
    end
  end

  describe '#set' do
    subject(:set) { described_class.new.invoke(:set, [gem_name], options) }

    before do
      allow(Domainic::Dev::GemManager).to receive(:gem).with(gem_name).and_return(gem)
      allow(gem).to receive(:version).and_return(version)
      allow(gem).to receive(:sync!)
    end

    let(:gem_name) { 'test' }
    let(:gem) { instance_double(Domainic::Dev::GemManager::Gem, name: gem_name) }
    let(:version) do
      instance_double(
        Domainic::Dev::GemManager::Version,
        :pre= => true,
        :build= => true
      )
    end

    context 'when setting the pre-release version' do
      let(:options) { { pre: 'alpha.1.0.0' } }

      it 'is expected to set the pre-release version' do
        set

        expect(version).to have_received(:pre=).with('alpha.1.0.0')
      end
    end

    context 'when setting the metadata version' do
      let(:options) { { build: '20240101' } }

      it 'is expected to set the metadata version' do
        set

        expect(version).to have_received(:build=).with('20240101')
      end
    end
  end

  describe '#sync' do
    subject(:sync) { described_class.new.invoke(:sync) }

    before do
      allow(Domainic::Dev::GemManager).to receive(:gems).and_return(gems)
    end

    let(:gems) { [gem_one, gem_two] }
    let(:gem_one) { instance_double(Domainic::Dev::GemManager::Gem, sync!: true) }
    let(:gem_two) { instance_double(Domainic::Dev::GemManager::Gem, sync!: true) }

    it 'is expected to sync all gem versions' do
      sync

      expect([gem_one, gem_two]).to all(have_received(:sync!))
    end
  end
end
