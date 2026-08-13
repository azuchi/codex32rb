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

# Split a master seed into 5 shares, any 3 of which recover the seed.
# The shares are derived from random values obtained from SecureRandom.
shares = Codex32.split(
  seed: "ffeeddccbbaa99887766554433221100",
  id: "test",
  threshold: 3,
  share_indexes: %w[a c d e f]
)
shares.map(&:to_s)

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

## Security considerations

Codex32 strings and master seeds are secret material. Keep the following
limitations in mind.

- **Use `Codex32.split` to create shares.** Shares built from anything but
  cryptographically secure randomness leak the master seed. `Codex32.split`
  uses `SecureRandom`.
- **Verify a backup before relying on it.** Recover the master seed from a
  threshold of the shares and compare it with the original. `Codex32.split`
  performs this check once for the shares it returns.
- **This library is not constant time.** Character lookups, the field
  arithmetic and the validation errors all depend on the data being processed.
  Run it on a machine you trust, preferably offline, and do not feed it input
  from untrusted parties on a shared host.
- **Secrets are not erased from memory.** Ruby gives a library no reliable way
  to wipe a string, so master seeds and shares stay in the heap until they are
  garbage collected, and may be copied by the GC or swapped to disk.