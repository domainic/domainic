# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/array_type'

RSpec.describe Domainic::Type::ArrayType do
  describe '#validate' do
    subject(:validate) { array_type.validate(subject_value) }

    let(:array_type) { described_class.new }

    context 'when the subject is not an array' do
      let(:subject_value) { '' }

      it { is_expected.to be false }
    end

    context 'when the subject is an array' do
      let(:subject_value) { [1, 2, 3] }

      it { is_expected.to be true }

      context 'when constrained to be duplicative' do
        before { array_type.being_duplicative }

        context 'when the subject is an array with duplicate values' do
          let(:subject_value) { [1, 1, 2] }

          it { is_expected.to be true }
        end

        context 'when the subject is an array without duplicate values' do
          let(:subject_value) { [1, 2, 3] }

          it { is_expected.to be false }
        end
      end

      context 'when constrained to be empty' do
        before { array_type.being_empty }

        context 'when the subject is an empty array' do
          let(:subject_value) { [] }

          it { is_expected.to be true }
        end

        context 'when the subject is a populated array' do
          let(:subject_value) { [1, 2, 3] }

          it { is_expected.to be false }
        end
      end

      context 'when constrained to be populated' do
        before { array_type.being_populated }

        context 'when the subject is a populated array' do
          let(:subject_value) { [1, 2, 3] }

          it { is_expected.to be true }
        end

        context 'when the subject is an empty array' do
          let(:subject_value) { [] }

          it { is_expected.to be false }
        end
      end

      context 'when constrained to be ordered' do
        before { array_type.being_ordered }

        context 'when the subject is an ordered array' do
          let(:subject_value) { [1, 2, 3] }

          it { is_expected.to be true }
        end

        context 'when the subject is an unordered array' do
          let(:subject_value) { [3, 2, 1] }

          it { is_expected.to be false }
        end
      end

      context 'when constrained to be unique' do
        before { array_type.being_unique }

        context 'when the subject is an array with unique values' do
          let(:subject_value) { [1, 2, 3] }

          it { is_expected.to be true }
        end

        context 'when the subject is an array with duplicate values' do
          let(:subject_value) { [1, 2, 2, 3] }

          it { is_expected.to be false }
        end
      end

      context 'when constrained to be unordered' do
        before { array_type.being_unordered }

        context 'when the subject is an unordered array' do
          let(:subject_value) { [3, 2, 1] }

          it { is_expected.to be true }
        end

        context 'when the subject is an ordered array' do
          let(:subject_value) { [1, 2, 3] }

          it { is_expected.to be false }
        end
      end

      context 'when constrained to contain certain entries' do
        before { array_type.containing(1, 2) }

        context 'when the subject contains all specified entries' do
          let(:subject_value) { [1, 2, 3] }

          it { is_expected.to be true }
        end

        context 'when the subject does not contain all specified entries' do
          let(:subject_value) { [1, 3, 4] }

          it { is_expected.to be false }
        end
      end

      context 'when constrained to exclude certain entries' do
        before { array_type.excluding(4, 5) }

        context 'when the subject does not contain excluded entries' do
          let(:subject_value) { [1, 2, 3] }

          it { is_expected.to be true }
        end

        context 'when the subject contains excluded entries' do
          let(:subject_value) { [1, 2, 4] }

          it { is_expected.to be false }
        end
      end

      context 'when constrained to have entries of a specific type' do
        before { array_type.of(Integer) }

        context 'when all entries are of the specified type' do
          let(:subject_value) { [1, 2, 3] }

          it { is_expected.to be true }
        end

        context 'when some entries are not of the specified type' do
          let(:subject_value) { [1, '2', 3] }

          it { is_expected.to be false }
        end
      end

      context 'when constrained to have an exact size' do
        before { array_type.having_exact_size(3) }

        context 'when the subject has the exact size' do
          let(:subject_value) { [1, 2, 3] }

          it { is_expected.to be true }
        end

        context 'when the subject has a different size' do
          let(:subject_value) { [1, 2] }

          it { is_expected.to be false }
        end
      end

      context 'when constrained to have a maximum size' do
        before { array_type.having_maximum_size(3) }

        context 'when the subject size is below the maximum' do
          let(:subject_value) { [1, 2] }

          it { is_expected.to be true }
        end

        context 'when the subject size equals the maximum' do
          let(:subject_value) { [1, 2, 3] }

          it { is_expected.to be true }
        end

        context 'when the subject size exceeds the maximum' do
          let(:subject_value) { [1, 2, 3, 4] }

          it { is_expected.to be false }
        end
      end

      context 'when constrained to have a minimum size' do
        before { array_type.having_minimum_size(2) }

        context 'when the subject size is above the minimum' do
          let(:subject_value) { [1, 2, 3] }

          it { is_expected.to be true }
        end

        context 'when the subject size equals the minimum' do
          let(:subject_value) { [1, 2] }

          it { is_expected.to be true }
        end

        context 'when the subject size is below the minimum' do
          let(:subject_value) { [1] }

          it { is_expected.to be false }
        end
      end

      context 'when constrained to have size between a range' do
        before { array_type.having_size_between(2, 4) }

        context 'when the subject size is within the range' do
          let(:subject_value) { [1, 2, 3] }

          it { is_expected.to be true }
        end

        context 'when the subject size is below the range' do
          let(:subject_value) { [1] }

          it { is_expected.to be false }
        end

        context 'when the subject size is above the range' do
          let(:subject_value) { [1, 2, 3, 4, 5] }

          it { is_expected.to be false }
        end
      end

      context 'when constrained to have a first entry' do
        before { array_type.having_first_entry(1) }

        context 'when the first entry matches' do
          let(:subject_value) { [1, 2, 3] }

          it { is_expected.to be true }
        end

        context 'when the first entry does not match' do
          let(:subject_value) { [2, 1, 3] }

          it { is_expected.to be false }
        end
      end

      context 'when constrained to have a last entry' do
        before { array_type.having_last_entry(3) }

        context 'when the last entry matches' do
          let(:subject_value) { [1, 2, 3] }

          it { is_expected.to be true }
        end

        context 'when the last entry does not match' do
          let(:subject_value) { [1, 3, 2] }

          it { is_expected.to be false }
        end
      end

      context 'when multiple constraints are applied, including inherited constraints' do
        before do
          array_type
            .being_unique
            .being_ordered
            .containing(1, 2)
            .having_exact_size(3)
            .of(Integer)
            .having_first_entry(1)
            .having_last_entry(3)
        end

        context 'when all constraints are satisfied' do
          let(:subject_value) { [1, 2, 3] }

          it { is_expected.to be true }
        end

        context 'when uniqueness is violated' do
          let(:subject_value) { [1, 2, 2] }

          it { is_expected.to be false }
        end

        context 'when ordering is violated' do
          let(:subject_value) { [2, 1, 3] }

          it { is_expected.to be false }
        end

        context 'when containing entries is violated' do
          let(:subject_value) { [1, 3, 4] }

          it { is_expected.to be false }
        end

        context 'when exact size is violated' do
          let(:subject_value) { [1, 2] }

          it { is_expected.to be false }
        end

        context 'when type constraint is violated' do
          let(:subject_value) { [1, '2', 3] }

          it { is_expected.to be false }
        end

        context 'when first entry is violated' do
          let(:subject_value) { [2, 1, 3] }

          it { is_expected.to be false }
        end

        context 'when last entry is violated' do
          let(:subject_value) { [1, 2, 4] }

          it { is_expected.to be false }
        end

        context 'when multiple constraints are violated' do
          let(:subject_value) { [2, 2, '3'] }

          it { is_expected.to be false }
        end
      end
    end
  end
end
