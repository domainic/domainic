# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/types/datetime/date_time_string_type'

RSpec.describe Domainic::Type::DateTimeStringType do
  subject(:type) { described_class.new }

  let(:valid_iso8601_value) { '2024-01-01T12:00:00Z' }
  let(:invalid_iso8601_value) { '2024/01/01 12:00:00' }
  let(:valid_rfc2822_value) { 'Thu, 31 Jan 2024 13:30:00 +0000' }
  let(:invalid_rfc2822_value) { '31-01-2024 13:30:00 +0000' }
  let(:valid_american_value) { '01/31/2024 12:30 PM' }
  let(:valid_european_value) { '31.01.2024 12:30:00' }

  describe '.validate' do
    subject(:validate) { type.validate(value) }

    context 'when validating a valid ISO8601 value' do
      let(:value) { valid_iso8601_value }

      before { type.having_iso8601_format }

      it { is_expected.to be true }
    end

    context 'when validating an invalid ISO8601 value' do
      let(:value) { invalid_iso8601_value }

      before { type.having_iso8601_format }

      it { is_expected.to be false }
    end

    context 'when validating a valid RFC2822 value' do
      let(:value) { valid_rfc2822_value }

      before { type.having_rfc2822_format }

      it { is_expected.to be true }
    end

    context 'when validating an invalid RFC2822 value' do
      let(:value) { invalid_rfc2822_value }

      before { type.having_rfc2822_format }

      it { is_expected.to be false }
    end

    context 'when validating a valid American format value' do
      let(:value) { valid_american_value }

      before { type.having_american_format }

      it { is_expected.to be true }
    end

    context 'when validating an invalid American format value' do
      let(:value) { valid_european_value }

      before { type.having_american_format }

      it { is_expected.to be false }
    end

    context 'when validating a valid European format value' do
      let(:value) { valid_european_value }

      before { type.having_european_format }

      it { is_expected.to be true }
    end

    context 'when validating an invalid European format value' do
      let(:value) { valid_american_value }

      before { type.having_european_format }

      it { is_expected.to be false }
    end

    context 'when validating a completely invalid value' do
      let(:value) { 'invalid date' }

      it { is_expected.to be false }
    end

    context 'when validating a non-string value' do
      let(:value) { :symbol }

      it { is_expected.to be false }
    end
  end

  describe '.validate!' do
    subject(:validate!) { type.validate!(value) }

    context 'when validating a valid ISO8601 value' do
      let(:value) { valid_iso8601_value }

      it { is_expected.to be true }
    end

    context 'when validating an invalid value' do
      let(:value) { 'invalid date' }

      it { expect { validate! }.to raise_error(TypeError, /Expected DateTimeString/) }
    end
  end

  describe '#being_between' do
    subject(:being_between) { type.being_between(start_date, end_date).validate(value) }

    let(:start_date) { '2024-01-01T00:00:00Z' }
    let(:end_date) { '2024-12-31T23:59:59Z' }

    context 'when value is within range' do
      let(:value) { '2024-06-15T12:00:00Z' }

      it { is_expected.to be true }
    end

    context 'when value is before the range' do
      let(:value) { '2023-12-31T23:59:59Z' }

      it { is_expected.to be false }
    end

    context 'when value is after the range' do
      let(:value) { '2025-01-01T00:00:00Z' }

      it { is_expected.to be false }
    end
  end

  describe '#being_before' do
    subject(:being_before) { type.being_before(boundary).validate(value) }

    let(:boundary) { '2024-01-01T12:00:00Z' }

    context 'when value is before the boundary' do
      let(:value) { '2023-12-31T12:00:00Z' }

      it { is_expected.to be true }
    end

    context 'when value is after the boundary' do
      let(:value) { '2024-01-02T12:00:00Z' }

      it { is_expected.to be false }
    end
  end

  describe '#being_after' do
    subject(:being_after) { type.being_after(boundary).validate(value) }

    let(:boundary) { '2024-01-01T12:00:00Z' }

    context 'when value is after the boundary' do
      let(:value) { '2024-01-02T12:00:00Z' }

      it { is_expected.to be true }
    end

    context 'when value is before the boundary' do
      let(:value) { '2023-12-31T12:00:00Z' }

      it { is_expected.to be false }
    end
  end

  describe '#being_equal_to' do
    subject(:being_equal_to) { type.being_equal_to(boundary).validate(value) }

    let(:boundary) { '2024-01-01T12:00:00Z' }

    context 'when value equals the boundary' do
      let(:value) { '2024-01-01T12:00:00Z' }

      it { is_expected.to be true }
    end

    context 'when value does not equal the boundary' do
      let(:value) { '2024-01-02T12:00:00Z' }

      it { is_expected.to be false }
    end
  end
end
