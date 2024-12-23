# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/constraints/character_set_constraint'

RSpec.describe Domainic::Type::Constraint::CharacterSetConstraint do
  describe '#expecting' do
    subject(:constraint) { described_class.new(:self).expecting(expectation) }

    context 'when given a valid set name' do
      let(:expectation) { :ascii }

      it { is_expected.to be_a(described_class) }
    end

    context 'when given an invalid set name', rbs: :skip do
      let(:expectation) { :invalid }

      it 'is expected to raise an ArgumentError' do
        expect { constraint }.to raise_error(
          ArgumentError,
          'set must be one of: ascii, alphanumeric, alpha, numeric, printable'
        )
      end
    end
  end

  describe '#satisfied?' do
    subject(:satisfied?) { constraint.satisfied?(actual_value) }

    let(:constraint) { described_class.new(:self).expecting(expected_value) }

    context 'when expecting ascii characters' do
      let(:expected_value) { :ascii }

      context 'when matching the set' do
        let(:actual_value) { 'Hello World 123!' }

        it { is_expected.to be true }
      end

      context 'when not matching the set' do
        let(:actual_value) { 'héllo' }

        it { is_expected.to be false }
      end
    end

    context 'when expecting alphanumeric characters' do
      let(:expected_value) { :alphanumeric }

      context 'when matching the set' do
        let(:actual_value) { 'abc123' }

        it { is_expected.to be true }
      end

      context 'when not matching the set' do
        let(:actual_value) { 'abc-123' }

        it { is_expected.to be false }
      end
    end

    context 'when expecting alpha characters' do
      let(:expected_value) { :alpha }

      context 'when matching the set' do
        let(:actual_value) { 'abcDEF' }

        it { is_expected.to be true }
      end

      context 'when not matching the set' do
        let(:actual_value) { 'abc123' }

        it { is_expected.to be false }
      end
    end

    context 'when expecting numeric characters' do
      let(:expected_value) { :numeric }

      context 'when matching the set' do
        let(:actual_value) { '12345' }

        it { is_expected.to be true }
      end

      context 'when not matching the set' do
        let(:actual_value) { '123.45' }

        it { is_expected.to be false }
      end
    end

    context 'when expecting printable characters' do
      let(:expected_value) { :printable }

      context 'when matching the set' do
        let(:actual_value) { 'Hello World! @#$%' }

        it { is_expected.to be true }
      end

      context 'when not matching the set' do
        let(:actual_value) { "Hello\x00World" }

        it { is_expected.to be false }
      end
    end
  end

  describe '#short_description' do
    subject(:short_description) { constraint.short_description }

    let(:constraint) { described_class.new(:self).expecting(:numeric) }

    it { is_expected.to eq('only numeric characters') }
  end

  describe '#short_violation_description' do
    subject(:short_violation_description) do
      constraint.satisfied?(actual_value)
      constraint.short_violation_description
    end

    let(:constraint) { described_class.new(:self).expecting(:numeric) }
    let(:actual_value) { 'abc123' }

    it { is_expected.to eq('non-numeric characters') }
  end
end
