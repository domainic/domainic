# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/definitions'

RSpec.describe Domainic::Type::Definitions do
  subject(:definitions) { dummy_class.new }

  let(:dummy_class) do
    Class.new do
      include Domainic::Type::Definitions
    end
  end

  describe '._Anything' do
    subject(:anything_type) { definitions._Anything }

    it 'is expected to return an AnythingType' do
      expect(anything_type).to be_a(Domainic::Type::AnythingType)
    end
  end

  describe '._Array' do
    subject(:array_type) { definitions._Array }

    it 'is expected to return an ArrayType' do
      expect(array_type).to be_a(Domainic::Type::ArrayType)
    end
  end

  describe '._Array?' do
    subject(:nullable_array_type) { definitions._Array? }

    it 'is expected to return a UnionType' do
      expect(nullable_array_type).to be_a(Domainic::Type::UnionType)
    end

    it 'is expected to validate nil values' do
      expect(nullable_array_type.validate(nil)).to be true
    end

    it 'is expected to validate array values' do
      expect(nullable_array_type.validate([])).to be true
    end
  end

  describe '._BigDecimal' do
    subject(:big_decimal_type) { definitions._BigDecimal }

    it 'is expected to return a BigDecimalType' do
      expect(big_decimal_type).to be_a(Domainic::Type::BigDecimalType)
    end
  end

  describe '._Boolean' do
    subject(:boolean_type) { definitions._Boolean }

    it 'is expected to return a frozen UnionType' do
      expect(boolean_type).to be_a(Domainic::Type::UnionType).and(be_frozen)
    end

    it 'is expected to validate true' do
      expect(boolean_type.validate(true)).to be true
    end

    it 'is expected to validate false' do
      expect(boolean_type.validate(false)).to be true
    end
  end

  describe '._CUID' do
    subject(:cuid_type) { definitions._CUID }

    it 'is expected to return an CUIDType' do
      expect(cuid_type).to be_a(Domainic::Type::CUIDType)
    end
  end

  describe '._Complex' do
    subject(:complex_type) { definitions._Complex }

    it 'is expected to return a ComplexType' do
      expect(complex_type).to be_a(Domainic::Type::ComplexType)
    end
  end

  describe '._Date' do
    subject(:date_type) { definitions._Date }

    it 'is expected to return a DateType' do
      expect(date_type).to be_a(Domainic::Type::DateType)
    end
  end

  describe '._DateTime' do
    subject(:datetime_type) { definitions._DateTime }

    it 'is expected to return a DateTimeType' do
      expect(datetime_type).to be_a(Domainic::Type::DateTimeType)
    end
  end

  describe '._DateTimeString' do
    subject(:datetime_string_type) { definitions._DateTimeString }

    it 'is expected to return a DateTimeStringType' do
      expect(datetime_string_type).to be_a(Domainic::Type::DateTimeStringType)
    end
  end

  describe '._Duck' do
    subject(:duck_type) { definitions._Duck }

    it 'is expected to return a DuckType' do
      expect(duck_type).to be_a(Domainic::Type::DuckType)
    end
  end

  describe '._EmailAddress' do
    subject(:email_address_type) { definitions._EmailAddress }

    it 'is expected to return an EmailAddressType' do
      expect(email_address_type).to be_a(Domainic::Type::EmailAddressType)
    end
  end

  describe '._Enum' do
    subject(:enum_type) { definitions._Enum(:foo, :bar) }

    it 'is expected to return an EnumType' do
      expect(enum_type).to be_a(Domainic::Type::EnumType)
    end
  end

  describe '._Hash' do
    subject(:hash_type) { definitions._Hash }

    it 'is expected to return a HashType' do
      expect(hash_type).to be_a(Domainic::Type::HashType)
    end
  end

  describe '._Hostname' do
    subject(:hostname_type) { definitions._Hostname }

    it 'is expected to return a HostnameType' do
      expect(hostname_type).to be_a(Domainic::Type::HostnameType)
    end
  end

  describe '._ID' do
    subject(:id_type) { definitions._ID }

    it 'is expected to return an UnionType' do
      expect(id_type).to be_a(Domainic::Type::UnionType)
    end
  end

  describe '._Instance' do
    subject(:instance_type) { definitions._Instance }

    it 'is expected to return an InstanceType' do
      expect(instance_type).to be_a(Domainic::Type::InstanceType)
    end
  end

  describe '._Nilable' do
    subject(:nilable_type) { definitions._Nilable(String) }

    it 'is expected to return a UnionType' do
      expect(nilable_type).to be_a(Domainic::Type::UnionType)
    end

    it 'is expected to validate nil values' do
      expect(nilable_type.validate(nil)).to be true
    end

    it 'is expected to validate values of the specified type' do
      expect(nilable_type.validate('test')).to be true
    end
  end

  describe '._Range' do
    subject(:range_type) { definitions._Range }

    it 'is expected to return a RangeType' do
      expect(range_type).to be_a(Domainic::Type::RangeType)
    end
  end

  describe '._Rational' do
    subject(:rational_type) { definitions._Rational }

    it 'is expected to return a RationalType' do
      expect(rational_type).to be_a(Domainic::Type::RationalType)
    end
  end

  describe '._Set' do
    subject(:set_type) { definitions._Set }

    it 'is expected to return a SetType' do
      expect(set_type).to be_a(Domainic::Type::SetType)
    end
  end

  describe '._Time' do
    subject(:time_type) { definitions._Time }

    it 'is expected to return a TimeType' do
      expect(time_type).to be_a(Domainic::Type::TimeType)
    end
  end

  describe '._Timestamp' do
    subject(:timestamp_type) { definitions._Timestamp }

    it 'is expected to return a TimestampType' do
      expect(timestamp_type).to be_a(Domainic::Type::TimestampType)
    end
  end

  describe '._UUID' do
    subject(:uuid_type) { definitions._UUID }

    it 'is expected to return an UUIDType' do
      expect(uuid_type).to be_a(Domainic::Type::UUIDType)
    end
  end

  describe '._Union' do
    subject(:union_type) { definitions._Union(String, Symbol) }

    it 'is expected to return a UnionType' do
      expect(union_type).to be_a(Domainic::Type::UnionType)
    end
  end

  describe '._URI' do
    subject(:uri_type) { definitions._URI }

    it 'is expected to return a UriType' do
      expect(uri_type).to be_a(Domainic::Type::URIType)
    end
  end

  describe '._Void' do
    subject(:void_type) { definitions._Void }

    it 'is expected to return a VoidType' do
      expect(void_type).to be_a(Domainic::Type::VoidType)
    end
  end
end
