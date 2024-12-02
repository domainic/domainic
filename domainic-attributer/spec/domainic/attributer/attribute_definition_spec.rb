# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Attributer::AttributeDefinition do
  let(:attribute) { Domainic::Attributer::Attribute.new(Class.new, name: :test) }

  describe '#initialize' do
    subject(:initialize_definition) { described_class.new(attribute, **options) }

    context 'with defaults' do
      let(:options) { {} }

      it 'is expected to use public visibility for both accessors' do
        expect(initialize_definition).to have_attributes(
          read_access: :public,
          write_access: :public
        )
      end
    end

    context 'with custom reader visibility' do
      let(:options) { { reader: :private } }

      it 'is expected to use specified reader visibility' do
        expect(initialize_definition.read_access).to eq(:private)
      end

      it 'is expected to use default writer visibility' do
        expect(initialize_definition.write_access).to eq(:public)
      end
    end

    context 'with custom writer visibility' do
      let(:options) { { writer: :private } }

      it 'is expected to use specified writer visibility' do
        expect(initialize_definition.write_access).to eq(:private)
      end

      it 'is expected to use default reader visibility' do
        expect(initialize_definition.read_access).to eq(:public)
      end
    end
  end

  describe '#attribute' do
    subject(:attribute_value) { attribute_definition.attribute }

    let(:attribute_definition) { described_class.new(attribute) }

    it 'is expected to return the underlying attribute' do
      expect(attribute_value).to eq(attribute)
    end
  end
end
