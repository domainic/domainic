# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/types/core_extended/big_decimal_type'

RSpec.describe Domainic::Type::BigDecimalType do
  subject(:type) { described_class.new }

  describe '.validate' do
    context 'when validating a valid BigDecimal value' do
      subject(:validation) { type.validate(BigDecimal('3.14')) }

      it { is_expected.to be true }
    end

    context 'when validating an invalid type' do
      subject(:validation) { type.validate(3.14) }

      it { is_expected.to be false }
    end
  end

  describe '.validate!' do
    context 'when validating a valid BigDecimal value' do
      subject(:validation) { type.validate!(BigDecimal('3.14')) }

      it { is_expected.to be true }
    end

    context 'when validating an invalid type' do
      it { expect { type.validate!(3.14) }.to raise_error(TypeError, /Expected BigDecimal, but got Float/) }
    end
  end

  describe '#being_positive' do
    context 'when the value is positive' do
      subject(:validation) { type.being_positive.validate(BigDecimal('3.14')) }

      it { is_expected.to be true }
    end

    context 'when the value is negative' do
      subject(:validation) { type.being_positive.validate(BigDecimal('-3.14')) }

      it { is_expected.to be false }
    end
  end

  describe '#being_divisible_by' do
    context 'when the value is divisible by the specified number' do
      subject(:validation) { type.being_divisible_by(BigDecimal('1.57')).validate(BigDecimal('3.14')) }

      it { is_expected.to be true }
    end

    context 'when the value is not divisible by the specified number' do
      subject(:validation) { type.being_divisible_by(BigDecimal('1.57')).validate(BigDecimal('3.15')) }

      it { is_expected.to be false }
    end
  end

  describe '#being_negative' do
    context 'when the value is negative' do
      subject(:validation) { type.being_negative.validate(BigDecimal('-3.14')) }

      it { is_expected.to be true }
    end

    context 'when the value is positive' do
      subject(:validation) { type.being_negative.validate(BigDecimal('3.14')) }

      it { is_expected.to be false }
    end
  end
end
