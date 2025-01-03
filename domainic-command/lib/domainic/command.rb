# frozen_string_literal: true

require 'domainic/command/class_methods'
require 'domainic/command/instance_methods'

module Domainic
  # A module that implements the Command pattern, providing a structured way to encapsulate business operations.
  # Commands are single-purpose objects that perform a specific action, validating their inputs and outputs while
  # maintaining a consistent interface for error handling and result reporting.
  #
  # @abstract Including classes must implement an {#execute} method that defines the command's business logic.
  #   The {#execute} method has access to validated inputs via the {#context} accessor and should set any output values
  #   on the context before returning.
  #
  # @example Basic command definition
  #   class CreateUser
  #     include Domainic::Command
  #
  #     argument :login, String, "The user's login", required: true
  #     argument :password, String, "The user's password", required: true
  #
  #     output :user, User, "The created user", required: true
  #     output :created_at, Time, "When the user was created"
  #
  #     def execute
  #       user = User.create!(login: context.login, password: context.password)
  #       context.user = user
  #       context.created_at = Time.current
  #     end
  #   end
  #
  # @example Using external context classes
  #   class CreateUserInput < Domainic::Command::Context::InputContext
  #     argument :login, String, "The user's login", required: true
  #     argument :password, String, "The user's password", required: true
  #   end
  #
  #   class CreateUserOutput < Domainic::Command::Context::OutputContext
  #     field :user, User, "The created user", required: true
  #     field :created_at, Time, "When the user was created"
  #   end
  #
  #   class CreateUser
  #     include Domainic::Command
  #
  #     accepts_arguments_matching CreateUserInput
  #     returns_output_matching CreateUserOutput
  #
  #     def execute
  #       user = User.create!(login: context.login, password: context.password)
  #       context.user = user
  #       context.created_at = Time.current
  #     end
  #   end
  #
  # @example Command usage
  #   # Successful execution
  #   result = CreateUser.call(login: "user@example.com", password: "secret123")
  #   result.successful? #=> true
  #   result.user #=> #<User id: 1, login: "user@example.com">
  #
  #   # Failed execution
  #   result = CreateUser.call(login: "invalid")
  #   result.failure? #=> true
  #   result.errors[:password] #=> ["is required"]
  #
  # @author {https://aaronmallen.me Aaron Allen}
  # @since 0.1.0
  module Command
    # @rbs override
    def self.included(base)
      super
      base.include(InstanceMethods)
      base.extend(ClassMethods)
    end
  end
end
