# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Attributer::Attribute do
  let(:base) do
    Class.new do
      def initialize
        @changes = []
        @coerced = []
        @test = nil
      end

      def coerce_value(value)
        @coerced << value
        "coerced: #{value}"
      end

      def generate_value
        'generated'
      end

      def record_change(old_value, new_value)
        @changes << [old_value, new_value]
      end

      def validate_valid(value)
        value.is_a?(String) && value.start_with?('valid')
      end

      attr_reader :changes, :coerced, :test

      attr_writer :test
    end
  end

  let(:name) { :test }
  let(:type) { :argument }

  describe '.new' do
    subject(:attribute) { described_class.new(base, name:, type:) }

    it { expect { attribute }.not_to raise_error }

    it 'is expected to set base' do
      expect(attribute.base).to eq(base)
    end

    it 'is expected to set name' do
      expect(attribute.name).to eq(:test)
    end

    it 'is expected to set description' do
      attribute = described_class.new(base, name:, type:, description: 'A test attribute')
      expect(attribute.description).to eq('A test attribute')
    end

    it 'is expected to handle static default values' do
      attribute = described_class.new(base, name:, type:, default: 'default')
      expect(attribute.generate_default(base.new)).to eq('default')
    end

    it 'is expected to handle default generators' do
      attribute = described_class.new(base, name:, type:, default: -> { generate_value })
      expect(attribute.generate_default(base.new)).to eq('generated')
    end

    context 'when base is invalid', rbs: :skip do
      let(:base) { 'not a class or module' }

      it { expect { attribute }.to raise_error(ArgumentError, /invalid base/) }
    end

    it 'is expected to require name', rbs: :skip do
      expect { described_class.new(base, type:) }.to raise_error(ArgumentError, /missing keyword :name/)
    end

    it 'is expected to require type', rbs: :skip do
      expect { described_class.new(base, name:) }.to raise_error(ArgumentError, /missing keyword :type/)
    end
  end

  describe '#apply!' do
    subject(:attribute) { described_class.new(base, name:, type:) }

    it 'is expected to set values' do
      instance = base.new
      attribute.apply!(instance, 'test value')
      expect(instance.test).to eq('test value')
    end

    it 'is expected to handle undefined values' do
      instance = base.new
      attribute = described_class.new(base, name:, type:, default: 'default value')
      attribute.apply!(instance, Domainic::Attributer::Undefined)
      expect(instance.test).to eq('default value')
    end

    it 'is expected to track coerced values' do
      instance = base.new
      attribute = described_class.new(base, name:, type:, coercers: :coerce_value)
      attribute.apply!(instance, 'test value')
      expect(instance.coerced).to eq(['test value'])
    end

    it 'is expected to apply coercion' do
      instance = base.new
      attribute = described_class.new(base, name:, type:, coercers: :coerce_value)
      attribute.apply!(instance, 'test value')
      expect(instance.test).to eq('coerced: test value')
    end

    it 'is expected to accept valid values' do
      instance = base.new
      validator = ->(value) { instance.validate_valid(value) }
      attribute = described_class.new(base, name:, type:, validators: validator)
      attribute.apply!(instance, 'valid test')
      expect(instance.test).to eq('valid test')
    end

    it 'is expected to reject invalid values', rbs: :skip do
      instance = base.new
      validator = ->(value) { instance.validate_valid(value) }
      attribute = described_class.new(base, name:, type:, validators: validator)
      expect { attribute.apply!(instance, 'invalid test') }.to raise_error(ArgumentError)
    end

    it 'is expected to trigger callbacks' do
      instance = base.new
      attribute = described_class.new(
        base,
        name:,
        type:,
        callbacks: ->(old_value, new_value) { record_change(old_value, new_value) }
      )
      attribute.apply!(instance, 'test value')
      expect(instance.changes).to contain_exactly([nil, 'test value'])
    end

    it 'is expected to track value changes' do
      instance = base.new
      instance.test = 'old value'
      attribute = described_class.new(
        base,
        name:,
        type:,
        callbacks: ->(old_value, new_value) { record_change(old_value, new_value) }
      )
      attribute.apply!(instance, 'test value')
      expect(instance.changes).to contain_exactly(['old value', 'test value'])
    end
  end

  describe '#default?' do
    subject(:default?) { attribute.default? }

    context 'when the attribute has a default value' do
      let(:attribute) { described_class.new(base, name:, type:, default: 'test') }

      it { is_expected.to be true }
    end

    context 'when the attribute does not have a default value' do
      let(:attribute) { described_class.new(base, name:, type:) }

      it { is_expected.to be false }
    end
  end

  describe '#dup_with_base' do
    let(:new_base) { Class.new }

    it 'is expected to duplicate attributes' do
      original = described_class.new(base, name:, type:)
      duped = original.dup_with_base(new_base)
      expect(duped.name).to eq(original.name)
    end

    it 'is expected to set new base' do
      original = described_class.new(base, name:, type:)
      duped = original.dup_with_base(new_base)
      expect(duped.base).to eq(new_base)
    end

    it 'is expected to validate new base', rbs: :skip do
      original = described_class.new(base, name:, type:)
      expect { original.dup_with_base('invalid') }.to raise_error(ArgumentError, /invalid base/)
    end
  end

  describe '#merge' do
    it 'is expected to create new instance' do
      original = described_class.new(base, name:, type:)
      other = described_class.new(Class.new, name: :other, type: :option)
      merged = original.merge(other)
      expect(merged).not_to be(original)
    end

    it 'is expected to prefer other name' do
      original = described_class.new(base, name:, type:)
      other = described_class.new(
        Class.new,
        name: :other,
        type: :option,
        description: 'Other test'
      )
      merged = original.merge(other)
      expect(merged.name).to eq(:other)
    end

    it 'is expected to prefer other description' do
      original = described_class.new(base, name:, type:)
      other = described_class.new(
        Class.new,
        name: :other,
        type: :option,
        description: 'Other test'
      )
      merged = original.merge(other)
      expect(merged.description).to eq('Other test')
    end

    it 'is expected to validate other attribute', rbs: :skip do
      original = described_class.new(base, name:, type:)
      expect { original.merge('invalid') }.to raise_error(ArgumentError, /must be an instance/)
    end
  end
end
