# Experimental Changes

## Domainic::Type

### [Unreleased]

### [v0.1.0-alpha.3.4.1] - 2024-12-31

#### Deprecated

* [#186](https://github.com/domainic/domainic/pull/186) deprecated description methods in
  `Domainic::Type::Constraint::Behavior` and `Domainic::Type::Constraint::Set` as we will be moving description logic
  out of constraints in the alpha 4 release. Use `RUBYOPT="-W0"` to suppress warnings.

### [v0.1.0-alpha.3.4.0] - 2024-12-30

#### Added

* [#165](https://github.com/domainic/domainic/pull/165) added `Domainic::Type::Constraint::PredicateConstraint` and
  `Domainic::Type::Behavior#satisfies` to allow for custom constraints.

#### Fixed

* [#164](https://github.com/domainic/domainic/pull/164) fixed `Domainic::Type::Constraint::NorConstraint` now prefixes
  "not" to it's short description when only one constraint is given.
* [#179](https://github.com/domainic/domainic/pull/179) fixed date parsing ambiguity in DateTimeBehavior

### [v0.1.0-alpha.3.3.0] - 2024-12-27

#### Added

* [#158](https://github.com/domainic/domainic/pull/158) added `README.md` and `docs/USAGE.md`
* [#159](https://github.com/domainic/domainic/pull/159) added `Domainic::Type::DateTimeStringType`
* [#160](https://github.com/domainic/domainic/pull/160) added `Domainic::Type::TimestampType`
* [#161](https://github.com/domainic/domainic/pull/161) added `Domainic::Type::BigDecimalType`,
  `Domainic::Type::ComplexType`, `Domainic::Type::RangeType`, `Domainic::Type::RationalType`, and
  `Domainic::Type::SetType`

#### Changed

* [#159](https://github.com/domainic/domainic/pull/159) `Domainic::Type::Behavior::DateTimeBehavior` can now handle
  Strings with various date and time formats.
* [#160](https://github.com/domainic/domainic/pull/160) `Domainic::Type::Behavior::DateTimeBehavior` now handles
  timestamps as integers.

### [v0.1.0-alpha.3.2.0] - 2024-12-26

#### Added

* [#155](https://github.com/domainic/domainic/pull/155) added `Domainic::Type::DateType`, `Domainic::Type::DateTimeType`,
  and `Domainic::Type::TimeType`

#### Fixed

* [#153](https://github.com/domainic/domainic/pull/153) renamed `Domainic::Type::Behavior._Uri` to
  `Domainic::Type::Behavior._URI` to follow standard naming conventions.
* [#156](https://github.com/domainic/domainic/pull/156) fixed Instance, Identifier and Network types now properly fail
  fast when not given the appropriate type.

### [v0.1.0-alpha.3.1.0] - 2024-12-26

#### Added

* [#148](https://github.com/domainic/domainic/pull/148) added `Domainic::Type::Behavior.intrinsically_constrain` to
  replace `Domainic::Type::Behavior.intrinsic`.
* [#149](https://github.com/domainic/domainic/pull/149) added `Domainic::Type::EmailAddressType`,
  `Domainic::Type::HostnameType`, and `Domainic::Type::URIType`.
* [#150](https://github.com/domainic/domainic/pull/150) add `Domainic::Type::CUIDType` and `Domainic::Type::UUIDType`.

#### Deprecated

* [#148](https://github.com/domainic/domainic/pull/148) deprecated `Domainic::Type::Behavior.intrinsic` use
  `Domainic::Type::Behavior.intrinsically_constrain` instead.

### [v0.1.0-alpha.3.0.2] - 2024-12-25

#### Added

* [#146](https://github.com/domainic/domainic/pull/146) added `Domainic::Type::InstanceType` for type checking
  instances.

### [v0.1.0-alpha.3.0.1] - 2024-12-23

#### Fixed

* [#138](https://github.com/domainic/domainic/issues/138) fixed error messages now only show failed constraints.

### v0.1.0-alpha.3.0.0 - 2024-12-23

* Initial alpha release

[Previous alpha versions were internal testing only]

> [!NOTE]
> As this is an experimental release, features may change significantly based on feedback. Refer to
> [Domainic::Type v0.1.0 Alpha](README.md) for full details and current testing focus.

[Unreleased]: https://github.com/domainic/domainic/compare/domainic-type-v0.1.0-alpha.3.4.1...HEAD
[v0.1.0-alpha.3.4.1]: https://github.com/domainic/domainic/compare/domainic-type-v0.1.0-alpha.3.4.0...domainic-type-v0.1.0-alpha.3.4.1
[v0.1.0-alpha.3.4.0]: https://github.com/domainic/domainic/compare/domainic-type-v0.1.0-alpha.3.3.0...domainic-type-v0.1.0-alpha.3.4.0
[v0.1.0-alpha.3.3.0]: https://github.com/domainic/domainic/compare/domainic-type-v0.1.0-alpha.3.2.0...domainic-type-v0.1.0-alpha.3.3.0
[v0.1.0-alpha.3.2.0]: https://github.com/domainic/domainic/compare/domainic-type-v0.1.0-alpha.3.1.0...domainic-type-v0.1.0-alpha.3.2.0
[v0.1.0-alpha.3.1.0]: https://github.com/domainic/domainic/compare/domainic-type-v0.1.0-alpha.3.0.2...domainic-type-v0.1.0-alpha.3.1.0
[v0.1.0-alpha.3.0.2]: https://github.com/domainic/domainic/compare/domainic-type-v0.1.0-alpha.3.0.1...domainic-type-v0.1.0-alpha.3.0.2
[v0.1.0-alpha.3.0.1]: https://github.com/domainic/domainic/compare/domainic-type-v0.1.0-alpha.3.0.0...domainic-type-v0.1.0-alpha.3.0.1

[![Back: Known Issues](https://img.shields.io/badge/%3C%3C%20Known%20Issues-blue?style=for-the-badge)](KNOWN_ISSUES.md)

|                               |                         |                                       |                                 |
|-------------------------------|-------------------------|---------------------------------------|---------------------------------|
| [Experiment Home](README.md)  | [Examples](EXAMPLES.md) | [Troubleshooting](TROUBLESHOOTING.md) | [Known Issues](KNOWN_ISSUES.md) |
