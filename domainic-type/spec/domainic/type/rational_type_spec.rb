# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/types/core/rational_type'

RSpec.describe Domainic::Type::RationalType do
  subject(:type) { described_class.new }

  describe 'intrinsic constraints' do
    describe 'type constraint' do
      context 'when value is a Rational number' do
        subject(:validation) { type.validate(Rational(3, 4)) }

        it { is_expected.to be true }
      end

      context 'when value is not a Rational number' do
        subject(:validation) { type.validate(0.75) }

        it { is_expected.to be false }
      end
    end
  end

  describe '#being_positive' do
    context 'when the value is positive' do
      subject(:validation) { type.being_positive.validate(Rational(3, 4)) }

      it { is_expected.to be true }
    end

    context 'when the value is not positive' do
      subject(:validation) { type.being_positive.validate(Rational(-3, 4)) }

      it { is_expected.to be false }
    end
  end

  describe '#being_negative' do
    context 'when the value is negative' do
      subject(:validation) { type.being_negative.validate(Rational(-3, 4)) }

      it { is_expected.to be true }
    end

    context 'when the value is not negative' do
      subject(:validation) { type.being_negative.validate(Rational(3, 4)) }

      it { is_expected.to be false }
    end
  end

  describe '#being_divisible_by' do
    context 'when the value is divisible by the divisor' do
      subject(:validation) { type.being_divisible_by(1).validate(Rational(3, 1)) }

      it { is_expected.to be true }
    end

    context 'when the value is not divisible by the divisor' do
      subject(:validation) { type.being_divisible_by(2).validate(Rational(3, 1)) }

      it { is_expected.to be false }
    end
  end

  describe '#being_greater_than' do
    context 'when the value is greater than the boundary' do
      subject(:validation) { type.being_greater_than(Rational(1, 2)).validate(Rational(3, 4)) }

      it { is_expected.to be true }
    end

    context 'when the value is not greater than the boundary' do
      subject(:validation) { type.being_greater_than(Rational(1, 2)).validate(Rational(1, 4)) }

      it { is_expected.to be false }
    end
  end
end
