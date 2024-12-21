# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/types/core/hash_type'

RSpec.describe Domainic::Type::HashType do
  subject(:type) { described_class.new }

  describe '#containing_keys' do
    context 'when validating a hash containing all specified keys' do
      subject(:validation) { type.containing_keys(:name, :email).validate({ name: 'John', email: 'john@example.com' }) }

      it { is_expected.to be true }
    end

    context 'when validating a hash missing specified keys' do
      subject(:validation) { type.containing_keys(:name, :email).validate({ name: 'John' }) }

      it { is_expected.to be false }
    end
  end

  describe '#containing_values' do
    context 'when validating a hash containing all specified values' do
      subject(:validation) do
        type.containing_values('John', 'john@example.com').validate({ name: 'John', email: 'john@example.com' })
      end

      it { is_expected.to be true }
    end

    context 'when validating a hash missing specified values' do
      subject(:validation) do
        type.containing_values('John', 'jane@example.com').validate({ name: 'John', email: 'john@example.com' })
      end

      it { is_expected.to be false }
    end
  end

  describe '#excluding_keys' do
    context 'when validating a hash without excluded keys' do
      subject(:validation) { type.excluding_keys(:admin).validate({ name: 'John', email: 'john@example.com' }) }

      it { is_expected.to be true }
    end

    context 'when validating a hash with excluded keys' do
      subject(:validation) { type.excluding_keys(:admin).validate({ name: 'John', admin: true }) }

      it { is_expected.to be false }
    end
  end

  describe '#excluding_values' do
    context 'when validating a hash without excluded values' do
      subject(:validation) { type.excluding_values(nil, '').validate({ name: 'John', email: 'john@example.com' }) }

      it { is_expected.to be true }
    end

    context 'when validating a hash with excluded values', skip: 'pending the resolution of #107' do
      subject(:validation) { type.excluding_values(nil, 'Jane').validate({ name: 'John', email: nil }) }

      it { is_expected.to be false }
    end
  end

  describe '#of' do
    context 'when validating a hash with correct key and value types' do
      subject(:validation) { type.of(Symbol => String).validate({ name: 'John', email: 'john@example.com' }) }

      it { is_expected.to be true }
    end

    context 'when validating a hash with incorrect key type' do
      subject(:validation) { type.of(Symbol => String).validate({ 'name' => 'John' }) }

      it { is_expected.to be false }
    end

    context 'when validating a hash with incorrect value type' do
      subject(:validation) { type.of(Symbol => String).validate({ name: 123 }) }

      it { is_expected.to be false }
    end

    context 'when given an invalid type specification', rbs: :skip do
      context 'when given a non-hash' do
        subject(:invalid_type) { type.of(String) }

        it 'is expected to raise ArgumentError' do
          expect { invalid_type }.to raise_error(ArgumentError, 'The key_to_value_type pair must be a Hash')
        end
      end

      context 'when given a hash with multiple entries' do
        subject(:invalid_type) { type.of(String => Integer, Symbol => String) }

        it 'is expected to raise ArgumentError' do
          expect do
            invalid_type
          end.to raise_error(ArgumentError, 'The key_to_value_type pair must have exactly one entry')
        end
      end
    end
  end

  # Test inherited enumerable behavior
  describe 'enumerable behavior' do
    context 'when validating size constraints' do
      subject(:validation) { type.having_size(2).validate({ name: 'John', email: 'john@example.com' }) }

      it { is_expected.to be true }
    end

    context 'when validating emptiness' do
      subject(:validation) { type.being_empty.validate({}) }

      it { is_expected.to be true }
    end
  end
end
