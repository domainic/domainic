# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/constraints/parity_constraint'

RSpec.describe Domainic::Type::Constraint::ParityConstraint do
  describe '#expecting' do
    subject(:expecting) { constraint.expecting(expectation) }

    let(:constraint) { described_class.new(:self) }

    context 'with valid expectations' do
      %i[even even? odd odd?].each do |value|
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

    context 'when expecting even' do
      let(:constraint) { described_class.new(:self).expecting(:even) }

      context 'with even number' do
        let(:value) { 42 }

        it { is_expected.to be true }
      end

      context 'with odd number' do
        let(:value) { 41 }

        it { is_expected.to be false }
      end

      context 'with zero' do
        let(:value) { 0 }

        it { is_expected.to be true }
      end
    end

    context 'when expecting odd' do
      let(:constraint) { described_class.new(:self).expecting(:odd) }

      context 'with even number' do
        let(:value) { 42 }

        it { is_expected.to be false }
      end

      context 'with odd number' do
        let(:value) { 41 }

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

    %i[even odd].each do |value|
      context "when expecting #{value}" do
        let(:constraint) { described_class.new(:self).expecting(value) }

        it { is_expected.to eq(value.to_s) }
      end
    end
  end

  describe '#short_violation_description' do
    subject(:short_violation_description) { constraint.short_violation_description }

    context 'when expecting even' do
      let(:constraint) { described_class.new(:self).expecting(:even) }

      before { constraint.satisfied?(41) }

      it { is_expected.to eq('odd') }
    end

    context 'when expecting odd' do
      let(:constraint) { described_class.new(:self).expecting(:odd) }

      before { constraint.satisfied?(42) }

      it { is_expected.to eq('even') }
    end
  end
end
