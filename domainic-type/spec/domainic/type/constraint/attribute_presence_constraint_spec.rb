# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/types/core/string_type'
require 'domainic/type/constraint/constraints/attribute_presence_constraint'

RSpec.describe Domainic::Type::Constraint::AttributePresenceConstraint do
  describe '#satisfied?' do
    subject(:satisfied?) { constraint.satisfied?(actual) }

    let(:constraint) { described_class.new(:self).expecting(expected) }
    let(:string_type) { Domainic::Type::StringType.new }
    let(:expected) { { name: String, age: Integer } }

    let(:actual) do
      Class.new do
        def initialize(name, age)
          @name = name
          @age = age
        end

        attr_reader :name, :age
      end.new('Test', 30)
    end

    it { is_expected.to be true }

    context 'when missing attributes' do
      let(:actual) { Object.new }

      it { is_expected.to be false }

      it 'is expected to report missing attributes' do
        satisfied?
        expect(constraint.short_violation_description).to eq('missing attributes: name, age')
      end
    end

    context 'when attributes have wrong types' do
      let(:actual) do
        Class.new do
          def initialize(name, age)
            @name = name
            @age = age
          end

          attr_reader :name, :age
        end.new(123, '30')
      end

      it { is_expected.to be false }

      it 'is expected to report invalid attributes' do
        satisfied?
        expect(constraint.short_violation_description).to eq('invalid attributes: name: 123, age: "30"')
      end
    end

    context 'with type constraints' do
      let(:expected) { { name: string_type } }

      before do
        allow(string_type).to receive(:validate).with('Test').and_return(true)
      end

      it { is_expected.to be true }

      context 'when type constraint fails' do
        before do
          allow(string_type).to receive(:===).with('Test').and_return(false)
        end

        it { is_expected.to be false }
      end
    end

    context 'with mixed missing and invalid attributes' do
      let(:actual) do
        Class.new do
          def initialize(name)
            @name = name
          end

          attr_reader :name
        end.new(123)
      end

      it { is_expected.to be false }

      it 'is expected to report both missing and invalid attributes' do
        satisfied?
        expect(constraint.short_violation_description)
          .to eq('missing attributes: age and invalid attributes: name: 123')
      end
    end
  end

  describe '#expecting' do
    subject(:expecting) { described_class.new(:self).expecting(attributes) }

    context 'with valid attributes' do
      let(:attributes) { { name: String } }

      it { is_expected.to be_an_instance_of(described_class) }
    end

    context 'when attributes are not a Hash', rbs: :skip do
      let(:attributes) { 'not a hash' }

      it 'is expected to raise ArgumentError' do
        expect { expecting }.to raise_error(ArgumentError, 'Expectation must be a Hash')
      end
    end

    context 'when attributes have invalid type values' do
      let(:attributes) { { name: 'String' } }

      it 'is expected to raise ArgumentError', rbs: :skip do
        expect { expecting }
          .to raise_error(ArgumentError, 'Expectation must have values of Class, Module, or Domainic::Type')
      end
    end
  end

  describe '#short_description' do
    subject(:short_description) { constraint.short_description }

    let(:constraint) { described_class.new(:self).expecting(**attributes) }
    let(:attributes) { { name: String, age: Integer } }

    it { is_expected.to eq('attributes name: String, age: Integer') }
  end
end
