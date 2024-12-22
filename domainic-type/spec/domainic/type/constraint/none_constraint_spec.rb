# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/behavior'
require 'domainic/type/constraint/constraints/none_constraint'

RSpec.describe Domainic::Type::Constraint::NoneConstraint do
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
    subject(:satisfied?) { constraint.satisfied?(actual_value) }

    let(:constraint) { described_class.new(:self).expecting(inner_constraint) }

    context 'when no elements satisfy the constraint' do
      let(:actual_value) { [1, 2, 3] }
      let(:inner_constraint) do
        Class.new do
          include Domainic::Type::Constraint::Behavior

          def satisfied?(value)
            value.is_a?(String)
          end
        end.new(:self)
      end

      it { is_expected.to be true }
    end

    context 'when any element satisfies the constraint' do
      let(:actual_value) { ['a', 1, 'c'] }
      let(:inner_constraint) do
        Class.new do
          include Domainic::Type::Constraint::Behavior

          def satisfied?(value)
            value.is_a?(String)
          end
        end.new(:self)
      end

      it { is_expected.to be false }
    end

    context 'when the value is not enumerable' do
      let(:actual_value) { nil }

      it { is_expected.to be false }
    end
  end

  describe '#short_description' do
    subject(:short_description) { constraint.short_description }

    let(:constraint) { described_class.new(:self).expecting(inner_constraint) }

    it 'returns the negated inner constraint short_description' do
      expect(short_description).to eq('not be a string')
    end
  end

  describe '#short_violation_description' do
    subject(:short_violation_description) { constraint.short_violation_description }

    let(:constraint) { described_class.new(:self).expecting(inner_constraint) }

    before { constraint.satisfied?(actual_value) }

    context 'when the value is not enumerable' do
      let(:actual_value) { nil }

      it { is_expected.to eq('not Enumerable') }
    end

    context 'when any elements satisfy the constraint' do
      let(:actual_value) { ['a', 1, 'c'] }
      let(:inner_constraint) do
        Class.new do
          include Domainic::Type::Constraint::Behavior

          def satisfied?(value)
            value.is_a?(String)
          end

          def short_description = 'a string'
        end.new(:self)
      end

      it { is_expected.to eq('a string') }
    end
  end
end
