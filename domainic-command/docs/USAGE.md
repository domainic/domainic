# Domainic::Command Usage Guide

A comprehensive guide to all features and capabilities of Domainic::Command.

## Table of Contents

* [Core Concepts](#core-concepts)
  * [Command Lifecycle](#command-lifecycle)
  * [Input & Output Contexts](#input--output-contexts)
  * [Error Handling](#error-handling)
* [Basic Usage](#basic-usage)
  * [Defining Commands](#defining-commands)
  * [Executing Commands](#executing-commands)
  * [Handling Results](#handling-results)
* [Advanced Features](#advanced-features)
  * [Type Safety with Domainic::Type](#type-safety-with-domainictype)
  * [External Context Classes](#external-context-classes)
  * [Runtime Context](#runtime-context)
  * [Command Composition](#command-composition)
* [Integration Patterns](#integration-patterns)
  * [Rails Integration](#rails-integration)
  * [API Endpoints](#api-endpoints)
  * [Background Jobs](#background-jobs)
* [Best Practices](#best-practices)
  * [Command Organization](#command-organization)
  * [Error Handling Strategies](#error-handling-strategies)
  * [Testing Commands](#testing-commands)

## Core Concepts

### Command Lifecycle

Every command goes through several distinct phases during execution:

1. **Input Validation**: Arguments are validated against their type constraints
2. **Context Preparation**: A runtime context is created with validated inputs
3. **Execution**: The command's business logic runs
4. **Output Validation**: Return values are validated
5. **Result Creation**: A Result object is created with the final state

```ruby
class ProcessOrder
  include Domainic::Command

  argument :order_id, Integer
  argument :payment_method, String

  output :order, Order
  output :receipt_url, String

  def execute
    # 1. Input Validation (automatic)
    # context.order_id and context.payment_method are already validated

    # 2. Business Logic
    order = Order.find(context.order_id)
    receipt = process_payment(order, context.payment_method)

    # 3. Set Outputs
    context.order = order
    context.receipt_url = receipt.url
    # 4. Output Validation (automatic)
  end

  private

  def process_payment(order, method)
    # Implementation
  end
end
```

### Input & Output Contexts

Commands use separate context objects for inputs and outputs, ensuring clear boundaries:

```ruby
# Input validation
argument :user_id, Integer, "The ID of the user", required: true
argument :amount, ->(val) { val.is_a?(Numeric) && val.positive? },
         "Amount to charge (must be positive)"

# Output requirements
output :transaction_id, String, "The payment processor's transaction ID"
output :status, Symbol, "The transaction status",
       default: :pending
```

### Error Handling

Commands provide structured error handling with different status codes for various failure points:

```ruby
begin
  result = RiskyOperation.call!(input: 'value')
rescue Domainic::Command::ExecutionError => e
  case e.result.status_code
  when Domainic::Command::Result::STATUS::FAILED_AT_INPUT
    # Handle input validation failure
  when Domainic::Command::Result::STATUS::FAILED_AT_RUNTIME
    # Handle runtime error
  when Domainic::Command::Result::STATUS::FAILED_AT_OUTPUT
    # Handle output validation failure
  end
end

# Or use the non-raising version:
result = RiskyOperation.call(input: 'value')
if result.failure?
  case result.status_code
  when Domainic::Command::Result::STATUS::FAILED_AT_INPUT
    # Handle input validation failure
  # ... etc
  end
end
```

## Basic Usage

### Defining Commands

Commands are defined by including `Domainic::Command` and implementing the `execute` method:

```ruby
class UpdateUserProfile
  include Domainic::Command

  # Required inputs
  argument :user_id, Integer
  argument :name, String, required: true

  # Optional inputs with defaults
  argument :title, String, default: nil
  argument :bio, String, default: ''

  # Required outputs
  output :user, User, required: true
  output :updated_at, Time, required: true

  def execute
    user = User.find(context.user_id)

    user.update!(
      name: context.name,
      title: context.title,
      bio: context.bio
    )

    context.user = user
    context.updated_at = Time.current
  end
end
```

### Executing Commands

Commands can be executed in several ways:

```ruby
# Basic execution - returns Result object, won't raise on failure
result = UpdateUserProfile.call(
  user_id: 1,
  name: "New Name",
  title: "Developer"
)

# Raising version - raises ExecutionError on failure
result = UpdateUserProfile.call!(
  user_id: 1,
  name: "New Name"
)

# Instance execution
command = UpdateUserProfile.new
result = command.call(user_id: 1, name: "New Name")
```

### Handling Results

Results provide a consistent interface for accessing outputs and checking status:

```ruby
result = UpdateUserProfile.call(user_id: 1, name: "New Name")

# Check status
result.successful? # or result.success?
result.failure?    # or result.failed?

# Access outputs (when successful)
result.user
result.updated_at

# Access errors (when failed)
result.errors             # => ErrorSet instance
result.errors[:user_id]   # => Array of error messages
result.errors.full_messages # => Array of formatted messages

# Get status code
result.status_code # => 0 for success, other codes for failures
```

## Advanced Features

### Type Safety with Domainic::Type

For enhanced type safety, combine commands with `Domainic::Type`. First, include both the command functionality and type
system:

```ruby
class CreateUser
  extend Domainic::Type::Definitions  # Add type definitions
  include Domainic::Command           # Add command functionality

  # Use type definitions for precise validation
  argument :email, _EmailAddress, required: true
  argument :password, _String.having_min_length(8), required: true
  argument :age, _Integer.having_min(18), "Must be an adult"

  # Complex type constraints
  argument :roles, _Array.of(_Symbol).having_max_size(3),
           "Up to 3 roles allowed"

  output :user, _Instance.of(User), required: true
  output :auth_token, _String.matching(/\A[a-z0-9]{32}\z/i),
         "32-character hex token"

  def execute
    # Implementation
  end
end
```

### External Context Classes

For reusable input/output contexts, define them separately:

```ruby
class UserCreationContext < Domainic::Command::Context::InputContext
  argument :email, String, required: true
  argument :password, String, required: true
end

class UserResultContext < Domainic::Command::Context::OutputContext
  field :user, User, required: true
  field :auth_token, String
end

class CreateUser
  include Domainic::Command

  accepts_arguments_matching UserCreationContext
  returns_data_matching UserResultContext

  def execute
    # Implementation using inherited contexts
  end
end
```

### Runtime Context

The runtime context provides a flexible workspace during execution:

```ruby
class ComplexOperation
  include Domainic::Command

  argument :input_data
  output :result

  def execute
    # Runtime context can store temporary data
    context.temp_value = process_first_stage
    context.another_temp = process_second_stage

    # Only declared outputs are validated
    context.result = final_result
  end
end
```

### Command Composition

Commands can be composed to build complex workflows:

```ruby
class CreateOrder
  include Domainic::Command

  argument :user_id, Integer
  argument :items, Array

  output :order, Order

  def execute
    # Validate inventory first
    inventory_check = CheckInventory.call!(items: context.items)

    # Create the order
    context.order = Order.create!(
      user_id: context.user_id,
      items: inventory_check.available_items
    )

    # Process payment
    ProcessPayment.call!(
      order_id: context.order.id,
      amount: context.order.total
    )
  end
end
```

## Integration Patterns

### Rails Integration

Create an ApplicationCommand base class for Rails-specific functionality:

```ruby
# app/commands/application_command.rb
class ApplicationCommand
  include Domainic::Command

  private

  # Add Rails-specific helper methods
  def translate(key, **options)
    I18n.translate(key, **options)
  end
  alias t translate

  def logger
    Rails.logger
  end
end

# app/commands/users/create.rb
module Users
  class Create < ApplicationCommand
    argument :email, String
    argument :password, String

    output :user, User

    def execute
      context.user = User.create!(
        email: context.email,
        password: context.password
      )
    end
  end
end
```

### API Endpoints

Commands work well with API endpoints:

```ruby
class Api::V1::UsersController < ApiController
  def create
    result = Users::Create.call(user_params)

    if result.successful?
      render json: UserSerializer.new(result.user),
             status: :created
    else
      render json: { errors: result.errors.to_h },
             status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
```

### Background Jobs

Commands can be used in background jobs:

```ruby
class ProcessReportJob < ApplicationJob
  def perform(report_id, user_id)
    Reports::Generate.call!(
      report_id: report_id,
      user_id: user_id
    )
  rescue Domainic::Command::ExecutionError => e
    # Handle failure (e.g., notify user, retry job)
    NotificationService.alert_failure(user_id, e.result)
    raise # Re-raise to trigger job retry
  end
end
```

### Command Line Tools

Commands work seamlessly with CLI tools, using the Result object's status codes for proper exit handling. These status
codes follow Unix conventions, making them perfect for command-line applications:

* 0 - Successful execution
* 1 - Runtime failure
* 2 - Input validation failure
* 3 - Output validation failure

For example, with Thor:

```ruby
class MyCLI < Thor
  desc 'create_user', 'Creates a new user'
  def create_user
    result = Users::Create.call(
      name: options[:name],
      email: options[:email]
    )

    if result.successful?
      puts "Created user #{result.user.name}"
    else
      puts "Failed: #{result.errors.full_messages.join(', ')}"
    end

    exit result.status_code  # Proper exit code for shell integration
  end
end
```

Or with a simple script:

```ruby
#!/usr/bin/env ruby
begin
  result = ComplexOperation.call!(params)
  exit 0  # Explicit success exit
rescue Domainic::Command::ExecutionError => e
  warn "Error: #{e.result.errors.full_messages.join(', ')}"
  exit e.result.status_code  # Proper failure exit code
end
```

## Best Practices

### Command Organization

Organize commands by domain context and functionality:

```markdown
app/
  commands/
    application_command.rb
    users/
      create.rb
      update.rb
      delete.rb
    orders/
      create.rb
      fulfill.rb
      cancel.rb
    payments/
      process.rb
      refund.rb
```

### Error Handling Strategies

Choose appropriate error handling based on context:

```ruby
# In controllers - use non-raising version
def create
  result = Users::Create.call(user_params)

  if result.successful?
    redirect_to user_path(result.user)
  else
    @user_form = UserForm.new
    @errors = result.errors
    render :new
  end
end

# In background jobs - use raising version
def perform(user_id)
  ProcessUserData.call!(user_id: user_id)
rescue Domainic::Command::ExecutionError => e
  handle_failure(e.result)
  raise # Allow job retry
end

# In other commands - choose based on recovery needs
def execute
  # Use non-raising when you can handle the failure
  result = SubOperation.call(input: value)
  if result.failure?
    handle_sub_operation_failure(result)
    return
  end

  # Use raising when failure should abort the whole operation
  AnotherOperation.call!(result.output)
end
```

### Testing Commands

Test commands thoroughly, including success and failure cases:

```ruby
RSpec.describe Users::Create do
  describe '.call' do
    subject(:command) { described_class.call(params) }

    context 'with valid parameters' do
      let(:params) do
        {
          email: 'user@example.com',
          password: 'password123'
        }
      end

      it 'is expected to be successful' do
        expect(command).to be_successful
      end

      it 'is expected to create a user' do
        expect { command }
          .to change(User, :count).by(1)
      end

      it 'is expected to set the correct email' do
        expect(command.user.email)
          .to eq('user@example.com')
      end
    end

    context 'with invalid parameters' do
      let(:params) do
        {
          email: 'invalid-email',
          password: 'short'
        }
      end

      it 'is expected to fail' do
        expect(command).to be_failure
      end

      it 'is expected to have appropriate errors' do
        expect(command.errors[:email])
          .to include('is not a valid email')
        expect(command.errors[:password])
          .to include('is too short')
      end
    end
  end
end
```
