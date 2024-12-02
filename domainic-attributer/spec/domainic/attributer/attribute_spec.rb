# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Attributer::Attribute do
  let(:klass) do
    Class.new do
      private

      def coerce_method(value)
        value.upcase
      end
    end
  end

  describe '#initialize' do
    subject(:initialize_attribute) { described_class.new(klass, **options) }

    context 'with valid options' do
      let(:options) { { name: :test } }

      it 'is expected to create a new Attribute' do
        expect(initialize_attribute).to be_a(described_class)
      end
    end

    context 'with missing name' do
      let(:options) { {} }

      it 'is expected to raise ArgumentError' do
        expect { initialize_attribute }.to raise_error(ArgumentError, '`initialize`: missing keyword: :name')
      end
    end
  end

  describe '#default' do
    subject(:default) { attribute.default }

    let(:attribute) { described_class.new(klass, name: :test) }

    context 'with no default set' do
      it 'is expected to return nil' do
        expect(default).to be_nil
      end
    end

    context 'with static default' do
      let(:attribute) { described_class.new(klass, name: :test, default: 'test') }

      it 'is expected to return the default value' do
        expect(default).to eq('test')
      end
    end

    context 'with proc default' do
      let(:instance) { klass.new }
      let(:klass) do
        Class.new do
          def generate_default
            'generated'
          end
        end
      end

      let(:attribute) { described_class.new(instance, name: :test, default: -> { generate_default }) }

      it 'is expected to evaluate the proc in the context of base' do
        expect(default).to eq('generated')
      end
    end
  end

  describe '#default?' do
    subject(:default?) { attribute.default? }

    let(:attribute) { described_class.new(klass, name: :test) }

    context 'with no default set' do
      it 'is expected to return false' do
        expect(default?).to be false
      end
    end

    context 'with default set' do
      let(:attribute) { described_class.new(klass, name: :test, default: 'test') }

      it 'is expected to return true' do
        expect(default?).to be true
      end
    end
  end

  describe '#value' do
    subject(:value) { attribute.value }

    let(:attribute) { described_class.new(klass, name: :test) }

    context 'when undefined' do
      it 'is expected to return nil' do
        expect(value).to be_nil
      end
    end
  end

  describe '#value=' do
    subject(:set_value) { attribute.value = new_value }

    context 'with coercers' do
      let(:coercer_proc) { lambda(&:to_s) }
      let(:new_value) { :symbol }
      let(:coercer_method) { :coerce_method }

      let(:attribute) { described_class.new(klass.new, name: :test, coercers: [coercer_proc, coercer_method]) }

      it 'is expected to apply coercers in sequence' do
        set_value
        expect(attribute.value).to eq('SYMBOL')
      end
    end

    context 'with validators' do
      let(:attribute) do
        described_class.new(klass,
                            name: :test,
                            validators: [
                              ->(value) { value.is_a?(String) },
                              ->(value) { value.length > 2 }
                            ])
      end

      context 'with valid value' do
        let(:new_value) { 'test' }

        it 'is expected to accept the value' do
          expect { set_value }.not_to raise_error
        end

        it 'is expected to store the value' do
          set_value
          expect(attribute.value).to eq('test')
        end
      end

      context 'with invalid value' do
        let(:new_value) { 'a' }

        it 'is expected to raise ArgumentError' do
          expect { set_value }.to raise_error(ArgumentError)
        end
      end
    end

    context 'with callbacks' do
      let(:callbacks) do
        results = []
        {
          results: results,
          first: ->(value) { results << "first: #{value}" },
          second: ->(value) { results << "second: #{value}" }
        }
      end
      let(:new_value) { 'test' }
      let(:attribute) do
        described_class.new(klass, name: :test, callbacks: [callbacks[:first], callbacks[:second]])
      end

      it 'is expected to execute callbacks in order' do
        set_value
        expect(callbacks[:results]).to eq(['first: test', 'second: test'])
      end
    end
  end

  describe '#undefined?' do
    subject(:undefined?) { attribute.undefined? }

    let(:attribute) { described_class.new(klass, name: :test) }

    context 'when value never set' do
      it 'is expected to return true' do
        expect(undefined?).to be true
      end
    end

    context 'when value has been set' do
      before { attribute.value = 'test' }

      it 'is expected to return false' do
        expect(undefined?).to be false
      end
    end
  end
end
