# Domainic::Attributer

[![Domainic::Attributer Version](https://badge.fury.io/rb/domainic-attributer.svg)](https://rubygems.org/gems/domainic-attributer)

A toolkit for creating self-documenting, type-safe class attributes with built-in validation, coercion, and default
values.

Your domain objects deserve better than plain old attributes. Level up your DDD game with powerful, configurable, and
well-documented class attributes that actually know what they want in life!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'domainic-attributer'
```

Or install it yourself as:

```bash
gem install domainic-attributer
```

## Usage

Include Domainic::Attributer in your class to define attributes with built-in validation, coercion, and defaults.

```ruby
require 'domainic/attributer'

class Person
  include Domainic::Attributer

  option :name, String
  option :age, Integer
end

Person.new(name: 'Aaron', age: 39)
#=> #<Person:0x00007f9b1b0b3b10 @name="Aaron", @age=39>
```

### Callbacks

Define callbacks that execute when an attribute value changes using the on_change method.

```ruby
class Person
  include Domainic::Attributer

  option :name, String do
    on_change do |name|
      broadcast_name_change
    end
  end

  private

  def broadcast_name_change
    puts "Name changed to #{name}"
  end
end

person = Person.new(name: 'Aaron')
person.name = 'Josh'
"Name changed to Josh"
```

### Coercion

Specify attribute coercion using the coerce_with or coerce methods. Coercion occurs before validation whenever the
attribute value changes. Coercers can be a `Proc`, `Symbol`, or `true`.

- `Proc`: Called with the value to coerce within the context of the class.
- `Symbol`: Calls the method with the given name on the class with the value to coerce.
- `true`: Calls a method named `coerce_<attribute_name>` on the class with the value to coerce.

```ruby
class Person
  include Domainic::Attributer

  option :name, String do
    coerce_with lambda(&:strip)
    coerce_with :capitalize_name
    coerce true
  end

  private

  def coerce_name(name)
    "#{name}!"
  end

  def capitalize_name(name)
    name.capitalize
  end
end

Person.new(name: ' aaron ')
#=> #<Person:0x00007f9b1b0b3b10 @name="Aaron!">

person = Person.new(name: 'aaron')
#=> #<Person:0x00007f9b1b0b3b10 @name="Aaron!">

person.name = 'josh'
person
#=> #<Person:0x00007f9b1b0b3b10 @name="Josh!">
```

### Default Values

Set default values for attributes, which can be a static value or a `Proc`.

Static Value:

```ruby
class Person
  include Domainic::Attributer

  option :name, String do
    default 'Anonymous'
  end
end

Person.new
#=> #<Person:0x00007f9b1b0b3b10 @name="Anonymous">
```

Using a `Proc`:

```ruby
class Person
  include Domainic::Attributer

  option :first_name, String
  option :last_name, String
  option :full_name, String do
    default { "#{first_name} #{last_name}" }
  end
end

Person.new(first_name: 'Aaron', last_name: 'Allen')
#=> #<Person:0x00007f9b1b0b3b10 @first_name="Aaron", @last_name="Allen", @full_name="Aaron Allen">
```

### Attribute Descriptions

Provide additional context about an attribute using the desc method.

```ruby
class Person
  include Domainic::Attributer

  option :name, String do
    desc 'The name of the person'
  end
end
```

### Required Values

Mark attributes as required using required: true or the required method. Required attributes must be provided when
initializing the class.

```ruby
class Person
  include Domainic::Attributer

  option :name, String, required: true
end

Person.new
`Person#name` is required (ArgumentError)
```

### Validation

Define validation rules for attributes using validate_with or validates. Validators can be a Proc or any object
responding to `===`, like a `Class` or `Range`.

```ruby
class Person
  include Domainic::Attributer

  option :age do
    validates Integer
    validate_with ->(age) { age >= 18 }
    validates (18..100)
  end
end

Person.new(age: '21')
`Person#age` has an invalid value: "21" (ArgumentError)

Person.new(age: 17)
`Person#age` has an invalid value: 17 (ArgumentError)

Person.new(age: 101)
`Person#age` has an invalid value: 101 (ArgumentError)

person = Person.new(age: 39)
#=> #<Person:0x00007f9b1b0b3b10 @age=39>

person.age = 101
`Person#age` has an invalid value: 101 (ArgumentError)
```

### Attribute Access

Define attribute access levels using the reader and writer options. Valid options are `:public` or `:private`,
defaulting to `:public`.

```ruby
class Person
  include Domainic::Attributer

  option :first_name, String
  option :last_name, String
  option :full_name, String, writer: :private
end
```

### Combining Features

Combine features like coercion, validation, and default values to create robust attributes.

```ruby
class Person
  include Domainic::Attributer

  option :first_name, String do
    desc 'The first name of the Person'
    coerce_with lambda(&:strip)
    coerce_with lambda(&:capitalize)
    required
  end

  option :last_name, String do
    desc 'The last name of the Person'
    coerce_with lambda(&:strip)
    coerce_with lambda(&:capitalize)
  end

  option :full_name, String, writer: :private do
    desc 'The full name of the Person'
    default { [first_name, last_name].compact.join(' ') }
  end

  option :age, Integer do
    desc 'The age of the Person'
    coerce_with lambda(&:to_i)
    validates (18..100)
    required
  end
end
```

### Aliasing the `option` Method

Alias the option method to a more domain-specific name using `Domainic.Attributer`.

```ruby
class TypeValidator
  include Domainic.Attributer(:constraint)

  constraint :type, ->(v) { v.is_a?(Class) || v.is_a?(Module) } do
    desc 'The type to validate against'
    coerce_with ->(v) { v.nil? ? NilClass : v }
  end
end
```

### Inheritance

Attributes can be inherited and overridden in subclasses.

```ruby
class Animal
  include Domainic::Attributer

  option :species, String do
    coerce_with lambda(&:capitalize)
  end
  option :name, String
end

class Dog < Animal
  option :species, writer: :private do
    default 'dog'
  end
end

Dog.new(name: 'Fido')
#=> #<Dog:0x00007f9b1b0b3b10 @species="Dog", @name="Fido">
```

### Attribute Lifecycle

Understanding the lifecycle of an attribute helps you effectively use coercion, validation, and callbacks. When you set
an attribute’s value, the following steps occur in order:

1. Coercion: The value is first passed through any defined coercers. Coercion transforms the input into the desired
   format or type before validation.
2. Validation: After coercion, the value is validated against any defined validators. Validation ensures the value meets
   specified criteria or constraints.
3. Assignment: If the value passes validation, it is assigned to the attribute.
4. Callbacks: After assignment, any defined callbacks are invoked. Callbacks can trigger side effects or update
   dependent attributes.

#### Detailed Flow

- **Setting an Attribute Value**:
   - **Input**: The raw input value is provided to the attribute.
   - **Coercion**:
      - Each coercer is applied in the order they were defined.
      - Coercers can be:
         - **`Proc`**: A lambda or proc that transforms the value.
         - **`Symbol`**: A method name as a symbol, called on the instance.
         - **`true`**: Calls a method named `coerce_<attribute_name>` on the instance.
      - The output of one coercer becomes the input for the next.
   - **Validation**:
      - Each validator checks the coerced value.
      - Validators can be:
         - **`Proc`**: A lambda or proc that returns `true` or `false`.
         - **Object responding to `===`**: Classes, modules, ranges, etc.
      - If a validator fails (returns `false` or `nil`), an `ArgumentError` is raised.
   - **Assignment**:
      - The validated, coerced value is assigned to the attribute.
   - **Callbacks**:
      - Each callback is invoked with the new value.
      - Used for logging, triggering events, or updating other attributes.

Example:

```ruby
class Person
  include Domainic::Attributer

  option :age, Integer do
    coerce_with lambda(&:to_i)
    validates (0..150)
    on_change do |age|
      puts "Age updated to #{age}"
    end
  end
end

person = Person.new
person.age = '30'
"Age updated to 30"
```

**Explanation**:

- Coercion:
   - Input value '30' is coerced to `Integer` 30 via `lambda(&:to_i)`.
- Validation:
   - The `Integer` 30 is checked to be within the range `(0..150)`.
- Assignment:
   - The attribute `age` is set to 30.
- Callbacks:
   - The `on_change` callback prints `“Age updated to 30”`.

**Notes:**

- Order Matters: Coercion happens before validation. Ensure your coercers produce values that your validators expect.
- Multiple Coercers and Validators: You can define multiple coercers and validators. They are applied in the order they
  were added.
- Error Handling: If coercion or validation fails, an `ArgumentError` is raised, and the attribute is not updated.
- Callbacks Execution: Callbacks are only executed if the value is successfully assigned.
