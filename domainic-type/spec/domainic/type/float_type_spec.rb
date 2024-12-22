# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/types/core/float_type'

RSpec.describe Domainic::Type::FloatType do
  subject(:type) { described_class.new }

  describe '.validate' do
    context 'when validating a float' do
      subject(:validation) { described_class.validate(3.14) }

      it { is_expected.to be true }
    end

    context 'when validating a non-float' do
      context 'with an integer' do
        subject(:validation) { described_class.validate(42) }

        it { is_expected.to be false }
      end

      context 'with a string' do
        subject(:validation) { described_class.validate('3.14') }

        it { is_expected.to be false }
      end
    end
  end

  describe '.validate!' do
    context 'when validating a float' do
      subject(:validation) { described_class.validate!(3.14) }

      it { is_expected.to be true }
    end

    context 'when validating a non-float' do
      it 'is expected to raise TypeError' do
        expect { described_class.validate!(42) }
          .to raise_error(TypeError, /Expected Float, but got Integer/)
      end
    end
  end

  # Test inherited numeric behavior
  describe 'numeric behavior' do
    describe '#being_finite' do
      context 'when validating a finite number' do
        subject(:validation) { type.being_finite.validate(3.14) }

        it { is_expected.to be true }
      end

      context 'when validating an infinite number' do
        subject(:validation) { type.being_finite.validate(Float::INFINITY) }

        it { is_expected.to be false }
      end
    end

    describe '#being_positive' do
      context 'when validating a positive number' do
        subject(:validation) { type.being_positive.validate(3.14) }

        it { is_expected.to be true }
      end

      context 'when validating a negative number' do
        subject(:validation) { type.being_positive.validate(-3.14) }

        it { is_expected.to be false }
      end
    end

    describe '#being_divisible_by' do
      context 'when validating a divisible number' do
        subject(:validation) { type.being_divisible_by(0.1).validate(0.3) }

        it { is_expected.to be true }
      end

      context 'when validating a non-divisible number' do
        subject(:validation) { type.being_divisible_by(0.1).validate(0.35) }

        it { is_expected.to be false }
      end

      context 'with custom tolerance' do
        subject(:validation) { type.being_divisible_by(0.1, tolerance: 0.01).validate(0.301) }

        it { is_expected.to be true }
      end
    end
  end
end
