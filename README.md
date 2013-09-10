# DefCache

[![Version](http://allthebadges.io/jwaldrip/def_cache/badge_fury.png)](http://allthebadges.io/jwaldrip/def_cache/badge_fury)
[![Dependencies](http://allthebadges.io/jwaldrip/def_cache/gemnasium.png)](http://allthebadges.io/jwaldrip/def_cache/gemnasium)
[![Build Status](http://allthebadges.io/jwaldrip/def_cache/travis.png)](http://allthebadges.io/jwaldrip/def_cache/travis)
[![Coverage](http://allthebadges.io/jwaldrip/def_cache/coveralls.png)](http://allthebadges.io/jwaldrip/def_cache/coveralls)
[![Code Climate](http://allthebadges.io/jwaldrip/def_cache/code_climate.png)](http://allthebadges.io/jwaldrip/def_cache/code_climate)

A gem for dynamically caching methods in your classes

## Installation

Add this line to your application's Gemfile:

    gem 'def_cache'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install funky_cache

## Usage

### Basic

```ruby

class MyClass
  include DefCache

  cache_method :my_foo_method

  def my_foo_method(bar, baz)
    "hello world"
  end
end

```

### With Cache Options

```ruby

class MyClass
  include DefCache

  cache_method :my_foo_method, expires_in: 30.minutes

  def my_foo_method(bar, baz)
    "hello world"
  end
end

```

### With Dynamic Keys

```ruby

class MyClass
  include DefCache

  cache_method :my_foo_method, keys: [:dyno_key]

  def my_foo_method(bar, baz)
    "hello world"
  end

  def dyno_key
    "value of key"
  end
end

```

### With a custom store

***defaults to Rails.cache in rails or :memory_store in ruby***

```ruby

class MyClass
  include DefCache

  cache_method :my_foo_method, with: :redis_store

  def my_foo_method(bar, baz)
    "hello world"
  end
end

```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
