# Domainic::Attributer

[![Domainic::Attributer Version](https://img.shields.io/gem/v/domainic-attributer?label=gem%20version&logo=rubygems&logoSize=auto&style=for-the-badge)](https://rubygems.org/gems/domainic-attributer)
[![Domainic::Attributer License](https://img.shields.io/github/license/domainic/domainic?logo=opensourceinitiative&logoColor=white&logoSize=auto&style=for-the-badge)](./LICENSE)
[![Domainic::Attributer Docs](https://img.shields.io/badge/docs-blue?logo=readthedocs&logoColor=white&logoSize=auto&style=for-the-badge)](https://rubydoc.info/gems/domainic-attributer)
[![Domainic::Attributer Open Issues](https://img.shields.io/github/issues-search/domainic/domainic?label=open%20issues&logo=github&logoSize=auto&query=is%3Aopen%20label%3Adomainic-attributer&color=red&style=for-the-badge)](https://github.com/domainic/domainic/issues?q=state%3Aopen%20label%3Adomainic-attributer%20)

Domainic::Attributer is a powerful toolkit that brings clarity and safety to your Ruby class attributes.
Ever wished your class attributes could:

* Validate themselves to ensure they only accept correct values?
* Transform input data automatically into the right format?
* Have clear, enforced visibility rules?
* Handle their own default values intelligently?
* Tell you when they change?
* Distinguish between required arguments and optional settings?

That's exactly what Domainic::Attributer does! It's particularly useful when building domain models, value
objects, or any Ruby classes where data integrity and clear interfaces matter. Instead of writing
repetitive validation code, manual type checking, and custom attribute methods, let Domainic::Attributer
handle the heavy lifting while you focus on your domain logic.

Think of it as giving your attributes a brain - they know what they want, how they should behave, and
they're not afraid to speak up when something's not right!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'domainic-attributer'
```

Or install it yourself as:

```bash
gem install domainic-attributer
```

## Quick Start

```ruby
class SuperDev
  include Domainic::Attributer

  argument :code_name, String
  option :power_level, Integer, default: 9000

  option :favorite_gem do
    validate_with ->(val) { val.to_s.end_with?('ruby') }
    coerce_with ->(val) { val.to_s.downcase }
    non_nilable
  end
end

dev = SuperDev.new('RubyNinja', favorite_gem: 'RAILS_RUBY')
dev.favorite_gem  # => "rails_ruby"
dev.power_level = 9001
dev.power_level = 'over 9000'  # Raises ArgumentError: invalid value for Integer
```

## Documentation

For detailed usage instructions and examples, see [USAGE.md](./docs/USAGE.md).

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](./../docs/CONTRIBUTING.md) for:

* Development setup and workflow
* Code style and documentation standards
* Testing requirements
* Pull request process

Before contributing, please review our [Code of Conduct](./../docs/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).
