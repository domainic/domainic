# Experimental Changes

## Domainic::Type

### [Unreleased]

#### Added

* [#158](https://github.com/domainic/domainic/pull/158) added `README.md` and `docs/USAGE.md`

### [0.1.0-alpha.3.2.0] - 2024-12-26

#### Added

* [#155](https://github.com/domainic/domainic/pull/155) added `Domainic::Type::DateType`, `Domainic::Type::DateTimeType`,
  and `Domainic::Type::TimeType`

#### Fixed

* [#153](https://github.com/domainic/domainic/pull/153) renamed `Domainic::Type::Behavior._Uri` to
  `Domainic::Type::Behavior._URI` to follow standard naming conventions.
* [#156](https://github.com/domainic/domainic/pull/156) fixed Instance, Identifier and Network types now properly fail
  fast when not given the appropriate type.

### [0.1.0-alpha.3.1.0] - 2024-12-26

#### Added

* [#148](https://github.com/domainic/domainic/pull/148) added `Domainic::Type::Behavior.intrinsically_constrain` to
  replace `Domainic::Type::Behavior.intrinsic`.
* [#149](https://github.com/domainic/domainic/pull/149) added `Domainic::Type::EmailAddressType`,
  `Domainic::Type::HostnameType`, and `Domainic::Type::URIType`.
* [#150](https://github.com/domainic/domainic/pull/150) add `Domainic::Type::CUIDType` and `Domainic::Type::UUIDType`.

#### Deprecated

* [#148](https://github.com/domainic/domainic/pull/148) deprecated `Domainic::Type::Behavior.intrinsic` use
  `Domainic::Type::Behavior.intrinsically_constrain` instead.

### [0.1.0-alpha.3.0.2] - 2024-12-25

#### Added

* [#146](https://github.com/domainic/domainic/pull/146) added `Domainic::Type::InstanceType` for type checking
  instances.

### [0.1.0-alpha.3.0.1] - 2024-12-23

#### Fixed

* [#138](https://github.com/domainic/domainic/issues/138) fixed error messages now only show failed constraints.

### 0.1.0-alpha.3.0.0 - 2024-12-23

* Initial alpha release

[Previous alpha versions were internal testing only]

> [!NOTE]
> As this is an experimental release, features may change significantly based on feedback. Refer to
> docs/experiments/domainic-type-v0.1.0-alpha.3/README.md for full details and current testing focus.

[Unreleased]: https://github.com/domainic/domainic/compare/domainic-type-v0.1.0-alpha.3.2.0...HEAD
[0.1.0-alpha.3.2.0]: https://github.com/domainic/domainic/compare/domainic-type-v0.1.0-alpha.3.1.0...domainic-type-v0.1.0-alpha.3.2.0
[0.1.0-alpha.3.1.0]: https://github.com/domainic/domainic/compare/domainic-type-v0.1.0-alpha.3.0.2...domainic-type-v0.1.0-alpha.3.1.0
[0.1.0-alpha.3.0.2]: https://github.com/domainic/domainic/compare/domainic-type-v0.1.0-alpha.3.0.1...domainic-type-v0.1.0-alpha.3.0.2
[0.1.0-alpha.3.0.1]: https://github.com/domainic/domainic/compare/domainic-type-v0.1.0-alpha.3.0.0...domainic-type-v0.1.0-alpha.3.0.1

[![Back: Known Issues](https://img.shields.io/badge/%3C%3C%20Known%20Issues-blue?style=for-the-badge)](KNOWN_ISSUES.md)

|                               |                         |                                       |                                 |
|-------------------------------|-------------------------|---------------------------------------|---------------------------------|
| [Experiment Home](README.md)  | [Examples](EXAMPLES.md) | [Troubleshooting](TROUBLESHOOTING.md) | [Known Issues](KNOWN_ISSUES.md) |
