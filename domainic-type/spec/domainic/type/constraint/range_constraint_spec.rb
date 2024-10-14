# frozen_string_literal: true

# spec/domainic/type/constraint/range_constraint_spec.rb

require 'spec_helper'
require 'date'
require 'domainic/type/base_type'
require 'domainic/type/constraint/range_constraint'

RSpec.describe Domainic::Type::Constraint::RangeConstraint do
  let(:constraint) { described_class.new(instance_double(Domainic::Type::BaseType)) }

  describe '#validate' do
    subject(:validate) { constraint.validate(subject_value) }

    context 'when subject is a numeric value' do
      let(:subject_value) { value }

      context 'with default parameters' do
        let(:value) { 5 }

        it { is_expected.to be true }
      end

      context 'when minimum and maximum are specified' do
        before do
          constraint.minimum = 1
          constraint.maximum = 10
        end

        context 'when value is within the range' do
          let(:value) { 5 }

          it { is_expected.to be true }
        end

        context 'when value is equal to the minimum' do
          let(:value) { 1 }

          it { is_expected.to be true }
        end

        context 'when value is equal to the maximum' do
          let(:value) { 10 }

          it { is_expected.to be true }
        end

        context 'when value is less than the minimum' do
          let(:value) { 0 }

          it { is_expected.to be false }
        end

        context 'when value is greater than the maximum' do
          let(:value) { 11 }

          it { is_expected.to be false }
        end
      end

      context 'when range is exclusive' do
        before do
          constraint.minimum = 1
          constraint.maximum = 10
          constraint.inclusive = false
        end

        context 'when value is within the range' do
          let(:value) { 5 }

          it { is_expected.to be true }
        end

        context 'when value is equal to the minimum' do
          let(:value) { 1 }

          it { is_expected.to be false }
        end

        context 'when value is equal to the maximum' do
          let(:value) { 10 }

          it { is_expected.to be false }
        end

        context 'when value is less than the minimum' do
          let(:value) { 0 }

          it { is_expected.to be false }
        end

        context 'when value is greater than the maximum' do
          let(:value) { 11 }

          it { is_expected.to be false }
        end
      end
    end

    context 'when subject is a Date' do
      let(:subject_value) { value }

      context 'with minimum and maximum dates specified' do
        before do
          constraint.minimum = Date.new(2020, 1, 1)
          constraint.maximum = Date.new(2020, 12, 31)
        end

        context 'when date is within the range' do
          let(:value) { Date.new(2020, 6, 15) }

          it { is_expected.to be true }
        end

        context 'when date is equal to the minimum' do
          let(:value) { Date.new(2020, 1, 1) }

          it { is_expected.to be true }
        end

        context 'when date is equal to the maximum' do
          let(:value) { Date.new(2020, 12, 31) }

          it { is_expected.to be true }
        end

        context 'when date is before the minimum' do
          let(:value) { Date.new(2019, 12, 31) }

          it { is_expected.to be false }
        end

        context 'when date is after the maximum' do
          let(:value) { Date.new(2021, 1, 1) }

          it { is_expected.to be false }
        end
      end

      context 'when range is exclusive' do
        before do
          constraint.minimum = Date.new(2020, 1, 1)
          constraint.maximum = Date.new(2020, 12, 31)
          constraint.inclusive = false
        end

        context 'when date is within the range' do
          let(:value) { Date.new(2020, 6, 15) }

          it { is_expected.to be true }
        end

        context 'when date is equal to the minimum' do
          let(:value) { Date.new(2020, 1, 1) }

          it { is_expected.to be false }
        end

        context 'when date is equal to the maximum' do
          let(:value) { Date.new(2020, 12, 31) }

          it { is_expected.to be false }
        end
      end
    end

    context 'when subject is a Time' do
      let(:subject_value) { value }

      context 'with minimum and maximum times specified' do
        before do
          constraint.minimum = Time.new(2020, 1, 1, 0, 0, 0)
          constraint.maximum = Time.new(2020, 1, 1, 23, 59, 59)
        end

        context 'when time is within the range' do
          let(:value) { Time.new(2020, 1, 1, 12, 0, 0) }

          it { is_expected.to be true }
        end

        context 'when time is equal to the minimum' do
          let(:value) { Time.new(2020, 1, 1, 0, 0, 0) }

          it { is_expected.to be true }
        end

        context 'when time is equal to the maximum' do
          let(:value) { Time.new(2020, 1, 1, 23, 59, 59) }

          it { is_expected.to be true }
        end

        context 'when time is before the minimum' do
          let(:value) { Time.new(2019, 12, 31, 23, 59, 59) }

          it { is_expected.to be false }
        end

        context 'when time is after the maximum' do
          let(:value) { Time.new(2020, 1, 2, 0, 0, 0) }

          it { is_expected.to be false }
        end
      end

      context 'when range is exclusive' do
        before do
          constraint.minimum = Time.new(2020, 1, 1, 0, 0, 0)
          constraint.maximum = Time.new(2020, 1, 1, 23, 59, 59)
          constraint.inclusive = false
        end

        context 'when time is within the range' do
          let(:value) { Time.new(2020, 1, 1, 12, 0, 0) }

          it { is_expected.to be true }
        end

        context 'when time is equal to the minimum' do
          let(:value) { Time.new(2020, 1, 1, 0, 0, 0) }

          it { is_expected.to be false }
        end

        context 'when time is equal to the maximum' do
          let(:value) { Time.new(2020, 1, 1, 23, 59, 59) }

          it { is_expected.to be false }
        end
      end
    end

    context 'when negated' do
      before do
        constraint.negated = true
        constraint.minimum = 1
        constraint.maximum = 10
      end

      context 'when value is within the range' do
        let(:subject_value) { 5 }

        it { is_expected.to be false }
      end

      context 'when value is outside the range' do
        let(:subject_value) { 11 }

        it { is_expected.to be true }
      end
    end

    context 'when subject is an enumerable and access_qualifier is set' do
      before do
        constraint.minimum = 1
        constraint.maximum = 10
        constraint.access_qualifier = :all?
      end

      context 'when all elements are within the range' do
        let(:subject_value) { [2, 3, 4] }

        it { is_expected.to be true }
      end

      context 'when not all elements are within the range' do
        let(:subject_value) { [2, 3, 11] }

        it { is_expected.to be false }
      end
    end

    context 'when minimum is greater than maximum' do
      before do
        constraint.minimum = 10
        constraint.maximum = 1
      end

      let(:subject_value) { 5 }

      it { is_expected.to be false }
    end

    context 'when minimum and maximum are not compatible types' do
      before do
        constraint.minimum = 1
        constraint.maximum = Date.new(2020, 1, 1)
      end

      let(:subject_value) { 5 }

      it { is_expected.to be false }
    end
  end
end
