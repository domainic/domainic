# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Attributer::Builder do
  let(:base) { Class.new }

  describe '#initialize' do
    subject(:initialize_builder) { described_class.new(base) }

    it 'is expected to create a new Builder' do
      expect(initialize_builder).to be_a(described_class)
    end
  end

  describe '#build!' do
    subject(:build!) { builder.build! }

    let(:builder) { described_class.new(base) }

    context 'with no definitions' do
      it 'is expected to return self' do
        expect(build!).to eq(builder)
      end
    end

    context 'with a pending definition' do
      let(:definitions) { {} }

      before do
        allow(base).to receive(:__attribute_definitions__).and_return(definitions)
        builder.define(:test)
      end

      it 'is expected to add the definition to the base' do
        build!
        expect(definitions[:test]).to be_a(Domainic::Attributer::AttributeDefinition)
      end

      it 'is expected to clear the current definition' do
        build!
        expect { builder.required }.to raise_error(RuntimeError)
      end
    end
  end

  describe '#coerce_with' do
    subject(:coerce_with) { builder.coerce_with(coercer) }

    let(:builder) { described_class.new(base) }
    let(:coercer) { lambda(&:to_s) }
    let(:definitions) { {} }

    before do
      allow(base).to receive(:__attribute_definitions__).and_return(definitions)
      builder.define(:test)
    end

    it 'is expected to add the coercer' do
      coerce_with.build!
      attribute = definitions[:test].attribute
      expect(attribute.send(:instance_variable_get, :@options)[:coercers]).to include(coercer)
    end
  end

  describe '#define' do
    subject(:define) do
      builder.define(name, definition_params[:validator], **definition_params[:options], &definition_params[:block])
    end

    let(:builder) { described_class.new(base) }
    let(:name) { :test }
    let(:definition_params) { { validator: nil, options: {}, block: nil } }

    it 'is expected to return self' do
      expect(define).to eq(builder)
    end

    context 'with a type validator' do
      let(:definition_params) { { validator: String, options: {} } }
      let(:definitions) { {} }

      before { allow(base).to receive(:__attribute_definitions__).and_return(definitions) }

      it 'is expected to set the validator' do
        define.build!
        attribute = definitions[:test].attribute
        expect(attribute.send(:instance_variable_get, :@options)[:validators]).to include(String)
      end
    end

    context 'with a configuration block' do
      let(:definition_params) { { validator: nil, options: {}, block: -> { required } } }
      let(:definitions) { {} }

      before { allow(base).to receive(:__attribute_definitions__).and_return(definitions) }

      it 'is expected to execute the block' do
        define.build!
        attribute = definitions[:test].attribute
        expect(attribute.required?).to be true
      end
    end
  end

  describe '#default' do
    subject(:default) { builder.default(value) }

    let(:builder) { described_class.new(base) }
    let(:value) { 'test' }
    let(:definitions) { {} }

    before do
      allow(base).to receive(:__attribute_definitions__).and_return(definitions)
      builder.define(:test)
    end

    it 'is expected to set the default value' do
      default.build!
      attribute = definitions[:test].attribute
      expect(attribute.default).to eq('test')
    end

    context 'when the value is falsy' do
      let(:value) { false }

      it 'is expected to set the value' do
        default.build!
        attribute = definitions[:test].attribute
        expect(attribute.default).to be(false)
      end
    end
  end

  describe '#description' do
    subject(:description) { builder.description(text) }

    let(:builder) { described_class.new(base) }
    let(:text) { 'test description' }
    let(:definitions) { {} }

    before do
      allow(base).to receive(:__attribute_definitions__).and_return(definitions)
      builder.define(:test)
    end

    it 'is expected to set the description' do
      description.build!
      attribute = definitions[:test].attribute
      expect(attribute.description).to eq(text)
    end
  end

  describe '#on_change' do
    subject(:on_change) { builder.on_change(callback) }

    let(:builder) { described_class.new(base) }
    let(:callback) { ->(value) { value } }
    let(:definitions) { {} }

    before do
      allow(base).to receive(:__attribute_definitions__).and_return(definitions)
      builder.define(:test)
    end

    it 'is expected to add the callback' do
      on_change.build!
      attribute = definitions[:test].attribute
      expect(attribute.send(:instance_variable_get, :@options)[:callbacks]).to include(callback)
    end
  end

  describe '#required' do
    subject(:required) { builder.required }

    let(:builder) { described_class.new(base) }
    let(:definitions) { {} }

    before do
      allow(base).to receive(:__attribute_definitions__).and_return(definitions)
      builder.define(:test)
    end

    it 'is expected to make the attribute required' do
      required.build!
      attribute = definitions[:test].attribute
      expect(attribute.required?).to be true
    end
  end

  describe '#validate_with' do
    subject(:validate_with) { builder.validate_with(validator) }

    let(:builder) { described_class.new(base) }
    let(:validator) { ->(value) { value.is_a?(String) } }
    let(:definitions) { {} }

    before do
      allow(base).to receive(:__attribute_definitions__).and_return(definitions)
      builder.define(:test)
    end

    it 'is expected to add the validator' do
      validate_with.build!
      attribute = definitions[:test].attribute
      expect(attribute.send(:instance_variable_get, :@options)[:validators]).to include(validator)
    end
  end
end
