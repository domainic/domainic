# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/base_type'
require 'domainic/type/constraint/base_constraint'
require 'domainic/type/constraint/provisioning/provisioned_constraint'

RSpec.describe Domainic::Type::Constraint::Provisioning::ProvisionedConstraint do
  describe '#dup_with_base' do
    subject(:dup_with_base) { provisioned_constraint.dup_with_base(new_base) }

    let(:provisioned_constraint) { described_class.new(constraint) }
    let(:constraint) { instance_double(Domainic::Type::Constraint::BaseConstraint, dup_with_base: true) }
    let(:new_base) { instance_double(Domainic::Type::BaseType) }

    it 'is expected to duplicate the constraint with the new base' do
      dup_with_base

      expect(constraint).to have_received(:dup_with_base).with(new_base)
    end
  end
end
