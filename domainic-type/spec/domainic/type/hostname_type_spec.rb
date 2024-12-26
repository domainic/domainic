# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/types/network/hostname_type'

RSpec.describe Domainic::Type::HostnameType do
  let(:type) { described_class.new }

  describe '.validate' do
    subject(:validate) { type.validate(hostname) }

    context 'when validating a valid hostname' do
      let(:hostname) { 'example.com' }

      it { is_expected.to be true }
    end

    context 'when validating an invalid hostname' do
      let(:hostname) { 'invalid_host' }

      it { is_expected.to be false }
    end

    context 'when validating a non-string' do
      let(:hostname) { :symbol }

      it { is_expected.to be false }
    end
  end

  describe '.validate!' do
    subject(:validate!) { type.validate!(hostname) }

    context 'when validating a valid hostname' do
      let(:hostname) { 'example.com' }

      it { is_expected.to be true }
    end

    context 'when validating an invalid hostname' do
      let(:hostname) { 'invalid_host' }

      it { expect { validate! }.to raise_error(TypeError, /Expected Hostname/) }
    end
  end

  describe '#matching' do
    subject(:matching) { type.matching(*hostnames).validate(hostname) }

    context 'when hostname matches one of the allowed hostnames' do
      let(:hostnames) { ['example.com', 'allowed.com'] }
      let(:hostname) { 'example.com' }

      it { is_expected.to be true }
    end

    context 'when hostname does not match any of the allowed hostnames' do
      let(:hostnames) { ['example.com', 'allowed.com'] }
      let(:hostname) { 'other.com' }

      it { is_expected.to be false }
    end
  end

  describe '#not_matching' do
    subject(:not_matching) { type.not_matching(*hostnames).validate(hostname) }

    context 'when hostname does not match any of the forbidden hostnames' do
      let(:hostnames) { ['forbidden.com', 'blocked.com'] }
      let(:hostname) { 'allowed.com' }

      it { is_expected.to be true }
    end

    context 'when hostname matches one of the forbidden hostnames' do
      let(:hostnames) { ['forbidden.com', 'blocked.com'] }
      let(:hostname) { 'forbidden.com' }

      it { is_expected.to be false }
    end
  end

  describe '#having_top_level_domain' do
    subject(:having_top_level_domain) { type.having_top_level_domain(*tlds).validate(hostname) }

    context 'when hostname uses an allowed TLD' do
      let(:tlds) { %w[com org] }
      let(:hostname) { 'example.com' }

      it { is_expected.to be true }
    end

    context 'when hostname uses a disallowed TLD' do
      let(:tlds) { %w[com org] }
      let(:hostname) { 'example.net' }

      it { is_expected.to be false }
    end
  end

  describe '#not_having_top_level_domain' do
    subject(:not_having_top_level_domain) { type.not_having_top_level_domain(*tlds).validate(hostname) }

    context 'when hostname does not use any forbidden TLDs' do
      let(:tlds) { %w[test dev] }
      let(:hostname) { 'example.com' }

      it { is_expected.to be true }
    end

    context 'when hostname uses a forbidden TLD' do
      let(:tlds) { %w[test dev] }
      let(:hostname) { 'example.dev' }

      it { is_expected.to be false }
    end
  end

  describe 'RFC compliance' do
    context 'when hostname exceeds maximum length' do
      subject(:validation) { type.validate("#{'a' * 254}.com") }

      it { is_expected.to be false }
    end

    context 'when hostname contains invalid characters' do
      subject(:validation) { type.validate('invalid@hostname.com') }

      it { is_expected.to be false }
    end
  end
end
