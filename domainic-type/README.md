# Domainic::Type

[![Domainic::Type Version](https://img.shields.io/gem/v/domainic-type?style=for-the-badge&logo=rubygems&logoColor=white&logoSize=auto&label=Gem%20Version)](https://rubygems.org/gems/domainic-type)
[![Domainic::Type License](https://img.shields.io/github/license/domainic/domainic?logo=opensourceinitiative&logoColor=white&logoSize=auto&style=for-the-badge)](./LICENSE)
[![Domainic::Type Docs](https://img.shields.io/badge/rubydoc-blue?style=for-the-badge&logo=readthedocs&logoColor=white&logoSize=auto&label=docs)](https://rubydoc.info/gems/domainic-type/0.1.0)
[![Domainic::Type Open Issues](https://img.shields.io/github/issues-search/domainic/domainic?query=state%3Aopen%20label%3Adomainic-type&color=red&style=for-the-badge&logo=github&logoColor=white&logoSize=auto&label=issues)](https://github.com/domainic/domainic/issues?q=state%3Aopen%20label%3Adomainic-type%20)

> [!IMPORTANT]  
> We're running an experiment with Domainic::Type! Help us explore flexible type validation in Ruby by trying our
> [alpha release](https://github.com/domainic/domainic/wiki/experiments-domainic-type-v0.1.0-alpha). Your feedback is
> invaluable for shaping the future of domain-driven design in Ruby.

A flexible type validation system for Ruby that brings the power of composable constraints and crystal-clear error
messages to your domain models. Domainic::Type provides a rich set of built-in types that know how to validate
themselves, intelligently handle various formats, and tell you exactly what's wrong when validation fails.

This is particularly useful when building domain-driven applications, where strong type validation and clear error
handling are essential. Instead of writing repetitive validation code and complex error messages, let Domainic::Type
bring type safety to your Ruby code in a way that feels natural and expressive.

## Quick Start

```ruby
require 'domainic/type/definitions'
include Domainic::Type::Definitions

# Type validation with clear error messages
username = _String
  .being_lowercase
  .being_alphanumeric
  .having_size_between(3, 20)

username.validate!("ABC123")
# => TypeError: Expected String(being lowercase), got String(not lowercase)

# Rich collection validation
admin_list = _Array
  .of(_String)
  .being_distinct
  .being_ordered
  .excluding("root")

admin_list.validate!(["admin", "admin", "user"])
# => TypeError: Expected Array(being distinct), got Array(containing duplicates)

# Strong type constraints
config = _Hash
  .of(_Symbol => _String)
  .containing_keys(:host, :port)

config.validate!({ host: 123 })
# => TypeError: Expected Hash(having values of String), got Hash(having values of Integer)
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'domainic-type'
```

Or install it yourself as:

```bash
gem install domainic-type
```

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
