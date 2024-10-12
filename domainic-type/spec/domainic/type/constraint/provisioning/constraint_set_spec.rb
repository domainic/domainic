# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/base_type'
require 'domainic/type/constraint/provisioning/constraint_set'

RSpec.describe Domainic::Type::Constraint::Provisioning::ConstraintSet do
  describe '#dup_with_base' do
    subject(:dup_with_base) { constraint_set.dup_with_base(new_base) }

    let(:constraint_set) { described_class.new(instance_double(Domainic::Type::BaseType)) }
    let(:new_base) { instance_double(Domainic::Type::BaseType) }

    it 'is expected to duplicate the constraint set with the new base' do
      expect(dup_with_base.instance_variable_get(:@base)).to eq(new_base)
    end

    it 'is expected to duplicate the provisioners with the new base' do
      provisioner = instance_double(Domainic::Type::Constraint::Provisioning::Provisioner, dup_with_base: true)
      constraint_set.instance_variable_set(:@entries, { provisioner: })
      dup_with_base

      expect(provisioner).to have_received(:dup_with_base).with(new_base)
    end
  end

  describe '#stage' do
    subject(:stage) { constraint_set.stage(accessor_name, constraint_name, **options) }

    let(:constraint_set) { described_class.new(instance_double(Domainic::Type::BaseType)) }
    let(:accessor_name) { :accessor }
    let(:constraint_name) { :constraint }
    let(:options) { { type: :test } }

    it 'is expected to stage the provisioner' do
      provisioner = instance_double(Domainic::Type::Constraint::Provisioning::Provisioner, stage: true)
      constraint_set.instance_variable_set(:@entries, { accessor: provisioner })
      stage

      expect(provisioner).to have_received(:stage).with(name: constraint_name, **options)
    end
  end

  describe '#to_array' do
    subject(:to_array) { constraint_set.to_array }

    let(:constraint_set) { described_class.new(instance_double(Domainic::Type::BaseType)) }

    it { is_expected.to be_an(Array) }

    it 'is expected to return an array of provisioned constraints' do
      provisioner = instance_double(Domainic::Type::Constraint::Provisioning::Provisioner, to_array: true)
      constraint_set.instance_variable_set(:@entries, { accessor: provisioner })
      to_array

      expect(provisioner).to have_received(:to_array)
    end
  end
end
