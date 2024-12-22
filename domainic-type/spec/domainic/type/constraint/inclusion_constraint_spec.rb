# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/constraints/inclusion_constraint'

RSpec.describe Domainic::Type::Constraint::InclusionConstraint do
  describe '#satisfied?' do
    subject(:satisfied?) { constraint.satisfied?(actual_value) }

    let(:constraint) { described_class.new(:self).expecting(expected_value) }

    context 'with arrays' do
      let(:expected_value) { 2 }

      context 'when including the value' do
        let(:actual_value) { [1, 2, 3] }

        it { is_expected.to be true }
      end

      context 'when not including the value' do
        let(:actual_value) { [1, 3, 4] }

        it { is_expected.to be false }
      end
    end

    context 'with ranges' do
      let(:expected_value) { 5 }

      context 'when including the value' do
        let(:actual_value) { 1..10 }

        it { is_expected.to be true }
      end

      context 'when not including the value' do
        let(:actual_value) { 11..20 }

        it { is_expected.to be false }
      end
    end

    context 'with strings' do
      let(:expected_value) { 'b' }

      context 'when including the value' do
        let(:actual_value) { 'abc' }

        it { is_expected.to be true }
      end

      context 'when not including the value' do
        let(:actual_value) { 'ac' }

        it { is_expected.to be false }
      end
    end
  end

  describe '#short_description' do
    subject(:short_description) { constraint.short_description }

    let(:constraint) { described_class.new(:self).expecting(42) }

    it { is_expected.to eq('including 42') }
  end

  describe '#short_violation_description' do
    subject(:short_violation_description) do
      constraint.satisfied?(actual_value)
      constraint.short_violation_description
    end

    let(:constraint) { described_class.new(:self).expecting(42) }
    let(:actual_value) { [] }

    it { is_expected.to eq('excluding 42') }
  end
end
