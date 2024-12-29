# Domainic::Command

[![Domainic::Command Version](https://img.shields.io/gem/v/domainic-command?style=for-the-badge&logo=rubygems&logoColor=white&logoSize=auto&label=Gem%20Version)](https://rubygems.org/gems/domainic-command)
[![Domainic::Command License](https://img.shields.io/github/license/domainic/domainic?style=for-the-badge&logo=opensourceinitiative&logoColor=white&logoSize=auto)](./LICENSE)
[![Domainic::Command Docs](https://img.shields.io/badge/rubydoc-blue?style=for-the-badge&logo=readthedocs&logoColor=white&logoSize=auto&label=docs)](https://rubydoc.info/gems/domainic-command/0.1.0)
[![Domainic::Command Open Issues](https://img.shields.io/github/issues-search/domainic/domainic?query=state%3Aopen%20label%3Adomainic-command&style=for-the-badge&logo=github&logoColor=white&logoSize=auto&label=issues&color=red)](https://github.com/domainic/domainic/issues?q=state%3Aopen%20label%3Adomainic-command%20)

A robust implementation of the Command pattern for Ruby applications, providing type-safe, self-documenting business
operations with standardized error handling and composable workflows.

Tired of scattered business logic and unclear error handling? Domainic::Command brings clarity to your domain operations
by:

* Enforcing explicit input/output contracts with type validation
* Providing consistent error handling and status reporting
* Enabling self-documenting business operations
* Supporting composable command workflows
* Maintaining thread safety for concurrent operations

## Quick Start

```ruby
class CreateUser
  include Domainic::Command

  # Define expected inputs with validation
  argument :login, String, "The user's login", required: true
  argument :password, String, "The user's password", required: true

  # Define expected outputs
  output :user, User, "The created user", required: true
  output :created_at, Time, "When the user was created"

  def execute
    user = User.create!(login: context.login, password: context.password)
    context.user = user
    context.created_at = Time.current
  end
end

# Success case
result = CreateUser.call(login: "user@example.com", password: "secret123")
result.successful? # => true
result.user       # => #<User id: 1, login: "user@example.com">

# Failure case
result = CreateUser.call(login: "invalid")
result.failure?   # => true
result.errors     # => { password: ["is required"] }
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'domainic-command'
```

Or install it yourself as:

```bash
gem install domainic-command
```

## Key Features

* **Type-Safe Arguments**: Define and validate input parameters with clear type constraints
* **Explicit Outputs**: Specify expected return values and their requirements
* **Standardized Error Handling**: Consistent error reporting with detailed failure information
* **Thread Safety**: Built-in thread safety for class definition and execution
* **Command Composition**: Build complex workflows by combining simpler commands
* **Self-Documenting**: Generate clear documentation from your command definitions
* **Framework Agnostic**: Use with any Ruby application (Rails, Sinatra, pure Ruby)

## Documentation

For detailed usage instructions and examples, see [USAGE.md](./docs/USAGE.md).

## Contributing

We welcome contributions! Please see our
[Contributing Guidelines](https://github.com/domainic/domainic/wiki/CONTRIBUTING) for:

* Development setup and workflow
* Code style and documentation standards
* Testing requirements
* Pull request process

Before contributing, please review our [Code of Conduct](https://github.com/domainic/domainic/wiki/CODE_OF_CONDUCT).

## License

The gem is available as open source under the terms of the [MIT License](./LICENSE).
