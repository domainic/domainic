# domainic-attributer v0.1.0

[![Milestone Progress](https://img.shields.io/github/milestones/progress-percent/domainic/domainic/4?style=for-the-badge&label=Progress)](https://github.com/domainic/domainic/milestone/4)

![Milestone Due Date](https://img.shields.io/badge/12%2F12%2F2024-blue?style=for-the-badge&label=Due%20Date)

A Ruby gem that provides an elegant DSL for defining and managing object attributes with built-in support for type
validation, coercion, change tracking, and more.

## Problem Statement

Ruby's built-in attribute methods (`attr_reader`, `attr_writer`, `attr_accessor`) provide basic attribute functionality
but lack important features needed for domain-driven design such as type validation, coercion, and change tracking.
Developers often end up writing repetitive boilerplate code to handle these common needs.

## Solution

Domainic::Attributer provides a rich DSL for defining object attributes that handles common attribute-related tasks
while maintaining Ruby's expressiveness. It distinguishes between constructor arguments and optional attributes while
providing a consistent interface for both.

## Key Features

* **Positional Arguments vs Named Options**: Clear distinction between required constructor arguments and optional
  attributes
* **Type Validation**: Built-in type checking with support for custom validators
* **Value Coercion**: Automatic value transformation with custom coercion support
* **Default Values**: Support for both static defaults and dynamic generators
* **Change Tracking**: Callback system for monitoring attribute changes
* **Visibility Control**: Fine-grained control over attribute reader/writer visibility
* **Extensible Design**: Support for custom naming conventions and attribute behaviors

## Usage Examples

```ruby
class UserCreator
  include Domainic::Attributer

  argument :login, String do
    desc 'The login for the User'
    coerce_with ->(value) { value.to_s }
    validate_with ->(value) { Uri::MailTo::EMAIL_REGEXP.match?(value) }
    non_nilable
  end

  option :password, String do
    desc 'The user password'
    non_nilable
    required
  end

  option :role, Symbol do
    desc 'The role of the User'
    default :basic
    validate_with ->(value) { USER_ROLES.include?(value) }
  end
end

# Usage:
UserCreator.new('hello@example.com', password: 'secure123')
UserCreator.new('hello@example.com', password: 'secure123', role: :admin)
```

## Technical Details

### Attribute Types

* **Arguments**: Positional parameters required during object initialization
* **Options**: Named parameters that may be optional or required

### Validation Features

* Non-nilable attributes
* Required vs optional options
* Type validation
* Custom validation rules

### Coercion System

* Automatic type coercion
* Custom coercion handlers
* Value transformation hooks

### Change Tracking

* Before/after change callbacks
* Custom change handlers
* Value transformation tracking

### Visibility Controls

* Public/protected/private readers
* Public/protected/private writers
* Mixed visibility support

## Dependencies

* Ruby 3.1+
* No external runtime dependencies

## Performance Considerations

* Minimal runtime overhead
* Lazy initialization of attribute handlers
* Efficient memory usage through shared handlers

## Future Considerations

* Integration points with domainic-validator
* Extension points for domainic-type
* Potential for custom attribute types
