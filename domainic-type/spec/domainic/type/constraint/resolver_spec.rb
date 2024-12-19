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

  after do
    # Explicitly reset the registry to isolate tests
    described_class.instance_variable_set(:@registry, nil)
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

  describe '.register_constraint' do
    let(:lookup_key) { :new_constraint }
    let(:constant_name) { 'Domainic::Type::Constraint::NewConstraint' }
    let(:require_path) { 'domainic/type/constraint/constraints/new_constraint' }

    it 'is expected to register a new constraint' do
      expect do
        described_class.register_constraint(lookup_key, constant_name, require_path)
      end.to change { described_class.send(:registry).key?(lookup_key) }.from(false).to(true)
    end

    it 'is expected to raise an error if the constraint is already registered' do
      described_class.register_constraint(lookup_key, constant_name, require_path)
      expect do
        described_class.register_constraint(lookup_key, constant_name, require_path)
      end.to raise_error(ArgumentError, "Constraint already registered: #{lookup_key}")
    end
  end

  describe '#resolve!' do
    context 'when the constraint is registered' do
      before do
        described_class.register_constraint(
          :test,
          'Domainic::Type::Constraint::TestConstraint',
          'domainic/type/constraint/constraints/test_constraint'
        )
      end

      it 'is expected to load and return the constraint class' do
        expect(resolver).to eq(Domainic::Type::Constraint::TestConstraint)
      end
    end

    context 'when the constraint is not registered' do
      it 'is expected to raise ArgumentError' do
        expect { resolver }.to raise_error(ArgumentError, 'Unknown constraint: test')
      end
    end

    context 'when the constraint file cannot be loaded' do
      before do
        described_class.register_constraint(
          :test,
          'Domainic::Type::Constraint::TestConstraint',
          'domainic/type/constraint/constraints/nonexistent_constraint'
        )
        allow(instance).to receive(:require).and_raise(LoadError)
      end

      it 'is expected to raise ArgumentError' do
        expect { resolver }.to raise_error(ArgumentError, "Constraint require path doesn't exist: test")
      end
    end
  end
end
