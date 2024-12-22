# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/behavior'
require 'domainic/type/constraint/constraints/nor_constraint'

RSpec.describe Domainic::Type::Constraint::NorConstraint do
  let(:string_constraint) do
    Class.new do
      include Domainic::Type::Constraint::Behavior

      def satisfied?(value) = value.is_a?(String)
      def short_description = 'be a string'
      def short_violation_description = 'was a string'
    end.new(:self)
  end

  let(:negative_number_constraint) do
    Class.new do
      include Domainic::Type::Constraint::Behavior

      def satisfied?(value) = value.is_a?(Numeric) && value.negative?
      def short_description = 'be a negative number'
      def short_violation_description = 'was a negative number'
    end.new(:self)
  end

  shared_examples 'validates constraints array' do
    context 'when given valid constraints as an array' do
      let(:expectation) { [string_constraint, negative_number_constraint] }

      it { expect { subject }.not_to raise_error }
    end

    context 'when given an invalid constraint in the array', rbs: :skip do
      let(:expectation) { ['not a constraint', string_constraint] }

      it { expect { subject }.to raise_error(ArgumentError, /must be a Domainic::Type::Constraint/) }
    end

    context 'when given a single invalid constraint', rbs: :skip do
      let(:expectation) { 'not a constraint' }

      it { expect { subject }.to raise_error(ArgumentError, /must be a Domainic::Type::Constraint/) }
    end
  end

  describe '#expecting' do
    subject(:expecting) { constraint.expecting(expectation) }

    let(:constraint) { described_class.new(:self) }

    include_examples 'validates constraints array'

    context 'when adding valid constraints incrementally' do
      let(:expectation) { [string_constraint] }

      it 'adds the constraints to the list' do
        expecting
        expect(constraint.short_description).to eq('be a string')
      end

      context 'when adding another valid constraint' do
        let(:expectation) { [negative_number_constraint] }

        it 'appends the new constraint and updates the description' do
          constraint.expecting([string_constraint])
          expecting
          expect(constraint.short_description).to eq('be a string nor be a negative number')
        end
      end
    end

    context 'when adding multiple valid constraints at once' do
      let(:expectation) { [string_constraint, negative_number_constraint] }

      it 'adds all constraints to the list and updates the description' do
        expecting
        expect(constraint.short_description).to eq('be a string nor be a negative number')
      end
    end
  end

  describe '#satisfied?' do
    subject(:satisfied?) { constraint.satisfied?(actual_value) }

    let(:constraint) { described_class.new(:self).expecting([string_constraint, negative_number_constraint]) }

    context 'when none of the constraints are satisfied' do
      let(:actual_value) { 123 }

      it { is_expected.to be true }
    end

    context 'when the first constraint is satisfied' do
      let(:actual_value) { 'a string' }

      it { is_expected.to be false }
    end

    context 'when the second constraint is satisfied' do
      let(:actual_value) { -5 }

      it { is_expected.to be false }
    end

    context 'when multiple constraints are satisfied' do
      let(:actual_value) { 'string' } # Only string_constraint is satisfied

      it { is_expected.to be false }
    end

    context 'when the value is not a string nor a negative number' do
      let(:actual_value) { 10 }

      it { is_expected.to be true }
    end

    context 'when the value is nil' do
      let(:actual_value) { nil }

      it { is_expected.to be true }
    end
  end

  describe '#short_description' do
    subject(:short_description) { constraint.short_description }

    let(:constraint) { described_class.new(:self).expecting([string_constraint, negative_number_constraint]) }

    it 'joins constraint short_descriptions with nor' do
      expect(short_description).to eq('be a string nor be a negative number')
    end

    context 'with a single constraint' do
      let(:constraint) { described_class.new(:self).expecting([string_constraint]) }

      it 'returns the single constraint short_description' do
        expect(short_description).to eq('be a string')
      end
    end
  end

  describe '#short_violation_description' do
    subject(:short_violation_description) { constraint.short_violation_description }

    let(:constraint) { described_class.new(:self).expecting([string_constraint, negative_number_constraint]) }

    before { constraint.satisfied?(actual_value) }

    context 'when the value is not a string nor a negative number' do
      let(:actual_value) { 123 }

      it 'returns an empty string' do
        expect(short_violation_description).to eq('')
      end
    end

    context 'when one constraint is satisfied' do
      let(:actual_value) { 'a string' }

      it 'includes the violated constraint description' do
        expect(short_violation_description).to eq('was a string')
      end
    end

    context 'when another single constraint is satisfied' do
      let(:actual_value) { -10 }

      it 'includes the violated constraint description' do
        expect(short_violation_description).to eq('was a negative number')
      end
    end

    context 'when multiple constraints are satisfied' do
      let(:actual_value) { 'a string' } # Only string_constraint is satisfied

      it 'includes all violated constraint descriptions separated by commas' do
        expect(short_violation_description).to eq('was a string')
      end
    end

    context 'when all constraints are satisfied by the value' do
      let(:actual_value) { 'a string' } # Only string_constraint is satisfied

      it 'includes all violated constraint descriptions without duplication' do
        expect(short_violation_description).to eq('was a string')
      end
    end
  end
end
