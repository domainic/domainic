# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/behavior'
require 'domainic/type/constraint/set'

RSpec.describe Domainic::Type::Constraint::Set do
  let(:constraint_class) do
    Class.new do
      include Domainic::Type::Constraint::Behavior

      def initialize(accessor, description = nil)
        super
        @expected = nil
        @actual = nil
        @result = nil
      end

      def short_description
        'test constraint'
      end

      protected

      def satisfies_constraint?
        @result = true
      end
    end
  end

  before do
    stub_const('TestConstraint', constraint_class)
    allow(Domainic::Type::Constraint::Resolver).to receive(:resolve!).with(:test).and_return(TestConstraint)
  end

  describe '.new' do
    subject(:set) { described_class.new }

    it 'is expected to initialize an empty set' do
      expect(set.count).to eq(0)
    end
  end

  describe '#add' do
    subject(:add_constraint) { set.add(accessor, :test, expectation, **options) }

    let(:set) { described_class.new }
    let(:accessor) { :self }
    let(:expectation) { nil }
    let(:options) { {} }

    it 'is expected to add a constraint to the set' do
      expect { add_constraint }.to change(set, :count).by(1)
    end

    context 'when given a description option' do
      let(:options) { { description: 'test description' } }

      it 'is expected to set the description on the constraint' do
        add_constraint
        expect(set.description).to include('test description')
      end
    end

    context 'when given additional options' do
      let(:options) { { abort_on_failure: true } }

      it 'is expected to apply options to the constraint' do
        add_constraint
        expect(set.find(accessor, :test)).to be_abort_on_failure
      end
    end

    context 'when a constraint with the same accessor and concerning already exists' do
      before { set.add(accessor, :test, nil, concerning: :test) }

      let(:options) { { concerning: :test } }

      it 'is expected to update the existing constraint' do
        expect { add_constraint }.not_to(change(set, :count))
      end
    end
  end

  describe '#all' do
    subject(:all_constraints) { set.all }

    let(:set) { described_class.new }

    before do
      set.add(:self, :test)
      set.add(:length, :test)
    end

    it 'is expected to return all constraints' do
      expect(all_constraints.count).to eq(2)
    end
  end

  describe '#count' do
    subject(:count) { set.count }

    let(:set) { described_class.new }

    before do
      set.add(:self, :test)
      set.add(:length, :test)
    end

    it 'is expected to return the total number of constraints' do
      expect(count).to eq(2)
    end
  end

  describe '#description' do
    subject(:description) { set.description }

    let(:set) { described_class.new }

    before do
      set.add(:self, :test, nil, description: 'first test')
      set.add(:length, :test, nil, description: 'second test')
    end

    it 'is expected to return a combined description of all constraints' do
      expect(description).to eq('first test test constraint, second test test constraint')
    end
  end

  describe '#exist?' do
    subject(:exist?) { set.exist?(accessor, concerning) }

    let(:set) { described_class.new }
    let(:accessor) { :self }
    let(:concerning) { :test }

    context 'when the constraint exists' do
      before { set.add(accessor, :test, concerning: concerning) }

      it { is_expected.to be true }
    end

    context 'when the constraint does not exist' do
      it { is_expected.to be false }
    end
  end

  describe '#failures?' do
    subject(:failures?) { set.failures? }

    let(:set) { described_class.new }
    let(:constraint) { instance_double(TestConstraint, failure?: has_failures) }

    before do
      allow(TestConstraint).to receive(:new).and_return(constraint)
      allow(constraint).to receive_messages(expecting: constraint, with_options: constraint)
      set.add(:self, :test)
    end

    context 'when there are failures' do
      let(:has_failures) { true }

      it { is_expected.to be true }
    end

    context 'when there are no failures' do
      let(:has_failures) { false }

      it { is_expected.to be false }
    end
  end

  describe '#find' do
    subject(:find_constraint) { set.find(accessor, concerning) }

    let(:set) { described_class.new }
    let(:accessor) { :self }
    let(:concerning) { :test }

    context 'when the constraint exists' do
      before { set.add(accessor, :test, concerning: concerning) }

      it { is_expected.to be_a(TestConstraint) }
    end

    context 'when the constraint does not exist' do
      it { is_expected.to be_nil }
    end
  end

  describe '#prepare' do
    subject(:prepare_constraint) { set.prepare(accessor, :test, expectation, **options) }

    let(:set) { described_class.new }
    let(:accessor) { :self }
    let(:expectation) { nil }
    let(:options) { { description: 'test description', abort_on_failure: true } }

    it 'is expected to return a configured constraint' do
      expect(prepare_constraint).to be_a(TestConstraint).and(be_abort_on_failure)
    end

    it 'is expected not to add the constraint to the set' do
      expect { prepare_constraint }.not_to(change(set, :count))
    end
  end

  describe '#violation_description' do
    subject(:violation_description) { set.violation_description }

    let(:set) { described_class.new }

    before do
      set.add(:self, :test, nil, description: 'first test')
      set.add(:length, :test, nil, description: 'second test')
    end

    it 'is expected to return a combined violation description of all constraints' do
      expect(violation_description).to eq('first test, second test')
    end
  end
end
