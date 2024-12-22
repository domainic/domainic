# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/behavior'
require 'domainic/type/behavior/numeric_behavior'

RSpec.describe Domainic::Type::Behavior::NumericBehavior do
  subject(:type) { test_class.new }

  let(:test_class) do
    Class.new do
      include Domainic::Type::Behavior
      include Domainic::Type::Behavior::NumericBehavior

      intrinsic :self, :type, Numeric, abort_on_failure: true, description: :not_described
    end
  end

  describe '#being_divisible_by' do
    context 'when validating a number divisible by the divisor' do
      subject(:validation) { type.being_divisible_by(3).validate(9) }

      it { is_expected.to be true }
    end

    context 'when validating a number not divisible by the divisor' do
      subject(:validation) { type.being_divisible_by(3).validate(10) }

      it { is_expected.to be false }
    end

    context 'with custom tolerance' do
      subject(:validation) { type.being_divisible_by(3, tolerance: 0.1).validate(9.05) }

      it { is_expected.to be true }
    end
  end

  describe '#being_equal_to' do
    context 'when validating a number equal to the expected value' do
      subject(:validation) { type.being_equal_to(42).validate(42) }

      it { is_expected.to be true }
    end

    context 'when validating a number not equal to the expected value' do
      subject(:validation) { type.being_equal_to(42).validate(7) }

      it { is_expected.to be false }
    end
  end

  describe '#being_even' do
    context 'when validating an even number' do
      subject(:validation) { type.being_even.validate(4) }

      it { is_expected.to be true }
    end

    context 'when validating an odd number' do
      subject(:validation) { type.being_even.validate(3) }

      it { is_expected.to be false }
    end
  end

  describe '#being_finite' do
    context 'when validating a finite number' do
      subject(:validation) { type.being_finite.validate(42) }

      it { is_expected.to be true }
    end

    context 'when validating an infinite number' do
      subject(:validation) { type.being_finite.validate(Float::INFINITY) }

      it { is_expected.to be false }
    end
  end

  describe '#being_greater_than' do
    context 'when validating a number greater than the boundary' do
      subject(:validation) { type.being_greater_than(5).validate(10) }

      it { is_expected.to be true }
    end

    context 'when validating a number equal to the boundary' do
      subject(:validation) { type.being_greater_than(5).validate(5) }

      it { is_expected.to be false }
    end

    context 'when validating a number less than the boundary' do
      subject(:validation) { type.being_greater_than(5).validate(3) }

      it { is_expected.to be false }
    end
  end

  describe '#being_greater_than_or_equal_to' do
    context 'when validating a number greater than the boundary' do
      subject(:validation) { type.being_greater_than_or_equal_to(5).validate(10) }

      it { is_expected.to be true }
    end

    context 'when validating a number equal to the boundary' do
      subject(:validation) { type.being_greater_than_or_equal_to(5).validate(5) }

      it { is_expected.to be true }
    end

    context 'when validating a number less than the boundary' do
      subject(:validation) { type.being_greater_than_or_equal_to(5).validate(3) }

      it { is_expected.to be false }
    end
  end

  describe '#being_infinite' do
    context 'when validating an infinite number' do
      subject(:validation) { type.being_infinite.validate(Float::INFINITY) }

      it { is_expected.to be true }
    end

    context 'when validating a finite number' do
      subject(:validation) { type.being_infinite.validate(42) }

      it { is_expected.to be false }
    end
  end

  describe '#being_less_than' do
    context 'when validating a number less than the boundary' do
      subject(:validation) { type.being_less_than(10).validate(5) }

      it { is_expected.to be true }
    end

    context 'when validating a number equal to the boundary' do
      subject(:validation) { type.being_less_than(10).validate(10) }

      it { is_expected.to be false }
    end

    context 'when validating a number greater than the boundary' do
      subject(:validation) { type.being_less_than(10).validate(15) }

      it { is_expected.to be false }
    end
  end

  describe '#being_less_than_or_equal_to' do
    context 'when validating a number less than the boundary' do
      subject(:validation) { type.being_less_than_or_equal_to(10).validate(5) }

      it { is_expected.to be true }
    end

    context 'when validating a number equal to the boundary' do
      subject(:validation) { type.being_less_than_or_equal_to(10).validate(10) }

      it { is_expected.to be true }
    end

    context 'when validating a number greater than the boundary' do
      subject(:validation) { type.being_less_than_or_equal_to(10).validate(15) }

      it { is_expected.to be false }
    end
  end

  describe '#being_negative' do
    context 'when validating a negative number' do
      subject(:validation) { type.being_negative.validate(-5) }

      it { is_expected.to be true }
    end

    context 'when validating a positive number' do
      subject(:validation) { type.being_negative.validate(5) }

      it { is_expected.to be false }
    end

    context 'when validating zero' do
      subject(:validation) { type.being_negative.validate(0) }

      it { is_expected.to be false }
    end
  end

  describe '#being_odd' do
    context 'when validating an odd number' do
      subject(:validation) { type.being_odd.validate(3) }

      it { is_expected.to be true }
    end

    context 'when validating an even number' do
      subject(:validation) { type.being_odd.validate(4) }

      it { is_expected.to be false }
    end
  end

  describe '#being_positive' do
    context 'when validating a positive number' do
      subject(:validation) { type.being_positive.validate(5) }

      it { is_expected.to be true }
    end

    context 'when validating a negative number' do
      subject(:validation) { type.being_positive.validate(-5) }

      it { is_expected.to be false }
    end

    context 'when validating zero' do
      subject(:validation) { type.being_positive.validate(0) }

      it { is_expected.to be false }
    end
  end

  describe '#being_zero' do
    context 'when validating zero' do
      subject(:validation) { type.being_zero.validate(0) }

      it { is_expected.to be true }
    end

    context 'when validating a non-zero number' do
      subject(:validation) { type.being_zero.validate(5) }

      it { is_expected.to be false }
    end
  end

  describe '#not_being_divisible_by' do
    context 'when validating a number not divisible by the divisor' do
      subject(:validation) { type.not_being_divisible_by(3).validate(10) }

      it { is_expected.to be true }
    end

    context 'when validating a number divisible by the divisor' do
      subject(:validation) { type.not_being_divisible_by(3).validate(9) }

      it { is_expected.to be false }
    end
  end

  describe '#not_being_equal_to' do
    context 'when validating a number not equal to the expected value' do
      subject(:validation) { type.not_being_equal_to(42).validate(7) }

      it { is_expected.to be true }
    end

    context 'when validating a number equal to the expected value' do
      subject(:validation) { type.not_being_equal_to(42).validate(42) }

      it { is_expected.to be false }
    end
  end

  describe '#not_being_zero' do
    context 'when validating a non-zero number' do
      subject(:validation) { type.not_being_zero.validate(5) }

      it { is_expected.to be true }
    end

    context 'when validating zero' do
      subject(:validation) { type.not_being_zero.validate(0) }

      it { is_expected.to be false }
    end
  end
end
