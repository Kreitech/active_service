# ActiveService [![Build Status](https://travis-ci.org/bilby91/active_service.svg?branch=master)](https://travis-ci.org/bilby91/active_service) [![Code Climate](https://codeclimate.com/github/bilby91/active_service/badges/gpa.svg)](https://codeclimate.com/github/bilby91/active_service)

Business classes on steroids :muscle:

`ActiveService` was created with the purpose of moving logic that usually lives in your controller to a separate layer in charge of business logic, leaving the parameters handling, format type responses (JSON, XML, HTML, etc) and other stuff to the controller.

When we started migrating to this new classes we wanted some cool features that controllers have like before, around and after actions. We also wanted exception handling.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_service'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_service

## Usage

When you include `ActiveService` in your service classes some features will be added to the class. `ActiveService` depends on the implementation of the method operation to work. The `operation` method should run all the realted business logic, for example creating a user.

__Note:__ ActiveServices don't have state.

### operation

An example UsersService could look like this:

```ruby
class CreateUserService

  include ActiveService

  def initialize(name:, email:)
    @name  = name
    @email = email
  end

  def operation
	  user = User.create!(name: @name, email: @email)
    UserMailer.welcome(user).deliver_later

	  user
	end

end
```

Services are runned by calling the method `execute`

```ruby
CreateUserService
  .new(name: 'Jhon', email: 'jhon@x.com')
  .execute
```

### pipe

`pipe` allows you to process and compose the output of a service operation. You can define as many pipes you want for an operation, this will allow you to process the output like bash `|` does.

```ruby
class UsersService

	include ActiveService

	# `pipe` name will probably change.
	pipe :create_presenter

  def initialize(name:, email:)
    @name  = name
    @email = email
  end

  def operation
    user = User.create!(name: @name, email: @email)
    UserMailer.welcome(user).deliver_later

    user
  end

	private

	def create_presenter(user)
    UserPresenter.new(user)
	end

end
```

### before / around / after

You can use filters like ActionController.

```ruby
class ActivateAccountService

	include ActiveService

	before :ensure_elegible

	# Blocks are supported too
	after do |account|
		SyncWorker.perform!(account)
		UserMailer.activation_alert(account).deliver_later
	end

	def operation(account:)
		account.activate!

		account
	end

	private

	def ensure_elegible(account)
		raise IneligibleAccountError unless account.elegible?
	end

end
```

## Plugins

Plugins for services can be built really easy around this four primitives `before`, `around`, `after` and `pipe`.

Example plugin code:

```ruby
module ActiveService::Plugins::YourPlugin

  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end

  module ClassMethods

    def your_plugin_dsl_method(error_klass, &block)
      around do |o|
        # Custom logic here
        o.call
        # Custom logic here
      end
    end

  end

end

```

### Bultin Plugins

#### ActiveService::Plugins::Database

This plugin will let you run your operation in a transaction.

```ruby
class CreateAndActivateAccountService

	include ActiveService
  include ActiveService::Plugins::Database

  run_in_transaction

  # This code will run inside a transaction
	def operation(user:)
    account = Account.create!(user: user)
		account.activate!

		account
	end

end
```

#### ActiveService::Plugins::Error

This plugin will let you rescue from errors and handle the exception in a clear way. This is the same as `ActionController#rescue_from`.

```ruby
class GetUserService

	include ActiveService
  include ActiveService::Plugins::Error

  rescue_from UserNotFoundError do |error|
    Logger.error(error)
  end

  # This code will run inside a transaction
	def operation(id:)
    user = User.find(id)

    raise UserNotFoundError.new(id) if user.nil?

    user
	end

end
```

## Contributing

1. Fork it ( https://github.com/bilby91/active_service/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
