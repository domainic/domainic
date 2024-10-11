# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Dev::CLI do
  before do
    allow(Thor).to receive(:puts) # suppress warnings
    allow(Domainic::Dev::GemManager).to receive(:gems).and_return([gem_one, gem_two])
    allow(Domainic::Dev::GemManager).to receive(:gem).with('gem_one').and_return(gem_one)
    allow(Domainic::Dev::GemManager).to receive(:gem).with('gem_two').and_return(gem_two)
  end

  let(:gem_one) { instance_double(Domainic::Dev::GemManager::Gem, name: 'gem_one', build!: true, publish!: true) }
  let(:gem_two) { instance_double(Domainic::Dev::GemManager::Gem, name: 'gem_two', build!: true, publish!: true) }

  describe '#build' do
    subject(:build) { described_class.new.invoke(:build, gem_names) }

    context 'when no gem names are provided' do
      let(:gem_names) { [] }

      it 'is expected to build all gems' do
        build

        expect([gem_one, gem_two]).to all(have_received(:build!))
      end
    end

    context 'when gem names are provided' do
      let(:gem_names) { %w[gem_one] }

      it 'is expected to build the specified gems' do
        build

        expect(gem_one).to have_received(:build!)
      end

      it 'is expected not to build the unspecified gems' do
        build

        expect(gem_two).not_to have_received(:build!)
      end
    end
  end

  describe '#publish' do
    subject(:publish) { described_class.new.invoke(:publish, gem_names) }

    context 'when no gem names are provided' do
      let(:gem_names) { [] }

      it 'is expected to build all gems' do
        publish

        expect([gem_one, gem_two]).to all(have_received(:publish!))
      end
    end

    context 'when gem names are provided' do
      let(:gem_names) { %w[gem_one] }

      it 'is expected to build the specified gems' do
        publish

        expect(gem_one).to have_received(:publish!)
      end

      it 'is expected not to build the unspecified gems' do
        publish

        expect(gem_two).not_to have_received(:publish!)
      end
    end
  end

  describe '#test' do
    subject(:test) { described_class.new.invoke(:test, gem_names) }

    before do
      allow(gem_one).to receive(:paths).and_return(
        instance_double(Domainic::Dev::GemManager::Gem::Paths, test: instance_double(Pathname, exist?: true))
      )
      allow(gem_two).to receive(:paths).and_return(
        instance_double(Domainic::Dev::GemManager::Gem::Paths, test: instance_double(Pathname, exist?: true))
      )
    end

    context 'when no gem names are provided' do
      let(:gem_names) { [] }

      it 'is expected to test all gems' do
        expected_paths = [gem_one, gem_two].map { |gem| gem.paths.test }
        expect_any_instance_of(described_class).to receive(:system) # rubocop:disable RSpec/AnyInstance
          .with(*%w[bundle exec rspec --require ./config/rspec_client], *expected_paths.map(&:to_s), exception: true)

        test
      end
    end

    context 'when gem names are provided' do
      let(:gem_names) { %w[gem_one] }

      it 'is expected to test the specified gems' do
        expected_paths = [gem_one.paths.test]
        expect_any_instance_of(described_class).to receive(:system) # rubocop:disable RSpec/AnyInstance
          .with(*%w[bundle exec rspec --require ./config/rspec_client], *expected_paths.map(&:to_s), exception: true)

        test
      end
    end
  end
end
