# Codex32

This library is [Codex32](https://secretcodex32.com/index.html) ruby implementation.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'codex32'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install codex32

## Usage

```ruby
require 'codex32'

# Parse codex32 share.
share = Codex32.parse("ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxx4nzvca9cmczlw")
# Get share data.
share.data

# Recovery master seed using shares.
share1 = Codex32.parse("MS12NAMEA320ZYXWVUTSRQPNMLKJHGFEDCAXRPP870HKKQRM")
share2 = Codex32.parse("MS12NAMECACDEFGHJKLMNPQRSTUVWXYZ023FTR2GDZMPY6PN")

secret = Codex32.generate_share([share1, share2], Codex32::SECRET_INDEX)
# Obtain master seed.
secret.data

# Generate new share with index 'd'
share3 = Codex32.generate_share([share1, share2], "d")
# Obtain bech32 string.
share3.to_s
```