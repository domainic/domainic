# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/types/core/complex_type'

RSpec.describe Domainic::Type::ComplexType do
  subject(:type) { described_class.new }

  describe '.validate' do
    context 'when validating a valid Complex number' do
      subject(:validation) { type.validate(Complex(3, 4)) }

      it { is_expected.to be true }
    end

    context 'when validating an invalid type' do
      subject(:validation) { type.validate(3.14) }

      it { is_expected.to be false }
    end
  end

  describe '.validate!' do
    context 'when validating a valid Complex number' do
      subject(:validation) { type.validate!(Complex(3, 4)) }

      it { is_expected.to be true }
    end

    context 'when validating an invalid type' do
      it { expect { type.validate!(3.14) }.to raise_error(TypeError, /Expected Complex, but got Float/) }
    end
  end

  describe '#being_positive' do
    context 'when the value is positive (Real part > 0)' do
      subject(:validation) { type.being_positive.validate(Complex(3, 0)) }

      it { is_expected.to be true }
    end

    context 'when the value is not positive (Real part <= 0)' do
      subject(:validation) { type.being_positive.validate(Complex(-3, 0)) }

      it { is_expected.to be false }
    end
  end

  describe '#being_divisible_by' do
    context 'when the real part of the value is divisible by the divisor' do
      subject(:validation) { type.being_divisible_by(2).validate(Complex(4, 3)) }

      it { is_expected.to be true }
    end

    context 'when the real part of the value is not divisible by the divisor' do
      subject(:validation) { type.being_divisible_by(3).validate(Complex(4, 3)) }

      it { is_expected.to be false }
    end

    context 'when the real part is zero and divisor is non-zero' do
      subject(:validation) { type.being_divisible_by(2).validate(Complex(0, 3)) }

      it { is_expected.to be true }
    end
  end

  describe '#being_negative' do
    context 'when the value is negative (Real part < 0)' do
      subject(:validation) { type.being_negative.validate(Complex(-3, 0)) }

      it { is_expected.to be true }
    end

    context 'when the value is not negative (Real part >= 0)' do
      subject(:validation) { type.being_negative.validate(Complex(3, 0)) }

      it { is_expected.to be false }
    end
  end
end
