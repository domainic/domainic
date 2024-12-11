# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Attributer::AttributeSet do
  let(:base) { Class.new }

  describe '.new' do
    subject(:set) { described_class.new(base, attributes) }

    let(:attribute) { Domainic::Attributer::Attribute.new(base, name: :test, type: :argument) }
    let(:attributes) { [attribute] }

    it { expect { set }.not_to raise_error }

    it 'is expected to set base' do
      expect(set.instance_variable_get(:@base)).to eq(base)
    end

    it 'is expected to add attributes' do
      expect(set[:test]).to eq(attribute)
    end
  end

  describe '#[]' do
    subject(:set) do
      attribute = Domainic::Attributer::Attribute.new(base, name: :test, type: :argument)
      described_class.new(base, [attribute])
    end

    it 'is expected to find attributes by name' do
      expect(set[:test]).to be_a(Domainic::Attributer::Attribute)
    end

    it 'is expected to find attributes by string name' do
      expect(set['test']).to be_a(Domainic::Attributer::Attribute)
    end

    it 'is expected to return nil for missing attributes' do
      expect(set[:missing]).to be_nil
    end
  end

  describe '#add' do
    subject(:set) { described_class.new(base) }

    it 'is expected to add attributes' do
      attribute = Domainic::Attributer::Attribute.new(base, name: :test, type: :argument)
      set.add(attribute)
      expect(set[:test]).to eq(attribute)
    end

    it 'is expected to merge duplicate attributes' do
      first = Domainic::Attributer::Attribute.new(base, name: :test, type: :argument, description: 'first')
      second = Domainic::Attributer::Attribute.new(base, name: :test, type: :argument, description: 'second')

      set.add(first)
      set.add(second)

      expect(set[:test].description).to eq('second')
    end

    it 'is expected to duplicate attributes from other bases' do
      other_base = Class.new
      attribute = Domainic::Attributer::Attribute.new(other_base, name: :test, type: :argument)

      set.add(attribute)
      expect(set[:test].base).to eq(base)
    end

    it 'is expected to maintain attribute order' do
      first = Domainic::Attributer::Attribute.new(base, name: :first, type: :argument)
      second = Domainic::Attributer::Attribute.new(base, name: :second, type: :argument, default: 'default')
      third = Domainic::Attributer::Attribute.new(base, name: :third, type: :option)

      # Add in random order
      set.add(third)
      set.add(first)
      set.add(second)

      expect(set.attribute_names).to eq(%i[first second third])
    end

    it 'is expected to reject invalid attributes', rbs: :skip do
      expect { set.add('not an attribute') }.to raise_error(ArgumentError, /Invalid attribute/)
    end
  end

  describe '#attribute?' do
    subject(:set) do
      attribute = Domainic::Attributer::Attribute.new(base, name: :test, type: :argument)
      described_class.new(base, [attribute])
    end

    it 'is expected to return true for existing attributes' do
      expect(set.attribute?(:test)).to be true
    end

    it 'is expected to return false for missing attributes' do
      expect(set.attribute?(:missing)).to be false
    end
  end

  describe '#dup_with_base' do
    subject(:original_set) do
      attribute = Domainic::Attributer::Attribute.new(base, name: :test, type: :argument)
      described_class.new(base, [attribute])
    end

    let(:new_base) { Class.new }

    it 'is expected to copy attributes' do
      duplicated = original_set.dup_with_base(new_base)
      expect(duplicated[:test]).to be_a(Domainic::Attributer::Attribute)
    end

    it 'is expected to set new base' do
      duplicated = original_set.dup_with_base(new_base)
      expect(duplicated[:test].base).to eq(new_base)
    end
  end

  describe '#except' do
    subject(:set) do
      first = Domainic::Attributer::Attribute.new(base, name: :first, type: :argument)
      second = Domainic::Attributer::Attribute.new(base, name: :second, type: :argument)
      described_class.new(base, [first, second])
    end

    it 'is expected to exclude specified attributes' do
      expect(set.except(:first).attribute_names).to eq([:second])
    end

    it 'is expected to handle string names' do
      expect(set.except('first').attribute_names).to eq([:second])
    end
  end

  describe '#merge' do
    subject(:set) do
      first = Domainic::Attributer::Attribute.new(base, name: :first, type: :argument)
      described_class.new(base, [first])
    end

    it 'is expected to combine attributes' do
      second = Domainic::Attributer::Attribute.new(base, name: :second, type: :argument)
      other = described_class.new(base, [second])
      merged = set.merge(other)
      expect(merged.attribute_names).to contain_exactly(:first, :second)
    end

    it 'is expected not to modify original sets' do
      other = described_class.new(base, [])
      merged = set.merge(other)
      expect(merged).not_to be(set)
    end

    it 'is expected to create new instance' do
      other = described_class.new(base, [])
      merged = set.merge(other)
      expect(merged).not_to be(other)
    end
  end

  describe '#select' do
    subject(:set) do
      first = Domainic::Attributer::Attribute.new(base, name: :first, type: :argument)
      second = Domainic::Attributer::Attribute.new(base, name: :second, type: :option)
      described_class.new(base, [first, second])
    end

    it 'is expected to filter attributes' do
      result = set.select { |_, attr| attr.signature.argument? }
      expect(result.attribute_names).to eq([:first])
    end
  end

  describe '#reject' do
    subject(:set) do
      first = Domainic::Attributer::Attribute.new(base, name: :first, type: :argument)
      second = Domainic::Attributer::Attribute.new(base, name: :second, type: :option)
      described_class.new(base, [first, second])
    end

    it 'is expected to exclude filtered attributes' do
      result = set.reject { |_, attr| attr.signature.option? }
      expect(result.attribute_names).to eq([:first])
    end
  end
end
