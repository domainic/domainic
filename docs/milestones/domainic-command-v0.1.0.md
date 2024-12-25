# domainic-command v0.1.0

![Milestone Status](https://img.shields.io/badge/Planned-blue?style=for-the-badge&label=Status)
[![Milestone Progress](https://img.shields.io/github/milestones/progress-percent/domainic/domainic/6?style=for-the-badge&label=Progress)](https://github.com/domainic/domainic/milestone/6)

![Milestone Start Date](https://img.shields.io/badge/TBD-blue?style=for-the-badge&label=Start%20Date)
![Milestone Due Date](https://img.shields.io/badge/TBD-blue?style=for-the-badge&label=Due%20Date)

[![Milestone Open Tasks](https://img.shields.io/github/issues-search/domainic/domainic?query=is%3Aopen%20milestone%3A%22domainic-command%20v0.1.0%22&style=for-the-badge&label=Open%20Tasks&color=red)](https://github.com/domainic/domainic/issues?q=is%3Aopen%20milestone%3A%22domainic-command%20v0.1.0%22)
[![Milestone Closed Tasks](https://img.shields.io/github/issues-search/domainic/domainic?query=is%3Aclosed%20milestone%3A%22domainic-command%20v0.1.0%22&style=for-the-badge&label=Closed%20Tasks&color=green)](https://github.com/domainic/domainic/issues?q=is%3Aclosed%20milestone%3A%22domainic-command%20v0.1.0%22)
[![Milestone Total Tasks](https://img.shields.io/github/issues-search/domainic/domainic?query=milestone%3A%22domainic-command%20v0.1.0%22&style=for-the-badge&label=Total%20Tasks&color=blue)](https://github.com/domainic/domainic/issues?q=milestone%3A%22domainic-command%20v0.1.0%22)

Domainic::Command is a powerful Ruby gem that brings the Command design pattern to life, offering a robust framework for
encapsulating and managing complex business operations. By treating commands as first-class objects, the gem provides a
structured, testable, and extensible approach to implementing domain logic.

## Problem Statement

Complex business operations often become tangled, difficult to test, and hard to maintain. Traditional approaches mix
concerns, making code less readable and more prone to errors. Developers need a way to isolate, compose, and manage
business logic with clarity and precision.

## Solution

Domainic::Command provides a clean, declarative approach to defining executable operations. Each command becomes a
self-contained object with clear input arguments, output expectations, and execution logic, promoting separation of
concerns and improving code maintainability.

## Key Features

* **Declarative Command Definition**
  * Clear argument specifications
  * Explicit return type declarations
  * Built-in validation for inputs and outputs
  * Support for required and optional arguments
* **Comprehensive Command Lifecycle**
  * Input validation
  * Execution context management
  * Return value tracking
  * Error handling capabilities
* **Flexible Execution Model**
  * Synchronous command execution
  * Potential for async/background processing
  * Composable command chains
  * Introspection of command metadata

## Usage Examples

```ruby
class CreateUser < Domainic::Command
  argument :login, EmailAddress, "The User's login", required: true
  argument :password, String, "The User's password", required: true
  argument :role, Symbol, "User's initial role", default: :member

  returns :user, User, 'The created User', required: true

  def execute
    context.user = User.create!(
      email: context.login,
      password: context.password,
      role: context.role
    )
  end
end

# Executing the command
result = CreateUser.call(login: 'user@example.com', password: 'secure_password')
result.success? #=> true
result.data.user #=> <# User:0x000000ab0c1d @login="user@example.com", @password_digest="...", @role=:member>
```

## Technical Details

### Command Characteristics

* Explicit argument definitions
* Type-checked inputs
* Standardized execution interface
* Metadata-rich command objects

### Execution Strategies

* Synchronous execution
* Potential background job integration
* Contextual execution support

## Design Philosophy

Domainic::Command prioritizes:

* Clarity of intent
* Testability of business logic
* Minimal boilerplate
* Flexible composition
* Type safety

## Dependencies

* Ruby 3.1+
* Optional integration with Domainic::Attributer
* Optional integration with Domainic::Validation

## Future Considerations

* Advanced command composition
* Async/background execution support
* Comprehensive logging and tracing
* Integration with workflow systems
* Performance optimizations

## Performance Considerations

* Lightweight command object creation
* Minimal runtime overhead
* Efficient validation mechanisms
* Lazy argument processing
