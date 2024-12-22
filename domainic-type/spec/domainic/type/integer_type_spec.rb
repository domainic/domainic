# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/types/core/integer_type'

RSpec.describe Domainic::Type::IntegerType do
  subject(:type) { described_class.new }

  describe '.validate' do
    context 'when validating an integer' do
      subject(:validation) { described_class.validate(42) }

      it { is_expected.to be true }
    end

    context 'when validating a non-integer' do
      context 'with a float' do
        subject(:validation) { described_class.validate(3.14) }

        it { is_expected.to be false }
      end

      context 'with a string' do
        subject(:validation) { described_class.validate('42') }

        it { is_expected.to be false }
      end
    end
  end

  describe '.validate!' do
    context 'when validating an integer' do
      subject(:validation) { described_class.validate!(42) }

      it { is_expected.to be true }
    end

    context 'when validating a non-integer' do
      it 'is expected to raise TypeError' do
        expect { described_class.validate!(3.14) }
          .to raise_error(TypeError, /Expected Integer, but got Float/)
      end
    end
  end

  # Test inherited numeric behavior
  describe 'numeric behavior' do
    describe '#being_even' do
      context 'when validating an even number' do
        subject(:validation) { type.being_even.validate(42) }

        it { is_expected.to be true }
      end

      context 'when validating an odd number' do
        subject(:validation) { type.being_even.validate(41) }

        it { is_expected.to be false }
      end
    end

    describe '#being_positive' do
      context 'when validating a positive number' do
        subject(:validation) { type.being_positive.validate(42) }

        it { is_expected.to be true }
      end

      context 'when validating a negative number' do
        subject(:validation) { type.being_positive.validate(-42) }

        it { is_expected.to be false }
      end
    end

    describe '#being_divisible_by' do
      context 'when validating a divisible number' do
        subject(:validation) { type.being_divisible_by(7).validate(42) }

        it { is_expected.to be true }
      end

      context 'when validating a non-divisible number' do
        subject(:validation) { type.being_divisible_by(7).validate(43) }

        it { is_expected.to be false }
      end
    end
  end
end
