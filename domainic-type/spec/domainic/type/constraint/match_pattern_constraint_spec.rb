# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/constraints/match_pattern_constraint'

RSpec.describe Domainic::Type::Constraint::MatchPatternConstraint do
  describe '#expecting' do
    subject(:constraint) { described_class.new(:self).expecting(expectation) }

    context 'when given a Regexp' do
      let(:expectation) { /\d+/ }

      it { is_expected.to be_a(described_class) }
    end

    context 'when given a String' do
      let(:expectation) { '\d+' }

      it { is_expected.to be_a(described_class) }

      it 'is expected to convert the string to a Regexp' do
        expect(constraint.instance_variable_get(:@expected)).to be_a(Regexp)
      end
    end

    context 'when given an invalid type' do
      let(:expectation) { 123 }

      it 'is expected to raise an ArgumentError', rbs: :skip do
        expect { constraint }.to raise_error(ArgumentError, 'expectation must be a Regexp')
      end
    end
  end

  describe '#satisfied?' do
    subject(:satisfied?) { constraint.satisfied?(actual_value) }

    let(:constraint) { described_class.new(:self).expecting(expected_value) }

    context 'when using a numeric pattern' do
      let(:expected_value) { /\A\d+\z/ }

      context 'when matching the pattern' do
        let(:actual_value) { '123' }

        it { is_expected.to be true }
      end

      context 'when not matching the pattern' do
        let(:actual_value) { 'abc' }

        it { is_expected.to be false }
      end
    end

    context 'when using an email pattern' do
      let(:expected_value) { /\A\w+@\w+\.\w+\z/ }

      context 'when matching the pattern' do
        let(:actual_value) { 'test@example.com' }

        it { is_expected.to be true }
      end

      context 'when not matching the pattern' do
        let(:actual_value) { 'invalid-email' }

        it { is_expected.to be false }
      end
    end
  end

  describe '#short_description' do
    subject(:short_description) { constraint.short_description }

    let(:constraint) { described_class.new(:self).expecting(/\d+/) }

    it { is_expected.to eq('matching /\\d+/') }
  end

  describe '#short_violation_description' do
    subject(:short_violation_description) do
      constraint.satisfied?(actual_value)
      constraint.short_violation_description
    end

    let(:constraint) { described_class.new(:self).expecting(/\d+/) }
    let(:actual_value) { 'abc' }

    it { is_expected.to eq('does not match /\\d+/') }
  end
end
