# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/constraints/type_constraint'

RSpec.describe Domainic::Type::Constraint::TypeConstraint do
  shared_examples 'coerces and validates expectation' do
    context 'when the expected type is valid' do
      let(:expected_type) { String }

      it { expect { subject }.not_to raise_error }
    end

    context 'when the expected type is nil' do
      let(:expected_type) { nil }

      it { expect { subject }.not_to raise_error }
    end

    context 'when the expected type is invalid', rbs: :skip do
      let(:expected_type) { 'not a class, module, or type' }

      it { expect { subject }.to raise_error(ArgumentError, /must be a Class, Module, or Domainic::Type/) }
    end
  end

  describe '.new' do
    subject(:constraint) { described_class.new(:self, expected_type) }

    include_examples 'coerces and validates expectation'
  end

  describe '#expecting' do
    subject(:expecting) { constraint.expecting(expected_type) }

    let(:constraint) { described_class.new(:self) }

    include_examples 'coerces and validates expectation'
  end

  describe '#satisfied?' do
    subject(:satisfied?) { constraint.satisfied?(actual_value) }

    let(:constraint) { described_class.new(:self, expected_type) }

    context 'when the actual value is an instance of the expected type' do
      let(:expected_type) { Integer }
      let(:actual_value) { 42 }

      it { is_expected.to be true }
    end

    context 'when the actual value is not an instance of the expected type' do
      let(:expected_type) { Integer }
      let(:actual_value) { 3.14 }

      it { is_expected.to be false }
    end
  end

  describe '#short_description' do
    subject(:short_description) { constraint.short_description }

    let(:constraint) { described_class.new(:self, expected_type) }
    let(:expected_type) { Array }

    it { is_expected.to eq('Array') }
  end

  describe '#short_violation_description' do
    subject(:short_violation_description) { constraint.short_violation_description }

    before do
      constraint.satisfied?(actual_value)
    end

    let(:constraint) { described_class.new(:self, expected_type) }
    let(:actual_value) { [] }
    let(:expected_type) { Integer }

    it { is_expected.to eq(actual_value.class.to_s) }
  end
end
