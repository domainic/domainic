# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Dev::GemManager::Publisher do
  describe '#publish' do
    subject(:publish!) { publisher.publish! }

    before do
      allow(publisher).to receive(:puts) # suppress logging
      allow(publisher).to receive(:`).with('git tag').and_return("test-v0.1.0\nother_test-v0.1.0")
      allow(publisher).to receive(:system)
    end

    let(:publisher) { described_class.new(gem) }

    context 'when the gem has a new version' do
      let(:gem) do
        version = instance_double(Domainic::Dev::GemManager::Version, to_gem_version: '0.2.0', to_semver: '0.2.0')
        instance_double(
          Domainic::Dev::GemManager::Gem,
          build!: true,
          dependencies: [],
          name: 'test',
          version:
        )
      end

      context 'when the gem has domainic dependencies' do
        before do
          allow(gem.dependencies).to receive(:map).and_return(['other_test'])
          allow(Domainic::Dev::GemManager).to receive(:gem).with('other_test').and_return(dependency)
          allow(described_class).to receive(:new).with(dependency).and_return(other_publisher)
        end

        let(:dependency) { instance_double(Domainic::Dev::GemManager::Gem) }
        let(:other_publisher) { instance_double(described_class, publish!: true) }

        it 'is expected to publish the gems dependencies' do
          publish!

          expect(other_publisher).to have_received(:publish!)
        end
      end

      it 'is expected to build the gem' do
        publish!

        expect(gem).to have_received(:build!)
      end

      it 'is expected to generate new git tags' do
        publish!

        expect(publisher).to have_received(:system).with('git tag test-v0.2.0')
      end

      it 'is expected to push the gem to rubygems.org' do
        publish!

        expect(publisher).to have_received(:system).with('gem push pkg/test-0.2.0.gem')
      end
    end

    context 'when the gem is domainic-dev' do
      let(:gem) do
        instance_double(Domainic::Dev::GemManager::Gem, name: 'domainic-dev', build!: true)
      end

      it 'is expected not to build the gem' do
        publish!

        expect(gem).not_to have_received(:build!)
      end
    end

    context 'when the gem has no new version' do
      let(:gem) do
        version = instance_double(Domainic::Dev::GemManager::Version, to_gem_version: '0.1.0', to_semver: '0.1.0')
        instance_double(
          Domainic::Dev::GemManager::Gem,
          build!: true,
          name: 'test',
          version:
        )
      end

      it 'is expected not to build the gem' do
        publish!

        expect(gem).not_to have_received(:build!)
      end
    end
  end
end
