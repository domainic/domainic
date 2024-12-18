# Domainic::Attributer Usage Guide

A comprehensive guide to all features and capabilities of Domainic::Attributer.

## Table of Contents

* [Core Concepts](#core-concepts)
   * [Arguments vs Options](#arguments-vs-options)
   * [Attribute Lifecycle](#attribute-lifecycle)
      * [Initialization Phase](#initialization-phase)
      * [Runtime Changes](#runtime-changes)
   * [Error Types](#error-types)
      * [CoercionExecutionError](#coercionexecutionerror)
      * [ValidationExecutionError](#validationexecutionerror)
      * [CallbackExecutionError](#callbackexecutionerror)
      * [ArgumentError](#argumenterror)
* [Features](#features)
   * [Type Validation](#type-validation)
   * [Value Coercion](#value-coercion)
   * [Nilability Control](#nilability-control)
   * [Change Tracking](#change-tracking)
   * [Visibility Control](#visibility-control)
   * [Default Values](#default-values)
   * [Documentation](#documentation)
   * [Custom Method Names](#custom-method-names)
* [Best Practices](#best-practices)
   * [Validation vs Coercion](#validation-vs-coercion)
   * [Managing Complex Attributes](#managing-complex-attributes)
   * [Error Handling Strategies](#error-handling-strategies)
* [Advanced Topics](#advanced-topics)
   * [Attribute Inheritance](#attribute-inheritance)
   * [Custom Validators](#custom-validators)

## Core Concepts

### Arguments vs Options

Domainic::Attributer provides two ways to define attributes:

* `argument`: Required positional parameters that must be provided in order
* `option`: Named parameters that can be provided in any order (optional by default)

```ruby
class Spaceship
  include Domainic::Attributer

  argument :captain    # Required, must be first
  argument :warp_core  # Required, must be second
  option :shields      # Optional, provided by name
  option :phasers      # Optional, provided by name
end

# Valid ways to create a spaceship:
Spaceship.new('Kirk', 'Dilithium', shields: true)
Spaceship.new('Picard', 'Matter/Antimatter', phasers: 'Charged')
```

### Attribute Lifecycle

Domainic::Attributer manages attributes throughout their entire lifecycle. All constraints (type validation, coercion,
nullability checks, etc.) are enforced both during initialization and whenever attributes are modified.

#### Initialization Phase

When creating a new object, attributes are processed in this order:

1. Arguments are processed in their defined order
2. Options are processed in any order
3. For each attribute:

* Default value is generated if no value provided
* Value is coerced to the correct format
* Value is validated
* Change callbacks are triggered

```ruby
class Jedi
  include Domainic::Attributer

  argument :name, String
  option :midi_chlorians, Integer do
    default 3000
    validate_with ->(val) { val.positive? }
  end
end

# During initialization:
jedi = Jedi.new(123)        # Raises ArgumentError (name must be String)
jedi = Jedi.new('Yoda', midi_chlorians: -1)  # Raises ArgumentError (must be positive)
jedi = Jedi.new('Yoda')     # Works! midi_chlorians defaults to 3000
```

#### Runtime Changes

The same validations and coercions apply when modifying attributes after initialization:

```ruby
jedi = Jedi.new('Yoda')
jedi.name = 456             # Raises ArgumentError (must be String)
jedi.midi_chlorians = -1    # Raises ArgumentError (must be positive)
jedi.midi_chlorians = '4000' # Coerced to Integer automatically
```

### Error Types

Domainic::Attributer uses specialized error classes to provide clear feedback when something goes wrong during attribute
processing.

#### Validation Failures

When a value fails validation (returns false or nil), an `ArgumentError` is raised:

```ruby
class Spaceship
  include Domainic::Attributer

  argument :name, String
  argument :crew_count, Integer do
    validate_with ->(val) { val.positive? }
  end
end

ship = Spaceship.new(123, 5)        # Raises ArgumentError: invalid value for String
ship = Spaceship.new("Enterprise", -1)  # Raises ArgumentError: has invalid value: -1
```

#### Internal Error Handling

The following errors are raised by Domainic::Attributer when internal processing fails:

* `ValidationExecutionError` - Raised when a validation handler itself raises an error
* `CoercionExecutionError` - Raised when a coercion handler raises an error
* `CallbackExecutionError` - Raised when a change callback raises an error

These errors can be rescued for debugging or error handling:

```ruby
class TimeMachine
  include Domainic::Attributer

  option :year, Integer do
    on_change ->(old_val, new_val) {
      calculate_temporal_coordinates
    }
  end

  private

  def calculate_temporal_coordinates
    # Complex calculation that might fail
    raise "Flux capacitor malfunction!"
  end
end

machine = TimeMachine.new
begin
  machine.year = 1985
rescue Domainic::Attributer::CallbackExecutionError => e
  puts "Time travel failed: #{e.message}"
end
```

## Features

### Type Validation

Type validation ensures attributes contain the correct type of data.

<details>
<summary>Available Methods</summary>

#### Option Hash Style

* `validate: handler` - Add a validation handler
* `validate_with: handler` - Alias for validate
* `validators: [handler1, handler2]` - Add multiple handlers

#### Block Style

* `validate_with(handler)` - Add a validation handler
* `validate(handler)` - Alias for validate_with
* `validates(handler)` - Alias for validate_with

</details>

```ruby
class Pokemon
  include Domainic::Attributer

  # Simple type validation
  argument :name, String
  argument :level, Integer

  # Custom validation logic
  option :moves do
    validate_with ->(val) { val.is_a?(Array) && val.size <= 4 }
  end

  # Combining multiple validations
  option :evolution do
    validate_with PokemonSpecies # Custom type check
    validate_with ->(val) {
      return true if val.nil?  # Allow nil values
      val.level > level        # Must be higher level
    }
  end
end

pikachu = Pokemon.new("Pikachu", 5)
pikachu.moves = ["Thunderbolt", "Quick Attack", "Tail Whip", "Thunder Wave"]  # Works!
pikachu.moves = ["Thunderbolt", "Quick Attack", "Tail Whip", "Thunder Wave", "Tackle"]  # Raises ArgumentError
```

### Value Coercion

Transform input values into the correct format automatically.

<details>
<summary>Available Methods</summary>

#### Option Hash Style

* `coerce: handler` - Add a coercion handler
* `coerce_with: handler` - Alias for coerce
* `coercers: [handler1, handler2]` - Add multiple handlers

#### Block Style

* `coerce_with(handler)` - Add a coercion handler
* `coerce(handler)` - Alias for coerce_with

Handlers can be:

* Procs/lambdas accepting one argument
* Symbols referencing instance methods

</details>

```ruby
class Superhero
   include Domainic::Attributer

   # For non-nilable attributes, you don't need to handle nil
   argument :code_name do
      non_nilable
      coerce_with ->(val) { val.to_s.upcase }
   end

   # For nilable attributes, your coercer must handle nil
   option :secret_identity do
      coerce_with ->(val) { val.nil? ? nil : val.to_s.capitalize }
   end

   # Multiple coercions are applied in order
   option :power_level do
      coerce_with ->(val) { val.to_s }         # First convert to string
      coerce_with ->(val) { val.gsub(/\D/, '') }  # Remove non-digits
      coerce_with ->(val) { val.to_i }         # Convert to integer
   end
end

hero = Superhero.new("spiderman")
hero.code_name  # => "SPIDERMAN"
hero.secret_identity = :parker  # => "Parker"
hero.secret_identity = nil      # => nil
hero.power_level = "over 9000!" # => 9000
```

### Nilability Control

Manage how attributes handle nil values.

<details>
<summary>Available Methods</summary>

#### Option Hash Style

* `non_nilable: true` - Prevent nil values
* `non_nil: true` - Alias for non_nilable
* `non_null: true` - Alias for non_nilable
* `non_nullable: true` - Alias for non_nilable
* `not_nil: true` - Alias for non_nilable
* `not_nilable: true` - Alias for non_nilable
* `not_null: true` - Alias for non_nilable
* `not_nullable: true` - Alias for non_nilable
* `null: false` - Another way to prevent nil

#### Block Style

* `non_nilable` - Prevent nil values
* `non_nil` - Alias for non_nilable
* `non_null` - Alias for non_nilable
* `non_nullable` - Alias for non_nilable
* `not_nil` - Alias for non_nilable
* `not_nilable` - Alias for non_nilable
* `not_null` - Alias for non_nilable
* `not_nullable` - Alias for non_nilable

</details>

```ruby
class Ninja
  include Domainic::Attributer

  # Using block style
  argument :code_name do
    non_nilable  # Must always have a code name
  end

  # Using option hash style
  argument :rank, non_null: true  # Must always have a rank

  # Optional but can't be nil if provided
  option :special_technique, not_nilable: true

  # Optional and allows nil
  option :current_mission
end

ninja = Ninja.new(nil, 'Genin')          # Raises ArgumentError
ninja = Ninja.new('Shadow', nil)          # Raises ArgumentError
ninja = Ninja.new('Shadow', 'Genin', special_technique: nil)  # Raises ArgumentError
ninja = Ninja.new('Shadow', 'Genin', current_mission: nil)    # Works!
```

### Change Tracking

Monitor and react to attribute value changes.

<details>
<summary>Available Methods</summary>

#### Option Hash Style

* `on_change: handler` - Add a change handler
* `callback: handler` - Alias for on_change
* `callbacks: [handler1, handler2]` - Add multiple handlers

#### Block Style

* `on_change(handler)` - Add a change handler

Handlers must be Procs/lambdas accepting two arguments (old_value, new_value)
</details>

```ruby
class VideoGame
  include Domainic::Attributer

  argument :title

  option :health do
    default 100
    validate_with ->(val) { val.between?(0, 100) }

    on_change ->(old_val, new_val) {
      game_over! if new_val <= 0
      heal_effect! if new_val > old_val
      damage_effect! if new_val < old_val
    }
  end

  option :power_ups, Array, default: [] do
    on_change ->(old_val, new_val) {
      new_items = new_val - old_val
      lost_items = old_val - new_val

      new_items.each { |item| activate_power_up(item) }
      lost_items.each { |item| deactivate_power_up(item) }
    }
  end

  private

  def game_over!; end
  def heal_effect!; end
  def damage_effect!; end
  def activate_power_up(item); end
  def deactivate_power_up(item); end
end

game = VideoGame.new('Super Ruby World')
game.health = 0      # Triggers game_over!
game.health = 50     # Triggers damage_effect!
game.power_ups = ['Star']  # Activates the star power-up
```

### Visibility Control

Control attribute access levels.

<details>
<summary>Available Methods</summary>

#### Option Hash Style

* `read: :private/:protected/:public` - Set read visibility
* `read_access: :private/:protected/:public` - Alias for read
* `reader: :private/:protected/:public` - Alias for read
* `write_access: :private/:protected/:public` - Set write visibility
* `writer: :private/:protected/:public` - Alias for write_access

#### Block Style

* `private` - Make both read and write private
* `private_read` - Make only read private
* `private_write` - Make only write private
* `protected` - Make both read and write protected
* `protected_read` - Make only read protected
* `protected_write` - Make only write protected
* `public` - Make both read and write public
* `public_read` - Make only read public
* `public_write` - Make only write public

</details>

```ruby
class SecretAgent
  include Domainic::Attributer

  # Public interface
  argument :code_name

  # Private data
  option :real_name do
    private  # Both read and write are private
  end

  # Mixed visibility
  option :current_mission do
    protected_read   # Other agents can read
    private_write    # Only self can update
  end

  # Hash style visibility
  option :gadget_count,
    read: :public,      # Anyone can read
    write: :protected   # Only agents can update
end

agent = SecretAgent.new('007')
agent.code_name       # => "007"
agent.real_name       # NoMethodError
agent.gadget_count = 5  # NoMethodError (unless called from another agent)
```

### Default Values

Provide static defaults or generate them dynamically.

<details>
<summary>Available Methods</summary>

#### Option Hash Style

* `default: value` - Set a static default
* `default_generator: proc` - Set a dynamic default
* `default_value: value` - Alias for default

#### Block Style

* `default(value)` - Set static default
* `default { block }` - Set dynamic default
* `default_generator(value)` - Alias for default
* `default_value(value)` - Alias for default

</details>

```ruby
class RPGCharacter
  include Domainic::Attributer

  argument :name

  # Static defaults
  option :level, Integer, default: 1
  option :health_max, default: 100

  # Dynamic defaults
  option :created_at do
    default { Time.now }
  end

  option :health_current do
    default { health_max }
  end

  # Complex default generation
  option :inventory do
    default {
      base_items = ['Health Potion', 'Map']
      base_items << 'Lucky Coin' if Random.rand < 0.1
      base_items
    }
  end
end

hero = RPGCharacter.new('Ruby Knight')
hero.level           # => 1
hero.health_current  # => 100
hero.inventory       # => ["Health Potion", "Map"] or ["Health Potion", "Map", "Lucky Coin"]
```

### Documentation

Add descriptions to your attributes for better code clarity.

<details>
<summary>Available Methods</summary>

#### Option Hash Style

* `desc: text` - Short description
* `description: text` - Full description (overrides desc)

#### Block Style

* `desc(text)` - Short description
* `description(text)` - Full description

</details>

```ruby
class MagicItem
  include Domainic::Attributer

  argument :name do
    description 'The name of the magic item, must be unique'
  end

  option :power_level do
    desc 'Magical energy from 0-100'
    validate_with ->(val) { val.between?(0, 100) }
  end

  option :enchantments,
    description: 'List of active enchantments on the item',
    default: []
end
```

### Custom Method Names

Create your own DSL by customizing method names or disabling features you don't need.

```ruby
# Custom method names
class GameConfig
  include Domainic.Attributer(
    argument: :required_setting,
    option: :optional_setting
  )

  required_setting :difficulty
  optional_setting :sound_enabled, default: true
end

# Disable features
class StrictConfig
  include Domainic.Attributer(
    option: nil  # Only allows arguments
  )

  argument :api_key
  argument :environment
  # option method is not available
end
```

## Best Practices

### Validation vs Coercion

Use validation when you want to ensure values meet specific criteria:

```ruby
class SpellBook
  include Domainic::Attributer

  # Bad: Using coercion for validation
  option :spell_count do
    coerce_with ->(val) {
      val = val.to_i
      raise ArgumentError unless val.positive?
      val
    }
  end

  # Good: Separate concerns
  option :spell_count do
    coerce_with ->(val) { val.to_i }
    validate_with ->(val) { val.positive? }
  end
end
```

### Managing Complex Attributes

For attributes with multiple validations or transformations, use the block syntax for better readability:

```ruby
class BattleMech
  include Domainic::Attributer

  # Hard to read
  option :weapon_system,
    description: 'Primary weapon configuration',
    non_nilable: true,
    validate_with: [
      WeaponSystem,
      ->(val) { val.power_draw <= max_power },
      ->(val) { val.weight <= max_weight }
    ],
    on_change: ->(old_val, new_val) { recalculate_power_grid }

  # Better organization
  option :weapon_system do
    description 'Primary weapon configuration'
    non_nilable

    validate_with WeaponSystem
    validate_with ->(val) { val.power_draw <= max_power }
    validate_with ->(val) { val.weight <= max_weight }

    on_change ->(old_val, new_val) {
      recalculate_power_grid
    }
  end
end
```

## Advanced Topics

### Attribute Inheritance

Attributes are inherited from parent classes, and subsequent definitions in child classes add to rather than replace
the parent's configuration:

```ruby
class Superhero
  include Domainic::Attributer

  argument :name, String
  argument :powers do
    validate_with Array
    validate_with ->(val) { val.any? }  # Must have at least one power
  end
end

class XMen < Superhero
  # Adds additional validation to the inherited :powers attribute
  argument :powers do
    validate_with ->(val) { val.all? { |p| p.is_a?(String) } }  # Powers must be strings
  end

  # Adds a new attribute specific to X-Men
  option :mutant_name
end

# Now :powers must be:
# 1. An Array (from parent)
# 2. Non-empty (from parent)
# 3. Contain only strings (from child)

wolverine = XMen.new(
  "Logan",
  ["Healing", "Adamantium Claws"],  # Works - array of strings
  mutant_name: "Wolverine"
)

# Fails - powers must be strings
cyclops = XMen.new("Scott", [:optic_blast])  

# Fails - powers can't be empty
jubilee = XMen.new("Jubilation", [])
```

### Custom Validators

Create reusable validators for common patterns:

```ruby
module GameValidators
  HealthPoints = ->(val) { val.between?(0, 100) }

  Username = ->(val) {
    val.match?(/\A[a-z0-9_]{3,16}\z/i)
  }

  class DamageRange
    def self.===(value)
      value.is_a?(Range) &&
        value.begin.is_a?(Integer) &&
        value.end.is_a?(Integer) &&
        value.begin.positive? &&
        value.begin < value.end
    end
  end
end

class Player
  include Domainic::Attributer

  argument :username do
    coerce_with ->(val) { val.to_s.downcase }
    validate_with GameValidators::Username
  end

  option :hp do
    default 100
    validate_with GameValidators::HealthPoints
  end

  option :damage_range do
    default 1..10
    validate_with GameValidators::DamageRange
  end
end
```

This completes our comprehensive guide to Domainic::Attributer. Remember that the key to effective use is finding the
right balance of validation, coercion, and error handling for your specific needs.
