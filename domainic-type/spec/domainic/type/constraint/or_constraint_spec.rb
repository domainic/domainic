# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/behavior'
require 'domainic/type/constraint/constraints/or_constraint'

RSpec.describe Domainic::Type::Constraint::OrConstraint do
  let(:string_constraint) do
    Class.new do
      include Domainic::Type::Constraint::Behavior

      def short_description = 'be a string'
      def short_violation_description = 'was not a string'
      def satisfied?(value) = value.is_a?(String)
    end.new(:self)
  end

  let(:symbol_constraint) do
    Class.new do
      include Domainic::Type::Constraint::Behavior

      def short_description = 'be a symbol'
      def short_violation_description = 'was not a symbol'
      def satisfied?(value) = value.is_a?(Symbol)
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

  describe '#expecting' do
    subject(:expecting) { constraint.expecting(expectation) }

    let(:constraint) { described_class.new(:self, [string_constraint]) }

    context 'when adding a valid constraint' do
      let(:expectation) { symbol_constraint }

      it 'adds the constraint to the list' do
        expecting
        expect(constraint.short_description).to eq('be a string or be a symbol')
      end
    end

    context 'when adding an invalid constraint', rbs: :skip do
      let(:expectation) { 'not a constraint' }

      it { expect { expecting }.to raise_error(ArgumentError, /must be a Domainic::Type::Constraint/) }
    end
  end

  describe '#satisfied?' do
    subject(:satisfied?) { constraint.satisfied?(actual_value) }

    let(:constraint) { described_class.new(:self, [string_constraint, symbol_constraint]) }

    context 'when value satisfies no constraints' do
      let(:actual_value) { 123 }

      it { is_expected.to be false }
    end

    context 'when value satisfies first constraint' do
      let(:actual_value) { 'test' }

      it { is_expected.to be true }
    end

    context 'when value satisfies second constraint' do
      let(:actual_value) { :test }

      it { is_expected.to be true }
    end
  end

  describe '#short_description' do
    subject(:short_description) { constraint.short_description }

    let(:constraint) { described_class.new(:self, [string_constraint, symbol_constraint]) }

    it 'joins constraint short_descriptions with or' do
      expect(short_description).to eq('be a string or be a symbol')
    end
  end

  describe '#short_violation_description' do
    subject(:short_violation_description) { constraint.short_violation_description }

    let(:constraint) { described_class.new(:self, [string_constraint, symbol_constraint]) }

    before { constraint.satisfied?(actual_value) }

    context 'when no constraints are satisfied' do
      let(:actual_value) { 123 }

      it 'joins violation short_descriptions with and' do
        expect(short_violation_description).to eq('was not a string and was not a symbol')
      end
    end
  end
end
