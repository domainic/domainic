# Domainic

[![Domainic Version](https://img.shields.io/badge/unreleased-orange?label=gem%20version&logo=rubygems&logoColor=white&logoSize=auto&style=for-the-badge)](https://rubygems.org/gems/domainic)
[![Domainic Build](https://img.shields.io/github/actions/workflow/status/domainic/domainic/build.yml?branch=main&style=for-the-badge&logo=githubactions&logoColor=white&logoSize=auto)](https://github.com/domainic/domainic/actions/workflows/build.yml)
[![Domainic Code Quality](https://img.shields.io/codacy/grade/17177dca4a76428c9422ceb8fb970271/main?style=for-the-badge&logo=codacy&logoSize=auto)](https://app.codacy.com/gh/domainic/domainic/dashboard)
[![Domainic Code Coverage](https://img.shields.io/codacy/coverage/17177dca4a76428c9422ceb8fb970271/main?style=for-the-badge&logo=codacy&logoSize=auto)](https://app.codacy.com/gh/domainic/domainic/coverage)
[![Domainic License](https://img.shields.io/github/license/domainic/domainic?logo=opensourceinitiative&logoColor=white&logoSize=auto&style=for-the-badge)](./LICENSE)
[![Domainic Open Issues](https://img.shields.io/github/issues-search/domainic/domainic?label=open%20issues&logo=github&logoSize=auto&query=is%3Aopen&color=red&style=for-the-badge)](https://github.com/domainic/domainic/issues?q=state%3Aopen)

> [!IMPORTANT]  
> We're running an experiment with Domainic::Type! Help us explore flexible type validation in Ruby by trying our
> [alpha release](./docs/experiments/domainic-type-alpha-3/README.md). Your feedback is invaluable for shaping
> the future of domain-driven design in Ruby.

A suite of Ruby libraries crafted to arm engineers with the magic of domain-driven design.

> [!WARNING]
> The Domainic gem is currently in pre-release. Until v0.1.0, components must be installed individually.

## About

Domainic is an ecosystem of Ruby gems designed to provide a comprehensive toolkit for domain-driven design. The v0.1.0
release will include:

* [domainic-attributer](https://github.com/domainic/domainic/tree/main/domainic-attributer) - Type-safe,
  self-documenting class attributes
* domainic-boundary - Clean interfaces between domain boundaries
* domainic-command - First-class command objects for business operations
* domainic-type - Sophisticated type constraints and validation

## Current Status

The `domainic` gem itself will bundle all components starting with v0.1.0. Until then:

* Components are being released individually
* You must install each component separately
* Only domainic-attributer is currently available

## Installation

### Current Pre-release Usage

Install components individually:

```ruby
# Gemfile
gem 'domainic-attributer' # Only component currently available
```

### Future v0.1.0 Usage

Once v0.1.0 is released, you'll be able to install everything at once:

```ruby
# Gemfile
gem 'domainic' # Will include all components
```

## Available Components

* [domainic-attributer](./domainic-attributer/README.md) - A library for defining type-safe self-documenting class
  attributes

## Development

### Quick Start

1. Clone the repository
2. Run `bin/setup` to install dependencies
3. Run `bin/dev ci` to ensure everything is set up correctly

### Development CLI

Domainic uses a development CLI to manage the monorepo and ensure consistent development practices. View available
commands with `bin/dev help`. See [domainic-dev](./domainic-dev/README.md) for more information.

Key commands:

```bash
bin/dev ci      # Run the full CI pipeline - REQUIRED before submitting PRs
bin/dev test    # Run tests for specific gems
bin/dev lint    # Run linters
```

### Project Structure

Domainic is organized as a monorepo containing multiple gems:

* `domainic-attributer/` - Type-safe class attributes
* `domainic-boundary/` - Clean domain boundaries
* `domainic-command/` - Command objects
* `domainic-type/` - Type constraints and validation

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](./docs/CONTRIBUTING.md) for:

* Development setup and workflow
* Code style and documentation standards
* Testing requirements
* Pull request process

Before contributing, please review our [Code of Conduct](./docs/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).
