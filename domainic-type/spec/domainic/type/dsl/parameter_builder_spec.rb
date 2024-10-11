# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/base_type'
require 'domainic/type/constraint/base_constraint'
require 'domainic/type/dsl/parameter_builder'

RSpec.describe Domainic::Type::DSL::ParameterBuilder do
  describe '#build!' do
    subject(:build!) { builder.build! }

    let(:builder) { described_class.new(constraint_class) }

    context 'when parameters have been defined' do
      before { builder.define(:test) }

      let(:constraint_class) do
        class_double(Domainic::Type::Constraint::BaseConstraint, parameters:)
      end
      let(:parameters) { instance_double(Domainic::Type::Constraint::Specification::ParameterSet, add: true) }

      it 'is expected to add the parameters to the constraint' do
        build!

        expect(parameters).to have_received(:add).with(callbacks: [], coercers: [], name: :test, required: false)
      end

      it 'is expected to define getter and setter methods for each parameter' do
        build!

        expect(constraint_class.instance_methods).to include(:test).and(include(:test=)).and(include(:test_default))
      end

      context 'when the parameter has already been added to the constraint' do
        before do
          allow(parameters).to receive(:respond_to?).with(:test).and_return(true)
        end

        it 'is expected not to add the parameter to the constraint' do
          build!

          expect(parameters).not_to have_received(:add)
        end
      end
    end
  end

  describe '#coercer' do
    subject(:coercer) { builder.coercer(*arguments) }

    let(:builder) { described_class.new(class_double(Domainic::Type::Constraint::BaseConstraint)) }
    let(:arguments) { [] }

    context 'when a parameter is being defined' do
      before { builder.define(:test) }

      it { expect { coercer }.not_to raise_error }

      context 'when given a Proc, Symbol, or `true`' do
        let(:arguments) { [[:test, lambda(&:to_s), true].sample] }

        it "is expected to add the Proc, Symbol, or `true` to the current parameter's constraints" do
          coercer

          expect(builder.instance_variable_get(:@current_parameter)[:coercers]).to eq([arguments.first])
        end
      end

      context 'when given a block' do
        it {
          expect { |b| coercer(&b) }.to(
            change(builder.instance_variable_get(:@current_parameter)[:coercers], :count).by(1)
          )
        }
      end
    end

    context 'when no parameter is being defined' do
      it { expect { coercer }.to raise_error(RuntimeError) }
    end
  end

  describe '#default' do
    subject(:default) { builder.default(value) }

    let(:builder) { described_class.new(class_double(Domainic::Type::Constraint::BaseConstraint)) }
    let(:value) { double }

    context 'when a parameter is being defined' do
      before { builder.define(:test) }

      it { expect { default }.not_to raise_error }

      it 'is expected to set the default value for the current parameter' do
        default

        expect(builder.instance_variable_get(:@current_parameter)[:default]).to eq(value)
      end
    end

    context 'when no parameter is being defined' do
      it { expect { default }.to raise_error(RuntimeError) }
    end
  end

  describe '#description' do
    subject(:description) { builder.description(value) }

    let(:builder) { described_class.new(class_double(Domainic::Type::Constraint::BaseConstraint)) }
    let(:value) { 'test' }

    context 'when a parameter is being defined' do
      before { builder.define(:test) }

      it { expect { description }.not_to raise_error }

      it 'is expected to set the description for the current parameter' do
        description

        expect(builder.instance_variable_get(:@current_parameter)[:description]).to eq(value)
      end
    end

    context 'when no parameter is being defined' do
      it { expect { description }.to raise_error(RuntimeError) }
    end
  end

  describe '#dup_with_base' do
    subject(:dup_with_base) { builder.dup_with_base(new_base) }

    let(:builder) { described_class.new(class_double(Domainic::Type::Constraint::BaseConstraint)) }
    let(:new_base) { class_double(Domainic::Type::Constraint::BaseConstraint) }

    it { expect(dup_with_base).to be_a(described_class) }

    it 'is expected to set the new base constraint' do
      expect(dup_with_base.instance_variable_get(:@base)).to eq(new_base)
    end
  end

  describe '#on_change' do
    subject(:on_change) { builder.on_change }

    let(:builder) { described_class.new(class_double(Domainic::Type::Constraint::BaseConstraint)) }

    context 'when a parameter is being defined' do
      before { builder.define(:test) }

      it { expect { on_change }.not_to raise_error }

      it {
        expect { |b| on_change(&b) }.to(
          change(builder.instance_variable_get(:@current_parameter)[:callbacks], :count).by(1)
        )
      }
    end

    context 'when no parameter is being defined' do
      it { expect { on_change }.to raise_error(RuntimeError) }
    end
  end

  describe '#required' do
    subject(:required) { builder.required }

    let(:builder) { described_class.new(class_double(Domainic::Type::Constraint::BaseConstraint)) }

    context 'when a parameter is being defined' do
      before { builder.define(:test) }

      it { expect { required }.not_to raise_error }

      it 'is expected to mark the current parameter as required' do
        required

        expect(builder.instance_variable_get(:@current_parameter)[:required]).to be(true)
      end
    end

    context 'when no parameter is being defined' do
      it { expect { required }.to raise_error(RuntimeError) }
    end
  end

  describe '#validator' do
    subject(:validator) { builder.validator(*arguments) }

    let(:builder) { described_class.new(class_double(Domainic::Type::Constraint::BaseConstraint)) }
    let(:arguments) { [] }

    context 'when a parameter is being defined' do
      before { builder.define(:test) }

      it { expect { validator }.not_to raise_error }

      context 'when given a Proc or Symbol' do
        let(:arguments) { [[:test, lambda(&:to_s)].sample] }

        it "is expected to add the Proc or Symbol to the current parameter's constraints" do
          validator

          expect(builder.instance_variable_get(:@current_parameter)[:validator]).to eq(arguments.first)
        end
      end

      context 'when given a block' do
        it "is expected to add the block to the current parameter's validators" do
          builder.validator do |value|
            value.is_a?(String)
          end

          expect(builder.instance_variable_get(:@current_parameter)[:validator]).to be_a(Proc)
        end
      end
    end

    context 'when no parameter is being defined' do
      it { expect { validator }.to raise_error(RuntimeError) }
    end
  end
end
