# frozen_string_literal: true

require 'domainic/attributer/attribute'
require 'domainic/attributer/dsl/attribute_builder/option_parser'
require 'domainic/attributer/undefined'

module Domainic
  module Attributer
    module DSL
      # This class provides a rich DSL for configuring attributes with support for default values, coercion, validation,
      # visibility controls, and change tracking. It uses method chaining to allow natural, declarative attribute
      # definitions
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class AttributeBuilder
        # @rbs @base: __todo__
        # @rbs @options: OptionParser::result

        # Initialize a new AttributeBuilder
        #
        # @param base [Class, Module] the class or module to build the attribute in
        # @param attribute_name [String, Symbol] the name of the attribute
        # @param attribute_type [String, Symbol] the type of attribute
        # @param type_validator [Proc, Object, nil] optional type validator
        # @param options [Hash{Symbol => Object}] additional options for attribute configuration. See
        #   {OptionParser#initialize} for details
        #
        # @return [AttributeBuilder] the new AttributeBuilder instance
        # @rbs (
        #   __todo__ base,
        #   String | Symbol attribute_name,
        #   String | Symbol attribute_type,
        #   ?Attribute::Validator::handler? type_validator,
        #   OptionParser::options options,
        #   ) ? { (?) [self: AttributeBuilder] -> void } -> void
        def initialize(base, attribute_name, attribute_type, type_validator = Undefined, **options, &block)
          @base = base
          # @type var options: OptionParser::options
          @options = OptionParser.parse!(attribute_name, attribute_type, options)
          @options[:validators] << type_validator if type_validator != Undefined
          instance_exec(&block) if block
        end

        # Build and finalize the {Attribute}
        #
        # @!visibility private
        # @api private
        #
        # @return [Attribute] the configured attribute
        # @rbs () -> Attribute
        def build!
          options = @options.compact
                            .reject { |_, value| value == Undefined || (value.respond_to?(:empty?) && value.empty?) }
          Attribute.new(@base, **options) # steep:ignore InsufficientKeywordArguments
        end

        # Provides a way to automatically transform attribute values into the desired format or type. Coercion ensures
        # input values conform to the expected structure by applying one or more handlers. Handlers can be Procs,
        # lambdas, or method symbols.
        #
        # Coercions are applied during initialization or whenever the attribute value is updated.
        #
        # @note When coercion is used with nilable attributes, handlers should account for `nil` values appropriately.
        #
        # @example Simple coercion
        #   class Superhero
        #     include Domainic::Attributer
        #
        #     argument :code_name do
        #       coerce_with ->(val) { val.to_s.upcase }
        #     end
        #   end
        #
        #   hero = Superhero.new("spiderman")
        #   hero.code_name # => "SPIDERMAN"
        #
        # @example Multiple coercions
        #   class Superhero
        #     include Domainic::Attributer
        #
        #     option :power_level do
        #       coerce_with ->(val) { val.to_s }         # Convert to string
        #       coerce_with do |val|                     # Remove non-digits
        #         val.gsub(/\D/, '')
        #       end
        #       coerce_with ->(val) { val.to_i }         # Convert to integer
        #     end
        #   end
        #
        #   hero = Superhero.new(power_level: "over 9000!")
        #   hero.power_level # => 9000
        #
        # @example Coercion with an instance method
        #   class Superhero
        #     include Domainic::Attributer
        #
        #     option :alias_name do
        #       coerce_with :format_alias
        #     end
        #
        #     private
        #
        #     def format_alias(value)
        #       value.to_s.downcase.split.map(&:capitalize).join(' ')
        #     end
        #   end
        #
        #   hero = Superhero.new(alias_name: "ironMAN")
        #   hero.alias_name # => "Ironman"
        #
        # @param proc_symbol [Proc, Symbol, nil] optional coercion handler
        # @yield optional coercion block
        # @yieldparam value [Object] the value to coerce
        # @yieldreturn [Object] the coerced value
        #
        # @return [self] the builder for method chaining
        # @rbs (?(Attribute::Coercer::proc | Object)? proc_symbol) ?{ (untyped value) -> untyped } -> self
        def coerce_with(proc_symbol = Undefined, &block)
          handler = proc_symbol == Undefined ? block : proc_symbol #: Attribute::Coercer::handler
          @options[:coercers] << handler
          self
        end
        alias coerce coerce_with

        # Provides a way to assign default values to attributes. These values can be static or dynamically generated
        # using a block. The default value is only applied when no explicit value is provided for the attribute
        #
        # @example Static default values
        #   class RPGCharacter
        #     include Domainic::Attributer
        #
        #     option :level, Integer do
        #       default 1
        #     end
        #
        #     option :health_max do
        #       default 100
        #     end
        #   end
        #
        #   hero = RPGCharacter.new
        #   hero.level           # => 1
        #   hero.health_max      # => 100
        #
        # @example Dynamic default values
        #   class RPGCharacter
        #     include Domainic::Attributer
        #
        #     option :created_at do
        #       default { Time.now }
        #     end
        #
        #     option :health_current do
        #       default { health_max }
        #     end
        #   end
        #
        #   hero = RPGCharacter.new
        #   hero.created_at      # => Current timestamp
        #   hero.health_current  # => Defaults to the value of `health_max`
        #
        # @example Complex dynamic default values
        #   class RPGCharacter
        #     include Domainic::Attributer
        #
        #     option :inventory do
        #       default do
        #         base_items = ['Health Potion', 'Map']
        #         base_items << 'Lucky Coin' if Random.rand < 0.1
        #         base_items
        #       end
        #     end
        #   end
        #
        #   hero = RPGCharacter.new
        #   hero.inventory       # => ["Health Potion", "Map"] or ["Health Potion", "Map", "Lucky Coin"]
        #
        # @param value_or_proc [Object, Proc, nil] optional default value or generator
        # @yield optional default value generator block
        # @yieldreturn [Object] the default value
        #
        # @return [self] the builder for method chaining
        # @rbs (?untyped? value_or_proc) ?{ (?) -> untyped } -> self
        def default(value_or_proc = Undefined, &block)
          @options[:default] = value_or_proc == Undefined ? block : value_or_proc
          self
        end
        alias default_generator default
        alias default_value default

        # Provides a way to add descriptive metadata to attributes. Descriptions improve code clarity by documenting
        # the purpose or behavior of an attribute. These descriptions can be short or detailed, depending on the
        # context.
        #
        # @note Descriptions are optional but highly recommended for improving readability and maintainability of the
        #   code.
        #
        # @example Adding a short description
        #   class MagicItem
        #     include Domainic::Attributer
        #
        #     argument :name do
        #       desc 'The name of the magic item, must be unique'
        #     end
        #   end
        #
        # @example Adding a detailed description
        #   class MagicItem
        #     include Domainic::Attributer
        #
        #     option :power_level do
        #       description 'The magical power level of the item, ranging from 0 to 100.
        #                    Higher power levels increase effectiveness but may come with
        #                    increased risks during use.'
        #       validate_with ->(val) { val.between?(0, 100) }
        #     end
        #   end
        #
        # @param text [String] the description text
        #
        # @return [self] the builder for method chaining
        # @rbs (String? text) -> self
        def description(text)
          @options[:description] = text
          self
        end
        alias desc description

        # Ensures that an attribute defined in the block DSL cannot have a `nil` value. This validation is enforced
        # during initialization and when modifying the attribute value at runtime. Use `non_nilable` for attributes that
        # must always have a value.
        #
        # @example Preventing `nil` values for an attribute
        #   class Ninja
        #     include Domainic::Attributer
        #
        #     argument :code_name do
        #       non_nilable
        #     end
        #   end
        #
        #   Ninja.new(nil)  # Raises ArgumentError: nil value is not allowed
        #
        # @example Combining `non_nilable` with other features
        #   class Ninja
        #     include Domainic::Attributer
        #
        #     argument :rank do
        #       desc 'The rank of the ninja, such as Genin or Chunin'
        #       non_nilable
        #     end
        #   end
        #
        #   ninja = Ninja.new('Genin') # => Works
        #   ninja.rank = nil # Raises ArgumentError: nil value is not allowed
        #
        # @return [self] the builder for method chaining
        # @rbs () -> self
        def non_nilable
          @options[:nilable] = false
          self
        end
        alias non_nil non_nilable
        alias non_null non_nilable
        alias non_nullable non_nilable
        alias not_nil non_nilable
        alias not_nilable non_nilable
        alias not_null non_nilable
        alias not_nullable non_nilable

        # Allows defining a callback to be triggered whenever the attribute's value changes. The callback receives the
        # old value and the new value as arguments, enabling custom logic to be executed on changes. Use `on_change` to
        # react to changes in attribute values, such as updating dependent attributes or triggering side effects.
        #
        # @example Reacting to changes in an attribute
        #   class VideoGame
        #     include Domainic::Attributer
        #
        #     option :health do
        #       default 100
        #       on_change ->(old_value, new_value) {
        #         puts "Health changed from #{old_value} to #{new_value}"
        #       }
        #     end
        #   end
        #
        #   game = VideoGame.new
        #   game.health = 50  # Outputs: Health changed from 100 to 50
        #
        # @example Performing complex logic on change
        #   class VideoGame
        #     include Domainic::Attributer
        #
        #     option :power_ups do
        #       default []
        #       on_change do |old_value, new_value|
        #         new_items = new_value - old_value
        #         lost_items = old_value - new_value
        #
        #         new_items.each { |item| activate_power_up(item) }
        #         lost_items.each { |item| deactivate_power_up(item) }
        #       end
        #     end
        #
        #     private
        #
        #     def activate_power_up(item)
        #       puts "Activated power-up: #{item}"
        #     end
        #
        #     def deactivate_power_up(item)
        #       puts "Deactivated power-up: #{item}"
        #     end
        #   end
        #
        #   game = VideoGame.new
        #   game.power_ups = ['Shield', 'Speed Boost']
        #   # Outputs: Activated power-up: Shield
        #   #          Activated power-up: Speed Boost
        #   game.power_ups = ['Shield']
        #   # Outputs: Deactivated power-up: Speed Boost
        #
        # @param proc [Proc, nil] optional callback handler
        # @yield optional callback block
        # @yieldparam old_value [Object] the previous value of the attribute
        # @yieldparam new_value [Object] the new value of the attribute
        # @yieldreturn [void]
        #
        # @return [self] the builder for method chaining
        # @rbs (?Attribute::Callback::handler? proc) ?{ (untyped old_value, untyped new_value) -> void } -> self
        def on_change(proc = Undefined, &block)
          handler = proc == Undefined ? block : proc #: Attribute::Callback::handler
          @options[:callbacks] << handler
          self
        end

        # Sets both the read and write visibility of an attribute to private. This ensures the attribute can only be
        # accessed or modified within the class itself.
        #
        # @example Making an attribute private
        #   class SecretAgent
        #     include Domainic::Attributer
        #
        #     option :real_name do
        #       desc 'The real name of the agent, hidden from external access.'
        #       private
        #     end
        #   end
        #
        #   agent = SecretAgent.new(real_name: 'James Bond')
        #   agent.real_name  # Raises NoMethodError: private method `real_name' called for #<SecretAgent>
        #   agent.real_name = 'John Doe'  # Raises NoMethodError: private method `real_name=' called for #<SecretAgent>
        #
        # @return [self] the builder for method chaining
        # @rbs () -> self
        def private
          private_read
          private_write
        end

        # Sets the read visibility of an attribute to private, allowing the attribute to be read only within the class
        # itself. The write visibility remains unchanged unless explicitly modified. Use `private_read` when the value
        # of an attribute should be hidden from external consumers but writable by external code if needed.
        #
        # @example Making the reader private
        #   class SecretAgent
        #     include Domainic::Attributer
        #
        #     option :mission_code do
        #       desc 'The secret mission code, readable only within the class.'
        #       private_read
        #       default { generate_code }
        #     end
        #
        #     private
        #
        #     def generate_code
        #       "M-#{rand(1000..9999)}"
        #     end
        #   end
        #
        #   agent = SecretAgent.new
        #   agent.mission_code  # Raises NoMethodError: private method `mission_code' called for #<SecretAgent>
        #   agent.mission_code = 'Override Code'  # Works, as write visibility is still public
        #
        # @return [self] the builder for method chaining
        # @rbs () -> self
        def private_read
          @options[:read] = :private
          self
        end

        # Sets the write visibility of an attribute to private, allowing the attribute to be modified only within the
        # class. The read visibility remains unchanged unless explicitly modified. Use `private_write` to ensure that an
        # attribute's value can only be updated internally, while still allowing external code to read its value if
        # needed.
        #
        # @example Making the writer private
        #   class SecretAgent
        #     include Domainic::Attributer
        #
        #     option :mission_code do
        #       desc 'The secret mission code, writable only within the class.'
        #       private_write
        #       default { generate_code }
        #     end
        #
        #     private
        #
        #     def generate_code
        #       "M-#{rand(1000..9999)}"
        #     end
        #   end
        #
        #   agent = SecretAgent.new
        #   agent.mission_code          # => "M-1234"
        #   agent.mission_code = '007'  # Raises NoMethodError: private method `mission_code=' called for #<SecretAgent>
        #
        # @return [self] the builder for method chaining
        # @rbs () -> self
        def private_write
          @options[:write] = :private
          self
        end

        # Sets both the read and write visibility of an attribute to protected, allowing access only within the class
        # and its subclasses. This visibility restricts external access entirely. Use `protected` to share attributes
        # within a class hierarchy while keeping them hidden from external consumers.
        #
        # @example Defining a protected attribute
        #   class SecretAgent
        #     include Domainic::Attributer
        #
        #     option :mission_code do
        #       protected
        #       description 'The mission code, accessible only within the class and its subclasses.'
        #     end
        #   end
        #
        #   class DoubleAgent < SecretAgent
        #     def reveal_code
        #       self.mission_code
        #     end
        #   end
        #
        #   agent = SecretAgent.new(mission_code: '007')
        #   agent.mission_code          # Raises NoMethodError
        #   DoubleAgent.new.reveal_code # => '007'
        #
        # @return [self] the builder for method chaining
        # @rbs () -> self
        def protected
          protected_read
          protected_write
        end

        # Sets both the read and write visibility of an attribute to protected. This allows the attribute to be accessed
        # or modified only within the class and its subclasses. Use `protected` for attributes that should be accessible
        # to the class and its subclasses but hidden from external consumers.
        #
        # @example Making an attribute protected
        #   class SecretAgent
        #     include Domainic::Attributer
        #
        #     option :mission_code do
        #       desc 'The mission code, accessible only within the class or subclasses.'
        #       protected
        #     end
        #   end
        #
        #   class DoubleAgent < SecretAgent
        #     def reveal_code
        #       self.mission_code
        #     end
        #   end
        #
        #   agent = SecretAgent.new(mission_code: '007')
        #   agent.mission_code          # Raises NoMethodError
        #   DoubleAgent.new.reveal_code # => '007'
        #
        # @return [self] the builder for method chaining
        # @rbs () -> self
        def protected_read
          @options[:read] = :protected
          self
        end

        # Sets both the read and write visibility of an attribute to protected. This allows the attribute to be accessed
        # or modified only within the class and its subclasses. Use `protected` for attributes that should be accessible
        # to the class and its subclasses but hidden from external consumers.
        #
        # @example Making an attribute protected
        #   class SecretAgent
        #     include Domainic::Attributer
        #
        #     option :mission_code do
        #       desc 'The mission code, accessible only within the class or subclasses.'
        #       protected
        #     end
        #   end
        #
        #   class DoubleAgent < SecretAgent
        #     def reveal_code
        #       self.mission_code
        #     end
        #   end
        #
        #   agent = SecretAgent.new(mission_code: '007')
        #   agent.mission_code          # Raises NoMethodError
        #   DoubleAgent.new.reveal_code # => '007'
        #
        # @return [self] the builder for method chaining
        # @rbs () -> self
        def protected_write
          @options[:write] = :protected
          self
        end

        # Explicitly sets both the read and write visibility of an attribute to public, overriding any inherited or
        # previously set visibility. By default, attributes are public, so this is typically used to revert an
        # attribute's visibility if it was changed in a parent class or module.
        #
        # @note Attributes are public by default. Use `public` explicitly to override inherited or modified visibility.
        #
        # @example Reverting visibility to public in a subclass
        #   class SecretAgent
        #     include Domainic::Attributer
        #
        #     option :mission_code do
        #       desc 'The mission code, protected in the base class.'
        #       private
        #     end
        #   end
        #
        #   class FieldAgent < SecretAgent
        #     option :mission_code do
        #       desc 'The mission code, made public in the subclass.'
        #       public
        #     end
        #   end
        #
        #   agent = FieldAgent.new(mission_code: '007')
        #   agent.mission_code          # => '007' (now accessible)
        #   agent.mission_code = '008'  # Works, as visibility is public in the subclass
        #
        # @return [self] the builder for method chaining
        # @rbs () -> self
        def public
          public_read
          public_write
        end

        # Explicitly sets the read visibility of an attribute to public, overriding any inherited or previously set
        # visibility. By default, attributes are readable publicly, so this is typically used to revert the read
        # visibility of an attribute if it was modified in a parent class or module.
        #
        # @note Attributes are publicly readable by default. Use `public_read` explicitly to override inherited or
        #   modified visibility.
        #
        # @example Reverting read visibility to public in a subclass
        #   class SecretAgent
        #     include Domainic::Attributer
        #
        #     option :mission_code do
        #       desc 'The mission code, privately readable in the base class.'
        #       private_read
        #     end
        #   end
        #
        #   class FieldAgent < SecretAgent
        #     option :mission_code do
        #       desc 'The mission code, made publicly readable in the subclass.'
        #       public_read
        #     end
        #   end
        #
        #   agent = FieldAgent.new(mission_code: '007')
        #   agent.mission_code          # => '007' (now publicly readable)
        #   agent.mission_code = '008'  # Raises NoMethodError, as write visibility is still private
        #
        # @return [self] the builder for method chaining
        # @rbs () -> self
        def public_read
          @options[:read] = :public
          self
        end

        # Explicitly sets the write visibility of an attribute to public, overriding any inherited or previously set
        # visibility. By default, attributes are writable publicly, so this is typically used to revert the write
        # visibility of an attribute if it was modified in a parent class or module.
        #
        # @note Attributes are publicly writable by default. Use `public_write` explicitly to override inherited or
        #   modified visibility.
        #
        # @example Reverting write visibility to public in a subclass
        #   class SecretAgent
        #     include Domainic::Attributer
        #
        #     option :mission_code do
        #       desc 'The mission code, writable only within the class or subclasses in the base class.'
        #       private_write
        #     end
        #   end
        #
        #   class FieldAgent < SecretAgent
        #     option :mission_code do
        #       desc 'The mission code, now writable publicly in the subclass.'
        #       public_write
        #     end
        #   end
        #
        #   agent = FieldAgent.new(mission_code: '007')
        #   agent.mission_code          # Raises NoMethodError, as read visibility remains restricted
        #   agent.mission_code = '008'  # Works, as write visibility is now public
        #
        # @return [self] the builder for method chaining
        # @rbs () -> self
        def public_write
          @options[:write] = :public
          self
        end

        # Marks an {ClassMethods#option option} attribute as required, ensuring that a value must be provided during
        # initialization. If a required attribute is not supplied, an error is raised. Use `required` to enforce
        # mandatory attributes.
        #
        # @note required options are enforced during initialization; as long as the option is provided
        #   (even if it is `nil`) no error will be raised.
        #
        # @example Defining a required attribute
        #   class Superhero
        #     include Domainic::Attributer
        #
        #     option :name do
        #       desc 'The name of the superhero, which must be provided.'
        #       required
        #     end
        #   end
        #
        #   Superhero.new          # Raises ArgumentError: missing required attribute: name
        #   Superhero.new(name: 'Spiderman') # Works, as the required attribute is supplied
        #   Superhero.new(name: nil) # Works, as the required attribute is supplied (even if it is nil)
        #
        # @return [self] the builder for method chaining
        # @rbs () -> self
        def required
          @options[:required] = true
          self
        end

        # Adds a custom validation to an attribute, allowing you to define specific criteria that the attribute's value
        # must meet. Validators can be Procs, lambdas, or symbols referencing instance methods. Validation occurs during
        # initialization and whenever the attribute value is updated. Use `validate_with` to enforce rules beyond type
        # or presence, such as ranges, formats, or custom logic.
        #
        # @example Adding a simple validation
        #   class Superhero
        #     include Domainic::Attributer
        #
        #     argument :power_level do
        #       desc 'The power level of the superhero, which must be an integer between 0 and 100.'
        #       validate_with ->(val) { val.is_a?(Integer) && val.between?(0, 100) }
        #     end
        #   end
        #
        #   Superhero.new(150)      # Raises ArgumentError: invalid value for power_level
        #   Superhero.new(85)       # Works, as 85 is within the valid range
        #
        # @example Using an instance method as a validator
        #   class Superhero
        #     include Domainic::Attributer
        #
        #     argument :alias_name do
        #       desc 'The alias name of the superhero, validated using an instance method.'
        #       validate_with :validate_alias_name
        #     end
        #
        #     private
        #
        #     def validate_alias_name(value)
        #       value.is_a?(String) && value.match?(/\A[A-Z][a-z]+\z/)
        #     end
        #   end
        #
        #   Superhero.new('Spiderman')  # Works, as the alias name matches the validation criteria
        #   Superhero.new('spiderman')  # Raises ArgumentError: invalid value for alias_name
        #
        # @example Combining multiple validators
        #   class Vehicle
        #     include Domainic::Attributer
        #
        #     option :speed do
        #       desc 'The speed of the vehicle, which must be a non-negative number.'
        #       validate_with ->(val) { val.is_a?(Numeric) }
        #       validate_with do |val|
        #         val.zero? || val.positive?
        #       end
        #     end
        #   end
        #
        #   Vehicle.new(speed: -10)  # Raises ArgumentError: invalid value for speed
        #   Vehicle.new(speed: 50)   # Works, as 50 meets all validation criteria
        #
        # @param object_or_proc [Object, Proc, nil] optional validation handler
        # @yield optional validation block
        # @yieldparam value [Object] the value to validate
        # @yieldreturn [Boolean] `true` if the value is valid, `false` otherwise
        #
        # @return [self] the builder for method chaining
        # @rbs (?Attribute::Validator::handler? object_or_proc) ?{ (untyped value) -> boolish } -> self
        def validate_with(object_or_proc = Undefined, &block)
          handler = object_or_proc == Undefined ? block : object_or_proc #: Attribute::Validator::handler
          @options[:validators] << handler
          self
        end
        alias validate validate_with
        alias validates validate_with
      end
    end
  end
end
