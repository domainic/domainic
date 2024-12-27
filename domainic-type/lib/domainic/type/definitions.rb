# frozen_string_literal: true

module Domainic
  module Type
    # A module providing convenient factory methods for creating type instances.
    #
    # This module serves as a temporary access point for type creation in the Domainic::Type
    # system, offering a collection of factory methods with consistent naming patterns.
    # Each method creates and configures a specific type instance, with optional nilable
    # variants and aliases for common use cases.
    #
    # @note This module is considered temporary and may be significantly altered or removed
    #   before the final release. It should not be considered part of the stable API.
    #
    # @example Basic type creation
    #   include Domainic::Type::Definitions
    #
    #   string_type = _String()
    #   array_type = _Array()
    #   hash_type = _Hash()
    #
    # @example Creating nilable types
    #   nullable_string = _String?()
    #   nullable_array = _Array?()
    #
    # @example Using union types
    #   string_or_symbol = _Union(String, Symbol)
    #   boolean = _Boolean()  # Union of TrueClass and FalseClass
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    module Definitions
      # rubocop:disable Naming/MethodName

      # Creates an AnythingType instance.
      #
      # @example
      #   type = _Anything
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::AnythingType] the created type
      # @rbs (**__todo__ options) -> AnythingType
      def _Anything(**options)
        require 'domainic/type/types/specification/anything_type'
        Domainic::Type::AnythingType.new(**options)
      end
      alias _Any _Anything

      # Creates an ArrayType instance.
      #
      # @example
      #   type = _Array
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::ArrayType] the created type
      # @rbs (**__todo__ options) -> ArrayType
      def _Array(**options)
        require 'domainic/type/types/core/array_type'
        Domainic::Type::ArrayType.new(**options)
      end
      alias _List _Array

      # Creates a nilable ArrayType instance.
      #
      # @example
      #   type = _Array?
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::UnionType] the created type (Array or NilClass)
      # @rbs (**__todo__ options) -> UnionType
      def _Array?(**options)
        array = _Array(**options)
        _Nilable(array)
      end
      alias _List? _Array?

      # Creates a Boolean type.
      #
      # Represents a union of TrueClass and FalseClass.
      #
      # @example
      #   type = _Boolean
      #
      # @return [Domainic::Type::UnionType] the created type
      # @rbs () -> UnionType
      def _Boolean
        _Union(TrueClass, FalseClass).freeze
      end
      alias _Bool _Boolean

      # Creates a nilable Boolean type.
      #
      # @example
      #   type = _Boolean?
      #
      # @return [Domainic::Type::UnionType] the created type (TrueClass, FalseClass, or NilClass)
      # @rbs () -> UnionType
      def _Boolean?
        _Nilable(_Boolean)
      end
      alias _Bool? _Boolean?

      # Creates a CUIDType instance
      #
      # @example
      #   type = _CUID.v2
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::CUIDType] the created type
      # @rbs (**__todo__ options) -> CUIDType
      def _CUID(**options)
        require 'domainic/type/types/identifier/cuid_type'
        Domainic::Type::CUIDType.new(**options)
      end
      alias _Cuid _CUID

      # Creates a nilable CUIDType instance.
      #
      # @example
      #   _CUID? === "la6m1dv00000gv25zp9ru12g" # => true
      #   _CUID? === nil                        # => true
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::UnionType] the created type (CUIDType or NilClass)
      # @rbs (**__todo__ options) -> UnionType
      def _CUID?(**options)
        _Nilable(_CUID(**options))
      end
      alias _Cuid? _CUID?

      # Creates a DateType instance.
      #
      # DateType restricts values to valid `Date` objects.
      #
      # @example
      #   type = _Date
      #   type.validate(Date.new(2024, 1, 1)) # => true
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::DateType] the created type
      # @rbs (**__todo__ options) -> DateType
      def _Date(**options)
        require 'domainic/type/types/datetime/date_type'
        Domainic::Type::DateType.new(**options)
      end

      # Creates a nilable DateType instance.
      #
      # @example
      #   _Date? === Date.new(2024, 1, 1) # => true
      #   _Date? === nil                  # => true
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::UnionType] the created type (DateType or NilClass)
      # @rbs (**__todo__ options) -> UnionType
      def _Date?(**options)
        _Nilable(_Date(**options))
      end

      # Creates a DateTimeType instance.
      #
      # DateTimeType restricts values to valid `DateTime` objects.
      #
      # @example
      #   type = _DateTime
      #   type.validate(DateTime.new(2024, 1, 1, 12, 0, 0)) # => true
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::DateTimeType] the created type
      # @rbs (**__todo__ options) -> DateTimeType
      def _DateTime(**options)
        require 'domainic/type/types/datetime/date_time_type'
        Domainic::Type::DateTimeType.new(**options)
      end

      # Creates a nilable DateTimeType instance.
      #
      # @example
      #   _DateTime? === DateTime.new(2024, 1, 1, 12, 0, 0) # => true
      #   _DateTime? === nil                                # => true
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::UnionType] the created type (DateTimeType or NilClass)
      # @rbs (**__todo__ options) -> UnionType
      def _DateTime?(**options)
        _Nilable(_DateTime(**options))
      end

      # Creates a DateTimeStringType instance.
      #
      # DateTimeStringType restricts values to valid date-time strings.
      #
      # @example
      #   type = _DateTimeString
      #   type.validate('2024-01-01T12:00:00Z') # => true
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::DateTimeStringType] the created type
      # @rbs (**__todo__ options) -> DateTimeStringType
      def _DateTimeString(**options)
        require 'domainic/type/types/datetime/date_time_string_type'
        Domainic::Type::DateTimeStringType.new(**options)
      end
      alias _DateString _DateTimeString

      # Creates a nilable DateTimeStringType instance.
      #
      # @example
      #   _DateTimeString? === '2024-01-01T12:00:00Z' # => true
      #   _DateTimeString? === nil                    # => true
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::UnionType] the created type (DateTimeStringType or NilClass)
      # @rbs (**__todo__ options) -> UnionType
      def _DateTimeString?(**options)
        _Nilable(_DateTimeString(**options))
      end
      alias _DateString? _DateTimeString?

      # Creates a DuckType instance.
      #
      # DuckType allows specifying behavior based on method availability.
      #
      # @example
      #   type = _Duck(respond_to: :to_s)
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::DuckType] the created type
      # @rbs (**__todo__ options) -> DuckType
      def _Duck(**options)
        require 'domainic/type/types/specification/duck_type'
        Domainic::Type::DuckType.new(**options)
      end
      alias _Interface _Duck
      alias _Protocol _Duck
      alias _RespondingTo _Duck

      # Creates an EmailAddressType instance.
      #
      # EmailAddressType restricts values to valid email addresses.
      #
      # @example
      #   type = _EmailAddress.having_hostname('example.com')
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::EmailAddressType] the created type
      # @rbs (**__todo__ options) -> EmailAddressType
      def _EmailAddress(**options)
        require 'domainic/type/types/network/email_address_type'
        Domainic::Type::EmailAddressType.new(**options)
      end
      alias _Email _EmailAddress

      # Creates a nilable EmailAddressType instance.
      #
      # @example
      #   _EmailAddress?.validate("user@example.com") # => true
      #   _EmailAddress?.validate(nil)                # => true
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::UnionType] the created type (EmailAddress or NilClass)
      # @rbs (**__todo__ options) -> UnionType
      def _EmailAddress?(**options)
        _Nilable(_EmailAddress(**options))
      end
      alias _Email? _EmailAddress?

      # Creates an EnumType instance.
      #
      # EnumType restricts values to a specific set of literals.
      #
      # @example
      #   type = _Enum(:red, :green, :blue)
      #
      # @param literals [Array<Object>] the allowed literals
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::EnumType] the created type
      # @rbs (*untyped literals, **__todo__ options) -> EnumType
      def _Enum(*literals, **options)
        require 'domainic/type/types/specification/enum_type'
        Domainic::Type::EnumType.new(*literals, **options)
      end
      alias _Literal _Enum

      # Creates a nilable EnumType instance.
      #
      # @example
      #   type = _Enum?(:red, :green, :blue)
      #
      # @param literals [Array<Object>] the allowed literals
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::UnionType] the created type (Enum or NilClass)
      # @rbs (*untyped literals, **__todo__ options) -> UnionType
      def _Enum?(*literals, **options)
        enum = _Enum(*literals, **options)
        _Nilable(enum)
      end
      alias _Literal? _Enum?

      # Creates a FloatType instance.
      #
      # @example
      #   type = _Float
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::FloatType] the created type
      # @rbs (**__todo__ options) -> FloatType
      def _Float(**options)
        require 'domainic/type/types/core/float_type'
        Domainic::Type::FloatType.new(**options)
      end
      alias _Decimal _Float
      alias _Real _Float

      # Creates a nilable FloatType instance.
      #
      # @example
      #   type = _Float?
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::UnionType] the created type (Float or NilClass)
      # @rbs (**__todo__ options) -> UnionType
      def _Float?(**options)
        float = _Float(**options)
        _Nilable(float)
      end
      alias _Decimal? _Float?
      alias _Real? _Float?

      # Creates a HashType instance.
      #
      # @example
      #   type = _Hash
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::HashType] the created type
      # @rbs (**__todo__ options) -> HashType
      def _Hash(**options)
        require 'domainic/type/types/core/hash_type'
        Domainic::Type::HashType.new(**options)
      end
      alias _Map _Hash

      # Creates a nilable HashType instance.
      #
      # @example
      #   type = _Hash?
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::UnionType] the created type (Hash or NilClass)
      # @rbs (**__todo__ options) -> UnionType
      def _Hash?(**options)
        hash = _Hash(**options)
        _Nilable(hash)
      end
      alias _Map? _Hash?

      # Creates a HostnameType instance.
      #
      # HostnameType restricts values to valid hostnames.
      #
      # @example
      #   type = _Hostname.matching('example.com')
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::HostnameType] the created type
      # @rbs (**__todo__ options) -> HostnameType
      def _Hostname(**options)
        require 'domainic/type/types/network/hostname_type'
        Domainic::Type::HostnameType.new(**options)
      end

      # Creates a nilable HostnameType instance.
      #
      # @example
      #   _Hostname?.validate("example.com") # => true
      #   _Hostname?.validate(nil)           # => true
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::UnionType] the created type (Hostname or NilClass)
      # @rbs (**__todo__ options) -> UnionType
      def _Hostname?(**options)
        _Nilable(_Hostname(**options))
      end

      # Creates a UnionType of IntegerType, UUIDType, and CUIDType
      #
      # @example
      #   _ID === 1234567890                             # => true
      #   _ID === '123e4567-e89b-42d3-a456-426614174000' # => true
      #   _ID === 'la6m1dv00000gv25zp9ru12g'             # => true
      #
      # @return [Domainic::Type::UnionType] the created type
      # @rbs () -> UnionType
      def _ID
        _Union(_Integer, _UUID, _CUID)
      end

      # Creates a nilable UnionType of IntegerType, UUIDType, and CUIDType
      #
      # @example
      #   _ID === 1234567890                             # => true
      #   _ID === '123e4567-e89b-42d3-a456-426614174000' # => true
      #   _ID === 'la6m1dv00000gv25zp9ru12g'             # => true
      #   _ID === nil                                    # => true
      #
      # @return [Domainic::Type::UnionType] the created type
      # @rbs () -> UnionType
      def _ID?
        _Nilable(_ID)
      end

      # Create an InstanceType instance.
      #
      # @example
      #   _type = _Instance.of(User)
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::InstanceType]
      # @rbs (**__todo__ options) -> InstanceType
      def _Instance(**options)
        require 'domainic/type/types/specialized/instance_type'
        Domainic::Type::InstanceType.new(**options)
      end
      alias _Record _Instance

      # Create an InstanceType instance.
      #
      # @example
      #   _type = _Instance?(of: User)
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::UnionType] the created type (InstanceType or NilClass)
      # @rbs (**__todo__ options) -> UnionType
      def _Instance?(**options)
        _Nilable(_Instance(**options))
      end
      alias _Record? _Instance?

      # Creates an IntegerType instance.
      #
      # @example
      #   type = _Integer
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::IntegerType] the created type
      # @rbs (**__todo__ options) -> IntegerType
      def _Integer(**options)
        require 'domainic/type/types/core/integer_type'
        Domainic::Type::IntegerType.new(**options)
      end
      alias _Int _Integer
      alias _Number _Integer

      # Creates a nilable IntegerType instance.
      #
      # @example
      #   type = _Integer?
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::UnionType] the created type (Integer or NilClass)
      # @rbs (**__todo__ options) -> UnionType
      def _Integer?(**options)
        integer = _Integer(**options)
        _Nilable(integer)
      end
      alias _Int? _Integer?
      alias _Number? _Integer?

      # Creates a Nilable (nullable) type.
      #
      # Combines one or more types with `NilClass` to allow nil values.
      #
      # @example
      #   type = _Nilable(String, Symbol)
      #
      # @param types [Array<Class, Module, Behavior>] the base types
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::UnionType] the created type (NilClass or other specified types)
      # @rbs (*Class | Module | Behavior[untyped, untyped, untyped] types, **__todo__ options) -> UnionType
      def _Nilable(*types, **options)
        _Union(NilClass, *types, **options)
      end
      alias _Nullable _Nilable

      # Creates a StringType instance.
      #
      # @example
      #   type = _String
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::StringType] the created type
      # @rbs (**__todo__ options) -> StringType
      def _String(**options)
        require 'domainic/type/types/core/string_type'
        Domainic::Type::StringType.new(**options)
      end
      alias _Text _String

      # Creates a nilable StringType instance.
      #
      # @example
      #   type = _String?
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::UnionType] the created type (String or NilClass)
      # @rbs (**__todo__ options) -> UnionType
      def _String?(**options)
        string = _String(**options)
        _Nilable(string)
      end
      alias _Text? _String?

      # Creates a SymbolType instance.
      #
      # @example
      #   type = _Symbol
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::SymbolType] the created type
      # @rbs (**__todo__ options) -> SymbolType
      def _Symbol(**options)
        require 'domainic/type/types/core/symbol_type'
        Domainic::Type::SymbolType.new(**options)
      end
      alias _Interned _Symbol

      # Creates a nilable SymbolType instance.
      #
      # @example
      #   type = _Symbol?
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::UnionType] the created type (Symbol or NilClass)
      # @rbs (**__todo__ options) -> UnionType
      def _Symbol?(**options)
        symbol = _Symbol(**options)
        _Nilable(symbol)
      end
      alias _Interned? _Symbol?

      # Creates a TimeType instance.
      #
      # TimeType restricts values to valid `Time` objects.
      #
      # @example
      #   type = _Time
      #   type.validate(Time.new(2024, 1, 1, 12, 0, 0)) # => true
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::TimeType] the created type
      # @rbs (**__todo__ options) -> TimeType
      def _Time(**options)
        require 'domainic/type/types/datetime/time_type'
        Domainic::Type::TimeType.new(**options)
      end

      # Creates a nilable TimeType instance.
      #
      # @example
      #   _Time? === Time.new(2024, 1, 1, 12, 0, 0) # => true
      #   _Time? === nil                            # => true
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::UnionType] the created type (TimeType or NilClass)
      # @rbs (**__todo__ options) -> UnionType
      def _Time?(**options)
        _Nilable(_Time(**options))
      end

      # Creates a URIType instance.
      #
      # URIType restricts values to valid URIs.
      #
      # @example
      #   type = _URI.having_scheme('https')
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::URIType] the created type
      # @rbs (**__todo__ options) -> URIType
      def _URI(**options)
        require 'domainic/type/types/network/uri_type'
        Domainic::Type::URIType.new(**options)
      end
      alias _URL _URI
      alias _Url _URI
      alias _Uri _URI

      # Creates a nilable URIType instance.
      #
      # @example
      #   _Uri?.validate("https://example.com") # => true
      #   _Uri?.validate(nil)                   # => true
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::UnionType] the created type (URIType or NilClass)
      # @rbs (**__todo__ options) -> UnionType
      def _URI?(**options)
        _Nilable(_Uri(**options))
      end
      alias _URL? _URI?
      alias _Url? _URI?
      alias _Uri? _URI?

      # Creates a UUIDType instance
      #
      # @example
      #   type = _UUID.v4_compact
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::UUIDType] the created type
      # @rbs (**__todo__ options) -> UUIDType
      def _UUID(**options)
        require 'domainic/type/types/identifier/uuid_type'
        Domainic::Type::UUIDType.new(**options)
      end
      alias _Uuid _UUID

      # Creates a nilable UUIDType instance.
      #
      # @example
      #   _UUID? === '123e4567-e89b-42d3-a456-426614174000' # => true
      #   _UUID? === nil                                    # => true
      #
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::UnionType] the created type (UUIDType or NilClass)
      # @rbs (**__todo__ options) -> UnionType
      def _UUID?(**options)
        _Nilable(_UUID(**options))
      end
      alias _Uuid? _UUID?

      # Creates a UnionType instance.
      #
      # Allows combining multiple types into a single union type.
      #
      # @example
      #   type = _Union(String, Symbol)
      #
      # @param types [Array<Class, Module, Behavior>] the types included in the union
      # @param options [Hash] additional configuration options
      #
      # @return [Domainic::Type::UnionType] the created type
      # @rbs (*Class | Module | Behavior[untyped, untyped, untyped] types, **__todo__ options) -> UnionType
      def _Union(*types, **options)
        require 'domainic/type/types/specification/union_type'
        Domainic::Type::UnionType.new(*types, **options)
      end
      alias _Either _Union

      # Creates a VoidType instance.
      #
      # Represents an operation that returns no value.
      #
      # @example
      #   type = _Void
      #
      # @return [Domainic::Type::VoidType] the created type
      # @rbs () -> VoidType
      def _Void
        require 'domainic/type/types/specification/void_type'
        Domainic::Type::VoidType.new
      end
      # rubocop:enable Naming/MethodName
    end
  end
end
