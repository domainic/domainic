# Domainic::Type Usage Guide

A comprehensive guide to all features and capabilities of Domainic::Type. See the [README.md](../README.md) for a quick
introduction and installation instructions.

## Table of Contents

* [About](#about)
* [Core Concepts](#core-concepts)
  * [Basic Type Validation](#basic-type-validation)
  * [Type Constraints](#type-constraints)
  * [Error Messages](#error-messages)
* [Built-in Types](#built-in-types)
  * [Simple Types](#simple-types)
  * [Collection Types](#collection-types)
  * [Date and Time Types](#date-and-time-types)
  * [Network Types](#network-types)
  * [Identifier Types](#identifier-types)
  * [Specification Types](#specification-types)
* [Advanced Usage](#advanced-usage)
  * [Custom Types](#custom-types)
  * [Type Composition](#type-composition)
  * [Integration Patterns](#integration-patterns)

## About

Stop wrestling with complex type validations and unclear error messages. Domainic::Type brings type validation to Ruby
that is both powerful and delightful to use. Build composable type constraints with crystal-clear error messages that
actually tell you what went wrong. From simple type checks to complex collection validations, make your types work for
you, not against you!

Key features include:

* Rich set of built-in types with purpose-specific validation:

  ```ruby
  _String.being_uppercase.matching(/^[A-Z]+$/)  # String validation
  _Integer.being_positive.being_even            # Number validation
  _Array.of(_String).being_distinct            # Collection validation
  _EmailAddress.having_hostname("example.com")  # Email validation
  _UUID.being_version(4).being_standard        # ID validation
  ```

* Composable type constraints for precise validation rules:

  ```ruby
  username = _String
    .being_lowercase         # Must be lowercase
    .being_alphanumeric     # Letters and numbers only
    .having_size_between(3, 20)  # Length constraint
  ```

* Clear, actionable error messages that explain what failed:

  ```ruby
  username.validate!("BAD!")
  # => TypeError: Expected String(being lowercase, having size between 3 and 20),
  #    got String(not lowercase, having size 4)
  ```

* Custom type definitions for reusable validation:

  ```ruby
  Username = _String.being_lowercase.having_size_between(3, 20)
  EmailAddress = _String.matching(URI::MailTo::EMAIL_REGEXP)
  ```

* Full integration with Ruby's pattern matching:

  ```ruby
  case value
  when _String.being_uppercase then puts "Uppercase string"
  when _Integer.being_positive then puts "Positive number"
  end
  ```

* Support for optional values and complex type combinations:

  ```ruby
  _Nilable(_String)            # String or nil (also as _String?)
  _Union(_String, _Integer)    # String or Integer
  ```

## Core Concepts

### Basic Type Validation

Domainic::Type provides two main validation methods:

* `validate` - Returns true/false without raising errors
* `validate!` - Raises TypeError for invalid values

```ruby
require 'domainic/type/definitions'
include Domainic::Type::Definitions

string_type = _String
string_type.validate("hello")   # => true
string_type.validate(123)       # => false
string_type.validate!("hello")  # => true
string_type.validate!(123)      # => TypeError: Expected String, but got Integer
```

All types also support the case equality operator (===):

```ruby
case value
when _String then puts "It's a string!"
when _Integer then puts "It's an integer!"
end
```

### Type Constraints

Types can be constrained with additional validation rules. Constraints are chainable and combine logically. When
multiple constraints are applied, they form a single compound constraint that must be fully satisfied:

```ruby
# String with multiple constraints
username = _String
  .being_lowercase         # Must be lowercase
  .being_alphanumeric     # Only letters and numbers
  .having_size_between(3, 20)  # Length between 3-20 chars
  .not_matching(/^admin/i)     # Can't start with 'admin'

# Array with element and size constraints
numbers = _Array
  .of(_Integer)              # Elements must be integers
  .being_ordered            # Must be sorted
  .having_minimum_size(1)   # At least one element
  .containing(42)           # Must include 42
```

### Error Messages

Error messages clearly indicate what validation failed and why. For compound constraints, the error message shows all
failing constraints to help pinpoint the exact issues:

```ruby
# Type mismatch
_String.validate!(123)
# => TypeError: Expected String, but got Integer

# Constraint violation
_String.being_uppercase.validate!("hello")
# => TypeError: Expected String(being upper case), but got String(not upper case)

# Multiple constraints
_Integer.being_positive.being_even.validate!(-2)
# => TypeError: Expected Integer(being positive), got Integer(negative)

# Complex validation
_Array.of(_String.being_uppercase).validate!(["Hello", "WORLD"])
# => TypeError: Expected Array of String(being upper case), got Array containing String(not upper case)
```

## Built-in Types

### Simple Types

#### _String

String validation with comprehensive text manipulation constraints:

```ruby
_String                     # Basic string validation
  .being_ascii             # ASCII characters only
  .being_alphanumeric      # Letters and numbers only
  .being_lowercase         # Must be lowercase
  .being_uppercase         # Must be uppercase
  .being_titlecase         # Title Case Format
  .being_empty            # Must be empty
  .being_printable        # Printable characters only
  .containing("text")      # Must contain substring
  .excluding("bad")        # Must not contain substring
  .matching(/pattern/)     # Must match pattern
  .not_matching(/admin/)   # Must not match pattern
  .having_size(10)         # Exact length
  .having_size_between(1, 100)  # Length range
```

Also available as `_Text` and in nilable variants `_String?` and `_Text?`.

#### _Symbol

Symbol validation with all string constraints applied to the symbol name:

```ruby
_Symbol                     # Basic symbol validation
  .being_ascii             # ASCII characters only
  .being_alphanumeric      # Letters and numbers only
  .being_lowercase         # Must be lowercase
  .having_size_between(1, 100)  # Name length range
  .matching(/^[a-z_][a-z0-9_]*$/)  # Pattern matching
```

Also available as `_Interned` and in nilable variants `_Symbol?` and `_Interned?`.

#### _Integer

Integer validation with numeric constraints:

```ruby
_Integer                    # Basic integer validation
  .being_positive          # Must be positive
  .being_negative          # Must be negative
  .being_even             # Must be even
  .being_odd              # Must be odd
  .being_zero            # Must be zero
  .being_divisible_by(3)   # Must be divisible by 3
  .being_greater_than(0)   # Must be > 0
  .being_less_than(100)    # Must be < 100
  .being_between(1, 10)    # Must be between 1 and 10
```

Also available as `_Int`, `_Number` and in nilable variants `_Integer?`, `_Int?`, `_Number?`.

#### _Float

Float validation with numeric constraints:

```ruby
_Float                      # Basic float validation
  .being_positive          # Must be positive
  .being_negative          # Must be negative
  .being_finite           # Must be finite
  .being_infinite         # Must be infinite
  .being_divisible_by(0.5)  # Must be divisible by 0.5
  .being_greater_than(0.0)  # Must be > 0.0
  .being_less_than(1.0)     # Must be < 1.0
  .being_between(0.0, 1.0)  # Must be between 0.0 and 1.0
```

Also available as `_Decimal`, `_Real` and in nilable variants `_Float?`, `_Decimal?`, `_Real?`.

#### _Boolean

Boolean validation accepting only true or false:

```ruby
_Boolean === true   # => true
_Boolean === false  # => true
_Boolean === 1      # => false
_Boolean === 'true' # => false
```

Also available as `_Bool` and in nilable variants `_Boolean?`, `_Bool?`.

### Collection Types

#### _Array

Array validation with element and collection constraints:

```ruby
_Array                      # Basic array validation
  .of(_String)             # Element type constraint
  .being_empty            # Must be empty
  .being_populated        # Must not be empty
  .being_distinct         # No duplicate elements
  .being_ordered          # Must be sorted
  .containing(1, 2)       # Must contain elements
  .excluding(3, 4)        # Must not contain elements
  .having_size(3)         # Exact size
  .having_minimum_size(1)  # Minimum size
  .having_maximum_size(10) # Maximum size
```

Also available as `_List` and in nilable variants `_Array?`, `_List?`.

#### _Hash

Hash validation with key/value and collection constraints:

```ruby
_Hash                       # Basic hash validation
  .of(_Symbol => _String)   # Key/value type constraints
  .containing_keys(:a, :b)  # Required keys
  .excluding_keys(:c, :d)   # Forbidden keys
  .containing_values(1, 2)  # Required values
  .excluding_values(nil)    # Forbidden values
  .having_size(3)          # Exact size
  .having_minimum_size(1)   # Minimum size
```

Also available as `_Map` and in nilable variants `_Hash?`, `_Map?`.

### Date and Time Types

#### _Date

Date validation with chronological constraints:

```ruby
_Date                      # Basic date validation
  .being_after(Date.today)  # Must be after date
  .being_before(Date.today) # Must be before date
  .being_between(          # Must be in date range
    Date.today,
    Date.today + 30
  )
```

Available in nilable variant `_Date?`.

#### _DateTime

DateTime validation with chronological constraints:

```ruby
_DateTime                   # Basic datetime validation
  .being_after(DateTime.now)  # Must be after datetime
  .being_before(DateTime.now) # Must be before datetime
  .being_on_or_after(      # Must be >= datetime
    DateTime.now
  )
```

Available in nilable variant `_DateTime?`.

#### _Time

Time validation with chronological constraints:

```ruby
_Time                      # Basic time validation
  .being_after(Time.now)    # Must be after time
  .being_before(Time.now)   # Must be before time
  .being_on_or_before(     # Must be <= time
    Time.now
  )
```

Available in nilable variant `_Time?`.

### Network Types

#### _EmailAddress

Email validation with domain and format constraints:

```ruby
_EmailAddress              # Basic email validation
  .having_hostname("example.com")  # Specific domain
  .having_local_matching(/^[a-z]+$/)  # Username format
  .not_having_hostname("blocked.com")  # Blocked domains
```

Also available as `_Email` and in nilable variants `_EmailAddress?`, `_Email?`.

#### _URI

URI validation with component and format constraints:

```ruby
_URI                      # Basic URI validation
  .having_scheme("https")  # Specific scheme
  .having_hostname("api.example.com")  # Specific host
  .having_path("/v1/users")  # Specific path
  .not_having_scheme("ftp")  # Forbidden scheme
```

Also available as `_URL`, `_Url`, `_Uri` and in nilable variants `_URI?`, `_URL?`, `_Url?`, `_Uri?`.

#### _Hostname

Hostname validation according to RFC standards:

```ruby
_Hostname                  # Basic hostname validation
  .matching("example.com")  # Exact hostname match
  .not_matching("blocked")  # Hostname exclusion
  .being_ascii            # ASCII characters only
  .having_size_between(1, 253)  # Valid length range
```

Available in nilable variant `_Hostname?`.

### Identifier Types

#### _UUID

UUID validation with version and format constraints:

```ruby
_UUID                     # Basic UUID validation
  .being_version(4)       # Specific UUID version
  .being_compact         # No hyphens format
  .being_standard        # With hyphens format
  .being_version_four    # Must be v4 UUID
  .being_version_seven   # Must be v7 UUID
```

Also available as `_Uuid` and in nilable variants `_UUID?`, `_Uuid?`.

#### _CUID

CUID validation with version and format constraints:

```ruby
_CUID                     # Basic CUID validation
  .being_version(2)       # Specific CUID version
  .being_version_one     # Must be v1 CUID
  .being_version_two     # Must be v2 CUID
```

Also available as `_Cuid` and in nilable variants `_CUID?`, `_Cuid?`.

#### _ID

A union type accepting common ID formats:

```ruby
_ID === 123                    # Integer IDs
_ID === "clh3am1f30000bhqg"   # CUIDs
_ID === "123e4567-e89b-12d3"  # UUIDs
```

Available in nilable variant `_ID?`.

### Specification Types

#### _Anything

Accepts any value except those explicitly excluded:

```ruby
_Anything              # Accepts any value
_Anything.but(_String)  # Anything except strings
_Any                  # Alias for _Anything
```

#### _Duck

Duck type validation based on method presence:

```ruby
_Duck                                # Duck type validation
  .responding_to(:to_s, :to_i)       # Must have methods
  .not_responding_to(:dangerous_op)  # Must not have methods
```

Also available as `_Interface`, `_Protocol`, `_RespondingTo`.

#### _Enum

Enumerated value validation:

```ruby
_Enum(:red, :green, :blue)   # Must be one of values
_Enum("draft", "published")  # String enumeration
```

Also available as `_Literal` and in nilable variants `_Enum?`, `_Literal?`.

#### _Instance

Instance type validation with attribute constraints:

```ruby
_Instance              # Instance validation
  .of(User)           # Must be User instance
  .having_attributes(  # With attribute types
    name: _String,
    age: _Integer
  )
```

Also available as `_Record` and in nilable variants `_Instance?`, `_Record?`.

#### _Union

Combine multiple types with OR logic:

```ruby
_Union(_String, _Integer)   # String OR Integer
_Union(                     # Complex union
  _String.being_uppercase,
  _Integer.being_positive
)
```

Also available as `_Either`.

#### _Nilable

Make any type accept nil values:

```ruby
_Nilable(_String)          # String or nil
_String?                   # Same as above
```

Also available as `_Nullable`.

#### _Void

Accepts any value, useful for void returns:

```ruby
_Void === nil     # => true
_Void === false   # => true
_Void === Object.new  # => true
```

## Advanced Usage

### Custom Types

Create reusable custom types:

```ruby
module Types
  extend Domainic::Type::Definitions

  Username = _String
    .being_lowercase
    .being_alphanumeric
    .having_size_between(3, 20)
    .not_matching(/^admin/i)

  UserPassword = lambda { |username
    _String
      .having_size_between(8, 20)
      .being_mixedcase
      .not_matching(username)
  }
end

username = "alice123"
Types::Username.validate!(username)  # => true
Types::UserPassword.call(username).validate!("p@$Sw0rd")  # => true
```

### Type Composition

Build complex type hierarchies:

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
  _Hash.of(_Symbol => _String)
    .containing_keys(:error, :message)
))

# Form data validation
FormData = _Hash.of(
  _Symbol => _Union(
    _String.being_alphanumeric.having_size_between(3, 20),
    _String.matching(URI::MailTo::EMAIL_REGEXP),
    _Nilable(_Integer.being_greater_than_or_equal_to(18)),
    _Array.of(_String).having_maximum_size(5)
  )
).containing_keys(:username, :email, :age, :interests)
```

### Integration Patterns

#### With Classes

```ruby
class User
  extend Domainic::Type::Definitions

  attr_reader :name, :email

  def initialize(name, email)
    self.name = name
    self.email = email
  end

  def name=(value)
    _String
      .having_size_between(2, 50)
      .validate!(value)
    @name = value
  end

  def email=(value)
    _EmailAddress.validate!(value)
    @email = value
  end
end
```

#### With Domainic::Attributer

```ruby
require 'domainic/attributer'
require 'domainic/type/definitions'

class Configuration
  extend Domainic::Type::Definitions
  include Domainic::Attributer

  argument :environment, _Enum(:development, :test, :production)
  argument :log_level, _Enum(:debug, :info, :warn, :error)

  option :database_url, _String.matching(%r{\Apostgres://})
  option :redis_url, _String.matching(%r{\Aredis://})
  option :api_keys, _Array.of(_String).being_distinct
end
```
