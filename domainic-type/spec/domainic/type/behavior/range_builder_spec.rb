# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/behavior'
require 'domainic/type/behavior/range_builder'

RSpec.describe Domainic::Type::Behavior::RangeBuilder do
  subject(:builder) { described_class.new(type, constraining, **options) }

  let(:type) do
    Class.new do
      include Domainic::Type::Behavior
    end.new
  end
  let(:constraining) { :size }
  let(:options) { { description: 'having count' } }

  before do
    allow(type).to receive(:send).with(:constrain, anything, anything, anything, anything).and_return(type)
  end

  it { is_expected.to respond_to(:at_least) }
  it { is_expected.to respond_to(:at_most) }
  it { is_expected.to respond_to(:between) }
  it { is_expected.to respond_to(:exactly) }

  describe '#at_least' do
    it 'is expected to create a minimum range constraint' do
      allow(type).to receive(:send)
      builder.at_least(5)

      expect(type).to have_received(:send).with(
        :constrain,
        constraining,
        :range,
        { minimum: 5 },
        description: 'having count'
      )
    end

    it 'is expected to return self for chaining' do
      expect(builder.at_least(5)).to eq(builder)
    end
  end

  describe '#at_most' do
    it 'is expected to create a maximum range constraint' do
      allow(type).to receive(:send)
      builder.at_most(10)

      expect(type).to have_received(:send).with(
        :constrain,
        constraining,
        :range,
        { maximum: 10 },
        description: 'having count'
      )
    end

    it 'is expected to return self for chaining' do
      expect(builder.at_most(10)).to eq(builder)
    end
  end

  describe '#between' do
    context 'with min/max parameters' do
      it 'is expected to create a range constraint' do
        allow(type).to receive(:send)
        builder.between(min: 5, max: 10)

        expect(type).to have_received(:send).with(
          :constrain,
          constraining,
          :range,
          { minimum: 5, maximum: 10 },
          description: 'having count',
          inclusive: false
        )
      end
    end

    context 'with minimum/maximum parameters' do
      it 'is expected to create a range constraint' do
        allow(type).to receive(:send)
        builder.between(minimum: 5, maximum: 10)

        expect(type).to have_received(:send).with(
          :constrain,
          constraining,
          :range,
          { minimum: 5, maximum: 10 },
          description: 'having count',
          inclusive: false
        )
      end
    end

    it 'is expected to return self for chaining' do
      expect(builder.between(min: 5, max: 10)).to eq(builder)
    end
  end

  describe '#exactly' do
    it 'is expected to create an exact range constraint' do
      allow(type).to receive(:send)
      builder.exactly(7)

      expect(type).to have_received(:send).with(
        :constrain,
        constraining,
        :range,
        { minimum: 7, maximum: 7 },
        description: 'having count'
      )
    end

    it 'is expected to return self for chaining' do
      expect(builder.exactly(7)).to eq(builder)
    end
  end
end
