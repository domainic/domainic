# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/constraints/case_constraint'

RSpec.describe Domainic::Type::Constraint::CaseConstraint do
  describe '#expecting' do
    subject(:constraint) { described_class.new(:self).expecting(expectation) }

    context 'when given a valid case format' do
      let(:expectation) { :upper }

      it { is_expected.to be_a(described_class) }
    end

    context 'when given an invalid case format' do
      let(:expectation) { :invalid }

      it 'is expected to raise an ArgumentError', rbs: :skip do
        expect { constraint }.to raise_error(
          ArgumentError,
          'case must be one of: upper, lower, mixed, title'
        )
      end
    end
  end

  describe '#satisfied?' do
    subject(:satisfied?) { constraint.satisfied?(actual_value) }

    let(:constraint) { described_class.new(:self).expecting(expected_value) }

    context 'when expecting upper case' do
      let(:expected_value) { :upper }

      context 'when matching the case' do
        let(:actual_value) { 'HELLO WORLD' }

        it { is_expected.to be true }
      end

      context 'when not matching the case' do
        let(:actual_value) { 'Hello World' }

        it { is_expected.to be false }
      end
    end

    context 'when expecting lower case' do
      let(:expected_value) { :lower }

      context 'when matching the case' do
        let(:actual_value) { 'hello world' }

        it { is_expected.to be true }
      end

      context 'when not matching the case' do
        let(:actual_value) { 'Hello World' }

        it { is_expected.to be false }
      end
    end

    context 'when expecting mixed case' do
      let(:expected_value) { :mixed }

      context 'when matching the case' do
        let(:actual_value) { 'helloWORLD' }

        it { is_expected.to be true }
      end

      context 'when not matching the case (all uppercase)' do
        let(:actual_value) { 'HELLO' }

        it { is_expected.to be false }
      end

      context 'when not matching the case (all lowercase)' do
        let(:actual_value) { 'hello' }

        it { is_expected.to be false }
      end
    end

    context 'when expecting title case' do
      let(:expected_value) { :title }

      context 'when matching the case' do
        let(:actual_value) { 'Hello World' }

        it { is_expected.to be true }
      end

      context 'when not matching the case' do
        let(:actual_value) { 'hello world' }

        it { is_expected.to be false }
      end

      context 'when matching with multiple spaces' do
        let(:actual_value) { 'Hello   World' }

        it { is_expected.to be true }
      end
    end
  end

  describe '#short_description' do
    subject(:short_description) { constraint.short_description }

    let(:constraint) { described_class.new(:self).expecting(:upper) }

    it { is_expected.to eq('upper case') }
  end

  describe '#short_violation_description' do
    subject(:short_violation_description) do
      constraint.satisfied?(actual_value)
      constraint.short_violation_description
    end

    let(:constraint) { described_class.new(:self).expecting(:upper) }
    let(:actual_value) { 'Hello' }

    it { is_expected.to eq('not upper case') }
  end
end
