# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/types/core/array_type'

RSpec.describe Domainic::Type::ArrayType do
  subject(:type) { described_class.new }

  describe '.validate' do
    context 'when validating an array' do
      subject(:validation) { described_class.validate([1, 2, 3]) }

      it { is_expected.to be true }
    end

    context 'when validating a non-array' do
      subject(:validation) { described_class.validate('not an array') }

      it { is_expected.to be false }
    end
  end

  describe '.validate!' do
    context 'when validating an array' do
      subject(:validation) { described_class.validate!([1, 2, 3]) }

      it { is_expected.to be true }
    end

    context 'when validating a non-array' do
      it 'is expected to raise TypeError' do
        expect { described_class.validate!('not an array') }
          .to raise_error(TypeError, /Expected Array, but got String/)
      end
    end
  end

  # Test inherited enumerable behavior
  describe 'enumerable behavior' do
    describe '#of' do
      context 'when validating an array of strings' do
        subject(:validation) { type.of(String).validate(%w[a b c]) }

        it { is_expected.to be true }
      end

      context 'when validating an array with mixed types' do
        subject(:validation) { type.of(String).validate(['a', 1, 'c']) }

        it { is_expected.to be false }
      end
    end

    describe '#being_empty' do
      context 'when validating an empty array' do
        subject(:validation) { type.being_empty.validate([]) }

        it { is_expected.to be true }
      end

      context 'when validating a non-empty array' do
        subject(:validation) { type.being_empty.validate([1]) }

        it { is_expected.to be false }
      end
    end

    describe '#having_size' do
      context 'when validating an array with correct size' do
        subject(:validation) { type.having_size(3).validate([1, 2, 3]) }

        it { is_expected.to be true }
      end

      context 'when validating an array with incorrect size' do
        subject(:validation) { type.having_size(2).validate([1, 2, 3]) }

        it { is_expected.to be false }
      end
    end

    describe '#containing' do
      context 'when validating an array containing required elements' do
        subject(:validation) { type.containing(1, 2).validate([1, 2, 3]) }

        it { is_expected.to be true }
      end

      context 'when validating an array missing required elements' do
        subject(:validation) { type.containing(1, 4).validate([1, 2, 3]) }

        it { is_expected.to be false }
      end
    end

    describe '#being_sorted' do
      context 'when validating a sorted array' do
        subject(:validation) { type.being_sorted.validate([1, 2, 3]) }

        it { is_expected.to be true }
      end

      context 'when validating an unsorted array' do
        subject(:validation) { type.being_sorted.validate([3, 1, 2]) }

        it { is_expected.to be false }
      end
    end
  end
end
