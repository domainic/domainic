# frozen_string_literal: true

RSpec.shared_examples 'a datetime type' do |type_class, valid_value, invalid_value|
  let(:type) { type_class.new }

  describe '.validate' do
    subject(:validate) { type.validate(value) }

    context 'when validating a valid value' do
      let(:value) { valid_value }

      it { is_expected.to be true }
    end

    context 'when validating an invalid value' do
      let(:value) { invalid_value }

      it { is_expected.to be false }
    end

    context 'when validating a non-date/time value' do
      let(:value) { :symbol }

      it { is_expected.to be false }
    end
  end

  describe '.validate!' do
    subject(:validate!) { type.validate!(value) }

    context 'when validating a valid value' do
      let(:value) { valid_value }

      it { is_expected.to be true }
    end

    context 'when validating an invalid value' do
      let(:value) { invalid_value }

      it { expect { validate! }.to raise_error(TypeError, /Expected #{type_class}/) }
    end
  end

  describe '#being_between' do
    subject(:being_between) { type.being_between(start_date, end_date).validate(value) }

    let(:start_date) { valid_value - 1 }
    let(:end_date) { valid_value + 1 }

    context 'when value is within range' do
      let(:value) { valid_value }

      it { is_expected.to be true }
    end

    context 'when value is outside the range' do
      let(:value) { valid_value + 2 }

      it { is_expected.to be false }
    end
  end

  describe '#being_before' do
    subject(:being_before) { type.being_before(boundary).validate(value) }

    let(:boundary) { valid_value }

    context 'when value is before the boundary' do
      let(:value) { valid_value - 1 }

      it { is_expected.to be true }
    end

    context 'when value is after the boundary' do
      let(:value) { valid_value + 1 }

      it { is_expected.to be false }
    end
  end

  describe '#being_after' do
    subject(:being_after) { type.being_after(boundary).validate(value) }

    let(:boundary) { valid_value }

    context 'when value is after the boundary' do
      let(:value) { valid_value + 1 }

      it { is_expected.to be true }
    end

    context 'when value is before the boundary' do
      let(:value) { valid_value - 1 }

      it { is_expected.to be false }
    end
  end

  describe '#being_equal_to' do
    subject(:being_equal_to) { type.being_equal_to(boundary).validate(value) }

    let(:boundary) { valid_value }

    context 'when value equals the boundary' do
      let(:value) { valid_value }

      it { is_expected.to be true }
    end

    context 'when value does not equal the boundary' do
      let(:value) { valid_value + 1 }

      it { is_expected.to be false }
    end
  end
end
