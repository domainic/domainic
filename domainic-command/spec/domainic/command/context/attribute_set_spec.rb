# frozen_string_literal: true

require 'rspec'
require 'domainic/command/context/attribute'
require 'domainic/command/context/attribute_set'

RSpec.describe Domainic::Command::Context::AttributeSet do
  let(:attribute_set) { described_class.new }
  let(:attribute) { instance_double(Domainic::Command::Context::Attribute, name: :test) }

  before do
    allow(attribute).to receive(:is_a?).with(Domainic::Command::Context::Attribute).and_return(true)
  end

  describe '#[]' do
    subject(:get_attribute) { attribute_set[attribute_name] }

    let(:attribute_name) { :test }

    context 'when the attribute exists' do
      before { attribute_set.add(attribute) }

      it { is_expected.to eq(attribute) }
    end

    context 'when the attribute does not exist' do
      it { is_expected.to be_nil }
    end

    context 'when given a string key' do
      let(:attribute_name) { 'test' }

      before { attribute_set.add(attribute) }

      it { is_expected.to eq(attribute) }
    end
  end

  describe '#add' do
    subject(:add_attribute) { -> { attribute_set.add(item) } }

    context 'when given a valid attribute' do
      let(:item) { attribute }

      it { expect { add_attribute }.not_to raise_error }

      it 'is expected to add the attribute to the set' do
        add_attribute.call
        expect(attribute_set[:test]).to eq(attribute)
      end
    end

    context 'when given an invalid attribute', rbs: :skip do
      let(:item) { 'not an attribute' }

      it 'is expected to raise an ArgumentError' do
        expect(add_attribute).to raise_error(
          ArgumentError,
          'Attribute must be an instance of Domainic::Command::Context::Attribute'
        )
      end
    end
  end

  describe '#all' do
    subject(:all_attributes) { attribute_set.all }

    context 'when the set is empty' do
      it { is_expected.to be_empty }
    end

    context 'when the set contains attributes' do
      before { attribute_set.add(attribute) }

      it { is_expected.to contain_exactly(attribute) }
    end
  end

  describe '#each' do
    subject(:iteration) { -> { attribute_set.each { |attr| yielded << attr } } }

    let(:yielded) { [] }

    before { attribute_set.add(attribute) }

    it 'is expected to yield each attribute' do
      iteration.call
      expect(yielded).to contain_exactly(attribute)
    end
  end

  describe '#each_with_object' do
    subject(:each_with_object) { attribute_set.each_with_object([]) { |attr, memo| memo << attr.name } }

    before { attribute_set.add(attribute) }

    it { is_expected.to contain_exactly(:test) }
  end
end
