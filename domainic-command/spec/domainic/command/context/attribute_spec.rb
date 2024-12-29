# frozen_string_literal: true

require 'rspec'
require 'domainic/command/context/attribute'

RSpec.describe Domainic::Command::Context::Attribute do
  describe '.new' do
    subject(:attribute) { described_class.new(name, *type_validator_and_description, **options) }

    let(:name) { :test_attribute }
    let(:type_validator_and_description) { [] }
    let(:options) { {} }

    context 'when only the name is provided' do
      it { is_expected.to have_attributes(name: :test_attribute, description: nil, required?: false) }
    end

    context 'when a description is provided' do
      let(:type_validator_and_description) { ['A sample description'] }

      it { is_expected.to have_attributes(description: 'A sample description') }
    end

    context 'when required is set to true' do
      let(:options) { { required: true } }

      it { is_expected.to have_attributes(required?: true) }
    end
  end

  describe '#default' do
    subject(:default) { attribute.default }

    let(:attribute) { described_class.new(name, **options) }
    let(:name) { :attribute_name }
    let(:options) { {} }

    context 'when a static default value is set' do
      let(:options) { { default: 'default_value' } }

      it { is_expected.to eq('default_value') }
    end

    context 'when a default generator is provided' do
      let(:options) { { default_generator: -> { 'generated_value' } } }

      it { is_expected.to eq('generated_value') }
    end

    context 'when no default is set' do
      it { is_expected.to be_nil }
    end
  end

  describe '#valid?' do
    subject(:valid?) { attribute.valid?(value) }

    let(:attribute) { described_class.new(name, *type_validator_and_description, **options) }
    let(:name) { :attribute_name }
    let(:type_validator_and_description) { [] }
    let(:options) { {} }
    let(:value) { nil }

    context 'when a Proc validator is used' do
      let(:type_validator_and_description) { [->(val) { val.is_a?(String) }] }

      context 'with a valid value' do
        let(:value) { 'valid' }

        it { is_expected.to be true }
      end

      context 'with an invalid value' do
        let(:value) { 123 }

        it { is_expected.to be false }
      end
    end

    context 'when a type class is used' do
      let(:type_validator_and_description) { [String] }

      context 'with a valid value' do
        let(:value) { 'valid' }

        it { is_expected.to be true }
      end

      context 'with an invalid value' do
        let(:value) { 123 }

        it { is_expected.to be false }
      end
    end

    context 'when the attribute is required and the value is nil' do
      let(:options) { { required: true } }

      it { is_expected.to be false }
    end
  end
end
