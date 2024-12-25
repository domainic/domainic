# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/behavior/enumerable_behavior'

RSpec.describe Domainic::Type::Behavior::EnumerableBehavior do
  subject(:type) { test_class.new }

  let(:test_class) do
    Class.new do
      include Domainic::Type::Behavior
      include Domainic::Type::Behavior::EnumerableBehavior

      intrinsically_constrain :self, :type, Enumerable, abort_on_failure: true, description: :not_described
    end
  end

  describe '#being_distinct' do
    context 'when validating an array with unique elements' do
      subject(:validation) { type.being_distinct.validate([1, 2, 3]) }

      it { is_expected.to be true }
    end

    context 'when validating an array with duplicate elements' do
      subject(:validation) { type.being_distinct.validate([1, 1, 2]) }

      it { is_expected.to be false }
    end
  end

  describe '#being_duplicative' do
    context 'when validating an array with duplicate elements' do
      subject(:validation) { type.being_duplicative.validate([1, 1, 2]) }

      it { is_expected.to be true }
    end

    context 'when validating an array with unique elements' do
      subject(:validation) { type.being_duplicative.validate([1, 2, 3]) }

      it { is_expected.to be false }
    end
  end

  describe '#being_empty' do
    context 'when validating an empty array' do
      subject(:validation) { type.being_empty.validate([]) }

      it { is_expected.to be true }
    end

    context 'when validating a non-empty array' do
      subject(:validation) { type.being_empty.validate([1]) }

      it { is_expected.to be false }
    end
  end

  describe '#being_populated' do
    context 'when validating a non-empty array' do
      subject(:validation) { type.being_populated.validate([1]) }

      it { is_expected.to be true }
    end

    context 'when validating an empty array' do
      subject(:validation) { type.being_populated.validate([]) }

      it { is_expected.to be false }
    end
  end

  describe '#being_sorted' do
    context 'when validating a sorted array' do
      subject(:validation) { type.being_sorted.validate([1, 2, 3]) }

      it { is_expected.to be true }
    end

    context 'when validating an unsorted array' do
      subject(:validation) { type.being_sorted.validate([3, 1, 2]) }

      it { is_expected.to be false }
    end
  end

  describe '#being_unsorted' do
    context 'when validating an unsorted array' do
      subject(:validation) { type.being_unsorted.validate([3, 1, 2]) }

      it { is_expected.to be true }
    end

    context 'when validating a sorted array' do
      subject(:validation) { type.being_unsorted.validate([1, 2, 3]) }

      it { is_expected.to be false }
    end
  end

  describe '#containing' do
    context 'when validating an array containing all specified elements' do
      subject(:validation) { type.containing(1, 2).validate([1, 2, 3]) }

      it { is_expected.to be true }
    end

    context 'when validating an array missing specified elements' do
      subject(:validation) { type.containing(1, 2).validate([1, 3]) }

      it { is_expected.to be false }
    end
  end

  describe '#ending_with' do
    context 'when validating an array ending with the specified element' do
      subject(:validation) { type.ending_with(3).validate([1, 2, 3]) }

      it { is_expected.to be true }
    end

    context 'when validating an array not ending with the specified element' do
      subject(:validation) { type.ending_with(2).validate([1, 2, 3]) }

      it { is_expected.to be false }
    end
  end

  describe '#excluding' do
    context 'when validating an array without specified elements' do
      subject(:validation) { type.excluding(4, 5).validate([1, 2, 3]) }

      it { is_expected.to be true }
    end

    context 'when validating an array containing specified elements' do
      subject(:validation) { type.excluding(1, 2).validate([1, 2, 3]) }

      it { is_expected.to be false }
    end
  end

  describe '#of' do
    context 'when validating an array of specified type' do
      subject(:validation) { type.of(String).validate(%w[a b c]) }

      it { is_expected.to be true }
    end

    context 'when validating an array with elements of wrong type' do
      subject(:validation) { type.of(String).validate(['a', 1, 'c']) }

      it { is_expected.to be false }
    end
  end

  describe '#starting_with' do
    context 'when validating an array starting with the specified element' do
      subject(:validation) { type.starting_with(1).validate([1, 2, 3]) }

      it { is_expected.to be true }
    end

    context 'when validating an array not starting with the specified element' do
      subject(:validation) { type.starting_with(2).validate([1, 2, 3]) }

      it { is_expected.to be false }
    end
  end
end
