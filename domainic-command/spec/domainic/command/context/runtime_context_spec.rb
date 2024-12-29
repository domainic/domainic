# frozen_string_literal: true

require 'spec_helper'
require 'domainic/command/context/runtime_context'

RSpec.describe Domainic::Command::Context::RuntimeContext do
  describe '.new', rbs: :skip do
    subject(:runtime_context) { described_class.new(**options) }

    let(:options) { { test: 'value' } }

    it 'is expected to initialize with the given options' do
      expect(runtime_context[:test]).to eq('value')
    end

    context 'when given string keys' do
      let(:options) { { 'test' => 'value' } }

      it 'is expected to convert keys to symbols' do
        expect(runtime_context[:test]).to eq('value')
      end
    end
  end

  describe '#[]' do
    subject(:attribute_value) { runtime_context[attribute_name] }

    let(:runtime_context) { described_class.new(test: 'value') }
    let(:attribute_name) { :test }

    it 'is expected to retrieve the value for the given attribute' do
      expect(attribute_value).to eq('value')
    end

    context 'when given a string key' do
      let(:attribute_name) { 'test' }

      it 'is expected to retrieve the value using a symbolized key' do
        expect(attribute_value).to eq('value')
      end
    end
  end

  describe '#[]=' do
    subject(:set_attribute) { runtime_context[attribute_name] = value }

    let(:runtime_context) { described_class.new }
    let(:attribute_name) { :test }
    let(:value) { 'new value' }

    it 'is expected to set the value for the given attribute' do
      expect { set_attribute }.to change { runtime_context[attribute_name] }.from(nil).to(value)
    end

    context 'when given a string key' do
      let(:attribute_name) { 'test' }

      it 'is expected to set the value using a symbolized key' do
        set_attribute
        expect(runtime_context[:test]).to eq(value)
      end
    end
  end

  describe '#to_hash' do
    subject(:to_hash) { runtime_context.to_hash }

    let(:runtime_context) { described_class.new(**initial_data) }
    let(:initial_data) { { string: 'value', array: [1, 2, 3], klass: String } }

    it 'is expected to return a hash of all attributes' do
      expect(to_hash.keys).to match_array(%i[string array klass])
    end

    it 'is expected to duplicate mutable values' do
      expect(to_hash[:array]).not_to be(runtime_context[:array])
    end

    it 'is expected to maintain the same values' do
      expect(to_hash[:array]).to eq(runtime_context[:array])
    end

    it 'is expected to not duplicate classes' do
      expect(to_hash[:klass]).to be(runtime_context[:klass])
    end
  end

  describe 'method_missing' do
    subject(:runtime_context) { described_class.new(test: 'value') }

    it 'is expected to allow reading values via methods' do
      expect(runtime_context.test).to eq('value')
    end

    it 'is expected to allow writing values via methods' do
      expect { runtime_context.test = 'new value' }
        .to change { runtime_context.test } # rubocop:disable RSpec/ExpectChange
        .from('value')
        .to('new value')
    end

    it 'is expected to raise NoMethodError for undefined methods' do
      expect { runtime_context.undefined_method }.to raise_error(NoMethodError)
    end
  end
end
