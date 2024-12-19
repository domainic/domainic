# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog], and this project adheres to [Break Versioning].

## [Unreleased]

### Added

* [#22](https://github.com/domainic/domainic/pull/22) Specialized error classes (`ValidationExecutionError`,
  `CallbackExecutionError`, and`CoercionExecutionError`) to provide clear error reporting for validation, callback,
  and coercion failures.

### Changed

* [#18](https://github.com/domainic/domainic/pull/18) `Domainic::Attributer::Attribute::Coercer#call` will no longer
  attempt to coerce nil values when the attribute is not nilable. While small this is technically a breaking change.

### Fixed

* [#18](https://github.com/domainic/domainic/pull/18) Added missing requires for `Domainic::Attributer::Undefined` in
  the `Domainic::Attributer::Attribute` and `Domainic::Attributer::Attribute::Validator` classes.
* Various documentation improvements and corrections.

## [v0.1.0] - 2024-12-12

* Initial release

[Keep a Changelog]: https://keepachangelog.com/en/1.0.0/
[Break Versioning]: https://www.taoensso.com/break-versioning

<!-- versions -->

[Unreleased]: https://github.com/domainic/domainic/compare/domainic-attributer-v0.1.0...HEAD
[v0.1.0]: https://github.com/domainic/domainic/compare/53f3e992ab0e3f0092fd842c4cf89c22e41afa8a...domainic-attributer-v0.1.0
