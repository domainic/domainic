# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/types/identifier/uuid_type'

RSpec.describe Domainic::Type::UUIDType do
  let(:type) { described_class.new }

  describe '.validate' do
    subject(:validate) { type.validate(uuid) }

    context 'when validating a valid UUID' do
      let(:uuid) { '123e4567-e89b-12d3-a456-426614174000' }

      it { is_expected.to be true }
    end

    context 'when validating an invalid UUID' do
      let(:uuid) { 'not-a-uuid' }

      it { is_expected.to be false }
    end

    context 'when validating a non-string' do
      let(:uuid) { :symbol }

      it { is_expected.to be false }
    end
  end

  describe '.validate!' do
    subject(:validate!) { type.validate!(uuid) }

    context 'when validating a valid UUID' do
      let(:uuid) { '123e4567-e89b-12d3-a456-426614174000' }

      it { is_expected.to be true }
    end

    context 'when validating an invalid UUID' do
      let(:uuid) { 'not-a-uuid' }

      it { expect { validate! }.to raise_error(TypeError, /Expected UUID/) }
    end
  end

  describe '#being_compact' do
    subject(:being_compact) { type.being_compact.validate(uuid) }

    context 'when UUID is in compact format' do
      let(:uuid) { '123e4567e89b12d3a456426614174000' }

      it { is_expected.to be true }
    end

    context 'when UUID is in standard format' do
      let(:uuid) { '123e4567-e89b-12d3-a456-426614174000' }

      it { is_expected.to be false }
    end
  end

  describe '#being_standard' do
    subject(:being_standard) { type.being_standard.validate(uuid) }

    context 'when UUID is in standard format' do
      let(:uuid) { '123e4567-e89b-12d3-a456-426614174000' }

      it { is_expected.to be true }
    end

    context 'when UUID is in compact format' do
      let(:uuid) { '123e4567e89b12d3a456426614174000' }

      it { is_expected.to be false }
    end
  end

  describe '#being_version' do
    subject(:being_version) { type.being_version(version, format: format).validate(uuid) }

    context 'with standard format' do
      let(:format) { :standard }

      context 'when UUID matches version' do
        let(:version) { 4 }
        let(:uuid) { '123e4567-e89b-42d3-a456-426614174000' }

        it { is_expected.to be true }
      end

      context 'when UUID does not match version' do
        let(:version) { 4 }
        let(:uuid) { '123e4567-e89b-12d3-a456-426614174000' }

        it { is_expected.to be false }
      end
    end

    context 'with compact format' do
      let(:format) { :compact }

      context 'when UUID matches version' do
        let(:version) { 4 }
        let(:uuid) { '123e4567e89b42d3a456426614174000' }

        it { is_expected.to be true }
      end

      context 'when UUID does not match version' do
        let(:version) { 4 }
        let(:uuid) { '123e4567e89b12d3a456426614174000' }

        it { is_expected.to be false }
      end
    end

    context 'with invalid format', rbs: :skip do
      let(:version) { 4 }
      let(:format) { :invalid }
      let(:uuid) { '123e4567-e89b-42d3-a456-426614174000' }

      it 'raises ArgumentError' do
        expect { being_version }.to raise_error(ArgumentError, /Invalid format/)
      end
    end
  end

  describe 'RFC compliance' do
    context 'when UUID has incorrect version number' do
      subject(:validation) { type.validate('123e4567-e89b-82d3-a456-426614174000') }

      it { is_expected.to be false }
    end

    context 'when UUID has incorrect variant' do
      subject(:validation) { type.validate('123e4567-e89b-42d3-c456-426614174000') }

      it { is_expected.to be false }
    end
  end
end
