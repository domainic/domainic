# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/behavior'
require 'domainic/type/constraint/constraints/logical/and_constraint'

RSpec.describe Domainic::Type::Constraint::AndConstraint do
  let(:string_constraint) do
    Class.new do
      include Domainic::Type::Constraint::Behavior

      def satisfied?(value) = value.is_a?(String)
      def short_description = 'be a string'
      def short_violation_description = 'was not a string'
    end.new(:self)
  end

  let(:non_empty_constraint) do
    Class.new do
      include Domainic::Type::Constraint::Behavior

      def satisfied?(value) = !value.empty?
      def short_description = 'be non-empty'
      def short_violation_description = 'was empty'
    end.new(:self)
  end

  shared_examples 'validates constraints array' do
    context 'when given valid constraints' do
      let(:expectation) { string_constraint }

      it { expect { subject }.not_to raise_error }
    end

    context 'when given an invalid constraint', rbs: :skip do
      let(:expectation) { ['not a constraint'] }

      it { expect { subject }.to raise_error(ArgumentError, /must be a Domainic::Type::Constraint/) }
    end
  end

  describe '#expecting' do
    subject(:expecting) { constraint.expecting(expectation) }

    let(:constraint) { described_class.new(:self).expecting(string_constraint) }

    context 'when adding a valid constraint' do
      let(:expectation) { non_empty_constraint }

      it 'adds the constraint to the list' do
        expecting
        expect(constraint.short_description).to eq('be a string and be non-empty')
      end
    end

    context 'when adding an invalid constraint', rbs: :skip do
      let(:expectation) { 'not a constraint' }

      it { expect { expecting }.to raise_error(ArgumentError, /must be a Domainic::Type::Constraint/) }
    end
  end

  describe '#satisfied?' do
    subject(:satisfied?) { constraint.satisfied?(actual_value) }

    let(:constraint) { described_class.new(:self).expecting(string_constraint).expecting(non_empty_constraint) }

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

  describe '#short_description' do
    subject(:short_description) { constraint.short_description }

    let(:constraint) { described_class.new(:self).expecting(string_constraint).expecting(non_empty_constraint) }

    it 'joins constraint short_descriptions with and' do
      expect(short_description).to eq('be a string and be non-empty')
    end
  end

  describe '#short_violation_description' do
    subject(:short_violation_description) { constraint.short_violation_description }

    let(:constraint) { described_class.new(:self).expecting(string_constraint).expecting(non_empty_constraint) }

    before { constraint.satisfied?(actual_value) }

    context 'when no constraints are satisfied' do
      let(:actual_value) { [] }

      it 'joins violation short_descriptions with and' do
        expect(short_violation_description).to eq('was not a string and was empty')
      end
    end
  end
end
