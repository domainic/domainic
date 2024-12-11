# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Attributer::ClassMethods do
  let(:dummy_class) do
    Class.new do
      extend Domainic::Attributer::ClassMethods
    end
  end

  describe '.argument' do
    subject(:argument) { dummy_class.argument(name, type_validator, **options) }

    let(:name) { :test_argument }
    let(:type_validator) { ->(value) { value.is_a?(String) } }
    let(:options) { { read: :private } }

    it 'is expected to add the argument to __attributes__' do
      argument
      attribute = dummy_class.send(:__attributes__)[name]
      aggregate_failures do
        expect(attribute).to be_a(Domainic::Attributer::Attribute)
        expect(attribute.signature.type).to eq(:argument)
      end
    end

    it 'is expected to create accessor methods' do
      argument
      aggregate_failures do
        expect(dummy_class.private_method_defined?(name)).to be true
        expect(dummy_class.method_defined?(:"#{name}=")).to be true
      end
    end
  end

  describe '.option' do
    subject(:option) { dummy_class.option(name, type_validator, **options) }

    let(:name) { :test_option }
    let(:type_validator) { ->(value) { value.is_a?(Integer) } }
    let(:options) { { read: :private } }

    it 'is expected to add the option to __attributes__' do
      option
      attribute = dummy_class.send(:__attributes__)[name]
      aggregate_failures do
        expect(attribute).to be_a(Domainic::Attributer::Attribute)
        expect(attribute.signature.type).to eq(:option)
      end
    end

    it 'is expected to create accessor methods' do
      option
      aggregate_failures do
        expect(dummy_class.private_method_defined?(name)).to be true
        expect(dummy_class.method_defined?(:"#{name}=")).to be true
      end
    end
  end

  describe '.inherited' do
    let(:parent_class) { dummy_class }
    let(:child_class) { Class.new(parent_class) }

    before do
      parent_class.argument :parent_arg
      parent_class.option :parent_opt
    end

    it 'is expected to copy parent attributes to child' do
      expect(child_class.send(:__attributes__).attribute_names)
        .to match_array(%i[parent_arg parent_opt])
    end

    it 'is expected to create independent copies' do
      expect(child_class.send(:__attributes__)[:parent_arg])
        .not_to equal(parent_class.send(:__attributes__)[:parent_arg])
    end
  end
end
