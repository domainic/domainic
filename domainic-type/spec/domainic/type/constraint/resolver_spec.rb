# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/resolver'

RSpec.describe Domainic::Type::Constraint::Resolver do
  subject(:resolver) { instance.resolve! }

  let(:instance) { described_class.new(constraint_type) }
  let(:constraint_type) { :test }

  before do
    stub_const('Domainic::Type::Constraint::TestConstraint', Class.new)
    allow(instance).to receive(:require)
  end

  describe '.resolve!' do
    subject(:resolve) { described_class.resolve!(constraint_type) }

    let(:resolver_instance) { instance_double(described_class) }

    before do
      allow(described_class).to receive(:new).with(constraint_type).and_return(resolver_instance)
      allow(resolver_instance).to receive(:resolve!)
        .and_return(Domainic::Type::Constraint::TestConstraint)
    end

    it 'is expected to create a new resolver instance' do
      resolve
      expect(described_class).to have_received(:new).with(constraint_type)
    end

    it 'is expected to resolve the constraint' do
      resolve
      expect(resolver_instance).to have_received(:resolve!)
    end
  end

  describe '#resolve!' do
    it 'is expected to load and return the constraint class' do
      expect(resolver).to eq(Domainic::Type::Constraint::TestConstraint)
    end

    context 'when the constraint file cannot be loaded' do
      before do
        allow(instance).to receive(:require).and_raise(LoadError)
      end

      it 'is expected to raise ArgumentError' do
        expect { resolver }.to raise_error(
          ArgumentError,
          'Unknown constraint: test'
        )
      end
    end

    context 'when the constraint constant cannot be found' do
      before do
        allow(Domainic::Type::Constraint).to receive(:const_get)
          .with('TestConstraint')
          .and_raise(NameError)
      end

      it 'is expected to raise ArgumentError' do
        expect { resolver }.to raise_error(
          ArgumentError,
          'Unknown constraint: test'
        )
      end
    end

    context 'with constraint type containing boolean suffix' do
      let(:constraint_type) { :test? }

      it 'is expected to strip the suffix when loading' do
        resolver
        expect(instance).to have_received(:require)
          .with('domainic/type/constraint/constraints/test_constraint')
      end
    end

    context 'with constraint type containing bang suffix' do
      let(:constraint_type) { :test! }

      it 'is expected to strip the suffix when loading' do
        resolver
        expect(instance).to have_received(:require)
          .with('domainic/type/constraint/constraints/test_constraint')
      end
    end
  end
end
