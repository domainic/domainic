# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/base_type'
require 'domainic/type/constraint/base_constraint'
require 'domainic/type/constraint/provisioning/provisioner'

RSpec.describe Domainic::Type::Constraint::Provisioning::Provisioner do
  describe '#dup_with_base' do
    subject(:dup_with_base) { provisioner.dup_with_base(new_base) }

    let(:provisioner) { described_class.new(instance_double(Domainic::Type::BaseType), :self) }
    let(:new_base) { instance_double(Domainic::Type::BaseType) }

    it 'is expected to duplicate the provisioner with the new base' do
      expect(dup_with_base.instance_variable_get(:@base)).to eq(new_base)
    end

    it 'is expected to duplicate the provisioned constraints with the new base' do
      provisioned = instance_double(Domainic::Type::Constraint::Provisioning::ProvisionedConstraint,
                                    dup_with_base: true)
      provisioner.instance_variable_set(:@provisioned, { constraint: provisioned })
      dup_with_base

      expect(provisioned).to have_received(:dup_with_base).with(new_base)
    end
  end

  describe '#provisoion' do
    subject(:provision) { provisioner.provision(constraint_name, **options) }

    let(:provisioner) { described_class.new(instance_double(Domainic::Type::BaseType), :self) }
    let(:options) { {} }

    context 'when the constraint is already provisioned' do
      before do
        provisioner.instance_variable_set(:@provisioned, { provisioned.name => provisioned })
      end

      let(:constraint_name) { :test }
      let(:provisioned) do
        instance_double(Domainic::Type::Constraint::BaseConstraint, name: constraint_name, :negated= => true)
      end

      it { is_expected.to eq(provisioned) }

      context 'when given options' do
        let(:options) { { negated: true } }

        it 'is expected to set the options on the provisioned constraint' do
          provision

          expect(provisioned).to have_received(:negated=).with(true)
        end
      end
    end

    context 'when the constraint has not been provisioned' do
      context 'when the constraint type exists' do
        before do
          provisioner.stage(type: constraint_name)
          allow(Dir).to receive(:glob)
            .with(File.expand_path('../../../../../lib/domainic/type/constraint/test_constraint.rb', __dir__))
            .and_return(['fake/constraint/test_constraint.rb'])
          allow(provisioner).to receive(:require).with('fake/constraint/test_constraint.rb').and_return(true)
          allow(Object).to receive(:const_get).with('Domainic::Type::Constraint::TestConstraint')
                                              .and_return(mock_constraint_class)
        end

        let(:constraint_name) { :test }
        let(:mock_constraint_class) { Class.new(Domainic::Type::Constraint::BaseConstraint) }

        it { is_expected.to be_an_instance_of(Domainic::Type::Constraint::Provisioning::ProvisionedConstraint) }
      end

      context 'when the constraint type does not exist' do
        before { provisioner.stage(type: constraint_name) }

        let(:constraint_name) { :non_existent }

        it {
          expect { provision }.to(
            raise_error(ArgumentError, a_string_including('Invalid constraint type `non_existent` for'))
          )
        }
      end

      context 'when the constraint has not been staged' do
        let(:constraint_name) { :not_staged }

        it {
          expect { provision }.to(
            raise_error(ArgumentError, a_string_including('does not constrain `not_staged` on `self`'))
          )
        }
      end
    end
  end

  describe '#stage' do
    subject(:stage) { provisioner.stage(**options) }

    let(:options) { { type: :test } }
    let(:provisioner) { described_class.new(instance_double(Domainic::Type::BaseType), :self) }

    it 'is expected to add the constraint to the staged constraints' do
      stage

      expect(provisioner.instance_variable_get(:@staged)).to have_key(:test)
    end
  end

  describe '#to_array' do
    subject(:to_array) { provisioner.to_array }

    let(:provisioner) { described_class.new(instance_double(Domainic::Type::BaseType), :self) }

    it { is_expected.to be_an(Array) }

    it 'is expected to return the staged constraints' do
      expect(to_array).to eq(provisioner.instance_variable_get(:@provisioned).values)
    end
  end
end
