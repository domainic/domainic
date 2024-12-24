# Contributing to Domainic

Thank you for your interest in contributing to Domainic! We're building a suite of Ruby gems to empower developers with
domain-driven design tools. Before contributing, please review our [Development Guide](./../README.md#development) for
essential setup and CLI usage information.

## Table of Contents

* [Code of Conduct](#code-of-conduct)
* [Development Guidelines](#development-guidelines)
  * [Code Style](#code-style)
  * [Documentation](#documentation)
  * [Testing](#testing)
* [Making Changes](#making-changes)
  * [Branches](#branches)
  * [Commits](#commits)
  * [Pull Requests](#pull-requests)

## Code of Conduct

All contributors are expected to read and follow our [Code of Conduct](./CODE_OF_CONDUCT.md) before participating.

## Development Guidelines

### Code Style

We use RuboCop to enforce consistent code style throughout the project. Please ensure your changes pass the linting
checks by running `bin/dev lint` before submitting a PR. Our complete RuboCop configuration can be found in our
[rubocop config](./../.rubocop.yml).

### Documentation

Documentation should follow this order:

```ruby
# Description of the class/module.
#
# More verbose description if needed.
#
# @example Usage example here
#   MyClass.new.my_method
#
# @note Any additional notes
# @see Related classes/modules
# @abstract Optional abstraction details
# @!visibility Optional visibility details
# @api Optional API designation
#
# @author {https://aaronmallen.me Aaron Allen}
# @since VERSION
```

For methods:

```ruby
# Description of the method.
#
# More verbose description if needed.
#
# @example Usage example
#   my_method(argument)
#
# @param argument [Type] Description
# @return [Type] Description
# @rbs def method(argument: Type) -> Return_Type
```

### Testing

We use RSpec for testing. Key guidelines:

1. Use "is expected to" format for readability in test output:

  ```ruby
  # Good - produces clear output with --format documentation
  it { is_expected.to be_valid }

  # Also good - when example values shouldn't appear in output
  it 'is expected to have correct attributes' do
    expect(subject.name).to eq('example')
  end
```

2. Test Guidelines:
* Test behavior, not implementation
* One expectation per test
* Use descriptive contexts starting with "when", "with", or "without"
* Limit to 5 memoized helpers per context

## Making Changes

### Branches

Use descriptive branch names prefixed with the type:

* `enhancment/` or `feature/` for new features
* `fix/` for bug fixes
* `docs/` for documentation
* `refactor/` for code refactoring

While not required, we recommend prefixing branches with the gem name for clarity in our monorepo structure:

```markdown
domainic-attributer/feature/new-validator
domainic-type/fix/constraint-error
```

### Commits

Wrap all commit message lines at 72 characters:

```markdown
Add validation support to AttributeBuilder class

Implements a new validation system that provides:
- Type checking for attribute values
- Custom validation rules
- Clear error messages for validation failures

Changelog:
  - added `Domainic::Attributer::Validator`
  - changed `AttributeBuilder#validate`
  - added validation examples to documentation

Fixes #123
```

### Pull Requests

Before submitting a PR:

1. Run `bin/dev ci` to ensure all tests and checks pass
2. Update documentation as needed
3. Include in your PR:
* Clear title and description
* Reference to related issues
* List of significant changes
* Screenshots for UI changes

## For Questions

* Open an issue for bugs or feature requests
* Join our discussions for general questions
* Contact maintainers for sensitive issues
