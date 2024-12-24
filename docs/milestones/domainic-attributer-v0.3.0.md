# domainic-attributer-v0.3.0

[![Milestone Progress](https://img.shields.io/github/milestones/progress-percent/domainic/domainic/8?style=for-the-badge&label=Progress)](https://github.com/domainic/domainic/milestone/8)

![Milestone Due Date](https://img.shields.io/badge/TBD-blue?style=for-the-badge&label=Due%20Date)

## Overview

A major release introducing powerful attribute customization and error handling features. This release focuses on
enhancing flexibility and usability of Domainic::Attributer, with some breaking changes to support the new functionality.

## Confirmed Changes

### 1. Custom Validation Error Messages ([#21](https://github.com/domainic/domainic/issues/21))

* Allow custom error messages for validation handlers
* Aggregate and display all validation failures together
* Raise single ArgumentError with all collected error messages
* Breaking Change: Error message format will change

### 2. Immutable Attributes ([#32](https://github.com/domainic/domainic/issues/32))

* Add DSL method/option to declare attributes as immutable
* Allow setting immutable attribute values only during initialization
* Raise clear error on attempts to change immutable attributes
* Support immutable attributes with all existing features
* Provide comprehensive documentation and test coverage

### 3. Feature Toggles ([#68](https://github.com/domainic/domainic/issues/68))

* Allow disabling initialization management and/or post-initialization validation
* Support global and per-class configuration for feature toggles
* Breaking Change: Behavior will change when features are disabled
* Provide clear documentation of behavior changes with feature toggles
* Add comprehensive test coverage for all toggle combinations

### 4. Default Attribute Configurations ([#69](https://github.com/domainic/domainic/issues/69))

* Support global and class-level default attribute settings
* Allow defaults for any attribute feature (nilable, visibility, coercion, etc)
* Implement clear precedence rules (explicit > class > global)
* Support complex default options (coercers, validators, callbacks)
* Provide detailed documentation and test coverage

### 5. Improved Error Backtraces ([#82](https://github.com/domainic/domainic/issues/82))

* Manipulate error backtraces to originate from user code
* Support both initialization and assignment error backtraces
* Filter out internal Attributer frames from error backtraces
* Maintain original error message clarity
* Provide test coverage for various error scenarios

## Release Goals

* Enhance attribute customization options
* Improve error handling and reporting
* Introduce feature toggles for initialization/validation
* Support sophisticated default configurations
* Provide comprehensive documentation and test coverage

## Breaking Changes

1. Custom Validation Error Messages ([#21](https://github.com/domainic/domainic/issues/21))
  * Error message format will change to include all validation failures
  * Existing code relying on specific error message format may break
2. Feature Toggles ([#68](https://github.com/domainic/domainic/issues/68))
  * Disabling initialization management or post-initialization validation will change attribute behavior
  * Existing code assuming consistent attribute behavior may break

## Acceptance Criteria

* [ ] All confirmed changes are implemented
* [ ] Comprehensive test coverage for new features
* [ ] Clear, detailed documentation with examples and migration guide
* [ ] Performance remains unaffected
* [ ] Breaking changes are clearly communicated

## Release Preparation Workflow

1. Finalize code changes and test coverage (TODO: Add dates)
2. Prep documentation updates and migration guide (TODO: Add dates)
3. Release candidate testing and review (TODO: Add dates)
4. Final release (TODO: Add date)

## Risks & Mitigations

* Risk: Breaking changes disrupt existing projects
  * Mitigation: Clear communication, detailed migration guide, long beta period
* Risk: New features introduce complexity and potential bugs
  * Mitigation: Thorough testing, detailed documentation, phased rollout
* Risk: Feature toggles change expected behavior
  * Mitigation: Clear documentation, developer communication

## Open Questions

* What is the target release date?
* Are there any additional breaking changes to consider?
* How will the breaking changes and migration path be communicated to the developer community?
