# Domainic

[![Domainic Build](https://img.shields.io/github/actions/workflow/status/domainic/domainic/build.yml?branch=main&style=for-the-badge&logo=githubactions&logoColor=white&logoSize=auto)](https://github.com/domainic/domainic/actions/workflows/build.yml)
[![Domainic Version](https://img.shields.io/badge/not%20released-orange?label=gem%20version&logo=rubygems&logoSize=auto&style=for-the-badge)](https://rubygems.org/gems/domainic)
[![Domainic License](https://img.shields.io/github/license/domainic/domainic?logo=opensourceinitiative&logoColor=white&logoSize=auto&style=for-the-badge)](./LICENSE)
[![Domainic Open Issues](https://img.shields.io/github/issues-search/domainic/domainic?label=open%20issues&logo=github&logoSize=auto&query=is%3Aopen&color=red&style=for-the-badge)](https://github.com/domainic/domainic/issues?q=state%3Aopen)

A suite of Ruby libraries crafted to arm engineers with the magic of domain-driven design.

> **Note**: The Domainic gem is currently in pre-release. Until v0.1.0, components must be installed individually.

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
