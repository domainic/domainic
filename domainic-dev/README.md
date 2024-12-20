# Domainic Development Tools

Tools and utilities to streamline Domainic development.

## Quick Start

Run entire CI pipeline (required before pushing changes):

```bash
bin/dev ci
```

Run tests:

```bash
bin/dev test                # Test all gems
bin/dev test gem-name       # Test specific gem
bin/dev test --rbs         # Test with RBS enabled
```

Run linters:

```bash
bin/dev lint               # Run all linters
bin/dev lint ruby         # Run Rubocop
bin/dev lint types        # Run Steep (type checking)
bin/dev lint markdown     # Run markdownlint
```

## Available Commands

### Testing & Linting

- `bin/dev ci` - Run complete CI pipeline
- `bin/dev test [GEM_NAMES]` - Run tests for specified gems
- `bin/dev lint all` - Run all linters
- `bin/dev lint ruby|rb` - Run Rubocop
- `bin/dev lint types` - Run Steep type checking
- `bin/dev lint markdown|md` - Run markdownlint

### Package Management

- `bin/dev package [GEM_NAMES]` - Build gem packages
- `bin/dev publish [GEM_NAMES]` - Publish gems to RubyGems

### Code Generation

- `bin/dev generate gem NAME` - Generate new Domainic gem
- `bin/dev generate signatures [GEM_NAMES]` - Generate RBS type signatures

### Help & Documentation

- `bin/dev help` - Show available commands
- `bin/dev help COMMAND` - Show detailed help for command

## Example Workflows

### Creating a New Gem

```bash
# Generate new gem
bin/dev generate gem my-gem

# Run tests
bin/dev test my-gem

# Run linters
bin/dev lint all

# Package gem
bin/dev package my-gem
```

### Pre-Push Checklist

```bash
# Run full CI pipeline
bin/dev ci

# Or run individual checks:
bin/dev lint all          # Run all linters
bin/dev test --rbs       # Run tests with RBS
```

### Publishing Updates

```bash
# Run CI checks
bin/dev ci

# Package gems
bin/dev package

# Publish to RubyGems
bin/dev publish
```

## Development Guidelines

Always run the full CI pipeline (`bin/dev ci`) before pushing changes. This ensures:

- All tests pass
- Code meets style guidelines (Rubocop)
- Types are valid (Steep)
- Documentation is properly formatted (markdownlint)

For detailed information on any command:

```bash
bin/dev help [COMMAND]
```
