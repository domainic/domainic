# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/definitions'

RSpec.describe Domainic::Type::Definitions do
  subject(:definitions) { dummy_class.new }

  let(:dummy_class) do
    Class.new do
      include Domainic::Type::Definitions
    end
  end

  describe '._Anything' do
    subject(:anything_type) { definitions._Anything }

    it 'is expected to return an AnythingType' do
      expect(anything_type).to be_a(Domainic::Type::AnythingType)
    end
  end

  describe '._Array' do
    subject(:array_type) { definitions._Array }

    it 'is expected to return an ArrayType' do
      expect(array_type).to be_a(Domainic::Type::ArrayType)
    end
  end

  describe '._Array?' do
    subject(:nullable_array_type) { definitions._Array? }

    it 'is expected to return a UnionType' do
      expect(nullable_array_type).to be_a(Domainic::Type::UnionType)
    end

    it 'is expected to validate nil values' do
      expect(nullable_array_type.validate(nil)).to be true
    end

    it 'is expected to validate array values' do
      expect(nullable_array_type.validate([])).to be true
    end
  end

  describe '._Boolean' do
    subject(:boolean_type) { definitions._Boolean }

    it 'is expected to return a frozen UnionType' do
      expect(boolean_type).to be_a(Domainic::Type::UnionType).and(be_frozen)
    end

    it 'is expected to validate true' do
      expect(boolean_type.validate(true)).to be true
    end

    it 'is expected to validate false' do
      expect(boolean_type.validate(false)).to be true
    end
  end

  describe '._Duck' do
    subject(:duck_type) { definitions._Duck }

    it 'is expected to return a DuckType' do
      expect(duck_type).to be_a(Domainic::Type::DuckType)
    end
  end

  describe '._Enum' do
    subject(:enum_type) { definitions._Enum(:foo, :bar) }

    it 'is expected to return an EnumType' do
      expect(enum_type).to be_a(Domainic::Type::EnumType)
    end
  end

  describe '._Hash' do
    subject(:hash_type) { definitions._Hash }

    it 'is expected to return a HashType' do
      expect(hash_type).to be_a(Domainic::Type::HashType)
    end
  end

  describe '._Nilable' do
    subject(:nilable_type) { definitions._Nilable(String) }

    it 'is expected to return a UnionType' do
      expect(nilable_type).to be_a(Domainic::Type::UnionType)
    end

    it 'is expected to validate nil values' do
      expect(nilable_type.validate(nil)).to be true
    end

    it 'is expected to validate values of the specified type' do
      expect(nilable_type.validate('test')).to be true
    end
  end

  describe '._Union' do
    subject(:union_type) { definitions._Union(String, Symbol) }

    it 'is expected to return a UnionType' do
      expect(union_type).to be_a(Domainic::Type::UnionType)
    end
  end

  describe '._Void' do
    subject(:void_type) { definitions._Void }

    it 'is expected to return a VoidType' do
      expect(void_type).to be_a(Domainic::Type::VoidType)
    end
  end
end
