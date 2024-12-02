# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Attributer::MethodInjector do
  subject(:injector) { described_class.new(base_class) }

  let(:base_class) do
    Class.new do
      include Domainic::Attributer::InstanceMethods
    end
  end

  let(:attribute_name) { :test_attribute }
  let(:attribute) do
    Domainic::Attributer::Attribute.new(base_class, name: attribute_name)
  end
  let(:attribute_definition) do
    Domainic::Attributer::AttributeDefinition.new(
      attribute,
      reader: :public,
      writer: :public
    )
  end

  describe '#initialize' do
    subject(:method_injector) { described_class.new(base_class) }

    it 'is expected to set the base class' do
      expect(method_injector.instance_variable_get(:@base)).to eq(base_class)
    end
  end

  describe '#inject!' do
    subject(:inject!) { injector.inject!(attribute_definition) }

    it 'is expected to inject reader method into base class' do
      expect { inject! }.to change { base_class.instance_methods.include?(attribute_name) }.from(false).to(true)
    end

    it 'is expected to inject writer method into base class' do
      writer_method = :"#{attribute_name}="
      expect { inject! }.to change { base_class.instance_methods.include?(writer_method) }.from(false).to(true)
    end

    it 'is expected to inject undefined check method into base class' do
      undefined_method = :"#{attribute_name}_undefined?"
      expect { inject! }.to change { base_class.instance_methods.include?(undefined_method) }.from(false).to(true)
    end

    context 'when methods already exist' do
      before do
        base_class.define_method(attribute_name) { 'existing method' }
        base_class.define_method(:"#{attribute_name}=") { |value| value }
        base_class.define_method(:"#{attribute_name}_undefined?") { false }
      end

      it 'is expected not to redefine existing reader method' do
        original_method = base_class.instance_method(attribute_name)
        inject!
        expect(base_class.instance_method(attribute_name)).to eq(original_method)
      end

      it 'is expected not to redefine existing writer method' do
        original_method = base_class.instance_method(:"#{attribute_name}=")
        inject!
        expect(base_class.instance_method(:"#{attribute_name}=")).to eq(original_method)
      end

      it 'is expected not to redefine existing undefined check method' do
        original_method = base_class.instance_method(:"#{attribute_name}_undefined?")
        inject!
        expect(base_class.instance_method(:"#{attribute_name}_undefined?")).to eq(original_method)
      end
    end
  end
end
