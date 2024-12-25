# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/types/network/uri_type'

RSpec.describe Domainic::Type::URIType do
  let(:type) { described_class.new }

  describe '.validate' do
    subject(:validate) { type.validate(uri) }

    context 'when validating a valid URI' do
      let(:uri) { 'https://example.com/path?query=1' }

      it { is_expected.to be true }
    end

    context 'when validating an invalid URI' do
      let(:uri) { 'not-a-uri' }

      it { is_expected.to be false }
    end

    context 'when validating a non-string' do
      let(:uri) { :symbol }

      it { is_expected.to be false }
    end
  end

  describe '.validate!' do
    subject(:validate!) { type.validate!(uri) }

    context 'when validating a valid URI' do
      let(:uri) { 'https://example.com/path?query=1' }

      it { is_expected.to be true }
    end

    context 'when validating an invalid URI' do
      let(:uri) { 'not-a-uri' }

      it { expect { validate! }.to raise_error(TypeError, /Expected URI/) }
    end
  end

  describe '#having_scheme' do
    subject(:having_scheme) { type.having_scheme(*schemes).validate(uri) }

    context 'when URI uses an allowed scheme' do
      let(:schemes) { %w[http https] }
      let(:uri) { 'https://example.com' }

      it { is_expected.to be true }
    end

    context 'when URI uses a disallowed scheme' do
      let(:schemes) { %w[http https] }
      let(:uri) { 'ftp://example.com' }

      it { is_expected.to be false }
    end
  end

  describe '#not_having_scheme' do
    subject(:not_having_scheme) { type.not_having_scheme(*schemes).validate(uri) }

    context 'when URI does not use a forbidden scheme' do
      let(:schemes) { ['ftp'] }
      let(:uri) { 'https://example.com' }

      it { is_expected.to be true }
    end

    context 'when URI uses a forbidden scheme' do
      let(:schemes) { ['ftp'] }
      let(:uri) { 'ftp://example.com' }

      it { is_expected.to be false }
    end
  end

  describe '#having_hostname' do
    subject(:having_hostname) { type.having_hostname(*hostnames).validate(uri) }

    context 'when URI matches allowed hostname' do
      let(:hostnames) { ['example.com'] }
      let(:uri) { 'https://example.com' }

      it { is_expected.to be true }
    end

    context 'when URI does not match allowed hostname' do
      let(:hostnames) { ['example.com'] }
      let(:uri) { 'https://other.com' }

      it { is_expected.to be false }
    end
  end

  describe '#not_having_hostname' do
    subject(:not_having_hostname) { type.not_having_hostname(*hostnames).validate(uri) }

    context 'when URI does not match forbidden hostname' do
      let(:hostnames) { ['forbidden.com'] }
      let(:uri) { 'https://allowed.com' }

      it { is_expected.to be true }
    end

    context 'when URI matches forbidden hostname' do
      let(:hostnames) { ['forbidden.com'] }
      let(:uri) { 'https://forbidden.com' }

      it { is_expected.to be false }
    end
  end

  describe '#having_path' do
    subject(:having_path) { type.having_path(*patterns).validate(uri) }

    context 'when URI path matches allowed regex pattern' do
      let(:patterns) { [%r{^/api/v\d+}] }
      let(:uri) { 'https://example.com/api/v1' }

      it { is_expected.to be true }
    end

    context 'when URI path matches allowed string pattern' do
      let(:patterns) { ['/api/v1'] }
      let(:uri) { 'https://example.com/api/v1' }

      it { is_expected.to be true }
    end

    context 'when URI path does not match allowed patterns' do
      let(:patterns) { [%r{^/api/v\d+}, '/allowed'] }
      let(:uri) { 'https://example.com/forbidden' }

      it { is_expected.to be false }
    end
  end

  describe '#not_having_path' do
    subject(:not_having_path) { type.not_having_path(*patterns).validate(uri) }

    context 'when URI path does not match forbidden regex pattern' do
      let(:patterns) { [%r{^/admin}] }
      let(:uri) { 'https://example.com/user' }

      it { is_expected.to be true }
    end

    context 'when URI path does not match forbidden string pattern' do
      let(:patterns) { ['/admin'] }
      let(:uri) { 'https://example.com/user' }

      it { is_expected.to be true }
    end

    context 'when URI path matches forbidden patterns' do
      let(:patterns) { [%r{^/admin}, '/forbidden'] }
      let(:uri) { 'https://example.com/forbidden' }

      it { is_expected.to be false }
    end
  end

  describe 'RFC compliance' do
    context 'when URI contains non-ASCII characters' do
      subject(:validation) { type.validate('https://exämple.com') }

      it { is_expected.to be false }
    end
  end
end
