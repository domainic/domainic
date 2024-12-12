# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Attributer::DSL::Initializer do
  before do
    stub_const('TestClass', Class.new)
    allow(TestClass).to receive(:__attributes__).and_return(attribute_set)
    allow(base).to receive(:class).and_return(TestClass)
  end

  let(:attribute_set) { instance_double(Domainic::Attributer::AttributeSet) }
  let(:base) { instance_spy(TestClass) }
  let(:empty_selection) { instance_double(Domainic::Attributer::AttributeSet, attributes: []) }

  describe '.new' do
    subject(:initializer) { described_class.new(base) }

    before { allow(attribute_set).to receive(:select).and_return(empty_selection) }

    it 'is expected to assign the base instance' do
      expect(initializer.instance_variable_get(:@base)).to eq(base)
    end

    it 'is expected to retrieve the attribute set from the class' do
      expect(initializer.instance_variable_get(:@attributes)).to eq(attribute_set)
    end
  end

  describe '#assign!' do
    subject(:initializer) { described_class.new(base) }

    context 'with arguments' do
      subject(:assign) { initializer.assign!(*args) }

      let(:args) { [:value] }
      let(:signature) { build_signature(argument: true) }
      let(:arg_selection) { instance_double(Domainic::Attributer::AttributeSet, attributes: [attribute]) }

      before do
        allow(attribute_set).to receive(:select).and_return(arg_selection, empty_selection)
      end

      def attribute
        @attribute ||= build_attribute(:required_arg, signature)
      end

      it 'is expected to assign argument values' do
        assign
        expect(base).to have_received(:required_arg=).with(:value)
      end

      context 'when required arguments are missing' do
        let(:args) { [] }

        it 'is expected to raise ArgumentError' do
          expect { assign }.to raise_error(ArgumentError, 'wrong number of arguments (given 0, expected 1+)')
        end
      end
    end

    context 'with options' do
      subject(:assign) { initializer.assign!(**opts) }

      let(:signature) { build_signature(option: true) }
      let(:opt_selection) { instance_double(Domainic::Attributer::AttributeSet, attributes: [attribute]) }

      before do
        allow(attribute_set).to receive(:select).and_return(empty_selection, opt_selection)
      end

      def attribute
        @attribute ||= build_attribute(:optional, signature)
      end

      context 'when providing values' do
        let(:opts) { { optional: :test_value } }

        it 'is expected to assign option values' do
          assign
          expect(base).to have_received(:optional=).once.with(:test_value)
        end
      end

      context 'when options are missing' do
        let(:opts) { {} }

        it 'is expected to assign Undefined for missing options' do
          assign
          expect(base).to have_received(:optional=).once.with(Domainic::Attributer::Undefined)
        end
      end
    end

    context 'with both arguments and options' do
      subject(:assign) { initializer.assign!(:arg_value, optional: :opt_value) }

      let(:arg_signature) { build_signature(argument: true) }
      let(:opt_signature) { build_signature(option: true) }

      before do
        allow(attribute_set).to receive(:select) do |&block|
          block&.call(nil, arg_attribute) ? arg_selection : opt_selection
        end
      end

      def arg_attribute
        @arg_attribute ||= build_attribute(:required_arg, arg_signature)
      end

      def opt_attribute
        @opt_attribute ||= build_attribute(:optional, opt_signature)
      end

      def arg_selection
        @arg_selection ||= instance_double(Domainic::Attributer::AttributeSet, attributes: [arg_attribute])
      end

      def opt_selection
        @opt_selection ||= instance_double(Domainic::Attributer::AttributeSet, attributes: [opt_attribute])
      end

      it 'is expected to assign argument values' do
        assign
        expect(base).to have_received(:required_arg=).once.with(:arg_value)
      end

      it 'is expected to assign option values' do
        assign
        expect(base).to have_received(:optional=).once.with(:opt_value)
      end
    end
  end

  private

  def build_signature(argument: false, option: false)
    instance_double(
      Domainic::Attributer::Attribute::Signature,
      argument?: argument,
      option?: option
    )
  end

  def build_attribute(name, signature)
    instance_double(
      Domainic::Attributer::Attribute,
      default?: !signature.argument?,
      name: name,
      signature: signature
    )
  end
end
