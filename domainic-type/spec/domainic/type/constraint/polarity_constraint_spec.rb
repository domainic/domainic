# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/constraints/polarity_constraint'

RSpec.describe Domainic::Type::Constraint::PolarityConstraint do
  describe '#expecting' do
    subject(:expecting) { constraint.expecting(expectation) }

    let(:constraint) { described_class.new(:self) }

    context 'with valid expectations' do
      %i[negative negative? nonzero nonzero? positive positive? zero zero?].each do |value|
        context "when given #{value}" do
          let(:expectation) { value }

          it 'is expected not to raise error' do
            expect { expecting }.not_to raise_error
          end
        end
      end
    end

    context 'with invalid expectation', rbs: :skip do
      let(:expectation) { :invalid }

      it { expect { expecting }.to raise_error(ArgumentError, /Invalid expectation/) }
    end
  end

  describe '#satisfied?' do
    subject(:satisfied?) { constraint.satisfied?(value) }

    context 'when expecting positive' do
      let(:constraint) { described_class.new(:self).expecting(:positive) }

      context 'with positive number' do
        let(:value) { 42 }

        it { is_expected.to be true }
      end

      context 'with negative number' do
        let(:value) { -42 }

        it { is_expected.to be false }
      end

      context 'with zero' do
        let(:value) { 0 }

        it { is_expected.to be false }
      end
    end

    context 'when expecting negative' do
      let(:constraint) { described_class.new(:self).expecting(:negative) }

      context 'with positive number' do
        let(:value) { 42 }

        it { is_expected.to be false }
      end

      context 'with negative number' do
        let(:value) { -42 }

        it { is_expected.to be true }
      end

      context 'with zero' do
        let(:value) { 0 }

        it { is_expected.to be false }
      end
    end

    context 'when expecting zero' do
      let(:constraint) { described_class.new(:self).expecting(:zero) }

      context 'with positive number' do
        let(:value) { 42 }

        it { is_expected.to be false }
      end

      context 'with negative number' do
        let(:value) { -42 }

        it { is_expected.to be false }
      end

      context 'with zero' do
        let(:value) { 0 }

        it { is_expected.to be true }
      end
    end

    context 'when expecting nonzero' do
      let(:constraint) { described_class.new(:self).expecting(:nonzero) }

      context 'with positive number' do
        let(:value) { 42 }

        it { is_expected.to be true }
      end

      context 'with negative number' do
        let(:value) { -42 }

        it { is_expected.to be true }
      end

      context 'with zero' do
        let(:value) { 0 }

        it { is_expected.to be false }
      end
    end
  end

  describe '#short_description' do
    subject(:short_description) { constraint.short_description }

    %i[positive negative zero nonzero].each do |value|
      context "when expecting #{value}" do
        let(:constraint) { described_class.new(:self).expecting(value) }

        it { is_expected.to eq(value.to_s) }
      end
    end
  end

  describe '#short_violation_description' do
    subject(:short_violation_description) { constraint.short_violation_description }

    context 'when expecting positive' do
      let(:constraint) { described_class.new(:self).expecting(:positive) }

      context 'when value is zero' do
        before { constraint.satisfied?(0) }

        it { is_expected.to eq('zero') }
      end

      context 'when value is negative' do
        before { constraint.satisfied?(-42) }

        it { is_expected.to eq('negative') }
      end
    end

    context 'when expecting negative' do
      let(:constraint) { described_class.new(:self).expecting(:negative) }

      context 'when value is zero' do
        before { constraint.satisfied?(0) }

        it { is_expected.to eq('zero') }
      end

      context 'when value is positive' do
        before { constraint.satisfied?(42) }

        it { is_expected.to eq('positive') }
      end
    end

    context 'when expecting zero' do
      let(:constraint) { described_class.new(:self).expecting(:zero) }

      before { constraint.satisfied?(42) }

      it { is_expected.to eq('nonzero') }
    end

    context 'when expecting nonzero' do
      let(:constraint) { described_class.new(:self).expecting(:nonzero) }

      before { constraint.satisfied?(0) }

      it { is_expected.to eq('zero') }
    end
  end
end
