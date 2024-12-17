# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/behavior'
require 'domainic/type/constraint/behavior'

RSpec.describe Domainic::Type::Behavior do
  let(:passing_constraint) do
    Class.new do
      include Domainic::Type::Constraint::Behavior

      protected

      def satisfies_constraint?
        true
      end
    end
  end

  let(:failing_constraint) do
    Class.new do
      include Domainic::Type::Constraint::Behavior

      protected

      def satisfies_constraint?
        false
      end
    end
  end

  let(:type_class) do
    Class.new do
      include Domainic::Type::Behavior

      def test_method(*args, **kwargs)
        kwargs.empty? ? args.first : kwargs
      end

      private

      def initialize(**options)
        super
        constrain(:self, :test, :test, 'test value')
      end
    end
  end

  let(:type_instance) { type_class.new }
  let(:constraint_class) { passing_constraint }

  before do
    stub_const('Domainic::Type::Constraint::TestConstraint', constraint_class)
    allow(Domainic::Type::Constraint::Resolver).to receive(:resolve!)
      .with(:test).and_return(constraint_class)
  end

  describe '.validate' do
    subject(:validate) { type_class.validate(value) }

    before do
      allow(type_class).to receive(:new).and_return(type_instance)
      allow(type_instance).to receive(:validate).and_call_original
    end

    let(:value) { 'test value' }

    it 'is expected to delegate to a new instance' do
      validate
      expect(type_instance).to have_received(:validate).with(value)
    end
  end

  describe '.validate!' do
    subject(:validate!) { type_class.validate!(value) }

    before do
      allow(type_class).to receive(:new).and_return(type_instance)
      allow(type_instance).to receive(:validate!).and_call_original
    end

    let(:value) { 'test value' }

    it 'is expected to delegate to a new instance' do
      validate!
      expect(type_instance).to have_received(:validate!).with(value)
    end
  end

  describe '#validate' do
    subject(:validate) { type_instance.validate(value) }

    let(:value) { 'test value' }
    let(:constraints) { Domainic::Type::Constraint::Set.new }

    before do
      type_instance.instance_variable_set(:@constraints, constraints)
      constraints.add(:self, :test, :test)
    end

    context 'when all constraints are satisfied' do
      let(:constraint_class) { passing_constraint }

      it { is_expected.to be true }
    end

    context 'when any constraint is not satisfied' do
      let(:constraint_class) { failing_constraint }

      it { is_expected.to be false }
    end
  end

  describe '#validate!' do
    subject(:validate!) { type_instance.validate!(value) }

    let(:value) { 'test value' }
    let(:constraints) { Domainic::Type::Constraint::Set.new }

    before do
      type_instance.instance_variable_set(:@constraints, constraints)
      constraints.add(:self, :test, :test)
    end

    context 'when all constraints are satisfied' do
      let(:constraint_class) { passing_constraint }

      it { is_expected.to be true }
    end

    context 'when any constraint is not satisfied' do
      let(:constraint_class) { failing_constraint }

      it 'is expected to raise TypeError' do
        expect { validate! }.to raise_error(TypeError)
      end
    end
  end

  describe 'initialization with options' do
    subject(:test_instance) { test_class.new(**method_options) }

    let(:test_class) do
      Class.new do
        include Domainic::Type::Behavior
        attr_reader :test_method_args

        def test_method(*args, **kwargs)
          @test_method_args = kwargs.empty? ? args.first : kwargs
        end
      end
    end

    context 'when given hash arguments' do
      let(:method_options) { { test_method: { key: 'value' } } }

      it 'calls the method with keyword arguments' do
        expect(test_instance.test_method_args).to eq(key: 'value')
      end
    end

    context 'when given array arguments' do
      let(:method_options) { { test_method: ['value'] } }

      it 'calls the method with array arguments' do
        expect(test_instance.test_method_args).to eq('value')
      end
    end
  end
end
