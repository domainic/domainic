# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Dev::GemManager do
  describe '.gem' do
    subject(:gem) { described_class.gem(gem_name) }

    context 'when the gem exists' do
      before do
        mock_root = instance_double(Pathname, glob: [Pathname.new("fake/root/#{gem_name}/#{gem_name}.gemspec")])
        allow(Domainic::Dev).to receive(:root).and_return(mock_root)
        allow(Domainic::Dev::GemManager::Gem).to receive(:new)
          .with(Pathname.new("fake/root/#{gem_name}"))
          .and_return(mock_gem)
      end

      let(:gem_name) { 'test' }
      let(:mock_gem) { instance_double(Domainic::Dev::GemManager::Gem, name: gem_name) }

      it { is_expected.to eq(mock_gem) }
    end

    context 'when the gem does not exist' do
      let(:gem_name) { 'nonexistent' }

      it { is_expected.to be_nil }
    end
  end

  describe '.gems' do
    subject(:gems) { described_class.gems }

    before do
      mock_root = instance_double(Pathname, glob: [Pathname.new('fake/root/test/test.gemspec')])
      allow(Domainic::Dev).to receive(:root).and_return(mock_root)
      allow(Domainic::Dev::GemManager::Gem).to receive(:new)
        .with(Pathname.new('fake/root/test'))
        .and_return(mock_gem)
    end

    let(:mock_gem) { instance_double(Domainic::Dev::GemManager::Gem, name: 'test') }

    it { is_expected.to contain_exactly(mock_gem) }
  end
end
