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
      set.add(:self, :test, :test_constraint, 'test value', abort_on_failure: true)
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
        set.add('self', 'test', 'test constraint', 'test value')
      end

      it 'is expected to convert them to symbols' do
        add_constraint
        expect(set.find(:self, 'test constraint')).to be_a(constraint_class)
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
        set.add(:self, :test, :test_constraint1)
        set.add(:length, :test, :test_constraint2)
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
        set.add(:self, :test, :test_constraint2)
        set.add(:length, :test, :test_constraint2)
      end

      it { is_expected.to eq(2) }
    end
  end

  describe '#description' do
    subject(:description) { set.description }

    context 'when no constraints exist' do
      it { is_expected.to be_empty }
    end

    context 'when constraints exist' do
      before do
        set.add(:self, :test, 'being a', 'test value')
        set.add(:length, :test, 'having length', 'test value')
      end

      it { is_expected.to eq('being a test value, having length test value') }
    end

    context 'when constraints should not be described' do
      before do
        set.add(:self, :test, 'being a not_described', 'test value')
        set.add(:length, :test, 'having length', 'test value')
      end

      it { is_expected.to eq('having length test value') }
    end
  end

  describe '#exist?' do
    subject(:exist) { set.exist?(accessor, quantifier_description) }

    let(:accessor) { :self }
    let(:quantifier_description) { :test_constraint }

    context 'when the constraint exists' do
      before do
        set.add(accessor, :test, quantifier_description)
      end

      it { is_expected.to be true }
    end

    context 'when the constraint does not exist' do
      it { is_expected.to be false }
    end

    context 'when using string identifiers', rbs: :skip do
      let(:accessor) { 'self' }
      let(:quantifier_description) { 'test_constraint' }

      before do
        set.add(accessor, :test, quantifier_description)
      end

      it { is_expected.to be true }
    end
  end

  describe '#failures?' do
    subject(:failures?) { set.failures? }

    context 'when no constraints exist' do
      it { is_expected.to be false }
    end

    context 'when no constraints have failed' do
      before do
        set.add(:self, :test, 'being a', 'test value')
      end

      it { is_expected.to be false }
    end

    context 'when constraints have failed' do
      let(:constraint_class) do
        Class.new do
          include Domainic::Type::Constraint::Behavior

          protected

          def satisfies_constraint? = false
        end
      end

      before do
        set.add(:self, :test, 'being a', 'test value')
        set.all.each { |constraint| constraint.satisfied?('test') }
      end

      it { is_expected.to be true }
    end
  end

  describe '#find' do
    subject(:find) { set.find(accessor, quantifier_description) }

    let(:accessor) { :self }
    let(:quantifier_description) { :test_constraint }

    context 'when the constraint exists' do
      before do
        set.add(accessor, :test, quantifier_description)
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
      let(:quantifier_description) { 'test_constraint' }

      before do
        set.add(accessor, :test, quantifier_description)
      end

      it 'is expected to convert them to symbols' do
        expect(find).to be_a(constraint_class)
      end
    end
  end

  describe '#violation_description' do
    subject(:violation_description) { set.violation_description }

    let(:constraint_class) do
      Class.new do
        include Domainic::Type::Constraint::Behavior

        def short_description = @expected.to_s
        def short_violation_description = @actual.to_s

        protected

        def satisfies_constraint? = false
      end
    end

    context 'when no constraints exist' do
      it { is_expected.to be_empty }
    end

    context 'when constraints exist' do
      before do
        set.add(:self, :test, 'being a', 'test value')
        constraint = set.find(:self, 'being a')
        constraint.satisfied?('actual value')
      end

      it { is_expected.to eq('being a actual value') }
    end
  end
end
