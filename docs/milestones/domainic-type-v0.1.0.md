# domainic-type v0.1.0

![Milestone Status](https://img.shields.io/badge/In%20Progress-orange?style=for-the-badge&label=Status)
[![Milestone Progress](https://img.shields.io/github/milestones/progress-percent/domainic/domainic/5?style=for-the-badge&label=Progress)](https://github.com/domainic/domainic/milestone/5)

![Milestone Start Date](https://img.shields.io/badge/12%2F16%2F2024-blue?style=for-the-badge&label=Start%20Date)
![Milestone Due Date](https://img.shields.io/badge/02%2F01%2F2025-blue?style=for-the-badge&label=Due%20Date)

[![Milestone Open Tasks](https://img.shields.io/github/issues-search/domainic/domainic?query=is%3Aopen%20milestone%3A%22domainic-type%20v0.1.0%22&style=for-the-badge&label=Open%20Tasks&color=red)](https://github.com/domainic/domainic/issues?q=is%3Aopen%20milestone%3A%22domainic-type%20v0.1.0%22)
[![Milestone Closed Tasks](https://img.shields.io/github/issues-search/domainic/domainic?query=is%3Aclosed%20milestone%3A%22domainic-type%20v0.1.0%22&style=for-the-badge&label=Closed%20Tasks&color=green)](https://github.com/domainic/domainic/issues?q=is%3Aclosed%20milestone%3A%22domainic-type%20v0.1.0%22)
[![Milestone Total Tasks](https://img.shields.io/github/issues-search/domainic/domainic?query=milestone%3A%22domainic-type%20v0.1.0%22&style=for-the-badge&label=Total%20Tasks&color=blue)](https://github.com/domainic/domainic/issues?q=milestone%3A%22domainic-type%20v0.1.0%22)

## Problem Statement

Ruby lacks a robust, expressive type system that can capture complex domain constraints. While several type checking
solutions exist, they often focus on basic type validation or static analysis. Developers need a more sophisticated
runtime type system that can:

* Express complex structural and behavioral constraints
* Provide rich, composable type definitions
* Support domain-specific type requirements
* Maintain Ruby's expressiveness and flexibility
* Enable precise runtime type checking

Current solutions force developers to:

* Write verbose, repetitive validation code
* Mix validation logic with domain logic
* Create custom type checking systems
* Sacrifice expressiveness for type safety

## Context

We need to create a standalone type system that brings sophisticated type constraints to Ruby while maintaining its
elegant, expressive nature. The system should serve as a foundational tool that can be used:

1. **Independently**
  * Standalone type validation
  * Complex data structure validation
  * API contract enforcement
  * Domain model constraints
2. **As Part of Larger Systems**
  * Integration with ORMs
  * Validation frameworks
  * Domain-driven design tools
  * API frameworks

3. **In Various Contexts**
  * Web applications
  * Data processing systems
  * Domain modeling
  * Service interfaces

## Research & Discovery

### Type System Access

Two main approaches were evaluated:

1. **Global Prefix Module**:

   ```ruby
   Domainic::Type.configure do |config|
     config.enable_global_prefix(:T)
   end

   T.Array      # => Domainic::Type::ArrayType
   T::Array     # => Domainic::Type::ArrayType
   T.Array?     # => Union(Domainic::Type::ArrayType, nil)
   ```

2. **Module Installation**:

   ```ruby
   module MyTypes
     include Domainic::Type::Definitions
   end

   MyTypes.Array      # => Domainic::Type::ArrayType
   ```

### Type Constraint Expression

Explored fluent interfaces for complex constraints:

```ruby
Array.of(String)
  .having_minimum_count(2)
  .having_maximum_count(5)
  .beginning_with("foo")
  .ending_with("bar")
  .containing("baz")
```

### Error Message Composition

Evaluated multiple approaches and settled on structured formatting:

```ruby
Expected an Array, got an Array:
  * Expected all elements must be: a String, but got [Integer at index 0]
  * Expected not: being empty
```

## Decision

### 1. Architecture

1. **Core Components**:
  * Base type behavior module
  * Constraint system
  * Error message builder
  * Type registry
2. **Design Philosophy**:
  * Expressiveness over verbosity
  * Performance through lazy evaluation
  * Minimal memory overhead
  * Developer productivity focus

### 2. Type System Features

1. **Type Access**:
  * Support both global prefix and module installation
  * Use underscore prefix for conflict resolution
  * Support both dot and double colon notation
2. **Error Messages**:
  * Structured, hierarchical format
  * Clear type and constraint violations
  * Support for nested constraints
  * Actionable error messages
3. **Core Types** (v0.1.0):
  * Anything/Any
  * Array/List
  * Boolean/Bool
  * Duck/Interface/RespondsTo
  * Enum/Literal
  * Float/Decimal
  * Hash/Dictionary/Map
  * Integer/Int/Number
  * String/Text
  * Symbol
  * Union/Either
  * Void
4. **Constraint System**:
  * Base constraint behavior
  * Composable constraints
  * Extension points
  * Type-safe implementation

### 3. Technical Requirements

1. **Performance**:
  * Lazy constraint evaluation
  * Minimal object allocation
  * Efficient constraint chaining
2. **Safety**:
  * Thread-safe operations
  * Type-safe implementations
  * Clear validation boundaries
3. **Integration**:
  * Simple integration interface
  * Extensible constraint system
  * Custom type support

## Consequences

### Positive

1. Expressive type definitions
2. Clear validation messages
3. Flexible deployment options
4. Strong integration capabilities
5. Performance through lazy evaluation
6. Clean extension points
7. Standalone usability
8. Framework independence

### Negative

1. Initial implementation complexity
2. Learning curve for constraint authors
3. Potential memory overhead with complex chains
4. Need to handle Ruby core conflicts

### Neutral

1. Similar to existing type systems
2. Documentation overhead
3. Regular maintenance needs

## Implementation Plan

### Phase 1: Foundation (v0.1.0)

1. Core Infrastructure
  * Base type behavior
  * Constraint system
  * Error handling
  * Type registry
2. Basic Types
  * Simple types (Integer, String)
  * Basic constraints
  * Initial test suite

### Phase 2: Enhancement (v0.2.0)

1. Advanced Features
  * Complex types
  * Nested constraints
  * Custom validators
2. Documentation & Examples
  * Standalone usage
  * Integration patterns
  * Extension guides

### Phase 3: Optimization (v0.3.0)

1. Performance
  * Constraint caching
  * Memory optimization
  * Validation shortcuts
2. Extensions
  * Community types
  * Custom constraints
  * Additional validators

## Open Questions

1. Version-specific Ruby feature handling
2. Core class conflict resolution strategy
3. Type inference support scope
4. Runtime optimization approaches
5. Custom constraint verification
6. Framework integration patterns
