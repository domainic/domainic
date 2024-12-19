# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/behavior'
require 'domainic/type/constraint/constraints/logical/not_constraint'

RSpec.describe Domainic::Type::Constraint::NotConstraint do
  let(:inner_constraint) do
    Class.new do
      include Domainic::Type::Constraint::Behavior

      def satisfied?(_value) = true

      def short_description = 'be a string'

      def short_violation_description = 'was a string'
    end.new(:self)
  end

  shared_examples 'validates inner constraint' do
    context 'when given a valid constraint' do
      let(:expectation) { inner_constraint }

      it { expect { subject }.not_to raise_error }
    end

    context 'when given an invalid constraint', rbs: :skip do
      let(:expectation) { 'not a constraint' }

      it { expect { subject }.to raise_error(ArgumentError, /expected a Domainic::Type::Constraint/) }
    end
  end

  describe '#expecting' do
    subject(:expecting) { constraint.expecting(expectation) }

    let(:constraint) { described_class.new(:self) }

    include_examples 'validates inner constraint'
  end

  describe '#satisfied?' do
    subject(:satisfied?) { constraint.satisfied?(value) }

    let(:constraint) { described_class.new(:self).expecting(inner_constraint) }

    context 'when inner constraint is satisfied' do
      let(:inner_constraint) do
        Class.new do
          include Domainic::Type::Constraint::Behavior

          def satisfied?(_value) = true
        end.new(:self)
      end

      let(:value) { 'test' }

      it { is_expected.to be false }
    end

    context 'when inner constraint is not satisfied' do
      let(:inner_constraint) do
        Class.new do
          include Domainic::Type::Constraint::Behavior

          def satisfied?(_value) = false
        end.new(:self)
      end

      let(:value) { 123 }

      it { is_expected.to be true }
    end
  end

  describe '#short_description' do
    subject(:short_description) { constraint.short_description }

    let(:constraint) { described_class.new(:self).expecting(inner_constraint) }

    it 'negates the inner constraint short_description' do
      expect(short_description).to eq('not be a string')
    end
  end

  describe '#short_violation_description' do
    subject(:short_violation_description) { constraint.short_violation_description }

    let(:constraint) { described_class.new(:self).expecting(inner_constraint) }
    let(:value) { 'test' }

    before { constraint.satisfied?(value) }

    it 'negates the inner constraint failure short_description' do
      expect(short_violation_description).to eq('be a string')
    end
  end
end
