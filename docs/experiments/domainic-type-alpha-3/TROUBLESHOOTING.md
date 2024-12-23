# Troubleshooting

This guide covers common issues you might encounter while experimenting with Domainic::Type.

## Common Gotchas

### Type vs Constraint Errors

If you're seeing unexpected errors, check if you're dealing with a type failure or a constraint failure:

```ruby
# Type failure - value isn't even the right type
_String.validate!(123)  
# => TypeError: Expected String, but got Integer

# Constraint failure - right type but fails constraints
_String.being_uppercase.validate!("hello")
# => TypeError: Expected String(being upper case), but got String(not upper case)
```

### Constraint Overrides

Some constraints are mutually exclusive and will override each other based on order. The last called constraint wins:

```ruby
# The being_duplicative constraint will override being_distinct
_Array
  .being_distinct        # This constraint is ignored
  .being_duplicative    # This is the active constraint
  .validate!([1, 1, 2]) # => true

# The being_distinct constraint will override being_duplicative
_Array
  .being_duplicative    # This constraint is ignored
  .being_distinct      # This is the active constraint
  .validate!([1, 1, 2]) # => TypeError
```

Other examples of mutually exclusive constraints:

* `being_empty` vs `being_populated`
* `being_ordered` vs `being_unordered`
* `being_positive` vs `being_negative`
* `being_even` vs `being_odd`

### Nil Handling

By default, most types reject nil values. Use _Nilable if you want to allow nil:

```ruby
# Will reject nil:
_String.validate!(nil)  # => TypeError

# Will allow nil:
_Nilable(_String).validate!(nil)  # => true

# Will allow nil:
_String?.validate!(nil) # => true
```

### Union Type Gotchas

When using _Union types, remember that constraints apply to all possible types:

```ruby
# This might not work as expected:
_Union(_String, _Integer)
  .being_uppercase  # Can't apply string constraint to integer!
  .validate!(123)

# Instead, constrain the specific types:
_Union(
  _String.being_uppercase,
  _Integer
).validate!(123)  # Works!
```

### Hash Key/Value Types

When setting types for hash keys and values, the syntax can be tricky:

```ruby
# This works:
_Hash.of(Symbol => String)

# This also works and gives you more control:
_Hash.of(_Symbol => _String.being_uppercase)

# This won't work:
_Hash.of(symbol: string)  # Don't use Ruby hash syntax!
```

## Debugging Tips

### Inspect Type Definitions

You can print any type to see its constraints:

```ruby
type = _String.being_uppercase.having_minimum_size(5)
puts type  # Shows full type definition with constraints
```

### Step-by-Step Validation

Break down complex type validations into steps:

```ruby
complex_type = _Hash
  .of(_Symbol => _Array.of(_String.being_uppercase))
  .having_minimum_size(1)

# Test the inner type first
string_type = _String.being_uppercase
string_type.validate!("TEST")  # Does this work?

# Then the array type
array_type = _Array.of(string_type)
array_type.validate!(["TEST"])  # Does this work?

# Finally the full hash
complex_type.validate!({ key: ["TEST"] })  # Now where does it fail?
```

### Common Error Patterns

* If a type check fails immediately, you probably have a basic type mismatch
* If validation fails after type checking, look at your constraints
* If you're seeing method errors, check if you're using the right type for your constraints

## Still Stuck

Remember: This is an experiment! If something isn't working and you can't figure out why:

1. Open an issue! No need to figure it all out first.
2. Include your code example, what you expected, and what happened instead.
3. If you found a workaround, share that too - it helps us learn!

Every "stuck" moment is valuable feedback that helps us improve the library.
