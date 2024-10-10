# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/base_type'
require 'domainic/type/constraint/base_constraint'
require 'domainic/type/constraint/parameter'

RSpec.describe Domainic::Type::Constraint::Parameter do
  let(:constraint) { instance_double(Domainic::Type::Constraint::BaseConstraint) }

  describe '#initialize' do
    subject(:new_instance) { described_class.new(constraint, **options) }

    context 'when given valid options' do
      let(:options) { { description: 'A test parameter', name: :test } }

      it 'is expected to have the appropriate attributes' do
        expect(new_instance).to have_attributes(**options)
      end

      it 'is expected to default @callbacks to empty array' do
        expect(new_instance.instance_variable_get(:@callbacks)).to eq([])
      end

      it 'is expected to default @coercers to empty array' do
        expect(new_instance.instance_variable_get(:@coercers)).to eq([])
      end

      it 'is expected to default @default to UNSPECIFIED' do
        expect(new_instance.instance_variable_get(:@default)).to eq(Domainic::Type::UNSPECIFIED)
      end

      it 'is expected to default @required to false' do
        expect(new_instance.instance_variable_get(:@required)).to be(false)
      end

      it 'is expected to default @validator to a Proc that always returns true' do
        expect(new_instance.instance_variable_get(:@validator).call(nil)).to be(true)
      end

      it 'is expected to default @value to UNSPECIFIED' do
        expect(new_instance.instance_variable_get(:@value)).to eq(Domainic::Type::UNSPECIFIED)
      end
    end

    context 'when given callbacks' do
      let(:callback) { ->(value) { value } }

      let(:options) { { callbacks: [callback], description: 'A test parameter', name: :test } }

      it 'is expected to set @callbacks to the given callbacks' do
        expect(new_instance.instance_variable_get(:@callbacks)).to eq([callback])
      end
    end

    context 'when given coercers' do
      let(:coercer) { ->(value) { value } }

      let(:options) { { coercers: [coercer], description: 'A test parameter', name: :test } }

      it 'is expected to set @coercers to the given coercers' do
        expect(new_instance.instance_variable_get(:@coercers)).to eq([coercer])
      end
    end

    context 'when given a default' do
      let(:options) { { default: 'default value', description: 'A test parameter', name: :test } }

      it 'is expected to set @default to the given default' do
        expect(new_instance).to have_attributes(default?: true, default: 'default value')
      end
    end

    context 'when required' do
      let(:options) { { description: 'A test parameter', name: :test, required: true } }

      it 'is expected to set @required to true' do
        expect(new_instance.required?).to be true
      end
    end

    context 'when given a validator' do
      let(:validator) { ->(value) { value } }

      let(:options) { { description: 'A test parameter', name: :test, validator: } }

      it 'is expected to set @validator to the given validator' do
        expect(new_instance.instance_variable_get(:@validator)).to eq(validator)
      end
    end
  end

  describe '#default' do
    subject(:default) { parameter.default }

    context 'when given a default' do
      let(:parameter) { described_class.new(constraint, default: 'default value', name: :test) }

      it { is_expected.to eq('default value') }
    end

    context 'when not given a default' do
      let(:parameter) { described_class.new(constraint, name: :test) }

      it { is_expected.to be_nil }
    end
  end

  describe '#default?' do
    subject(:default?) { parameter.default? }

    context 'when given a default' do
      let(:parameter) { described_class.new(constraint, default: 'default value', name: :test) }

      it { is_expected.to be true }
    end

    context 'when not given a default' do
      let(:parameter) { described_class.new(constraint, name: :test) }

      it { is_expected.to be false }
    end
  end

  describe '#dup_with_base' do
    subject(:dup_with_base) { parameter.dup_with_base(new_base) }

    let(:parameter) { described_class.new(constraint, name: :test) }
    let(:new_base) { instance_double(Domainic::Type::Constraint::BaseConstraint) }

    it 'is expected to return a new instance' do
      expect(dup_with_base).to be_an_instance_of(described_class)
    end

    it 'is expected to have the appropriate base class' do
      expect(dup_with_base.instance_variable_get(:@base)).to eq(new_base)
    end
  end

  describe '#required?' do
    subject(:required?) { parameter.required? }

    context 'when required' do
      let(:parameter) { described_class.new(constraint, name: :test, required: true) }

      it { is_expected.to be true }
    end

    context 'when not required' do
      let(:parameter) { described_class.new(constraint, name: :test) }

      it { is_expected.to be false }
    end
  end

  describe '#value' do
    subject(:value) { parameter.value }

    context 'when given a value' do
      let(:parameter) { described_class.new(constraint, name: :test) }

      before { parameter.instance_variable_set(:@value, 'value') }

      it { is_expected.to eq('value') }
    end

    context 'when not given a value' do
      context 'when given a default' do
        let(:parameter) { described_class.new(constraint, default: 'default value', name: :test) }

        it { is_expected.to eq('default value') }
      end

      context 'when not given a default' do
        let(:parameter) { described_class.new(constraint, name: :test) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#value=' do
    subject(:set_value) { parameter.value = new_value }

    let(:parameter) { described_class.new(constraint, name: :test) }
    let(:new_value) { 'new value' }

    it 'is expected to set the value' do
      expect { set_value }.to change(parameter, :value).from(nil).to(new_value)
    end

    context 'when given change callbacks' do
      before do
        allow(constraint).to receive(:instance_exec)
          .with(anything, &parameter.instance_variable_get(:@validator))
          .and_return(true)
        allow(constraint).to receive(:instance_exec).with(anything, &callback)
      end

      let(:parameter) { described_class.new(constraint, callbacks: [callback], name: :test) }
      let(:callback) { ->(value) { value } }
      let(:new_value) { 'new value' }

      it 'is expected to call the callback' do
        set_value

        expect(constraint).to have_received(:instance_exec).with(anything, &callback).twice
      end
    end

    context 'when given a coercer' do
      let(:parameter) { described_class.new(constraint, name: :test, coercers: [coercer]) }
      let(:new_value) { 1 }

      context 'when the coercer is a Proc' do
        let(:coercer) { lambda(&:to_s) }

        it 'is expected to coerce the value' do
          expect { set_value }.to change(parameter, :value).from(nil).to('1')
        end
      end

      context 'when the coercer is a Symbol and the constraint responds to the method' do
        let(:constraint) do
          klass = Class.new(Domainic::Type::Constraint::BaseConstraint) do
            def self.name
              'TestConstraint'
            end

            private

            def coerce_test(value)
              value.to_s
            end
          end
          klass.new
        end

        let(:coercer) { :coerce_test }

        it 'is expected to coerce the value' do
          expect { set_value }.to change(parameter, :value).from(nil).to('1')
        end
      end

      context 'when the coercer is true and the constraint responds to the method matching the parameter name' do
        let(:constraint) do
          klass = Class.new(Domainic::Type::Constraint::BaseConstraint) do
            def self.name
              'TestConstraint'
            end

            private

            def coerce_test(value)
              value.to_s
            end
          end
          klass.new
        end

        let(:coercer) { true }

        it 'is expected to coerce the value' do
          expect { set_value }.to change(parameter, :value).from(nil).to('1')
        end
      end
    end

    context 'when given a validator' do
      let(:parameter) { described_class.new(constraint, name: :test, validator:) }
      let(:new_value) { 1 }

      context 'when the validator is a Proc and the value is valid' do
        let(:validator) { ->(value) { value.is_a?(Integer) } }

        it 'is expected to set the value' do
          expect { set_value }.to change(parameter, :value).from(nil).to(new_value)
        end
      end

      context 'when the validator is a Proc and the value is invalid' do
        let(:validator) { ->(value) { value.is_a?(String) } }

        it 'is expected to raise an InvalidParameterError' do
          expect { set_value }.to raise_error(Domainic::Type::InvalidParameterError)
        end
      end

      context 'when the validator is a Symbol and the base responds to the method and the value is valid' do
        let(:constraint) do
          klass = Class.new(Domainic::Type::Constraint::BaseConstraint) do
            def self.name
              'TestConstraint'
            end

            private

            def validate_test(value)
              value.is_a?(Integer)
            end
          end
          klass.new
        end

        let(:validator) { :validate_test }

        it 'is expected to set the value' do
          expect { set_value }.to change(parameter, :value).from(nil).to(new_value)
        end
      end

      context 'when the validator is a Symbol and the base responds to the method and the value is invalid' do
        let(:constraint) do
          klass = Class.new(Domainic::Type::Constraint::BaseConstraint) do
            def self.name
              'TestConstraint'
            end

            private

            def validate_test(value)
              value.is_a?(String)
            end
          end
          klass.new
        end

        let(:validator) { :validate_test }

        it 'is expected to raise an InvalidParameterError' do
          expect { set_value }.to raise_error(Domainic::Type::InvalidParameterError)
        end
      end
    end
  end
end
