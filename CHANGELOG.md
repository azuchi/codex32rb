## [Unreleased]

### Added

- `Codex32.split` splits a master seed into shares using `SecureRandom` and
  verifies that the generated shares recover the seed. Creating shares from
  anything but cryptographically secure randomness leaks the master seed, and
  the library previously offered no way to do it.
- A "Security considerations" section in the README, covering the lack of
  constant time operations and of memory wiping.

### Removed

- `Codex32::Errors::SeparatorNotFound`. It was never raised: a string which
  starts with `ms` but has no separator is reported as
  `Codex32::Errors::InvalidHRP`, the same as the invalid test vectors of BIP-93
  which mix a missing prefix and a missing separator.

### Security

- `Codex32.generate_share` no longer returns an all-zero share when the requested
  share index collides with the index of one of the given shares. The check was
  comparing a bech32 character with its integer value, so it never matched and
  the Lagrange interpolation silently collapsed to zero. It now raises
  `Codex32::Errors::DuplicateShareIndex`.
- `Codex32.from` validates the master seed. A non hexadecimal, odd length or out
  of range (128 to 512 bits) seed used to be silently converted into a different
  value by `Array#pack`. It now raises `Codex32::Errors::InvalidSeed`.
- `Codex32.parse` treats the last `1` as the separator, as BIP-93 requires.
  Appending `1` and arbitrary data to a valid codex32 string is no longer
  accepted, and the length is validated against the data part rather than the
  whole string.

### Fixed

- `Codex32.generate_share` compares the number of shares with the threshold of
  the shares themselves instead of the threshold of the first share, raises
  `Codex32::Errors::PayloadLengthMismatch` for shares with different payload
  lengths, and raises `Codex32::Errors::IdentifierMismatch` (previously a
  `NameError` was raised because of a missing namespace).
- `Codex32::Share#initialize` accepts an upper case `S` as the secret index.
- `Codex32.convert_bits` raises `ArgumentError` for a value which does not fit
  in the source bit width instead of returning `nil`, which the callers did not
  check for.

## [0.1.0] - 2023-03-12

- Initial release
