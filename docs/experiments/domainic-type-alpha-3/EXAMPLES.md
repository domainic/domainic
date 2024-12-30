# Example Usage

This document provides comprehensive examples of using Domainic::Type, from basic type validation to complex type composition.

## Table of Contents

* [Basic Usage](#basic-usage)
  * [Initialize a type with constraints](#initialize-a-type-with-constraints)
  * [Class with built-in type validations](#class-with-built-in-type-validations)
  * [A simple case statement](#a-simple-case-statement)
  * [Custom Constraint Examples](#custom-constraint-examples)
* [Advanced Usage](#advanced-usage)
  * [Using domainic-type with other gems](#using-domainic-type-with-other-gems)
  * [Creating Custom Types](#creating-custom-types)
  * [Advanced Type Composition](#advanced-type-composition)
* [Error Message Examples](#error-message-examples)
* [Using Types](#using-types)
  * [_Anything](#_anything)
  * [_Array](#_array)
  * [_BigDecimal](#_bigdecimal)
  * [_Boolean](#_boolean)
  * [_CUID](#_cuid)
  * [_Complex](#_complex)
  * [_Date](#_date)
  * [_DateTime](#_datetime)
  * [_DateTimeString](#_datetimestring)
  * [_Duck](#_duck)
  * [_EmailAddress](#_emailaddress)
  * [_Enum](#_enum)
  * [_Float](#_float)
  * [_Hash](#_hash)
  * [_Hostname](#_hostname)
  * [_ID](#_id)
  * [_Instance](#_instance)
  * [_Integer](#_integer)
  * [_Nilable](#_nilable)
  * [_Range](#_range)
  * [_Rational](#_rational)
  * [_Set](#_set)
  * [_String](#_string)
  * [_Symbol](#_symbol)
  * [_Time](#_time)
  * [_Timestamp](#_timestamp)
  * [_Union](#_union)
  * [_UUID](#_uuid)
  * [_URI](#_uri)
  * [_Void](#_void)

## Basic Usage

The following examples demonstrate fundamental usage patterns of Domainic::Type. These examples cover essential concepts
like type validation, constraint application, and integration with Ruby classes.

### Initialize a type with constraints

Domainic::Type provides two syntaxes for creating and constraining types: a hash-based syntax for simple constraints and
a method chaining syntax for more complex constraints. Both approaches are valid and can be used interchangeably based
on your preference and needs.

```ruby
# Hash syntax - good for simple constraints
_Array(of: _String, having_size: 3)

# Method chaining - more expressive for complex constraints
_Array.of(_String).having_size(3) # Equivalent to the above
```

### Class with built-in type validations

Type validation can be integrated directly into your Ruby classes through attribute setters. This pattern ensures type
safety at the point of value assignment, preventing invalid states from propagating through your system.

```ruby
require 'domainic/type/definitions'

class Jedi
  include Domainic::Type::Definitions

  attr_reader :name, :midi_chlorians

  def initialize(name, midi_chlorians:)
    self.name = name
    self.midi_chlorians = midi_chlorians
  end

  def name=(name)
    _String.having_maximum_length(255).validate!(name)
    @name = name
  end

  def midi_chlorians=(midi_chlorians)
    _Either(_Integer, _Float).being_positive.validate!(midi_chlorians)
    @midi_chlorians = midi_chlorians
  end
end

jedi = Jedi.new('Yoda', midi_chlorians: 900.0)
# => #<Jedi:0x00007f8b1b8b3b08 @name="Yoda", @midi_chlorians=900.0>

jedi = Jedi.new('A' * 256, midi_chlorians: 900.0)
# => TypeError: Expected String(having maximum length of 255) but got String(having length of 256)
```

### A simple case statement

Domainic types can be used in case statements thanks to Ruby's pattern matching capabilities. This enables powerful
type-based control flow that remains readable and maintainable.

```ruby
require 'domainic/type/definitions'

class SuperSaiyan
  include Domainic::Type::Definitions

  def categorize(power)
    case power
    when _Integer.being_less_than(9000)
      puts 'You\'re no Super Saiyan'
    when _Integer.being_equal_to(9000)
      puts 'Impressive...'
    when _Integer.being_greater_than(9000)
      puts 'It\'s over 9000!'
    end
  end
end
```

### Custom Constraint Examples

All types in Domainic::Type support adding custom constraints through the `satisfies` method. This is useful when you
need validation logic that goes beyond what the built-in constraints provide:

The `satisfies` method enables validation rules that can't be easily expressed using built-in constraints.
Here are examples of using custom constraints to solve real-world validation challenges:

```ruby
module Types
  extend Domainic::Type::Definitions

  # Physical quantities that must respect natural laws
  Kelvin = _Float.satisfies(
    ->(value) { value >= 0.0 },
    description: 'being a valid Kelvin temperature',
    violation_description: 'temperature below absolute zero'
  )

  Probability = _Float.satisfies(
    ->(value) { value >= 0.0 && value <= 1.0 },
    description: 'being a valid probability',
    violation_description: 'value outside probability range [0,1]'
  )

  # Complex validation involving multiple fields
  TimeRange = _Hash
    .of(_Symbol => _Time)
    .containing_keys(:starts_at, :ends_at)
    .satisfies(
      ->(range) {
        duration = range[:ends_at] - range[:starts_at]
        duration.positive? && duration <= 86_400 # 24 hours in seconds
      },
      description: 'having valid duration',
      violation_description: 'duration not between 0 and 24 hours'
    )

  # Relational integrity between collections
  DatabaseSchema = _Hash
    .of(_Symbol => _Array)
    .containing_keys(:tables, :foreign_keys)
    .satisfies(
      ->(schema) {
        schema[:foreign_keys].all? do |fk|
          schema[:tables].include?(fk[:references])
        end
      },
      description: 'having valid foreign key references',
      violation_description: 'contains references to non-existent tables'
    )

  # Domain-specific business rules
  MoneyTransfer = _Hash
    .of(_Symbol => _Union(_Integer, _String))
    .containing_keys(:amount, :currency, :beneficiary)
    .satisfies(
      ->(transfer) {
        transfer[:amount] <= daily_limit_for(transfer[:currency])
      },
      description: 'being within daily transfer limits',
      violation_description: 'amount exceeds daily transfer limit'
    )
    .satisfies(
      ->(transfer) {
        !blacklisted?(transfer[:beneficiary])
      },
      description: 'having valid beneficiary',
      violation_description: 'beneficiary is blacklisted'
    )

  # Resource availability rules
  MeetingRoom = _Hash
    .of(_Symbol => _Union(_String, _Array))
    .containing_keys(:room_id, :bookings)
    .satisfies(
      ->(room) {
        bookings = room[:bookings].sort_by { |b| b[:starts_at] }
        bookings.each_cons(2).all? { |a, b| a[:ends_at] < b[:starts_at] }
      },
      description: 'having non-overlapping bookings',
      violation_description: 'contains overlapping bookings'
    )

  # Network-related validation
  LoadBalancer = _Hash
    .of(_Symbol => _Union(_Array, _Integer))
    .containing_keys(:backends, :health_threshold)
    .satisfies(
      ->(config) {
        healthy_count = config[:backends].count { |b| b[:healthy] }
        healthy_count >= config[:health_threshold]
      },
      description: 'having sufficient healthy backends',
      violation_description: 'insufficient healthy backends'
    )
end
```

The `satisfies` method is particularly useful for:

* Physical constraints that must respect natural laws
* Complex relationships between multiple fields
* Maintaining referential integrity between collections
* Enforcing business rules that depend on external state
* Time-based constraints and scheduling rules
* Resource allocation and availability checks

## Advanced Usage

These examples demonstrate more sophisticated use cases and integration patterns for Domainic::Type.

### Using domainic-type with other gems

Domainic::Type is designed to work seamlessly with other Ruby gems and libraries. Here's an example of combining it with
Domainic::Attributer for declarative attribute validation:

```ruby
require 'domainic/attributer'
require 'domainic/type/definitions'

class Spaceship
  extend Domainic::Type::Definitions
  include Domainic::Attributer

  argument :name, _String.having_maximum_length(255).matching(SHIP_NAME_REGEX)
  argument :crew_count, _Integer.being_positive
end
```

### Creating Custom Types

You can create reusable custom types by extending the Definitions module in your own type container. This is useful for
domain-specific types that are used frequently in your application:

```ruby
require 'domainic/type/definitions'

module Types
  extend Domainic::Type::Definitions

  EmailAddress = _String.matching(URI::MailTo::EMAIL_REGEXP)
end

Types::EmailAddress.validate!('example@example.com') # => true
Types::EmailAddress.validate!('example@@example') # => TypeError
```

### Advanced Type Composition

Domainic::Type shines in complex scenarios where multiple types need to be composed together. Here are examples of
advanced type composition for real-world use cases:

```ruby
# API response validation
ApiResponse = _Hash.of(_Symbol => _Union(
  # Success case
  _Hash.of(
    _Symbol => _Union(
      _String,
      _Array.of(_Integer.being_positive),
      _Hash.of(_Symbol => _Boolean)
    )
  ),
  # Error case
  _Hash.of(_Symbol => _String).containing_keys(:error, :message)
))

# Form validation
FormData = _Hash.of(
  _Symbol => _Union(
    _String.being_alphanumeric.having_size_between(3, 20),
    _String.matching(URI::MailTo::EMAIL_REGEXP),
    _Nilable(_Integer.being_greater_than_or_equal_to(18)),
    _Array.of(_String).having_maximum_size(5)
  )
).containing_keys(:username, :email, :age, :interests)
```

## Error Message Examples

Domainic::Type strives to provide clear, actionable error messages. Here are examples of various error scenarios and
their corresponding messages:

```ruby
# Type mismatch
_String.validate!(42)
# => TypeError: Expected String, got Integer

# Constraint violation
_String.being_uppercase.validate!("hello")
# => TypeError: Expected String(being upper case), got String(not upper case)

# Multiple constraints
_Integer.being_positive.being_even.validate!(-2)
# => TypeError: Expected Integer(being positive), got Integer(negative)

# Nested type validation
_Array.of(_String.being_uppercase).validate!(["Hello", "WORLD"])
# => TypeError: Expected Array of String(being upper case), got Array containing String(not upper case)

# Complex union validation
_Union(
  _String.being_uppercase,
  _Integer.being_positive
).validate!(-42)
# => TypeError: Expected Union(String(being upper case) or Integer(being positive)), got Integer(negative)
```

## Using Types

Each type in Domainic::Type has its own set of constraints and capabilities. Below is a comprehensive reference of all
available types.

> [!WARNING]
> Nilable variants like _Array? and _Boolean? will return a _Union type and not respond to any of the available
> constraint methods of the type. If you need to constraint your type use _Nilable([_Type].[constraint_methods]) instead.

### _Anything

also known as `_Any`

The `_Anything` type acts as a wildcard, accepting any value except those explicitly excluded. This is useful when you
want to restrict values to "anything except X":

```ruby
_Anything.but(_String, _Integer) === 1.0 # => true
_Any.but(_String, _Integer) === ['a', 1] # => true
_Anything.but(_String, _Integer) === 'a' # => false
_Anything === 'a' # => true
```

### _Array

also known as `_List`, `_Array?`, `_List?`

> [!TIP]
> Many constraints have aliases to allow you to express your intent in a way that best maps to your mental model.
> Checkout the documentation for
> [EnumerableBehavior](https://github.com/domainic/domainic/blob/domainic-type-v0.1.0-alpha.3.3.0/domainic-type/lib/domainic/type/behavior/enumerable_behavior.rb)
> and
> [SizableBehavior](https://github.com/domainic/domainic/blob/domainic-type-v0.1.0-alpha.3.3.0/domainic-type/lib/domainic/type/behavior/sizable_behavior.rb)
> for the full list of available methods and aliases!

The `_Array` type provides comprehensive validation for array values with constraints for content, ordering, and size.
It includes nilable variants and supports rich composition with other types:

```ruby
_Array.of(_String) === %w[a b c] # => true
_Array.of(_String) === [1, 2, 3] # => false
_Array.of(_String) === 'a b c' # => false
_Array?.of(_String) === nil # => true

# Available Constraints
_Array.being_distinct # Constrains the array to contain only distinct values
_Array.being_duplicative # Constrains the array to contain only duplicative values
_Array.being_empty # Constrains the array to be empty
_Array.being_populated # Constrains the array to be populated
_Array.being_sorted # Constrains the array to be sorted
_Array.being_unsorted # Constrains the array to be unsorted
_Array.containing(value) # Constrains the array to contain the specified value
_Array.ending_with(value) # Constrains the array to end with the specified value
_Array.excluding(value) # Constrains the array to exclude the specified value
_Array.having_maximum_size(size) # Constrains the array to have a maximum size
_Array.having_minimum_size(size) # Constrains the array to have a minimum size
_Array.having_size(size) # Constrains the array to have a specific size
_Array.having_size_between(minimum, maximum) # Constrains the array to have a size between the specified min and max
_Array.of(type) # Constrains the array to contain only values of the specified type
_Array.starting_with(value) # Constrains the array to start with the specified value
```

### _BigDecimal

also known as `_BigDecimal?`

> [!TIP]
> Many constraints have aliases to allow you to express your intent in a way that best maps to your mental model.
> Checkout the documentation for
> [NumericBehavior](https://github.com/domainic/domainic/blob/domainic-type-v0.1.0-alpha.3.3.0/domainic-type/lib/domainic/type/behavior/numeric_behavior.rb)
> for the full list of available methods and aliases!

The `_BigDecimal` type provides precise decimal arithmetic validation with comprehensive numeric constraints:

```ruby
_BigDecimal === BigDecimal('3.14') # => true
_BigDecimal === 3.14 # => false

# Available Constraints
# Inherits all numeric constraints from NumericBehavior
_BigDecimal.being_positive # Must be positive
_BigDecimal.being_negative # Must be negative
_BigDecimal.being_finite # Must be finite
_BigDecimal.being_infinite # Must be infinite
_BigDecimal.being_divisible_by(BigDecimal('0.5')) # Must be divisible by 0.5
_BigDecimal.being_greater_than(BigDecimal('0')) # Must be > 0
_BigDecimal.being_less_than(BigDecimal('1')) # Must be < 1
```

### _Boolean

also known as `_Bool`, `_Boolean?`, `_Bool?`

The `_Boolean` type provides strict boolean validation, only accepting `true` or `false`. Includes nilable variants:

```ruby
_Boolean === false # => true
_Boolean === 'true' # => false
_Boolean? === nil # => true
```

### _CUID

also known as `_Cuid`, `_CUID?`, `_Cuid?`

The `_CUID` type validates values against the CUID format, a collision-resistant alternative to UUIDs:

```ruby
_CUID === 'ckj9g7z9z0000b3z1z7z6z7z6' # => true
_CUID === 'ckj9g7z9z0000b3z1z7z6z7z6z' # => false

# Available Constraints
_CUID.being_version(1_or_2) # Constrains the CUID to be version 1 or 2
_CUID.being_version_one # Constrains the CUID to be version 1
_CUID.being_version_two # Constrains the CUID to be version 2
```

### _Complex

also known as `_Complex?`

The `_Complex` type validates complex numbers with constraints applied to both real and imaginary parts:

```ruby
_Complex === Complex(1, 2) # => true
_Complex === 1 # => false

# Available Constraints
# Most numeric constraints are applied to the real part
_Complex.being_divisible_by(2) # Real part must be divisible by 2
_Complex.being_positive # Real part must be positive
_Complex.being_negative # Real part must be negative
_Complex.being_even # Real part must be even
_Complex.being_odd # Real part must be odd
```

### _Date

also known as `_Date?`

> [!TIP]
> Many constraints have aliases to allow you to express your intent in a way that best maps to your mental model.
> Checkout the documentation for
> [DateTimeBehavior](https://github.com/domainic/domainic/blob/domainic-type-v0.1.0-alpha.3.3.0/domainic-type/lib/domainic/type/behavior/date_time_behavior.rb)
> for the full list of available methods and aliases!

The `_Date` type validates date values with comprehensive constraints for range:

```ruby
_Date === Date.today # => true
_Date === '2022-01-01' # => false

# Available Constraints
_Date.being_after(date) # Constrains the date to be after the specified date
_Date.being_before(date) # Constrains the date to be before the specified date
_Date.being_between(after, before) # Constrains the date to be between the specified start and end dates
_Date.being_equal_to(date) # Constrains the date to be equal to the specified date
_Date.being_on_or_after(date) # Constrains the date to be on or after the specified date
_Date.being_on_or_before(date) # Constrains the date to be on or before the specified date
```

### _DateTime

also known as `_DateTime?`

> [!TIP]
> Many constraints have aliases to allow you to express your intent in a way that best maps to your mental model.
> Checkout the documentation for
> [DateTimeBehavior](https://github.com/domainic/domainic/blob/domainic-type-v0.1.0-alpha.3.3.0/domainic-type/lib/domainic/type/behavior/date_time_behavior.rb)
> for the full list of available methods and aliases!

The `_DateTime` type validates datetime values with comprehensive constraints for range:

```ruby
_DateTime === DateTime.now # => true
_DateTime === '2022-01-01' # => false

# Available Constraints
_DateTime.being_after(datetime) # Constrains the datetime to be after the specified datetime
_DateTime.being_before(datetime) # Constrains the datetime to be before the specified datetime
_DateTime.being_between(after, before) # Constrains the datetime to be between the specified start and end datetimes
_DateTime.being_equal_to(datetime) # Constrains the datetime to be equal to the specified datetime
_DateTime.being_on_or_after(datetime) # Constrains the datetime to be on or after the specified datetime
_DateTime.being_on_or_before(datetime) # Constrains the datetime to be on or before the specified datetime
```

### _DateTimeString

also known as `_DateString`, `_DateTimeString?`, `_DateString?`

> [!TIP]
> Many constraints have aliases to allow you to express your intent in a way that best maps to your mental model.
> Checkout the documentation for
> [DateTimeBehavior](https://github.com/domainic/domainic/blob/domainic-type-v0.1.0-alpha.3.3.0/domainic-type/lib/domainic/type/behavior/date_time_behavior.rb)
> for the full list of available methods and aliases!

The `_DateTimeString` type validates strings containing date and time information in various formats. It inherits all
datetime constraints from DateTimeBehavior in addition to format-specific validation:

```ruby
_DateTimeString === '2024-01-01T12:00:00Z' # => true
_DateTimeString === 'invalid date' # => false

# Available Format Constraints
_DateTimeString.having_american_format # MM/DD/YYYY
_DateTimeString.having_european_format # DD.MM.YYYY
_DateTimeString.having_iso8601_format # ISO 8601 format
_DateTimeString.having_rfc2822_format # RFC 2822 format

# Also supports all datetime constraints
_DateTimeString.being_after('2024-01-01') # After specific date
_DateTimeString.being_before('2024-12-31') # Before specific date
_DateTimeString.being_between('2024-01-01', '2024-12-31') # In date range
```

### _Duck

also known as `_Interface`, `_Protocol`, `_RespondingTo`

The `_Duck` type implements duck typing validation, checking for the presence of specified methods. This is particularly
useful when working with interfaces or protocols:

```ruby
object = Struct.new(:foo, :bar).new('foo', 'bar')
_Duck.responding_to(:foo, :bar) === object # => true
_Duck.responding_to(:foo) === object # => true
_Duck.responding_to(:foo).not_responding_to(:bar) === object # => false
```

### _EmailAddress

also known as `_Email`, `_EmailAddress?`, `_Email?`

> [!TIP]
> Many constraints have aliases to allow you to express your intent in a way that best maps to your mental model.
> Checkout the documentation for
> [StringBehavior](https://github.com/domainic/domainic/blob/domainic-type-v0.1.0-alpha.3.3.0/domainic-type/lib/domainic/type/behavior/string_behavior.rb)
> and
> [SizableBehavior](https://github.com/domainic/domainic/blob/domainic-type-v0.1.0-alpha.3.3.0/domainic-type/lib/domainic/type/behavior/sizeable_behavior.rb)
> for the full list of available methods and aliases!

The `_EmailAddress` type validates email addresses according to RFC 5321 and 5322 standards. It includes comprehensive
validation for all parts of an email address and supports all string constraints:

```ruby
_EmailAddress === 'user@example.com' # => true
_EmailAddress === 'invalid@@email' # => false

# Available Email-specific Constraints
_EmailAddress.having_hostname('example.com') # Constrains to specific domain
_EmailAddress.having_local_matching(/^[a-z]+$/) # Constrains local part format
_EmailAddress.not_having_hostname('blocked.com') # Excludes specific domains
_EmailAddress.not_having_local_matching(/^admin/) # Prevents specific local parts

# Available String Constraints
_EmailAddress.being_ascii # Enforces ASCII-only characters
_EmailAddress.being_lowercase # Enforces lowercase format
_EmailAddress.containing('specific.text') # Must contain substring
_EmailAddress.having_maximum_size(255) # Max length constraint
_EmailAddress.matching(/^[a-z]+@domain\.com$/) # Pattern matching
```

### _Enum

also known as `_Literal`, `_Enum?`, `_Literal?`

The `_Enum` type validates values against a predefined set of literals. Useful for ensuring values come from a fixed set
of options:

```ruby
_Enum('a', 'b', 'c') === 'a' # => true
_Enum('a', 'b', 'c') === 'd' # => false
_Enum.literal('a', 'b', 'c') === 'a' # => true
```

### _Float

also known as `_Decimal`, `_Real`, `_Float?`, `_Decimal?`, `_Real?`

> [!TIP]
> Many constraints have aliases to allow you to express your intent in a way that best maps to your mental model.
> Checkout the documentation for
> [NumericBehavior](https://github.com/domainic/domainic/blob/domainic-type-v0.1.0-alpha.3.3.0/domainic-type/lib/domainic/type/behavior/numeric_behavior.rb)
> for the full list of available methods and aliases!

The `_Float` type validates floating-point numbers with comprehensive numeric constraints:

```ruby
_Float === 1.0 # => true

# Available Constraints
_Float.being_divisible_by(value, tolerance: 1e-10) # Constrains the float to be divisible by the specified value
_Float.being_equal_to(value) # Constrains the float to be equal to the specified value
_Float.being_even # Constrains the float to be even
_Float.being_finite # Constrains the float to be finite
_Float.being_greater_than(value) # Constrains the float to be greater than the specified value
_Float.being_greater_than_or_equal_to(value) # Constrains the float to be greater than or equal to the specified value
_Float.being_infinite # Constrains the float to be infinite
_Float.being_less_than(value) # Constrains the float to be less than the specified value
_Float.being_less_than_or_equal_to(value) # Constrains the float to be less than or equal to the specified value
_Float.being_negative # Constrains the float to be negative
_Float.being_odd # Constrains the float to be odd
_Float.being_positive # Constrains the float to be positive
_Float.being_zero # Constrains the float to be zero
_Float.not_being_divisible_by(value, tolerance: 1e-10) # Constrains the float to not be divisible by the specified value
_Float.not_being_equal_to(value) # Constrains the float to not be equal to the specified value
_Float.not_being_even # Constrains the float to not be even
```

### _Hash

also known as `_Map`, `_Hash?`, `_Map?`

> [!TIP]
> Many constraints have aliases to allow you to express your intent in a way that best maps to your mental model.
> Checkout the documentation for
> [EnumerableBehavior](https://github.com/domainic/domainic/blob/domainic-type-v0.1.0-alpha.3.3.0/domainic-type/lib/domainic/type/behavior/enumerable_behavior.rb),
> [SizeableBehavior](https://github.com/domainic/domainic/blob/domainic-type-v0.1.0-alpha.3.3.0/domainic-type/lib/domainic/type/behavior/sizeable_behavior.rb),
> and [HashType](https://github.com/domainic/domainic/blob/domainic-type-v0.1.0-alpha.3.3.0/domainic-type/lib/domainic/type/types/core/hash_type.rb)
> for the full list of available methods and aliases!

The `_Hash` type provides validation for hash structures with constraints for keys, values, and overall composition:

```ruby
_Hash.of(_Symbol => _String) === { a: 'a', b: 'b', c: 'c' } # => true
_Hash.of(_Symbol => _String) === { 'a' => 1, 'b' => 2, 'c' => 3 } # => false

# Available Constraints
_Hash.being_distinct # Constrains the hash to contain only distinct values
_Hash.being_duplicative # Constrains the hash to contain only duplicative values
_Hash.being_empty # Constrains the hash to be empty
_Hash.being_populated # Constrains the hash to be populated
_Hash.being_sorted # Constrains the hash to be sorted
_Hash.being_unsorted # Constrains the hash to be unsorted
_Hash.containing_keys(keys) # Constrains the hash to contain the specified keys
_Hash.containing_values(values) # Constrains the hash to contain the specified values
_Hash.ending_with(value) # Constrains the hash to end with the specified value
_Hash.excluding_keys(keys) # Constrains the hash to exclude the specified keys
_Hash.excluding_values(values) # Constrains the hash to exclude the specified values
_Hash.having_maximum_size(size) # Constrains the hash to have a maximum size
_Hash.having_minimum_size(size) # Constrains the hash to have a minimum size
_Hash.having_size(size) # Constrains the hash to have a specific size
_Hash.having_size_between(minimum, maximum) # Constrains the hash to have a size between the specified min and max
_Hash.of(key_type => value_type) # Constrains the hash to contain only values of the specified type
_Hash.starting_with(value) # Constrains the hash to start with the specified value
```

### _Hostname

also known as `_Hostname?`

> [!TIP]
> Many constraints have aliases to allow you to express your intent in a way that best maps to your mental model.
> Checkout the documentation for
> [StringBehavior](https://github.com/domainic/domainic/blob/domainic-type-v0.1.0-alpha.3.3.0/domainic-type/lib/domainic/type/behavior/string_behavior.rb)
> and
> [SizableBehavior](https://github.com/domainic/domainic/blob/domainic-type-v0.1.0-alpha.3.3.0/domainic-type/lib/domainic/type/behavior/sizeable_behavior.rb)
> for the full list of available methods and aliases!

The `_Hostname` type validates hostnames according to RFC 1034 and 1123 standards. It supports all string constraints in
addition to hostname-specific validation:

```ruby
_Hostname === 'example.com' # => true
_Hostname === 'invalid@hostname' # => false

# Available Hostname-specific Constraints
_Hostname.matching('example.com') # Constrains to exact hostname
_Hostname.not_matching('blocked.com') # Excludes specific hostname

# Available String Constraints
_Hostname.being_ascii # Enforces ASCII-only characters
_Hostname.being_lowercase # Enforces lowercase format
_Hostname.having_size_between(1, 253) # Length constraints
_Hostname.matching(/^[a-z0-9-]+\.[a-z]+$/) # Pattern matching
_Hostname.not_matching(/^www\./) # Pattern exclusion
```

### _ID

also known as `_ID?`

The `_ID` type combines common identifier types into a single union, accepting integers, UUIDs, and CUIDs:

```ruby
_ID === 1234567890 # => true
_ID === '123e4567-e89b-42d3-a456-426614174000' # => true
_ID === 'clh3am1f30000udocbhqg4151' # => true
_ID === 'not-an-id' # => false
```

### _Instance

also known as `_Record`, `_Instance?`, `_Record?`

The `_Instance` type validates instances of a specific class or module. This is useful for ensuring objects conform to a
specific interface or protocol:

```ruby
_Instance.of(User).having_attributes(name: _String, age: _Integer) === User.new(name: 'Alice', age: 38) # => true
_Instance.of(User) === NotAUser.new # => false
_Instance.having_attributes(hype_man: _Literal('Flavor Flav')) === Struct.new(:hype_man).new('LL Cool J') # => false

# Available Constraints
_Instance.of(class_or_module) # Constrains the instance to be of the specified class or module
_Instance.having_attributes(attribute_name: attribute_type) # Constrains the instance to have the specified attributes
```

### _Integer

also known as `_Int`, `_Integer?`, `_Int?`

> [!TIP]
> Many constraints have aliases to allow you to express your intent in a way that best maps to your mental model.
> Checkout the documentation for
> [NumericBehavior](https://github.com/domainic/domainic/blob/domainic-type-v0.1.0-alpha.3.3.0/domainic-type/lib/domainic/type/behavior/numeric_behavior.rb)
> for the full list of available methods and aliases!

The `_Integer` type validates integer values with comprehensive numeric constraints:

```ruby
_Integer === 1 # => true

# Available Constraints
_Integer.being_divisible_by(value, tolerance: 1e-10) # Constrains the integer to be divisible by the specified value
_Integer.being_equal_to(value) # Constrains the integer to be equal to the specified value
_Integer.being_even # Constrains the integer to be even
_Integer.being_finite # Constrains the integer to be finite
_Integer.being_greater_than(value) # Constrains the integer to be greater than the specified value
_Integer.being_greater_than_or_equal_to(value) # Constrains the integer to be greater than or equal to the specified value
_Integer.being_infinite # Constrains the integer to be infinite
_Integer.being_less_than(value) # Constrains the integer to be less than the specified value
_Integer.being_less_than_or_equal_to(value) # Constrains the integer to be less than or equal to the specified value
_Integer.being_negative # Constrains the integer to be negative
_Integer.being_odd # Constrains the integer to be odd
_Integer.being_positive # Constrains the integer to be positive
_Integer.being_zero # Constrains the integer to be zero
_Integer.not_being_divisible_by(value) # Constrains integer to not be divisible by value
_Integer.not_being_equal_to(value) # Constrains integer to not equal value
_Integer.not_being_even # Constrains integer to be odd (alias for being_odd)
```

### _Nilable

also known as `_Nullable`

The `_Nilable` type wraps another type to allow nil values while maintaining all the original type's constraints when
the value is not nil:

```ruby
_Nilable(_Array.of(_String)) === %w[a b c] # => true
_Nilable(_Array.of(_String)) === nil # => true
_Nilable(_Array.of(_String)) === [1, 2, 3] # => false

# Complex nilable types maintain all constraints
_Nilable(
  _String.being_uppercase.having_minimum_size(3)
) === "ABC" # => true
```

### _Range

also known as `_Range?`

> [!TIP]
> Many constraints have aliases to allow you to express your intent in a way that best maps to your mental model.
> Checkout the documentation for
> [EnumerableBehavior](https://github.com/domainic/domainic/blob/domainic-type-v0.1.0-alpha.3.3.0/domainic-type/lib/domainic/type/behavior/enumerable_behavior.rb)
> for the full list of available methods and aliases!

The `_Range` type validates Ruby Range objects:

```ruby
_Range === (1..10) # => true
_Range === [1, 2, 3] # => false

# Available Constraints
# Inherits enumerable constraints
_Range.being_empty # Must be empty
_Range.being_populated # Must not be empty
_Range.containing(5) # Must include specific value
_Range.excluding(0) # Must not include specific value
```

### _Rational

also known as `_Rational?`

> [!TIP]
> Many constraints have aliases to allow you to express your intent in a way that best maps to your mental model.
> Checkout the documentation for
> [NumericBehavior](https://github.com/domainic/domainic/blob/domainic-type-v0.1.0-alpha.3.3.0/domainic-type/lib/domainic/type/behavior/numeric_behavior.rb)
> for the full list of available methods and aliases!

The `_Rational` type validates rational numbers with comprehensive numeric constraints:

```ruby
_Rational === Rational(1, 2) # => true
_Rational === 0.5 # => false

# Available Constraints
# Inherits all numeric constraints from NumericBehavior
_Rational.being_positive # Must be positive
_Rational.being_negative # Must be negative
_Rational.being_divisible_by(Rational(1, 2)) # Must be divisible by 1/2
_Rational.being_greater_than(Rational(0)) # Must be > 0
_Rational.being_less_than(Rational(1)) # Must be < 1
```

### _Set

also known as `_Set?`

> [!TIP]
> Many constraints have aliases to allow you to express your intent in a way that best maps to your mental model.
> Checkout the documentation for
> [EnumerableBehavior](https://github.com/domainic/domainic/blob/domainic-type-v0.1.0-alpha.3.3.0/domainic-type/lib/domainic/type/behavior/enumerable_behavior.rb)
> for the full list of available methods and aliases!

The `_Set` type validates Ruby Set objects:

```ruby
_Set === Set[1, 2, 3] # => true
_Set === [1, 2, 3] # => false

# Available Constraints
# Inherits all enumerable constraints
_Set.being_empty # Must be empty
_Set.being_populated # Must not be empty
_Set.containing(1, 2) # Must include specific values
_Set.excluding(3, 4) # Must not include specific values
_Set.having_size(3) # Must have specific size
_Set.of(_String) # Elements must be strings
```

### _String

also known as `_Text`, `_String?`, `_Text?`

> [!TIP]
> Many constraints have aliases to allow you to express your intent in a way that best maps to your mental model.
> Checkout the documentation for
> [StringBehavior](https://github.com/domainic/domainic/blob/domainic-type-v0.1.0-alpha.3.3.0/domainic-type/lib/domainic/type/behavior/string_behavior.rb)
> and
> [SizeableBehavior](https://github.com/domainic/domainic/blob/domainic-type-v0.1.0-alpha.3.3.0/domainic-type/lib/domainic/type/behavior/sizeable_behavior.rb)
> for the full list of available methods and aliases!

The `_String` type validates string values with comprehensive text manipulation constraints:

```ruby
_String === 'hello' # => true

# Available Constraints
_String.being_alphanumeric # Constrains string to only alphanumeric characters
_String.being_ascii # Constrains string to only ASCII characters
_String.being_empty # Constrains string to be empty
_String.being_equal_to(value) # Constrains string to equal specified value
_String.being_lowercase # Constrains string to be lowercase
_String.being_mixedcase # Constrains string to have mixed case
_String.being_only_letters # Constrains string to only letters
_String.being_only_numbers # Constrains string to only numbers
_String.being_ordered # Constrains string characters to be in order
_String.being_printable # Constrains string to only printable characters
_String.being_titlecase # Constrains string to be in title case
_String.being_unordered # Constrains string characters to not be in order
_String.being_uppercase # Constrains string to be uppercase
_String.containing(substring) # Constrains string to contain substring
_String.excluding(substring) # Constrains string to not contain substring
_String.having_size(size) # Constrains string to specific length
_String.having_size_between(min, max) # Constrains string length to range
_String.matching(pattern) # Constrains string to match pattern
_String.not_matching(pattern) # Constrains string to not match pattern
```

### _Symbol

also known as `_Interned`, `_Symbol?`, `_Interned?`

> [!TIP]
> Many constraints have aliases to allow you to express your intent in a way that best maps to your mental model.
> Checkout the documentation for
> [StringBehavior](https://github.com/domainic/domainic/blob/domainic-type-v0.1.0-alpha.3.3.0/domainic-type/lib/domainic/type/behavior/string_behavior.rb)
> and
> [SizeableBehavior](https://github.com/domainic/domainic/blob/domainic-type-v0.1.0-alpha.3.3.0/domainic-type/lib/domainic/type/behavior/sizeable_behavior.rb)
> for the full list of available methods and aliases!

The `_Symbol` type validates symbols and supports all string-like constraints applied to the symbol's name:

```ruby
_Symbol === :hello # => true
_Symbol === 'hello' # => false

# Supports all String constraints
_Symbol.being_uppercase # Constrains symbol name to be uppercase
_Symbol.matching(/^[A-Z_]+$/) # Constrains symbol name to match pattern
_Symbol.having_maximum_size(20) # Constrains symbol name length

# Common use case: Rails-style keys
_Symbol
  .matching(/^[a-z_][a-z0-9_]*$/)
  .having_maximum_size(63)
```

### _Time

also known as `_Time?`

> [!TIP]
> Many constraints have aliases to allow you to express your intent in a way that best maps to your mental model.
> Checkout the documentation for
> [DateTimeBehavior](https://github.com/domainic/domainic/blob/domainic-type-v0.1.0-alpha.3.3.0/domainic-type/lib/domainic/type/behavior/date_time_behavior.rb)
> for the full list of available methods and aliases!

The `_Time` type validates time values with comprehensive constraints for range:

```ruby
_Time === Time.now # => true
_Time === '13:27:42 -0600' # => false

# Available Constraints
_Time.being_after(time) # Constrains the time to be after the specified time
_Time.being_before(time) # Constrains the time to be before the specified time
_Time.being_between(after, before) # Constrains the time to be between the specified start and end times
_Time.being_equal_to(time) # Constrains the time to be equal to the specified time
_Time.being_on_or_after(time) # Constrains the time to be on or after the specified time
_Time.being_on_or_before(time) # Constrains the time to be on or before the specified time
```

### _Timestamp

also known as `_Timestamp?`

> [!TIP]
> Many constraints have aliases to allow you to express your intent in a way that best maps to your mental model.
> Checkout the documentation for
> [DateTimeBehavior](https://github.com/domainic/domainic/blob/domainic-type-v0.1.0-alpha.3.3.0/domainic-type/lib/domainic/type/behavior/date_time_behavior.rb)
> for the full list of available methods and aliases!

The `_Timestamp` type validates Unix timestamps:

```ruby
_Timestamp === 1640995200 # => true
_Timestamp === '2022-01-01' # => false

# Available Constraints
# Inherits all datetime constraints
_Timestamp.being_after(1640995200) # Must be after timestamp
_Timestamp.being_before(1672531200) # Must be before timestamp
_Timestamp.being_between(1640995200, 1672531200) # Must be in range
```

### _UUID

also known as `_Uuid`, `_UUID?`, `_Uuid?`

The `_UUID` type validates UUIDs according to RFC 4122 standards, supporting all UUID versions and both standard and
compact formats:

```ruby
_UUID === '123e4567-e89b-12d3-a456-426614174000' # => true
_UUID === 'not-a-uuid' # => false

# Available Constraints
_UUID.being_compact # Constrains to compact format (no hyphens)
_UUID.being_standard # Constrains to standard format (with hyphens)
_UUID.being_version(4) # Constrains to specific UUID version
_UUID.being_version_four # Constrains to version 4 (most common)
_UUID.being_version_one # Constrains to version 1 (time-based)
_UUID.being_version_seven # Constrains to version 7 (Unix Epoch time-based)
```

### _Union

also known as `_Either`

The `_Union` type combines multiple types with OR logic, allowing values that match any of the specified types:

```ruby
# Simple union
_Union(_String, _Integer) === 'hello' # => true
_Union(_String, _Integer) === 42 # => true
_Union(_String, _Integer) === 3.14 # => false

# Union with constraints
_Union(
  _String.being_uppercase,
  _Integer.being_positive
) === 'HELLO' # => true

# Complex nested unions
_Union(
  _Array.of(_String),
  _Hash.of(_Symbol => _Integer),
  _Nilable(_Boolean)
) === { foo: 42 } # => true
```

### _URI

also known as `_URL`, `_Uri`, `_Url`, `URI?`, `_URL?`, `_Uri?`, `_Url?`

> [!TIP]
> Many constraints have aliases to allow you to express your intent in a way that best maps to your mental model.
> Checkout the documentation for
> [StringBehavior](https://github.com/domainic/domainic/blob/domainic-type-v0.1.0-alpha.3.3.0/domainic-type/lib/domainic/type/behavior/string_behavior.rb)
> and
> [SizableBehavior](https://github.com/domainic/domainic/blob/domainic-type-v0.1.0-alpha.3.3.0/domainic-type/lib/domainic/type/behavior/sizeable_behavior.rb)
> for the full list of available methods and aliases!

The `_URI` type validates URIs according to RFC 3986 standards. In addition to URI-specific validation, it supports all
string constraints:

```ruby
_URI === 'https://example.com' # => true
_URI === 'not-a-url' # => false

# Available URI-specific Constraints
_URI.having_hostname('example.com') # Constrains to specific hostname
_URI.having_path('/api/v1') # Constrains path component
_URI.having_scheme('https') # Constrains to specific scheme
_URI.not_having_hostname('blocked.com') # Excludes specific hostname
_URI.not_having_path('/admin') # Excludes specific paths
_URI.not_having_scheme('ftp') # Excludes specific schemes

# Available String Constraints
_URI.being_ascii # Enforces ASCII-only characters
_URI.having_maximum_size(2000) # Common max URL length
_URI.matching(/^https:\/\/api\./) # Pattern matching
_URI.not_matching(/\s/) # No whitespace allowed
```

### _Void

The `_Void` type accepts any value. It's useful as a placeholder or for explicitly marking void returns in interface
definitions:

```ruby
_Void === nil # => true
_Void === false # => true
_Void === anything # => true

# Common use case: Interface definition
class Interface
  extend Domainic::Type::Definitions

  def self.method_returns_nothing
    _Void
  end
end
```

[![Back: Readme](https://img.shields.io/badge/%3C%3C%20README-blue?style=for-the-badge)](README.md)
[![Next: Troubleshooting](https://img.shields.io/badge/TroubleShooting%20%3E%3E-blue?style=for-the-badge)](TROUBLESHOOTING.md)

|                               |                                       |                                 |                            |
|-------------------------------|---------------------------------------|---------------------------------|----------------------------|
| [Experiment Home](README.md)  | [Troubleshooting](TROUBLESHOOTING.md) | [Known Issues](KNOWN_ISSUES.md) | [Changelog](CHANGELOG.md)  |
