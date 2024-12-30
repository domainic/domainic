# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/behavior'
require 'domainic/type/behavior/date_time_behavior'

RSpec.describe Domainic::Type::Behavior::DateTimeBehavior do
  subject(:type) { test_class.new }

  let(:test_class) do
    Class.new do
      include Domainic::Type::Behavior
      include Domainic::Type::Behavior::DateTimeBehavior
    end
  end

  describe '#being_after' do
    context 'when validating a date after the specified value' do
      subject(:validation) { type.being_after(Date.new(2024, 1, 1)).validate(Date.new(2024, 1, 2)) }

      it { is_expected.to be true }
    end

    context 'when validating a date equal to the specified value' do
      subject(:validation) { type.being_after(Date.new(2024, 1, 1)).validate(Date.new(2024, 1, 1)) }

      it { is_expected.to be false }
    end

    context 'when validating a date before the specified value' do
      subject(:validation) { type.being_after(Date.new(2024, 1, 1)).validate(Date.new(2023, 12, 31)) }

      it { is_expected.to be false }
    end

    described_class::DATETIME_PATTERNS.each do |pattern|
      context "when given a string matching #{pattern}" do
        subject(:validation) { type.being_after(reference_date).validate(value) }

        let(:reference_date) { DateTime.now.strftime(pattern) }
        let(:value) { (DateTime.now + 1).strftime(pattern) }

        it { is_expected.to be true }
      end
    end

    context 'when given a valid timestamp integer' do
      subject(:validation) { type.being_after(reference_date.to_time.to_i).validate(value) }

      let(:reference_date) { DateTime.now }
      let(:value) { (reference_date + 1).to_time.to_i }

      it { is_expected.to be true }
    end

    context 'when given an invalid date string' do
      subject(:validation) { type.being_after(Date.new(2024, 1, 1)).validate('not a date') }

      it { is_expected.to be false }
    end
  end

  describe '#being_before' do
    context 'when validating a date before the specified value' do
      subject(:validation) { type.being_before(Date.new(2024, 1, 1)).validate(Date.new(2023, 12, 31)) }

      it { is_expected.to be true }
    end

    context 'when validating a date equal to the specified value' do
      subject(:validation) { type.being_before(Date.new(2024, 1, 1)).validate(Date.new(2024, 1, 1)) }

      it { is_expected.to be false }
    end

    context 'when validating a date after the specified value' do
      subject(:validation) { type.being_before(Date.new(2024, 1, 1)).validate(Date.new(2024, 1, 2)) }

      it { is_expected.to be false }
    end

    described_class::DATETIME_PATTERNS.each do |pattern|
      context "when given a string matching #{pattern}" do
        subject(:validation) { type.being_before(reference_date).validate(value) }

        let(:reference_date) { DateTime.now.strftime(pattern) }
        let(:value) { (DateTime.now - 1).strftime(pattern) }

        it { is_expected.to be true }
      end
    end

    context 'when given a valid timestamp integer' do
      subject(:validation) { type.being_before(reference_date.to_time.to_i).validate(value) }

      let(:reference_date) { DateTime.now }
      let(:value) { (reference_date - 1).to_time.to_i }

      it { is_expected.to be true }
    end

    context 'when given an invalid date string' do
      subject(:validation) { type.being_before(Date.new(2024, 1, 1)).validate('not a date') }

      it { is_expected.to be false }
    end
  end

  describe '#being_between' do
    context 'when validating a date within the range' do
      subject(:validation) do
        type.being_between(Date.new(2024, 1, 1), Date.new(2024, 12, 31)).validate(Date.new(2024, 6, 15))
      end

      it { is_expected.to be true }
    end

    context 'when validating a date equal to the lower bound' do
      subject(:validation) do
        type.being_between(Date.new(2024, 1, 1), Date.new(2024, 12, 31)).validate(Date.new(2024, 1, 1))
      end

      it { is_expected.to be false }
    end

    context 'when validating a date equal to the upper bound' do
      subject(:validation) do
        type.being_between(Date.new(2024, 1, 1), Date.new(2024, 12, 31)).validate(Date.new(2024, 12, 31))
      end

      it { is_expected.to be false }
    end

    described_class::DATETIME_PATTERNS.each do |pattern|
      context "when given a string matching #{pattern}" do
        subject(:validation) { type.being_between(reference_after_date, reference_before_date).validate(value) }

        let(:reference_after_date) { DateTime.now.strftime(pattern) }
        let(:reference_before_date) { (DateTime.now + 2).strftime(pattern) }
        let(:value) { (DateTime.now + 1).strftime(pattern) }

        it { is_expected.to be true }
      end
    end

    context 'when given a valid timestamp integer' do
      subject(:validation) do
        type.being_between(reference_before_date.to_time.to_i, reference_after_date.to_time.to_i).validate(value)
      end

      let(:reference_before_date) { DateTime.now }
      let(:reference_after_date) { (DateTime.now + 2) }
      let(:value) { (DateTime.now + 1).to_time.to_i }

      it { is_expected.to be true }
    end

    context 'when given an invalid date string' do
      subject(:validation) { type.being_between(Date.new(2024, 1, 1), Date.new(2024, 1, 3)).validate('not a date') }

      it { is_expected.to be false }
    end
  end

  describe '#being_equal_to' do
    context 'when validating a date equal to the specified value' do
      subject(:validation) { type.being_equal_to(Date.new(2024, 1, 1)).validate(Date.new(2024, 1, 1)) }

      it { is_expected.to be true }
    end

    context 'when validating a date not equal to the specified value' do
      subject(:validation) { type.being_equal_to(Date.new(2024, 1, 1)).validate(Date.new(2023, 12, 31)) }

      it { is_expected.to be false }
    end

    described_class::DATETIME_PATTERNS.each do |pattern|
      context "when given a string matching #{pattern}" do
        subject(:validation) { type.being_equal_to(reference_date_string).validate(reference_date_string) }

        let(:reference_date) { DateTime.now }
        let(:reference_date_string) { reference_date.strftime(pattern) }

        it { is_expected.to be true }
      end
    end

    context 'when given a valid timestamp integer' do
      subject(:validation) { type.being_equal_to(reference_date.to_time.to_i).validate(value) }

      let(:reference_date) { DateTime.now }
      let(:value) { reference_date.to_time.to_i }

      it { is_expected.to be true }
    end

    context 'when given an invalid date string' do
      subject(:validation) { type.being_equal_to(Date.new(2024, 1, 1)).validate('not a date') }

      it { is_expected.to be false }
    end
  end

  describe '#being_on_or_after' do
    context 'when validating a date after the specified value' do
      subject(:validation) { type.being_on_or_after(Date.new(2024, 1, 1)).validate(Date.new(2024, 1, 2)) }

      it { is_expected.to be true }
    end

    context 'when validating a date equal to the specified value' do
      subject(:validation) { type.being_on_or_after(Date.new(2024, 1, 1)).validate(Date.new(2024, 1, 1)) }

      it { is_expected.to be true }
    end

    context 'when validating a date before the specified value' do
      subject(:validation) { type.being_on_or_after(Date.new(2024, 1, 1)).validate(Date.new(2023, 12, 31)) }

      it { is_expected.to be false }
    end

    described_class::DATETIME_PATTERNS.each do |pattern|
      context "when given a string matching #{pattern}" do
        subject(:validation) { type.being_on_or_after(reference_date_string).validate(value) }

        let(:reference_date) { DateTime.now }
        let(:reference_date_string) { reference_date.strftime(pattern) }
        let(:value) { [reference_date_string, (reference_date + 1).strftime(pattern)].sample }

        it { is_expected.to be true }
      end
    end

    context 'when given a valid timestamp integer' do
      subject(:validation) { type.being_on_or_after(reference_date.to_time.to_i).validate(value) }

      let(:reference_date) { DateTime.now }
      let(:value) { [reference_date.to_time.to_i, (reference_date + 1).to_time.to_i].sample }

      it { is_expected.to be true }
    end

    context 'when given an invalid date string' do
      subject(:validation) { type.being_on_or_after(Date.new(2024, 1, 1)).validate('not a date') }

      it { is_expected.to be false }
    end
  end

  describe '#being_on_or_before' do
    context 'when validating a date before the specified value' do
      subject(:validation) { type.being_on_or_before(Date.new(2024, 1, 1)).validate(Date.new(2023, 12, 31)) }

      it { is_expected.to be true }
    end

    context 'when validating a date equal to the specified value' do
      subject(:validation) { type.being_on_or_before(Date.new(2024, 1, 1)).validate(Date.new(2024, 1, 1)) }

      it { is_expected.to be true }
    end

    context 'when validating a date after the specified value' do
      subject(:validation) { type.being_on_or_before(Date.new(2024, 1, 1)).validate(Date.new(2024, 1, 2)) }

      it { is_expected.to be false }
    end

    described_class::DATETIME_PATTERNS.each do |pattern|
      context "when given a string matching #{pattern}" do
        subject(:validation) { type.being_on_or_before(reference_date_string).validate(value) }

        let(:reference_date) { DateTime.now }
        let(:reference_date_string) { reference_date.strftime(pattern) }
        let(:value) { [reference_date_string, (reference_date - 1).strftime(pattern)].sample }

        it { is_expected.to be true }
      end
    end

    context 'when given a valid timestamp integer' do
      subject(:validation) { type.being_on_or_before(reference_date.to_time.to_i).validate(value) }

      let(:reference_date) { DateTime.now }
      let(:value) { [reference_date.to_time.to_i, (reference_date - 1).to_time.to_i].sample }

      it { is_expected.to be true }
    end

    context 'when given an invalid date string' do
      subject(:validation) { type.being_on_or_before(Date.new(2024, 1, 1)).validate('not a date') }

      it { is_expected.to be false }
    end
  end
end
