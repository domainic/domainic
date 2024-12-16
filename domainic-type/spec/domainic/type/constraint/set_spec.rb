# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/behavior'
require 'domainic/type/constraint/set'

RSpec.describe Domainic::Type::Constraint::Set do
  let(:set) { described_class.new }
  let(:constraint_class) do
    Class.new do
      include Domainic::Type::Constraint::Behavior

      def initialize(accessor)
        super
        @expected = nil
        @options = {}
      end

      def expecting(expectation)
        @expected = expectation
        self
      end

      def with_options(**options)
        @options = options
        self
      end

      protected

      def satisfies_constraint?
        true
      end
    end
  end

  before do
    stub_const('Domainic::Type::Constraint::TestConstraint', constraint_class)
    allow(Domainic::Type::Constraint::Resolver).to receive(:resolve!)
      .with(:test).and_return(constraint_class)
  end

  describe '#add' do
    subject(:add_constraint) do
      set.add(:self, :test_constraint, :test, 'test value', abort_on_failure: true)
    end

    it 'is expected to create a new constraint' do
      add_constraint
      constraint = set.find(:self, :test_constraint)
      expect(constraint).to be_a(constraint_class)
    end

    it 'is expected to set the expectation' do
      add_constraint
      constraint = set.find(:self, :test_constraint)
      expect(constraint.instance_variable_get(:@expected)).to eq('test value')
    end

    it 'is expected to set the options' do
      add_constraint
      constraint = set.find(:self, :test_constraint)
      expect(constraint.instance_variable_get(:@options)).to eq(abort_on_failure: true)
    end

    context 'when using string identifiers', rbs: :skip do
      subject(:add_constraint) do
        set.add('self', 'test_constraint', 'test', 'test value')
      end

      it 'is expected to convert them to symbols' do
        add_constraint
        expect(set.find(:self, :test_constraint)).to be_a(constraint_class)
      end
    end
  end

  describe '#all' do
    subject(:all_constraints) { set.all }

    context 'when no constraints exist' do
      it { is_expected.to be_empty }
    end

    context 'when constraints exist' do
      before do
        set.add(:self, :test_constraint1, :test)
        set.add(:length, :test_constraint2, :test)
      end

      it 'is expected to return all constraints' do
        expect(all_constraints).to all(be_a(constraint_class))
      end

      it { is_expected.to have_attributes(size: 2) }
    end
  end

  describe '#count' do
    subject(:count) { set.count }

    context 'when no constraints exist' do
      it { is_expected.to eq(0) }
    end

    context 'when constraints exist' do
      before do
        set.add(:self, :test_constraint1, :test)
        set.add(:length, :test_constraint2, :test)
      end

      it { is_expected.to eq(2) }
    end
  end

  describe '#exist?' do
    subject(:exist) { set.exist?(accessor, constraint_name) }

    let(:accessor) { :self }
    let(:constraint_name) { :test_constraint }

    context 'when the constraint exists' do
      before do
        set.add(:self, :test_constraint, :test)
      end

      it { is_expected.to be true }
    end

    context 'when the constraint does not exist' do
      it { is_expected.to be false }
    end

    context 'when using string identifiers', rbs: :skip do
      let(:accessor) { 'self' }
      let(:constraint_name) { 'test_constraint' }

      before do
        set.add(:self, :test_constraint, :test)
      end

      it { is_expected.to be true }
    end
  end

  describe '#find' do
    subject(:find) { set.find(accessor, constraint_name) }

    let(:accessor) { :self }
    let(:constraint_name) { :test_constraint }

    context 'when the constraint exists' do
      before do
        set.add(:self, :test_constraint, :test)
      end

      it 'is expected to return the constraint' do
        expect(find).to be_a(constraint_class)
      end
    end

    context 'when the constraint does not exist' do
      it { is_expected.to be_nil }
    end

    context 'when using string identifiers', rbs: :skip do
      let(:accessor) { 'self' }
      let(:constraint_name) { 'test_constraint' }

      before do
        set.add(:self, :test_constraint, :test)
      end

      it 'is expected to convert them to symbols' do
        expect(find).to be_a(constraint_class)
      end
    end
  end
end
