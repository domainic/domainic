# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/behavior'

RSpec.describe Domainic::Type::Constraint::Behavior do
  let(:dummy_class) do
    Class.new do
      include Domainic::Type::Constraint::Behavior

      def description
        'test constraint'
      end

      def failure_description
        'test failure'
      end

      protected

      def satisfies_constraint?
        @actual == @expected
      end
    end
  end

  let(:constraint) { dummy_class.new(:self) }

  describe '.new' do
    subject(:initializer) { dummy_class.new(accessor, expectation, **options) }

    let(:accessor) { :self }
    let(:expectation) { nil }
    let(:options) { {} }

    context 'when given an invalid accessor', rbs: :skip do
      let(:accessor) { :invalid }

      it 'is expected to raise ArgumentError' do
        expect { initializer }.to raise_error(
          ArgumentError,
          'Invalid accessor: invalid must be one of begin, count, end, first, keys, last, length, self, size, values'
        )
      end
    end

    context 'when given a valid accessor', rbs: :skip do
      described_class::VALID_ACCESSORS.each do |valid_accessor|
        context "with #{valid_accessor}" do
          let(:accessor) { valid_accessor }

          it { expect { initializer }.not_to raise_error }
        end
      end
    end

    context 'when the implementing class validates expectations' do
      let(:dummy_class) do
        Class.new do
          include Domainic::Type::Constraint::Behavior

          protected

          def satisfies_constraint?
            true
          end

          def validate_expectation!(expectation)
            raise ArgumentError, 'invalid expectation' unless expectation.is_a?(String)
          end
        end
      end

      context 'when given an invalid expectation', rbs: :skip do
        let(:expectation) { 1 }

        it { expect { initializer }.to raise_error(ArgumentError, 'invalid expectation') }
      end

      context 'when given a valid expectation' do
        let(:expectation) { 'valid' }

        it { expect { initializer }.not_to raise_error }
      end
    end
  end

  describe '#abort_on_failure?' do
    subject(:abort_on_failure) { constraint.abort_on_failure? }

    context 'when initialized with abort_on_failure: true' do
      let(:constraint) { dummy_class.new(:self, nil, abort_on_failure: true) }

      it { is_expected.to be true }
    end

    context 'when initialized without abort_on_failure option' do
      it { is_expected.to be false }
    end
  end

  describe '#description' do
    subject(:description) { constraint.description }

    context 'when the implementing class does not override description' do
      let(:dummy_class) do
        Class.new do
          include Domainic::Type::Constraint::Behavior

          protected

          def satisfies_constraint?
            true
          end
        end
      end

      it { is_expected.to eq('') }
    end

    context 'when the implementing class overrides description' do
      it { is_expected.to eq('test constraint') }
    end
  end

  describe '#expecting' do
    subject(:expecting) { constraint.expecting(expectation) }

    let(:expectation) { 'test' }

    it 'is expected to set the expected value' do
      expect { expecting }.to change { constraint.instance_variable_get(:@expected) }.from(nil).to('test')
    end

    it 'is expected to return self' do
      expect(expecting).to be constraint
    end

    context 'when the implementing class validates expectations' do
      let(:dummy_class) do
        Class.new do
          include Domainic::Type::Constraint::Behavior

          protected

          def satisfies_constraint?
            true
          end

          def validate_expectation!(expectation)
            raise ArgumentError, 'invalid expectation' unless expectation.is_a?(String)
          end
        end
      end

      context 'when given an invalid expectation' do
        let(:expectation) { 1 }

        it { expect { expecting }.to raise_error(ArgumentError, 'invalid expectation') }
      end
    end

    context 'when the implementing class coerces expectations' do
      let(:dummy_class) do
        Class.new do
          include Domainic::Type::Constraint::Behavior

          protected

          def satisfies_constraint?
            true
          end

          def coerce_expectation(expectation)
            expectation.to_s
          end
        end
      end

      let(:expectation) { 1 }

      it 'is expected to coerce the expectation' do
        expect { expecting }.to change { constraint.instance_variable_get(:@expected) }.from(nil).to('1')
      end
    end
  end

  describe '#failure_description' do
    subject(:failure_description) { constraint.failure_description }

    context 'when the implementing class does not override failure_description' do
      let(:dummy_class) do
        Class.new do
          include Domainic::Type::Constraint::Behavior

          protected

          def satisfies_constraint?
            true
          end
        end
      end

      it { is_expected.to eq('') }
    end

    context 'when the implementing class overrides failure_description' do
      it { is_expected.to eq('test failure') }
    end
  end

  describe '#satisfied?' do
    subject(:satisfied) { constraint.satisfied?(value) }

    let(:value) { 'test' }

    context 'when using the :self accessor' do
      let(:constraint) { dummy_class.new(:self, 'test') }

      it 'is expected to be satisfied when the value equals the expectation' do
        expect(satisfied).to be true
      end

      it 'is expected to not be satisfied when the value does not equal the expectation' do
        expect(constraint.satisfied?('other')).to be false
      end
    end

    context 'when using a different accessor' do
      let(:constraint) { dummy_class.new(:length, 4) }

      it 'is expected to be satisfied when the accessed value equals the expectation' do
        expect(satisfied).to be true
      end

      it 'is expected to not be satisfied when the accessed value does not equal the expectation' do
        expect(constraint.satisfied?('other value')).to be false
      end
    end

    context 'when the implementing class coerces actual values' do
      let(:dummy_class) do
        Class.new do
          include Domainic::Type::Constraint::Behavior

          protected

          def satisfies_constraint?
            @actual == @expected
          end

          def coerce_actual(actual)
            actual.to_s
          end
        end
      end

      let(:constraint) { dummy_class.new(:self, '1') }
      let(:value) { 1 }

      it 'is expected to coerce the actual value' do
        expect(satisfied).to be true
      end
    end

    context 'when satisfies_constraint? raises an error' do
      let(:dummy_class) do
        Class.new do
          include Domainic::Type::Constraint::Behavior

          protected

          def satisfies_constraint?
            raise StandardError
          end
        end
      end

      it 'is expected to return false' do
        expect(satisfied).to be false
      end
    end
  end

  describe '#type_failure?' do
    subject(:type_failure) { constraint.type_failure? }

    context 'when initialized with is_type_failure: true' do
      let(:constraint) { dummy_class.new(:self, nil, is_type_failure: true) }

      it { is_expected.to be true }
    end

    context 'when initialized without is_type_failure option' do
      it { is_expected.to be false }
    end
  end

  describe '#with_options' do
    subject(:with_options) { constraint.with_options(**options) }

    let(:options) { { abort_on_failure: true, is_type_failure: true } }

    it 'is expected to update the options' do
      expect { with_options }
        .to change(constraint, :abort_on_failure?).from(false).to(true)
                                                  .and change(constraint, :type_failure?).from(false).to(true)
    end

    it 'is expected to return self' do
      expect(with_options).to be constraint
    end
  end
end
