# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/behavior'
require 'domainic/type/constraint/behavior'

RSpec.describe Domainic::Type::Behavior do
  let(:type_class) do
    Class.new do
      include Domainic::Type::Behavior

      private

      def initialize(**options)
        super
        constrain(:self, :test)
      end
    end
  end

  let(:constraint_class) do
    Class.new do
      include Domainic::Type::Constraint::Behavior

      def initialize(accessor, description = nil)
        super
        @expected = nil
        @actual = nil
        @result = nil
      end

      protected

      def satisfies_constraint?
        @result = !@actual.nil?
      end
    end
  end

  before do
    stub_const('TestType', type_class)
    stub_const('TestConstraint', constraint_class)
    allow(Domainic::Type::Constraint::Resolver).to receive(:resolve!).with(:test).and_return(TestConstraint)
  end

  describe '.included' do
    subject(:include_behavior) { Class.new { include Domainic::Type::Behavior } }

    it 'is expected to extend ClassMethods' do
      expect(include_behavior.singleton_class.included_modules).to include(described_class::ClassMethods)
    end
  end

  describe 'ClassMethods' do
    describe '.to_s' do
      subject(:to_string) { TestType.to_s }

      it 'is expected to return the class name without the Type suffix' do
        expect(to_string).to eq('Test')
      end
    end

    describe '.validate' do
      subject(:validate) { TestType.validate(value) }

      context 'when given a valid value' do
        let(:value) { 'valid' }

        it { is_expected.to be true }
      end

      context 'when given an invalid value' do
        let(:value) { nil }

        it { is_expected.to be false }
      end
    end

    describe '.validate!' do
      subject(:validate!) { TestType.validate!(value) }

      context 'when given a valid value' do
        let(:value) { 'valid' }

        it { is_expected.to be true }
      end

      context 'when given an invalid value' do
        let(:value) { nil }

        it 'is expected to raise TypeError' do
          expect { validate! }.to raise_error(TypeError)
        end
      end
    end

    describe '.method_missing' do
      subject(:call_missing) { TestType.public_send(method_name) }

      context 'when method exists on instance' do
        let(:method_name) { :to_s }

        it 'is expected to delegate to a new instance' do
          expect(call_missing).to eq('Test')
        end
      end

      context 'when method does not exist on instance' do
        let(:method_name) { :nonexistent_method }

        it 'is expected to raise NoMethodError' do
          expect { call_missing }.to raise_error(NoMethodError)
        end
      end
    end
  end

  describe '#initialize' do
    subject(:initialize_type) { TestType.new(**options) }

    let(:options) { {} }

    it 'is expected to create a new type instance' do
      expect(initialize_type).to be_a(TestType)
    end

    context 'when given options' do
      let(:type_with_options) do
        Class.new do
          include Domainic::Type::Behavior

          attr_reader :option_value

          def something(value)
            @option_value = value
          end
        end
      end

      let(:options) { { something: 'test' } }

      before do
        stub_const('TypeWithOptions', type_with_options)
      end

      it 'is expected to call methods with given options' do
        instance = TypeWithOptions.new(**options)
        expect(instance.option_value).to eq('test')
      end
    end
  end

  describe '#to_s' do
    subject(:to_string) { type.to_s }

    let(:type) { TestType.new }

    it 'is expected to return the type name' do
      expect(to_string).to eq('Test')
    end

    context 'when constraints have descriptions' do
      before { type.send(:constrain, :self, :test, nil, description: 'test description') }

      it 'is expected to include constraint descriptions' do
        expect(to_string).to eq('Test')
      end
    end
  end

  describe '#validate' do
    subject(:validate) { type.validate(value) }

    let(:type) { TestType.new }

    context 'when given a valid value' do
      let(:value) { 'valid' }

      it { is_expected.to be true }
    end

    context 'when given an invalid value' do
      let(:value) { nil }

      it { is_expected.to be false }
    end
  end

  describe '#validate!' do
    subject(:validate!) { type.validate!(value) }

    let(:type) { TestType.new }

    context 'when given a valid value' do
      let(:value) { 'valid' }

      it { is_expected.to be true }
    end

    context 'when given an invalid value' do
      let(:value) { nil }

      it 'is expected to raise TypeError' do
        expect { validate! }.to raise_error(TypeError, /Expected Test, but got NilClass/)
      end
    end

    context 'when a constraint is configured to abort on failure' do
      before do
        type.send(:constrain, :self, :test, nil, abort_on_failure: true)
      end

      let(:value) { nil }

      it 'is expected to stop validation on first failure' do
        expect { validate! }.to raise_error(TypeError)
      end
    end

    context 'when constraints have descriptions' do
      before do
        type.send(:constrain, :self, :test, nil, description: 'test description')
      end

      let(:value) { nil }

      it 'is expected to include descriptions in error message' do
        expect { validate! }.to raise_error(TypeError, 'Expected Test, but got NilClass')
      end
    end
  end
end
