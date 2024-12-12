# Domainic::Attributer

[![Domainic::Attributer Version](https://badge.fury.io/rb/domainic-attributer.svg)](https://rubygems.org/gems/domainic-attributer)

Domainic::Attributer is a powerful toolkit for Ruby that brings clarity and safety to your class attributes. It's
designed to solve common Domain-Driven Design (DDD) challenges by making your class attributes self-documenting,
type-safe, and well-behaved. Ever wished your class attributes could:

* Validate themselves to ensure they only accept correct values?
* Transform input data automatically into the right format?
* Have clear, enforced visibility rules?
* Handle their own default values intelligently?
* Tell you when they change?
* Distinguish between required arguments and optional settings?

That's exactly what Domainic::Attributer does! It's particularly useful when building domain models, value objects, or
any Ruby classes where data integrity and clear interfaces matter. Instead of writing repetitive validation code, manual
type checking, and custom attribute methods, let Domainic::Attributer handle the heavy lifting while you focus on your
domain logic.

Think of it as giving your attributes a brain - they know what they want, how they should behave, and they're not afraid
to speak up when something's not right!

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

### Basic Attributes

Getting started with Domainic::Attributer is as easy as including the module and declaring your attributes:

```ruby
class Person
  include Domainic::Attributer

  argument :name
  option :age, default: nil
end

person = Person.new("Alice", age: 30)
person.name  # => "Alice"
person.age   # => 30
```

### Arguments vs Options

Domainic::Attributer gives you two ways to define attributes:

* `argument`: Required positional parameters that must be provided in order
* `option`: Named parameters that can be provided in any order (and are optional by default)

```ruby
class Hero
  include Domainic::Attributer

  argument :name        # Required, must be first
  argument :power      # Required, must be second
  option :catchphrase  # Optional, can be provided by name
  option :sidekick     # Optional, can be provided by name
end

# All valid ways to create a hero:
Hero.new("Spider-Man", "Web-slinging", catchphrase: "With great power...")
Hero.new("Batman", "Being rich", sidekick: "Robin")
Hero.new("Wonder Woman", "Super strength")
```

#### Argument Ordering and Default Values

Arguments in Domainic::Attributer follow special ordering rules based on whether they have defaults:

* Arguments without defaults are required and are automatically moved to the front of the argument list
* Arguments with defaults are optional and are moved to the end of the argument list
* Within each group (with/without defaults), arguments maintain their order of declaration

This means the actual position when providing arguments to the constructor will be different from their declaration
order:

```ruby
class EmailMessage
  include Domainic::Attributer

  # This will be the first argument (no default)
  argument :to

  # This will be the third argument (has default)
  argument :priority, default: :normal

  # This will be the second argument (no default)
  argument :subject
end

# Arguments must be provided in their sorted order,
# with required arguments first:
EmailMessage.new("user@example.com", "Welcome!", :high)
# => #<EmailMessage:0x00007f9b1b8b3b10 @to="user@example.com", @priority=:high, @subject="Welcome!">

# If you try to provide the arguments in their declaration order, you'll get undesired results:
EmailMessage.new("user@example.com", :high, "Welcome!")
# => #<EmailMessage:0x00007f9b1b8b3b10 @to="user@example.com", @priority="Welcome!", @subject=:high>
```

This behavior ensures that required arguments are provided first and optional arguments (those with defaults) come
after, making argument handling more predictable. You can rely on this ordering regardless of how you declare the
arguments in your class. Best practice is to declare arguments without defaults first, followed by those with defaults.

### Nilability And Option Requirements

Be explicit about nil values:

```ruby
class User
  include Domainic::Attributer

  argument :email do
    non_nilable  # or not_null, non_null, etc.
  end

  option :nickname do
    default nil  # Explicitly allow nil
  end
end
```

Ensure certain options are always provided:

```ruby
class Order
  include Domainic::Attributer

  option :items, required: true
  option :status, Symbol
end

Order.new(option: ['item1', 'item2']) # OK
Order.new(status: :pending) # Raises ArgumentError
```

#### Required vs NonNilable

`required` and `non_nilable` are similar but not identical. `required` means the option must be provided when the object
is created, while `non_nilable` means the option must not be nil. A `required` option can still be nil if it's provided.

```ruby
class User
  include Domainic::Attributer

  option :email, String do
    required
    non_nilable
  end

  option :nickname, String do
    required
  end
end

User.new(email: 'example@example.com', nickname: nil) # OK
User.new(email: nil, nickname: 'example') # Raises ArgumentError because email is non_nilable
User.new(email: 'example@example.com') # Raises ArgumentError because nickname is required

user = User.new(email: 'example@example.com', nickname: 'example')
user.nickname = nil # OK
user.email = nil # Raises ArgumentError because email is non_nilable
```

### Type Validation

Keep your data clean with built-in type validation:

```ruby
class BankAccount
  include Domainic::Attributer

  argument :account_name, String                                # Direct class validation
  argument :opened_at, Time                                     # Another direct class example  
  option :balance, Integer, default: 0                          # Combining class validation with defaults
  option :status, ->(val) { [:active, :closed].include?(val) }  # Custom validation
end

# Will raise ArgumentError:
BankAccount.new(:my_account_name, Time.now)
BankAccount.new("my_account_name", "not a time")
BankAccount.new("my_account_name", Time.now, balance: "not an integer")
BankAccount.new("my_account_name", Time.now, balance: 100, status: :not_included_in_the_allow_list)
```

### Documentation

Make your attributes self-documenting:

```ruby
class Car
  include Domainic::Attributer

  argument :make, String do
    desc "The make of the car"
  end

  argument :model, String do
    description "The model of the car"
  end

  argument :year, ->(value) { value.is_a?(Integer) && value >= 1900 && value <= Time.now.year } do
    description "The year the car was made"
  end
end
```

### Value Coercion

Transform input values automatically:

```ruby
class Temperature
  include Domainic::Attributer

  argument :celsius do |value|
    coerce_with ->(val) { val.to_f }
    validate_with ->(val) { val.is_a?(Float) }
  end

  option :unit, default: "C" do |value|
    validate_with ->(val) { ["C", "F"].include?(val) }
  end
end

temp = Temperature.new("24.5")  # Automatically converted to Float
temp.celsius  # => 24.5
```

### Custom Validation

Domainic::Attributer provides flexible validation options that can be combined to create sophisticated validation rules.
You can:

* Use Ruby classes directly to validate types
* Use Procs/lambdas for custom validation logic
* Chain multiple validations
* Combine validations with coercions

```ruby
class BankTransfer
  include Domainic::Attributer

  # Combine coercion and multiple validations
  argument :amount do
    coerce_with ->(val) { val.to_f }             # First coerce to float
    validate_with Float                          # Then validate it's a float
    validate_with ->(val) { val.positive? }      # And validate it's positive
  end

  # Different validation styles
  argument :status do
    validate_with Symbol                         # Must be a Symbol
    validate_with ->(val) { [:pending, :completed, :failed].include?(val) }  # Must be one of these values
  end

  # Validation with custom error handling
  argument :reference_number do
    validate_with ->(val) {
      raise ArgumentError, "Reference must be 8 characters" unless val.length == 8
      true
    }
  end
end

# These will work:
BankTransfer.new("50.0", :pending, "12345678")    # amount coerced to 50.0
BankTransfer.new(75.25, :completed, "ABCD1234")   # amount already a float

# These will raise ArgumentError:
BankTransfer.new(-10, :pending, "12345678")       # amount must be positive
BankTransfer.new(100, :invalid, "12345678")       # invalid status
BankTransfer.new(100, :pending, "123")            # invalid reference number
```

Validations are run in the order they're defined, after any coercions. This lets you build up complex validation rules
while keeping them readable and maintainable.

### Visibility Control

Control access to your attributes:

```ruby
class SecretAgent
  include Domainic::Attributer

  argument :code_name
  option :real_name do
    private_read   # Can't read real_name from outside
    private_write  # Can't write real_name from outside
  end
  option :mission do
    protected  # Both read and write are protected
  end
end
```

### Change Callbacks

React to attribute changes:

```ruby
class Thermostat
  include Domainic::Attributer

  option :temperature do
    default 20
    on_change ->(old_val, new_val) {
      puts "Temperature changing from #{old_val}°C to #{new_val}°C"
    }
  end
end
```

### Default Values

Provide static defaults or generate them dynamically:

```ruby
class Order
  include Domainic::Attributer

  argument :items
  option :created_at do
    default { Time.now }  # Dynamic default
  end
  option :status do
    default "pending"     # Static default
  end
end
```

### Custom Method Names

Don't like `argument` and `option`? Create your own interface:

```ruby
class Configuration
  include Domainic.Attributer(argument: :param, option: :setting)

  param :environment
  setting :debug_mode, default: false
end
```

or turn off one of the methods entirely:

```ruby
class Configuration
  include Domainic.Attributer(argument: nil)

  option :environment
end
```

### Serialization

Convert your objects to hashes easily:

```ruby
class Product
  include Domainic::Attributer

  argument :name
  argument :price
  option :description, default: ""
  option :internal_id do
    private  # Won't be included in to_h output
  end
end

product = Product.new("Widget", 9.99, description: "A fantastic widget")
product.to_h  # => { name: "Widget", price: 9.99, description: "A fantastic widget" }
```

## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).
