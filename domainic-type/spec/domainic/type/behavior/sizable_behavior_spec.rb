# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/behavior/sizable_behavior'

RSpec.describe Domainic::Type::Behavior::SizableBehavior do
  let(:including_class) do
    Class.new do
      include Domainic::Type::Behavior
      include Domainic::Type::Behavior::SizableBehavior

      def self.name
        'TestType'
      end
    end
  end

  let(:type) { including_class.new }

  describe '#having_size' do
    subject(:having_size) { type.having_size(5) }

    it 'is expected to constrain size with exact value', rbs: :skip do
      allow(type).to receive(:constrain).and_call_original
      having_size

      expect(type).to have_received(:constrain).with(
        :size,
        :range,
        { minimum: 5, maximum: 5 },
        concerning: :size,
        description: 'having size'
      )
    end

    context 'when called through an alias' do
      subject(:count) { type.count(5) }

      it 'is expected to use the called method name in description', rbs: :skip do
        allow(type).to receive(:constrain).and_call_original
        count

        expect(type).to have_received(:constrain).with(
          :size,
          :range,
          { minimum: 5, maximum: 5 },
          concerning: :size,
          description: 'having count'
        )
      end
    end
  end

  describe '#having_maximum_size' do
    subject(:having_maximum_size) { type.having_maximum_size(10) }

    it 'is expected to constrain size with maximum value', rbs: :skip do
      allow(type).to receive(:constrain).and_call_original
      having_maximum_size

      expect(type).to have_received(:constrain).with(
        :size,
        :range,
        { maximum: 10 },
        concerning: :size,
        description: 'having size'
      )
    end

    context 'when called through an alias' do
      subject(:max_count) { type.max_count(10) }

      it 'is expected to use the called method name in description', rbs: :skip do
        allow(type).to receive(:constrain).and_call_original
        max_count

        expect(type).to have_received(:constrain).with(
          :size,
          :range,
          { maximum: 10 },
          concerning: :size,
          description: 'having count'
        )
      end
    end
  end

  describe '#having_minimum_size' do
    subject(:having_minimum_size) { type.having_minimum_size(3) }

    it 'is expected to constrain size with minimum value', rbs: :skip do
      allow(type).to receive(:constrain).and_call_original
      having_minimum_size

      expect(type).to have_received(:constrain).with(
        :size,
        :range,
        { minimum: 3 },
        concerning: :size,
        description: 'having size'
      )
    end

    context 'when called through an alias' do
      subject(:min_length) { type.min_length(3) }

      it 'is expected to use the called method name in description', rbs: :skip do
        allow(type).to receive(:constrain).and_call_original
        min_length

        expect(type).to have_received(:constrain).with(
          :size,
          :range,
          { minimum: 3 },
          concerning: :size,
          description: 'having length'
        )
      end
    end
  end

  describe '#having_size_between' do
    context 'with positional arguments' do
      subject(:having_size_between) { type.having_size_between(3, 10) }

      it 'is expected to constrain size with range' do
        allow(type).to receive(:constrain).and_call_original
        having_size_between

        expect(type).to have_received(:constrain).with(
          :size,
          :range,
          { minimum: 3, maximum: 10 },
          concerning: :size,
          description: 'having size',
          inclusive: false
        )
      end
    end

    context 'with keyword arguments' do
      subject(:having_size_between) { type.having_size_between(minimum: 3, maximum: 10) }

      it 'is expected to constrain size with range' do
        allow(type).to receive(:constrain).and_call_original
        having_size_between

        expect(type).to have_received(:constrain).with(
          :size,
          :range,
          { minimum: 3, maximum: 10 },
          concerning: :size,
          description: 'having size',
          inclusive: false
        )
      end
    end

    context 'with mixed arguments' do
      subject(:having_size_between) { type.having_size_between(3, max: 10) }

      it 'is expected to constrain size with range' do
        allow(type).to receive(:constrain).and_call_original
        having_size_between

        expect(type).to have_received(:constrain).with(
          :size,
          :range,
          { minimum: 3, maximum: 10 },
          concerning: :size,
          description: 'having size',
          inclusive: false
        )
      end
    end

    context 'when missing required arguments' do
      it 'is expected to raise ArgumentError with positional args' do
        expect { type.having_size_between(3) }.to raise_error(
          ArgumentError,
          'wrong number of arguments (given 1, expected 2)'
        )
      end

      it 'is expected to raise ArgumentError with keyword args' do
        expect { type.having_size_between(minimum: 3) }.to raise_error(
          ArgumentError,
          'missing keyword: :maximum'
        )
      end
    end
  end
end
