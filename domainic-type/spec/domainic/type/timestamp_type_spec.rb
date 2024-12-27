# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/types/datetime/timestamp_type'

RSpec.describe Domainic::Type::TimestampType do
  subject(:type) { described_class.new }

  let(:current_timestamp) { Time.now.to_i }
  let(:future_timestamp) { (Time.now + 3600).to_i } # 1 hour in the future
  let(:past_timestamp) { (Time.now - 3600).to_i }   # 1 hour in the past
  let(:negative_timestamp) { -1_234_567_890 } # Date before 1970-01-01
  let(:invalid_timestamp) { 'not a timestamp' } # Invalid type

  describe '.validate' do
    subject(:validate) { type.validate(value) }

    context 'when validating a valid current timestamp' do
      let(:value) { current_timestamp }

      it { is_expected.to be true }
    end

    context 'when validating a valid future timestamp' do
      let(:value) { future_timestamp }

      it { is_expected.to be true }
    end

    context 'when validating a valid past timestamp' do
      let(:value) { past_timestamp }

      it { is_expected.to be true }
    end

    context 'when validating an invalid timestamp' do
      let(:value) { invalid_timestamp }

      it { is_expected.to be false }
    end
  end

  describe '.validate!' do
    subject(:validate!) { type.validate!(value) }

    context 'when validating a valid current timestamp' do
      let(:value) { current_timestamp }

      it { is_expected.to be true }
    end

    context 'when validating an invalid timestamp' do
      let(:value) { invalid_timestamp }

      it { expect { validate! }.to raise_error(TypeError, /Expected Timestamp/) }
    end
  end

  describe '#being_after' do
    subject(:being_after) { type.being_after(reference_timestamp).validate(value) }

    let(:reference_timestamp) { current_timestamp }

    context 'when the value is after the reference timestamp' do
      let(:value) { future_timestamp }

      it { is_expected.to be true }
    end

    context 'when the value is equal to the reference timestamp' do
      let(:value) { reference_timestamp }

      it { is_expected.to be false }
    end

    context 'when the value is before the reference timestamp' do
      let(:value) { past_timestamp }

      it { is_expected.to be false }
    end
  end

  describe '#being_before' do
    subject(:being_before) { type.being_before(reference_timestamp).validate(value) }

    let(:reference_timestamp) { current_timestamp }

    context 'when the value is before the reference timestamp' do
      let(:value) { past_timestamp }

      it { is_expected.to be true }
    end

    context 'when the value is equal to the reference timestamp' do
      let(:value) { reference_timestamp }

      it { is_expected.to be false }
    end

    context 'when the value is after the reference timestamp' do
      let(:value) { future_timestamp }

      it { is_expected.to be false }
    end
  end

  describe '#being_between' do
    subject(:being_between) { type.being_between(start_timestamp, end_timestamp).validate(value) }

    let(:start_timestamp) { past_timestamp }
    let(:end_timestamp) { future_timestamp }

    context 'when the value is within the range' do
      let(:value) { current_timestamp }

      it { is_expected.to be true }
    end

    context 'when the value is equal to the start of the range' do
      let(:value) { start_timestamp }

      it { is_expected.to be false }
    end

    context 'when the value is equal to the end of the range' do
      let(:value) { end_timestamp }

      it { is_expected.to be false }
    end

    context 'when the value is outside the range' do
      let(:value) { (future_timestamp + 1) }

      it { is_expected.to be false }
    end
  end
end
