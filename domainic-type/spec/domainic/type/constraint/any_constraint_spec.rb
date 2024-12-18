# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/behavior'
require 'domainic/type/constraint/constraints/any_constraint'

RSpec.describe Domainic::Type::Constraint::AnyConstraint do
  let(:inner_constraint) do
    Class.new do
      include Domainic::Type::Constraint::Behavior

      def description = 'be a string'

      def violation_description = 'was not a string'

      def satisfied?(_value) = true
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

  describe '.new' do
    subject(:constraint) { described_class.new(:self, expectation) }

    include_examples 'validates inner constraint'
  end

  describe '#description' do
    subject(:description) { constraint.description }

    let(:constraint) { described_class.new(:self, inner_constraint) }

    it 'returns the inner constraint description' do
      expect(description).to eq('be a string')
    end
  end

  describe '#expecting' do
    subject(:expecting) { constraint.expecting(expectation) }

    let(:constraint) { described_class.new(:self) }

    include_examples 'validates inner constraint'
  end

  describe '#satisfied?' do
    subject(:satisfied?) { constraint.satisfied?(actual_value) }

    let(:constraint) { described_class.new(:self, inner_constraint) }

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

      it { is_expected.to be true }
    end

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

      it { is_expected.to be false }
    end

    context 'when the value is not enumerable' do
      let(:actual_value) { nil }

      it { is_expected.to be false }
    end
  end

  describe '#violation_description' do
    subject(:violation_description) { constraint.violation_description }

    let(:constraint) { described_class.new(:self, inner_constraint) }

    before { constraint.satisfied?(actual_value) }

    context 'when the value is not enumerable' do
      let(:actual_value) { nil }

      it { is_expected.to eq('not Enumerable') }
    end

    context 'when no elements satisfy the constraint' do
      let(:actual_value) { [1, 2, 3] }
      let(:inner_constraint) do
        Class.new do
          include Domainic::Type::Constraint::Behavior

          def violation_description = 'was not a string'

          def satisfied?(value)
            value.is_a?(String)
          end
        end.new(:self)
      end

      it { is_expected.to eq('was not a string') }
    end
  end
end
