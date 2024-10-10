# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Dev::GemManager::Version do
  describe '#initialize' do
    subject(:new_instance) { described_class.new('1.2.3-alpha+abc') }

    it 'is expected to properly parse the version string' do
      expect(new_instance).to have_attributes(major: 1, minor: 2, patch: 3, pre: 'alpha', build: 'abc')
    end
  end

  describe '#build' do
    subject(:build) { version.build }

    context 'when the Version has a build number' do
      let(:version) { described_class.new('1.2.3+abc') }

      it { is_expected.to eq('abc') }
    end

    context 'when the Version does not have a build number' do
      let(:version) { described_class.new('1.2.3') }

      it { is_expected.to be_nil }
    end
  end

  describe '#build=' do
    subject(:set_build) { version.build = build_version }

    let(:version) { described_class.new('1.2.3') }
    let(:build_version) { 'abc' }

    it { expect { set_build }.to change(version, :build).from(nil).to(build_version) }
  end

  describe '#increment!' do
    subject(:increment!) { version.increment!(version_part) }

    let(:version) { described_class.new('1.2.3-alpha+abc') }

    context 'when incrementing the major version' do
      let(:version_part) { :major }

      it { expect { increment! }.to change(version, :major).from(1).to(2) }
      it { expect { increment! }.to change(version, :minor).from(2).to(0) }
      it { expect { increment! }.to change(version, :patch).from(3).to(0) }
      it { expect { increment! }.to change(version, :pre).from('alpha').to(nil) }
      it { expect { increment! }.to change(version, :build).from('abc').to(nil) }
    end

    context 'when incrementing the minor version' do
      let(:version_part) { :minor }

      it { expect { increment! }.not_to change(version, :major) }
      it { expect { increment! }.to change(version, :minor).from(2).to(3) }
      it { expect { increment! }.to change(version, :patch).from(3).to(0) }
      it { expect { increment! }.to change(version, :pre).from('alpha').to(nil) }
      it { expect { increment! }.to change(version, :build).from('abc').to(nil) }
    end

    context 'when incrementing the patch version' do
      let(:version_part) { :patch }

      it { expect { increment! }.not_to change(version, :major) }
      it { expect { increment! }.not_to change(version, :minor) }
      it { expect { increment! }.to change(version, :patch).from(3).to(4) }
      it { expect { increment! }.to change(version, :pre).from('alpha').to(nil) }
      it { expect { increment! }.to change(version, :build).from('abc').to(nil) }
    end
  end

  describe '#major' do
    subject(:major) { version.major }

    let(:version) { described_class.new('1.2.3-alpha+abc') }

    it { is_expected.to eq(1) }
  end

  describe '#minor' do
    subject(:minor) { version.minor }

    let(:version) { described_class.new('1.2.3-alpha+abc') }

    it { is_expected.to eq(2) }
  end

  describe '#patch' do
    subject(:patch) { version.patch }

    let(:version) { described_class.new('1.2.3-alpha+abc') }

    it { is_expected.to eq(3) }
  end

  describe '#pre' do
    subject(:pre) { version.pre }

    context 'when the Version has a pre-release version' do
      let(:version) { described_class.new('1.2.3-alpha+abc') }

      it { is_expected.to eq('alpha') }
    end

    context 'when the Version does not have a pre-release version' do
      let(:version) { described_class.new('1.2.3+abc') }

      it { is_expected.to be_nil }
    end
  end

  describe '#pre=' do
    subject(:set_pre) { version.pre = pre_version }

    let(:version) { described_class.new('1.2.3') }
    let(:pre_version) { 'alpha' }

    it { expect { set_pre }.to change(version, :pre).from(nil).to(pre_version) }
  end

  describe '#to_gem_version' do
    subject(:to_gem_version) { version.to_gem_version }

    let(:version) { described_class.new('1.2.3-alpha+abc') }

    it { is_expected.to eq('1.2.3.alpha.abc') }
  end

  describe '#to_semver' do
    subject(:to_semver) { version.to_semver }

    let(:version) { described_class.new('1.2.3-alpha+abc') }

    it { is_expected.to eq('1.2.3-alpha+abc') }
  end
end
