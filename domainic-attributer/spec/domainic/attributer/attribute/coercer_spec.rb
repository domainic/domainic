# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Attributer::Attribute::Coercer do
  let(:attribute) { instance_double(Domainic::Attributer::Attribute, base: test_class, name: :test) }
  let(:test_class) do
    Class.new do
      def coerce_value(value)
        value.to_s
      end
    end
  end

  describe '.new' do
    subject(:coercer) { described_class.new(attribute, handlers) }

    context 'with a Proc handler' do
      let(:handlers) { lambda(&:to_s) }

      it { expect { coercer }.not_to raise_error }
    end

    context 'with a Symbol handler' do
      subject(:handlers) { :coerce_value }

      it { expect { coercer }.not_to raise_error }
    end

    context 'with multiple handlers' do
      subject(:handlers) { [proc(&:to_s), :coerce_value] }

      it { expect { coercer }.not_to raise_error }
    end

    context 'with an invalid handler', rbs: :skip do
      let(:handlers) { 42 }

      it { expect { coercer }.to raise_error(TypeError, /invalid coercer: 42/) }
    end

    context 'with a Symbol that does not map to a method on the base class' do
      let(:handlers) { :non_existent }

      it { expect { coercer }.to raise_error(TypeError, /invalid coercer:/) }
    end
  end

  describe '#call' do
    subject(:call) { coercer.call(test_class.new, value) }

    let(:coercer) { described_class.new(attribute, handlers) }

    context 'with a Proc handler' do
      let(:handlers) { lambda(&:to_s) }
      let(:value) { 42 }

      it 'is expected to coerce the value using the Proc' do
        expect(call).to eq('42')
      end
    end

    context 'with a Symbol handler' do
      let(:handlers) { :coerce_value }
      let(:value) { 42 }

      it 'is expected to coerce the value using the method' do
        expect(call).to eq('42')
      end
    end

    context 'with multiple handlers' do
      let(:handlers) { [proc(&:to_s), :coerce_value] }
      let(:value) { 42 }

      it 'is expected to coerce the value using all handlers' do
        expect(call).to eq('42')
      end
    end

    context 'when a handler raises an error' do
      let(:value) { 42 }
      let(:handlers) { [->(*) { raise 'Error' }] }

      it { expect { call }.to raise_error(Domainic::Attributer::CoercionExecutionError, /Failed to coerce 42/) }
    end
  end
end
