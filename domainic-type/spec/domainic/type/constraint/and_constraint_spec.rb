# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/behavior'
require 'domainic/type/constraint/constraints/and_constraint'

RSpec.describe Domainic::Type::Constraint::AndConstraint do
  let(:string_constraint) do
    Class.new do
      include Domainic::Type::Constraint::Behavior

      def description = 'be a string'
      def violation_description = 'was not a string'
      def satisfied?(value) = value.is_a?(String)
    end.new(:self)
  end

  let(:non_empty_constraint) do
    Class.new do
      include Domainic::Type::Constraint::Behavior

      def description = 'be non-empty'
      def violation_description = 'was empty'
      def satisfied?(value) = !value.empty?
    end.new(:self)
  end

  shared_examples 'validates constraints array' do
    context 'when given valid constraints' do
      let(:expectation) { [string_constraint] }

      it { expect { subject }.not_to raise_error }
    end

    context 'when given an invalid constraint', rbs: :skip do
      let(:expectation) { ['not a constraint'] }

      it { expect { subject }.to raise_error(ArgumentError, /must be a Domainic::Type::Constraint/) }
    end
  end

  describe '.new' do
    subject(:constraint) { described_class.new(:self, expectation) }

    include_examples 'validates constraints array'
  end

  describe '#description' do
    subject(:description) { constraint.description }

    let(:constraint) { described_class.new(:self, [string_constraint, non_empty_constraint]) }

    it 'joins constraint descriptions with and' do
      expect(description).to eq('be a string and be non-empty')
    end
  end

  describe '#expecting' do
    subject(:expecting) { constraint.expecting(expectation) }

    let(:constraint) { described_class.new(:self, [string_constraint]) }

    context 'when adding a valid constraint' do
      let(:expectation) { non_empty_constraint }

      it 'adds the constraint to the list' do
        expecting
        expect(constraint.description).to eq('be a string and be non-empty')
      end
    end

    context 'when adding an invalid constraint', rbs: :skip do
      let(:expectation) { 'not a constraint' }

      it { expect { expecting }.to raise_error(ArgumentError, /must be a Domainic::Type::Constraint/) }
    end
  end

  describe '#satisfied?' do
    subject(:satisfied?) { constraint.satisfied?(actual_value) }

    let(:constraint) { described_class.new(:self, [string_constraint, non_empty_constraint]) }

    context 'when all constraints are satisfied' do
      let(:actual_value) { 'test' }

      it { is_expected.to be true }
    end

    context 'when first constraint fails' do
      let(:actual_value) { 123 }

      it { is_expected.to be false }
    end

    context 'when second constraint fails' do
      let(:actual_value) { '' }

      it { is_expected.to be false }
    end

    context 'when all constraints fail' do
      let(:actual_value) { [] }

      it { is_expected.to be false }
    end
  end

  describe '#violation_description' do
    subject(:violation_description) { constraint.violation_description }

    let(:constraint) { described_class.new(:self, [string_constraint, non_empty_constraint]) }

    before { constraint.satisfied?(actual_value) }

    context 'when no constraints are satisfied' do
      let(:actual_value) { 123 }

      it 'joins violation descriptions with and' do
        expect(violation_description).to eq('was not a string and was empty')
      end
    end
  end
end
