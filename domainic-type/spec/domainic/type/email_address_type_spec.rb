# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/types/network/email_address_type'

RSpec.describe Domainic::Type::EmailAddressType do
  let(:type) { described_class.new }

  describe '.validate' do
    subject(:validate) { type.validate(email_address) }

    context 'when validating a valid email address' do
      let(:email_address) { 'user@example.com' }

      it { is_expected.to be true }
    end

    context 'when validating an invalid email address' do
      let(:email_address) { 'not-an-email' }

      it { is_expected.to be false }
    end

    context 'when validating a non-string' do
      let(:email_address) { :symbol }

      it { is_expected.to be false }
    end
  end

  describe '.validate!' do
    subject(:validate!) { type.validate!(email_address) }

    context 'when validating a valid email address' do
      let(:email_address) { 'user@example.com' }

      it { is_expected.to be true }
    end

    context 'when validating an invalid email address' do
      let(:email_address) { 'not-an-email' }

      it { expect { validate! }.to raise_error(TypeError, /Expected EmailAddress/) }
    end
  end

  describe '#having_hostname' do
    subject(:having_hostname) { type.having_hostname(hostname).validate(email_address) }

    context 'when given a hostname without a TLD' do
      context 'when email matches allowed hostname' do
        let(:hostname) { 'example' }
        let(:email_address) { 'user@example.com' }

        it { is_expected.to be true }
      end

      context 'when email does not match allowed hostname' do
        let(:hostname) { 'example' }
        let(:email_address) { 'user@other.com' }

        it { is_expected.to be false }
      end
    end

    context 'when given a hostname with a TLD' do
      context 'when email matches allowed hostname' do
        let(:hostname) { 'example.com' }
        let(:email_address) { 'user@example.com' }

        it { is_expected.to be true }
      end

      context 'when email does not match allowed hostname' do
        let(:hostname) { 'example.com' }
        let(:email_address) { 'user@example.net' }

        it { is_expected.to be false }
      end
    end
  end

  describe '#having_local_matching' do
    subject(:having_local_matching) { type.having_local_matching(pattern).validate(email_address) }

    context 'when local part matches pattern' do
      let(:pattern) { /^user/ }
      let(:email_address) { 'user@example.com' }

      it { is_expected.to be true }
    end

    context 'when local part does not match pattern' do
      let(:pattern) { /^user/ }
      let(:email_address) { 'admin@example.com' }

      it { is_expected.to be false }
    end
  end

  describe '#having_top_level_domain' do
    subject(:having_top_level_domain) { type.having_top_level_domain(tld).validate(email_address) }

    context 'when email uses allowed TLD' do
      let(:tld) { 'com' }
      let(:email_address) { 'user@example.com' }

      it { is_expected.to be true }
    end

    context 'when email uses disallowed TLD' do
      let(:tld) { 'com' }
      let(:email_address) { 'user@example.net' }

      it { is_expected.to be false }
    end
  end

  describe '#not_having_hostname' do
    subject(:not_having_hostname) { type.not_having_hostname(hostname).validate(email_address) }

    context 'when given a hostname without a TLD' do
      context 'when email matches forbidden hostname' do
        let(:hostname) { 'example' }
        let(:email_address) { 'user@example.com' }

        it { is_expected.to be false }
      end

      context 'when email does not match forbidden hostname' do
        let(:hostname) { 'example' }
        let(:email_address) { 'user@other.com' }

        it { is_expected.to be true }
      end
    end

    context 'when given a hostname with a TLD' do
      context 'when email matches forbidden hostname' do
        let(:hostname) { 'example.com' }
        let(:email_address) { 'user@example.com' }

        it { is_expected.to be false }
      end

      context 'when email does not match forbidden hostname' do
        let(:hostname) { 'example.com' }
        let(:email_address) { 'user@example.net' }

        it { is_expected.to be true }
      end
    end
  end

  describe '#not_having_local_matching' do
    subject(:not_having_local_matching) { type.not_having_local_matching(pattern).validate(email_address) }

    context 'when local part does not match forbidden pattern' do
      let(:pattern) { /^admin/ }
      let(:email_address) { 'user@example.com' }

      it { is_expected.to be true }
    end

    context 'when local part matches forbidden pattern' do
      let(:pattern) { /^admin/ }
      let(:email_address) { 'admin@example.com' }

      it { is_expected.to be false }
    end
  end

  describe '#not_having_top_level_domain' do
    subject(:not_having_top_level_domain) { type.not_having_top_level_domain(tld).validate(email_address) }

    context 'when email does not use forbidden TLD' do
      let(:tld) { 'test' }
      let(:email_address) { 'user@example.com' }

      it { is_expected.to be true }
    end

    context 'when email uses forbidden TLD' do
      let(:tld) { 'test' }
      let(:email_address) { 'user@example.test' }

      it { is_expected.to be false }
    end
  end

  describe 'RFC compliance' do
    context 'when email exceeds maximum length' do
      subject(:validation) do
        type.validate("#{'x' * 243}@example.com") # 243 + 11 = 254 characters
      end

      it { is_expected.to be false }
    end

    context 'when email contains non-ASCII characters' do
      subject(:validation) { type.validate('üser@example.com') }

      it { is_expected.to be false }
    end
  end
end
