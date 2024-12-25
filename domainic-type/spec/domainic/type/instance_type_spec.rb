# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/types/specialized/instance_type'

RSpec.describe Domainic::Type::InstanceType do
  subject(:type) { described_class.new }

  describe '#of' do
    context 'when constraining an object to be an instance of the specified class' do
      subject(:validate) { type.of(String).validate('test') }

      it { is_expected.to be true }
    end

    context 'when the object is not an instance of the specified class' do
      subject(:validate) { type.of(String).validate(123) }

      it { is_expected.to be false }
    end

    context 'when constraining an object to be an instance of a module' do
      subject(:validate) { type.of(Enumerable).validate([]) } # Array includes Enumerable

      it { is_expected.to be true }
    end

    context 'when the object is not an instance of the specified module' do
      subject(:validate) { type.of(Enumerable).validate('string') }

      it { is_expected.to be false }
    end

    context 'when given an invalid type specification', rbs: :skip do
      context 'when the type is not a Class or Module' do
        subject(:invalid_type) { type.of(123) }

        it 'is expected to raise ArgumentError' do
          expect { invalid_type }.to raise_error(ArgumentError, 'Expectation must be a Class or Module')
        end
      end
    end
  end

  describe '#having_attributes' do
    context 'when the object has all specified attributes with correct types' do
      subject(:validate) do
        type.having_attributes(name: String, age: Integer).validate(
          Struct.new(:name, :age, keyword_init: true).new(name: 'John', age: 30)
        )
      end

      it { is_expected.to be true }
    end

    context 'when the object is missing required attributes' do
      subject(:validate) do
        type.having_attributes(name: String, age: Integer).validate(
          Struct.new(:name, keyword_init: true).new(name: 'John')
        )
      end

      it { is_expected.to be false }
    end

    context 'when the object has incorrect attribute types' do
      subject(:validate) do
        type.having_attributes(name: String, age: Integer).validate(
          Struct.new(:name, :age, keyword_init: true).new(name: 'John', age: 'thirty')
        )
      end

      it { is_expected.to be false }
    end

    context 'when no attributes are provided', rbs: :skip do
      subject(:invalid_attributes) { type.having_attributes(nil) }

      it 'is expected to raise an ArgumentError' do
        expect { invalid_attributes }.to raise_error(ArgumentError)
      end
    end
  end
end
