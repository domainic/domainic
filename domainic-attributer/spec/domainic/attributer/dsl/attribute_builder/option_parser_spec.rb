# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Attributer::DSL::AttributeBuilder::OptionParser do
  describe '.parse!' do
    subject(:parsed) { described_class.parse!(name, type, options) }

    let(:name) { :test }
    let(:type) { :argument }
    let(:options) { {} }

    describe '.parse!' do
      subject(:parsed) { described_class.parse!(name, type, options) }

      let(:name) { :test }
      let(:type) { :argument }
      let(:options) { {} }

      it 'is expected to set name' do
        expect(parsed[:name]).to eq(:test)
      end

      it 'is expected to set type' do
        expect(parsed[:type]).to eq(:argument)
      end

      context 'with empty options' do
        it 'is expected to initialize empty callbacks' do
          expect(parsed[:callbacks]).to be_empty
        end

        it 'is expected to initialize empty coercers' do
          expect(parsed[:coercers]).to be_empty
        end

        it 'is expected to initialize empty validators' do
          expect(parsed[:validators]).to be_empty
        end
      end

      context 'with string values' do
        let(:name) { 'test' }
        let(:type) { 'argument' }

        it 'is expected to convert name to symbol' do
          expect(parsed[:name]).to eq(:test)
        end

        it 'is expected to convert type to symbol' do
          expect(parsed[:type]).to eq(:argument)
        end
      end
    end
  end

  describe 'accessor parsing' do
    it 'is expected to handle read options' do
      result = described_class.parse!(:test, :argument, read: :private)
      expect(result[:read]).to eq(:private)
    end

    it 'is expected to handle read_access options' do
      result = described_class.parse!(:test, :argument, read_access: :private)
      expect(result[:read]).to eq(:private)
    end

    it 'is expected to handle reader options' do
      result = described_class.parse!(:test, :argument, reader: :private)
      expect(result[:read]).to eq(:private)
    end

    it 'is expected to handle write options' do
      result = described_class.parse!(:test, :argument, write: :private)
      expect(result[:write]).to eq(:private)
    end

    it 'is expected to handle write_access options' do
      result = described_class.parse!(:test, :argument, write_access: :private)
      expect(result[:write]).to eq(:private)
    end

    it 'is expected to handle writer options' do
      result = described_class.parse!(:test, :argument, writer: :private)
      expect(result[:write]).to eq(:private)
    end
  end

  describe 'callback parsing' do
    it 'is expected to handle callback option' do
      callback = ->(old_value, new_value) { [old_value, new_value] }
      result = described_class.parse!(:test, :argument, callback:)
      expect(result[:callbacks]).to eq([callback])
    end

    it 'is expected to handle on_change option' do
      callback = ->(old_value, new_value) { [old_value, new_value] }
      result = described_class.parse!(:test, :argument, on_change: callback)
      expect(result[:callbacks]).to eq([callback])
    end

    it 'is expected to handle callbacks option' do
      callback = ->(old_value, new_value) { [old_value, new_value] }
      result = described_class.parse!(:test, :argument, callbacks: [callback])
      expect(result[:callbacks]).to eq([callback])
    end

    it 'is expected to combine multiple callbacks' do
      first = ->(old_value, new_value) { [old_value, new_value] }
      second = ->(old_value, new_value) { [old_value, new_value] }
      result = described_class.parse!(:test, :argument, callback: first, on_change: second)
      expect(result[:callbacks]).to eq([first, second])
    end
  end

  describe 'coercer parsing' do
    it 'is expected to handle coerce option' do
      coercer = lambda(&:to_s)
      result = described_class.parse!(:test, :argument, coerce: coercer)
      expect(result[:coercers]).to eq([coercer])
    end

    it 'is expected to handle coerce_with option' do
      coercer = lambda(&:to_s)
      result = described_class.parse!(:test, :argument, coerce_with: coercer)
      expect(result[:coercers]).to eq([coercer])
    end

    it 'is expected to handle coercers option' do
      coercer = lambda(&:to_s)
      result = described_class.parse!(:test, :argument, coercers: [coercer])
      expect(result[:coercers]).to eq([coercer])
    end

    it 'is expected to combine multiple coercers' do
      first = lambda(&:to_s)
      second = lambda(&:to_i)
      result = described_class.parse!(:test, :argument, coerce: first, coerce_with: second)
      expect(result[:coercers]).to eq([first, second])
    end
  end

  describe 'default parsing' do
    it 'is expected to handle default option' do
      result = described_class.parse!(:test, :argument, default: 'value')
      expect(result[:default]).to eq('value')
    end

    it 'is expected to handle default_value option' do
      result = described_class.parse!(:test, :argument, default_value: 'value')
      expect(result[:default]).to eq('value')
    end

    it 'is expected to handle default_generator option' do
      result = described_class.parse!(:test, :argument, default_generator: 'value')
      expect(result[:default]).to eq('value')
    end
  end

  describe 'description parsing' do
    it 'is expected to handle description option' do
      result = described_class.parse!(:test, :argument, description: 'test')
      expect(result[:description]).to eq('test')
    end

    it 'is expected to handle desc option' do
      result = described_class.parse!(:test, :argument, desc: 'test')
      expect(result[:description]).to eq('test')
    end
  end

  describe 'nilability parsing' do
    it 'is expected to handle non_nil option' do
      result = described_class.parse!(:test, :argument, non_nil: true)
      expect(result[:nilable]).to be false
    end

    it 'is expected to handle non_null option' do
      result = described_class.parse!(:test, :argument, non_null: true)
      expect(result[:nilable]).to be false
    end

    it 'is expected to handle not_nil option' do
      result = described_class.parse!(:test, :argument, not_nil: true)
      expect(result[:nilable]).to be false
    end

    it 'is expected to handle null: false option' do
      result = described_class.parse!(:test, :argument, null: false)
      expect(result[:nilable]).to be false
    end
  end

  describe 'required parsing' do
    it 'is expected to handle required option' do
      result = described_class.parse!(:test, :argument, required: true)
      expect(result[:required]).to be true
    end

    it 'is expected to handle optional: false option' do
      result = described_class.parse!(:test, :argument, optional: false)
      expect(result[:required]).to be true
    end
  end

  describe 'validator parsing' do
    it 'is expected to handle validate option' do
      validator = ->(value) { value.is_a?(String) }
      result = described_class.parse!(:test, :argument, validate: validator)
      expect(result[:validators]).to eq([validator])
    end

    it 'is expected to handle validate_with option' do
      validator = ->(value) { value.is_a?(String) }
      result = described_class.parse!(:test, :argument, validate_with: validator)
      expect(result[:validators]).to eq([validator])
    end

    it 'is expected to handle validators option' do
      validator = ->(value) { value.is_a?(String) }
      result = described_class.parse!(:test, :argument, validators: [validator])
      expect(result[:validators]).to eq([validator])
    end

    it 'is expected to combine multiple validators' do
      first = ->(value) { value.is_a?(String) }
      second = ->(value) { value.length > 3 }
      result = described_class.parse!(:test, :argument, validate: first, validate_with: second)
      expect(result[:validators]).to eq([first, second])
    end
  end
end
