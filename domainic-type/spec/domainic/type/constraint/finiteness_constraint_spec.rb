# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/constraints/finiteness_constraint'

RSpec.describe Domainic::Type::Constraint::FinitenessConstraint do
  describe '#expecting' do
    subject(:expecting) { constraint.expecting(expectation) }

    let(:constraint) { described_class.new(:self) }

    context 'with valid expectations' do
      %i[finite finite? infinite infinite?].each do |value|
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

    context 'when expecting finite' do
      let(:constraint) { described_class.new(:self).expecting(:finite) }

      context 'with finite number' do
        let(:value) { 42.0 }

        it { is_expected.to be true }
      end

      context 'with infinite number' do
        let(:value) { Float::INFINITY }

        it { is_expected.to be false }
      end

      context 'with negative infinite number' do
        let(:value) { -Float::INFINITY }

        it { is_expected.to be false }
      end
    end

    context 'when expecting infinite' do
      let(:constraint) { described_class.new(:self).expecting(:infinite) }

      context 'with finite number' do
        let(:value) { 42.0 }

        it { is_expected.to be false }
      end

      context 'with infinite number' do
        let(:value) { Float::INFINITY }

        it { is_expected.to be true }
      end

      context 'with negative infinite number' do
        let(:value) { -Float::INFINITY }

        it { is_expected.to be true }
      end
    end
  end

  describe '#short_description' do
    subject(:short_description) { constraint.short_description }

    let(:constraint) { described_class.new(:self).expecting(:finite) }

    it { is_expected.to eq('finite') }
  end

  describe '#short_violation_description' do
    subject(:short_violation_description) { constraint.short_violation_description }

    let(:constraint) { described_class.new(:self).expecting(:finite) }

    it { is_expected.to eq('infinite') }
  end
end
