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
  end
end
