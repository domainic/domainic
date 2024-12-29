# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Attributer::Attribute::Signature do
  let(:attribute) { instance_double(Domainic::Attributer::Attribute, base: Class.new, name: :test) }

  before do
    allow(attribute).to receive(:is_a?).with(Domainic::Attributer::Attribute).and_return(true)
  end

  describe '.new' do
    subject(:signature) { described_class.new(attribute, **options) }

    context 'with valid options' do
      let(:options) do
        {
          type: described_class::TYPE::ARGUMENT,
          position: 1,
          read: described_class::VISIBILITY::PROTECTED,
          write: described_class::VISIBILITY::PRIVATE
        }
      end

      it 'is expected to initialize correctly' do
        expect(signature).to have_attributes(
          type: described_class::TYPE::ARGUMENT,
          position: 1,
          read_visibility: described_class::VISIBILITY::PROTECTED,
          write_visibility: described_class::VISIBILITY::PRIVATE
        )
      end
    end

    context 'with an invalid position', rbs: :skip do
      let(:options) do
        {
          type: described_class::TYPE::ARGUMENT,
          position: 'invalid',
          read: described_class::VISIBILITY::PROTECTED,
          write: described_class::VISIBILITY::PRIVATE
        }
      end

      it { expect { signature }.to raise_error(ArgumentError, /invalid position: invalid/) }
    end

    context 'with an invalid read visibility', rbs: :skip do
      let(:options) do
        {
          type: described_class::TYPE::ARGUMENT,
          position: 1,
          read: :invalid,
          write: described_class::VISIBILITY::PRIVATE
        }
      end

      it { expect { signature }.to raise_error(ArgumentError, /invalid read visibility: invalid/) }
    end

    context 'with an invalid write visibility', rbs: :skip do
      let(:options) do
        {
          type: described_class::TYPE::ARGUMENT,
          position: 1,
          read: described_class::VISIBILITY::PROTECTED,
          write: :invalid
        }
      end

      it { expect { signature }.to raise_error(ArgumentError, /invalid write visibility: invalid/) }
    end

    context 'with an invalid type', rbs: :skip do
      let(:options) do
        {
          type: :invalid,
          position: 1,
          read: described_class::VISIBILITY::PROTECTED,
          write: described_class::VISIBILITY::PRIVATE
        }
      end

      it { expect { signature }.to raise_error(ArgumentError, /invalid type: invalid/) }
    end

    context 'with an invalid nilable', rbs: :skip do
      let(:options) do
        {
          type: described_class::TYPE::ARGUMENT,
          nilable: 'invalid'
        }
      end

      it { expect { signature }.to raise_error(ArgumentError, /invalid nilable: invalid/) }
    end

    context 'with an invalid required', rbs: :skip do
      let(:options) do
        {
          type: described_class::TYPE::ARGUMENT,
          required: 'invalid'
        }
      end

      it { expect { signature }.to raise_error(ArgumentError, /invalid required: invalid/) }
    end
  end

  describe '#argument?' do
    subject(:argument?) { signature.argument? }

    let(:signature) { described_class.new(attribute, type:) }

    context 'when the signature is for an argument' do
      let(:type) { described_class::TYPE::ARGUMENT }

      it { is_expected.to be true }
    end

    context 'when the signature is for an option' do
      let(:type) { described_class::TYPE::OPTION }

      it { is_expected.to be false }
    end
  end

  describe '#nilable?' do
    subject(:nilable?) { signature.nilable? }

    let(:signature) { described_class.new(attribute, type: described_class::TYPE::ARGUMENT, nilable:) }

    context 'when the signature is nilable' do
      let(:nilable) { true }

      it { is_expected.to be true }
    end

    context 'when the signature is not nilable' do
      let(:nilable) { false }

      it { is_expected.to be false }
    end
  end

  describe '#option?' do
    subject(:option?) { signature.option? }

    let(:signature) { described_class.new(attribute, type:) }

    context 'when the signature is for an option' do
      let(:type) { described_class::TYPE::OPTION }

      it { is_expected.to be true }
    end

    context 'when the signature is for an argument' do
      let(:type) { described_class::TYPE::ARGUMENT }

      it { is_expected.to be false }
    end
  end

  describe '#optional?' do
    subject(:optional?) { signature.optional? }

    let(:signature) { described_class.new(attribute, type: described_class::TYPE::ARGUMENT, required:) }

    context 'when the signature is not required' do
      let(:required) { false }

      it { is_expected.to be true }
    end

    context 'when the signature is required' do
      let(:required) { true }

      it { is_expected.to be false }
    end
  end

  describe '#private?' do
    subject(:private?) { signature.private? }

    let(:signature) { described_class.new(attribute, type: described_class::TYPE::ARGUMENT, read:, write:) }
    let(:read) { described_class::VISIBILITY::PUBLIC }
    let(:write) { described_class::VISIBILITY::PUBLIC }

    context 'when both read and write are public' do
      it { is_expected.to be false }
    end

    context 'when read is protected and write is public' do
      let(:read) { described_class::VISIBILITY::PROTECTED }

      it { is_expected.to be false }
    end

    context 'when read is private and write is public' do
      let(:read) { described_class::VISIBILITY::PRIVATE }

      it { is_expected.to be false }
    end

    context 'when read is public and write is protected' do
      let(:write) { described_class::VISIBILITY::PROTECTED }

      it { is_expected.to be false }
    end

    context 'when read is public and write is private' do
      let(:write) { described_class::VISIBILITY::PRIVATE }

      it { is_expected.to be false }
    end

    context 'when read is protected and write is protected' do
      let(:read) { described_class::VISIBILITY::PROTECTED }
      let(:write) { described_class::VISIBILITY::PROTECTED }

      it { is_expected.to be true }
    end

    context 'when read is private and write is private' do
      let(:read) { described_class::VISIBILITY::PRIVATE }
      let(:write) { described_class::VISIBILITY::PRIVATE }

      it { is_expected.to be true }
    end

    context 'when read is protected and write is private' do
      let(:read) { described_class::VISIBILITY::PROTECTED }
      let(:write) { described_class::VISIBILITY::PRIVATE }

      it { is_expected.to be true }
    end

    context 'when read is private and write is protected' do
      let(:read) { described_class::VISIBILITY::PRIVATE }
      let(:write) { described_class::VISIBILITY::PROTECTED }

      it { is_expected.to be true }
    end
  end

  describe '#private_read?' do
    subject(:private_read?) { signature.private_read? }

    let(:signature) { described_class.new(attribute, type: described_class::TYPE::ARGUMENT, read:) }

    context 'when read is private' do
      let(:read) { described_class::VISIBILITY::PRIVATE }

      it { is_expected.to be true }
    end

    context 'when read is protected' do
      let(:read) { described_class::VISIBILITY::PROTECTED }

      it { is_expected.to be true }
    end

    context 'when read is public' do
      let(:read) { described_class::VISIBILITY::PUBLIC }

      it { is_expected.to be false }
    end
  end

  describe '#private_write?' do
    subject(:private_write?) { signature.private_write? }

    let(:signature) { described_class.new(attribute, type: described_class::TYPE::ARGUMENT, write:) }

    context 'when write is private' do
      let(:write) { described_class::VISIBILITY::PRIVATE }

      it { is_expected.to be true }
    end

    context 'when write is protected' do
      let(:write) { described_class::VISIBILITY::PROTECTED }

      it { is_expected.to be true }
    end

    context 'when write is public' do
      let(:write) { described_class::VISIBILITY::PUBLIC }

      it { is_expected.to be false }
    end
  end

  describe '#protected?' do
    subject(:protected?) { signature.protected? }

    let(:signature) { described_class.new(attribute, type: described_class::TYPE::ARGUMENT, read:, write:) }
    let(:read) { described_class::VISIBILITY::PUBLIC }
    let(:write) { described_class::VISIBILITY::PUBLIC }

    context 'when both read and write are protected' do
      let(:read) { described_class::VISIBILITY::PROTECTED }
      let(:write) { described_class::VISIBILITY::PROTECTED }

      it { is_expected.to be true }
    end

    context 'when read is public and write is protected' do
      let(:write) { described_class::VISIBILITY::PROTECTED }

      it { is_expected.to be false }
    end

    context 'when read is protected and write is public' do
      let(:read) { described_class::VISIBILITY::PROTECTED }

      it { is_expected.to be false }
    end

    context 'when read is private and write is protected' do
      let(:read) { described_class::VISIBILITY::PRIVATE }
      let(:write) { described_class::VISIBILITY::PROTECTED }

      it { is_expected.to be false }
    end

    context 'when read is protected and write is private' do
      let(:read) { described_class::VISIBILITY::PROTECTED }
      let(:write) { described_class::VISIBILITY::PRIVATE }

      it { is_expected.to be false }
    end

    context 'when read is public and write is public' do
      it { is_expected.to be false }
    end

    context 'when read is private and write is private' do
      let(:read) { described_class::VISIBILITY::PRIVATE }
      let(:write) { described_class::VISIBILITY::PRIVATE }

      it { is_expected.to be false }
    end

    context 'when read is public and write is private' do
      let(:write) { described_class::VISIBILITY::PRIVATE }

      it { is_expected.to be false }
    end

    context 'when read is private and write is public' do
      let(:read) { described_class::VISIBILITY::PRIVATE }

      it { is_expected.to be false }
    end
  end

  describe '#protected_read?' do
    subject(:protected_read?) { signature.protected_read? }

    let(:signature) { described_class.new(attribute, type: described_class::TYPE::ARGUMENT, read:) }

    context 'when read is protected' do
      let(:read) { described_class::VISIBILITY::PROTECTED }

      it { is_expected.to be true }
    end

    context 'when read is private' do
      let(:read) { described_class::VISIBILITY::PRIVATE }

      it { is_expected.to be false }
    end

    context 'when read is public' do
      let(:read) { described_class::VISIBILITY::PUBLIC }

      it { is_expected.to be false }
    end
  end

  describe '#protected_write?' do
    subject(:protected_write?) { signature.protected_write? }

    let(:signature) { described_class.new(attribute, type: described_class::TYPE::ARGUMENT, write: write) }

    context 'when write is protected' do
      let(:write) { described_class::VISIBILITY::PROTECTED }

      it { is_expected.to be true }
    end

    context 'when write is private' do
      let(:write) { described_class::VISIBILITY::PRIVATE }

      it { is_expected.to be false }
    end

    context 'when write is public' do
      let(:write) { described_class::VISIBILITY::PUBLIC }

      it { is_expected.to be false }
    end
  end

  describe '#public?' do
    subject(:public?) { signature.public? }

    let(:signature) { described_class.new(attribute, type: described_class::TYPE::ARGUMENT, read:, write:) }
    let(:read) { described_class::VISIBILITY::PUBLIC }
    let(:write) { described_class::VISIBILITY::PUBLIC }

    context 'when both read and write are public' do
      it { is_expected.to be true }
    end

    context 'when read is protected and write is public' do
      let(:read) { described_class::VISIBILITY::PROTECTED }

      it { is_expected.to be false }
    end

    context 'when read is private and write is public' do
      let(:read) { described_class::VISIBILITY::PRIVATE }

      it { is_expected.to be false }
    end

    context 'when read is public and write is protected' do
      let(:write) { described_class::VISIBILITY::PROTECTED }

      it { is_expected.to be false }
    end

    context 'when read is public and write is private' do
      let(:write) { described_class::VISIBILITY::PRIVATE }

      it { is_expected.to be false }
    end

    context 'when read is protected and write is protected' do
      let(:read) { described_class::VISIBILITY::PROTECTED }
      let(:write) { described_class::VISIBILITY::PROTECTED }

      it { is_expected.to be false }
    end

    context 'when read is private and write is private' do
      let(:read) { described_class::VISIBILITY::PRIVATE }
      let(:write) { described_class::VISIBILITY::PRIVATE }

      it { is_expected.to be false }
    end

    context 'when read is protected and write is private' do
      let(:read) { described_class::VISIBILITY::PROTECTED }
      let(:write) { described_class::VISIBILITY::PRIVATE }

      it { is_expected.to be false }
    end

    context 'when read is private and write is protected' do
      let(:read) { described_class::VISIBILITY::PRIVATE }
      let(:write) { described_class::VISIBILITY::PROTECTED }

      it { is_expected.to be false }
    end
  end

  describe '#public_read?' do
    subject(:public_read?) { signature.public_read? }

    let(:signature) { described_class.new(attribute, type: described_class::TYPE::ARGUMENT, read:) }

    context 'when read is public' do
      let(:read) { described_class::VISIBILITY::PUBLIC }

      it { is_expected.to be true }
    end

    context 'when read is protected' do
      let(:read) { described_class::VISIBILITY::PROTECTED }

      it { is_expected.to be false }
    end

    context 'when read is private' do
      let(:read) { described_class::VISIBILITY::PRIVATE }

      it { is_expected.to be false }
    end
  end

  describe '#public_write?' do
    subject(:public_write?) { signature.public_write? }

    let(:signature) { described_class.new(attribute, type: described_class::TYPE::ARGUMENT, write:) }

    context 'when write is public' do
      let(:write) { described_class::VISIBILITY::PUBLIC }

      it { is_expected.to be true }
    end

    context 'when write is protected' do
      let(:write) { described_class::VISIBILITY::PROTECTED }

      it { is_expected.to be false }
    end

    context 'when write is private' do
      let(:write) { described_class::VISIBILITY::PRIVATE }

      it { is_expected.to be false }
    end
  end

  describe '#required?' do
    subject(:required) { signature.required? }

    let(:signature) { described_class.new(attribute, type: described_class::TYPE::ARGUMENT, required:) }

    context 'when the signature is not required' do
      let(:required) { false }

      it { is_expected.to be false }
    end

    context 'when the signature is required' do
      let(:required) { true }

      it { is_expected.to be true }
    end
  end
end
