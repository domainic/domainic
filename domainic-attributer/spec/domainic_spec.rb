# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic do
  describe '.Attributer' do
    subject(:include_module) { klass.include(described_class.Attributer(aliased_name)) }

    let(:klass) { Class.new }
    let(:aliased_name) { :property }

    it 'is expected to extend the class with ClassMethods' do
      include_module
      expect(klass.singleton_class.included_modules).to include(Domainic::Attributer::ClassMethods)
    end

    it 'is expected to include InstanceMethods' do
      include_module
      expect(klass.included_modules).to include(Domainic::Attributer::InstanceMethods)
    end

    it 'is expected to alias the option method' do
      include_module
      expect(klass).to respond_to(aliased_name)
    end

    context 'when using the aliased method' do
      before { include_module }

      it 'is expected to define attributes' do
        expect do
          klass.class_eval do
            property :name, String
          end
        end.not_to raise_error
      end

      it 'is expected to create working attributes' do
        klass.class_eval do
          property :age do
            coerce(&:to_i)
            validates(&:positive?)
          end
        end

        instance = klass.new(age: '42')
        expect(instance.age).to eq(42)
      end
    end
  end
end
