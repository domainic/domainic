# Domainic::Type Alpha 3

Welcome to the Domainic::Type Alpha 3 experiment! This is a Ruby gem exploring flexible, composable type
validation with clear error messages.

![Experiment Status](https://img.shields.io/badge/ACTIVE-orange?label=Status&style=for-the-badge)

![Experiment Start Date](https://img.shields.io/badge/12%2F23%2F2024-blue?style=for-the-badge&label=Start%20Date)
![Experiment End Date](https://img.shields.io/badge/02%2F01%2F2025-blue?style=for-the-badge&label=End%20Date)

## Documentation Structure

This experiment includes several documentation files:

* [EXAMPLES](./EXAMPLES.md) - Comprehensive examples from basic to advanced usage, covering all types and features
* [TROUBLESHOOTING](./TROUBLESHOOTING.md) - Common issues, gotchas, debugging tips, and known behavior quirks
* [CHANGELOG](./CHANGELOG.md) - Version history and changes between experiment versions
* [KNOWN_ISSUES](./KNOWN_ISSUES.md) - Tracks discovered issues and their current status

## Quick Start

```ruby
gem 'domainic-type', '~> 0.1.0.alpha.3'
```

```ruby
require 'domainic/type/definitions'
include Domainic::Type::Definitions

# Simple type validation
string_type = _String
string_type.validate!("hello")  # => true
string_type.validate!(123)      # => TypeError: Expected String, but got Integer

# Chain ALL the constraints!
username = _String
  .being_lowercase
  .being_alphanumeric
  .having_size_between(3, 20)
  .not_matching(/^admin/i)

# Complex array validation
admin_list = _Array
  .of(_String)
  .being_distinct
  .being_ordered
  .excluding("root")
  .having_minimum_size(1)

# Hash with specific key/value types
config = _Hash
  .of(Symbol => _String)
  .containing_keys(:host, :port)
  .excluding_values(nil, "")
```

## What We're Exploring

This experiment focuses on three main areas:

### 1. Error Message Composition 🎯

We're particularly interested in how error messages compose when using multiple constraints. Try these scenarios:

```ruby
# Scenario 1: Multiple String Constraints
name_type = _String
  .being_titlecase
  .matching(/^[A-Z][a-z]+$/)
  .having_size_between(2, 30)

name_type.validate!("a")  # What error message do you get?

# Scenario 2: Nested Type Constraints
user_type = _Hash
  .of(Symbol => _Union(_String, _Integer))
  .containing_keys(:name, :age)
  .excluding_values(nil)

user_type.validate!({
  name: 123,
  age: "twenty"
})  # How clear is this error?

# Scenario 3: Array Element Validation
numbers = _Array
  .of(_Integer)
  .being_ordered
  .having_size(3)
  .containing(42)

numbers.validate!(["1", 2, 3])  # Is the error helpful?
```

### 2. Built-in Types

Currently supported types:

* `_String`
* `_Integer`
* `_Float`
* `_Array`
* `_Hash`
* `_Symbol`
* `_Boolean`
* `_Union`
* `_Enum`
* `_Duck`
* `_Anything`
* `_Nilable`

Try them out! What types are missing? What would make existing types more useful?

### 3. Constraints

Each type comes with its own set of constraints. Here are some highlights:

String constraints:

```ruby
_String
  .being_ascii
  .being_alphanumeric
  .being_lowercase
  .being_uppercase
  .being_titlecase
  .matching(/pattern/)
  .containing("substring")
  .having_size_between(min, max)
```

Numeric constraints:

```ruby
_Integer
  .being_positive
  .being_negative
  .being_even
  .being_odd
  .being_divisible_by(3)
  .being_between(1, 100)
```

Array/Hash constraints:

```ruby
_Array
  .being_empty
  .being_ordered
  .being_distinct
  .containing(1, 2, 3)
  .excluding(4, 5, 6)
  .having_size(5)

_Hash
  .containing_keys(:a, :b)
  .excluding_values(nil)
  .having_minimum_size(2)
```

What constraints would you add? What would make existing constraints more powerful?

## Providing Feedback

We want to make providing feedback as easy as possible! Leave a comment on one of the mega-issues described below or
just open an issue on GitHub describing what you found. No formal template required - tell us what worked, what didn't,
what confused you, or what you wish existed.

Some things we'd love to hear about:

* Confusing or unhelpful error messages
* Missing types or constraints you need
* Unexpected errors or behavior
* Creative ways you worked around limitations
* Ideas for making the library more useful
* Your use cases and how you're using types

Include code examples if you can, but don't worry if you can't!

### Feedback Categories

We've set up mega-issues for collecting certain types of feedback:

* [Error Messages](https://github.com/domainic/domainic/issues/132) - Share confusing or unhelpful error messages
* [Unexpected Behavior](https://github.com/domainic/domainic/issues/133) - Report surprising or unexpected behavior
* [Feature Requests](https://github.com/domainic/domainic/issues/134) - Suggest new types, constraints, or capabilities
* [General Feedback](https://github.com/domainic/domainic/issues/135) - Everything else!

## Inspiration

This experiment draws inspiration from several existing type systems and validation libraries:

* [ValueSemantics](https://github.com/tomdalling/value_semantics)
* [Literal](https://github.com/joeldrapper/literal)
* [Sorbet](https://github.com/sorbet/sorbet) & [RBS](https://github.com/ruby/rbs)
* [TypeScript](https://github.com/microsoft/TypeScript)

## Going Wild

Don't hold back! Try complex combinations of types and constraints. Chain constraints together in creative ways. Push
the boundaries of what's possible. The more you experiment, the more we learn!

```ruby
# Example: Go nuts!
response_type = _Hash
  .of(_Symbol => _Union(
    _String.being_uppercase.matching(/^[A-Z]{2,5}$/),
    _Array.of(_Integer.being_positive.being_less_than(100)),
    _Hash.of(_Symbol => _Boolean)
  ))
  .containing_keys(:status, :data)
  .having_minimum_size(2)
```

## Questions

Not sure about something? Just open an issue! The only bad question is the unasked question!

Remember: This is an experiment! Things might break, error messages might be confusing, and features might be missing.
That's exactly what we want to learn about!

|                         |                                       |                                 |                            |
|-------------------------|---------------------------------------|---------------------------------|----------------------------|
| [Examples](EXAMPLES.md) | [Troubleshooting](TROUBLESHOOTING.md) | [Known Issues](KNOWN_ISSUES.md) | [Changelog](CHANGELOG.md)  |
