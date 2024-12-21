# domainic-attributer v0.2.0

[![Milestone Progress](https://img.shields.io/github/milestones/progress-percent/domainic/domainic/3?style=for-the-badge&label=Progress)](https://github.com/domainic/domainic/milestone/3)

![Milestone Due Date](https://img.shields.io/badge/01%2F01%2F2025-blue?style=for-the-badge&label=Due%20Date)

## Overview

A significant release focusing on developer experience, error handling, and documentation clarity. This release
introduces several improvements that may impact existing code, necessitating a minor version bump.

## Confirmed Changes

### 1. Nil Handling in Coercion

* Prevent coercion of nil values for non-nilable attributes
* Provide clear documentation about nil handling in coercion methods
* Modify coercion logic to respect nilability constraints

### 2. Documentation Improvements

* Clarify attribute validation and coercion behavior
* Explain attribute constraint application across object lifecycle
* Provide comprehensive examples of validation mechanisms
* Explicitly document that constraints apply to ALL attribute assignments

### 3. Callback Error Handling

* Implement comprehensive error handling for callback execution
* Introduce configurable error handling strategies:
  1. Raise an error and stop execution (default)
  2. Log the error and continue
  3. Collect errors and raise a composite error
* Create custom `CallbackError` and `CompositeCallbackError` classes
* Add configuration option for error handling strategy

## Release Goals

* Improve nil value handling
* Enhance error handling for callbacks
* Provide crystal-clear documentation
* Increase overall library robustness

## Breaking Changes

1. Nil Coercion Prevention
  * Non-nilable attributes will no longer coerce nil values
  * Existing code may need to be updated to explicitly handle nil cases
2. Callback Error Handling
  * New error handling strategies
  * Introduction of custom error classes
  * Potential changes to callback execution behavior

### Nil Coercion

```ruby
# Before (0.1.x)
option :count, Integer do
  coerce_with :to_i  # Would attempt to coerce nil
end

# After (0.2.0)
option :count, Integer do
  coerce_with :to_i  # Nil will be prevented for non-nilable attributes
  # Explicitly handle nil if needed
  coerce_with ->(val) { val.nil? ? 0 : val.to_i }
end
```

### Callback Error Handling

```ruby
# Before (0.1.x)
# No explicit error handling

# After (0.2.0)
class MyClass
  include Domainic::Attributer

  option :value do
    on_change ->(old, new) { ... }

    # Optional: Configure error handling
    on_change_error_strategy :log  # or :raise, :collect
  end
end
```

## Acceptance Criteria

* [x] Nil coercion prevention implemented
* [x] Comprehensive documentation updates
* [x] Callback error handling mechanism complete
* [x] All existing tests pass
* [x] New tests cover nil handling and error strategies
* [x] Migration guide is clear and comprehensive

## Release Preparation Workflow

1. **Feature Implementation** (Now * Dec 25th)
  * Finalize code changes
  * Comprehensive testing
  * Documentation updates
2. **Final Review** (Dec 26th * Dec 31st)
  * Thorough testing
  * Documentation review
  * Migration guide verification
3. **Release** (January 1st)
  * Tag release
  * Publish to RubyGems
  * Update documentation

## Communication Plan

* Detailed changelog highlighting breaking changes
* Clear migration guide
* Community notification about new features

## Risks

* Potential confusion with breaking changes
* Complexity of error handling strategies
* Performance implications of new error handling

## Post-Release Considerations

* Monitor community feedback
* Be prepared to provide additional clarification
* Potential follow-up patch releases for any discovered issues
