# frozen_string_literal: true

require_relative "codex32/version"
require_relative "codex32/share"

# Codex32 library.
module Codex32
  class Error < StandardError
  end

  HRP = "ms"

  SEPARATOR = "1"

  # stree-ignore
  CHARSET = %w[q p z r y 9 x 8 g f 2 t v d w 0 s 3 j n 5 4 k h c e 6 m u a 7 l].freeze

  # stree-ignore
  BECH32_INV = [0, 1, 20, 24, 10, 8, 12, 29, 5, 11, 4, 9, 6, 28, 26, 31,
                22, 18, 17, 23, 2, 25, 16, 19, 3, 21, 14, 30, 13, 7, 27, 15].freeze

  MS32_CONST = 0x10ce0795c2fd1e62a
  MS32_LONG_CONST = 0x43381e570bf4798ab26

  SECRET_INDEX = "s"

  module_function

  # Parse codex32 string.
  # @param [String] codex32 Codex32 string
  # @return [Codex32::Share]
  # @raise [ArgumentError]
  def parse(codex32)
    hrp, remain = codex32.downcase.split(SEPARATOR)
    if remain.nil?
      raise ArgumentError, "codex32 string dose not include separator."
    end
    raise ArgumentError, "Invalid hrp specified." unless hrp.downcase == HRP
    unless valid_checksum?(bech32_to_array(remain))
      raise ArgumentError, "The checksum is incorrect."
    end

    checksum_len = remain.chars.length <= 93 ? 13 : 15

    remain = remain.chars
    threshold = remain[0].to_i
    id = remain[1..4].join
    share_index = remain[5]
    payload_end = remain.length - checksum_len
    payload = remain[6...payload_end].join
    Share.new(id, threshold, share_index, payload)
  end

  # Create codex32 string.
  # @param [String] seed Secret with hex format.
  # @param [Integer] threshold Threshold value.
  # @param [String] id Identifier.
  # @param [String] share_index Index of share.
  # @return [Codex32::Share]
  def from(seed:, id:, share_index:, threshold: 0)
    unless threshold.is_a?(Integer)
      raise ArgumentError, "threshold must be integer."
    end
    raise ArgumentError, "id must be 4 characters." unless id.length == 4
    if CHARSET.index(share_index).nil?
      raise ArgumentError, "Invalid share_index specified."
    end

    payload =
      array_to_bech32(
        convert_bits([seed].pack("H*").unpack("C*"), 8, 5, padding: true)
      )
    Share.new(id, threshold, share_index, payload)
  end

  # Convert bech32 string to array.
  # @param [String] bech32_str bech32 string.
  # @return [Array(Integer)] array of bech32 data.
  # @raise ArgumentError
  def bech32_to_array(bech32_str)
    bech32_str.downcase.each_char.map do |c|
      i = CHARSET.index(c)
      raise ArgumentError, "#{c} is an invalid bech32 character." if i.nil?
      i
    end
  end

  # Recover secret using +shares+.
  # @param [Array(Codex32::Share)] shares Array of share.
  # @param [String] share_index A share index.
  # @return [Codex32::Share] Recovery secret.
  def generate_share(shares, share_index)
    raise ArgumentError, "shares must be array." unless shares.is_a?(Array)
    unless shares.map(&:id).uniq.length == 1
      raise ArgumentError, "Share ids does not match."
    end
    threshold = shares.map(&:threshold).uniq
    threshold.delete(0)
    unless threshold.length == 1
      raise ArgumentError, "Share threshold does not match."
    end
    index = CHARSET.index(share_index.downcase)
    raise ArgumentError, "Invalid share index specified." if index.nil?
    indices = shares.map(&:index).uniq
    unless indices.length == shares.length
      raise ArgumentError, "Share index duplicate."
    end
    if indices.first == index
      raise ArgumentError,
            "The index of the share to be generated is included in the existing share."
    end
    if shares.length < shares[0].threshold
      raise ArgumentError, "The number of shares does not meet the threshold."
    end

    data =
      shares.map do |share|
        bech32_to_array(
          share.threshold.to_s + share.id + share.index + share.payload
        )
      end
    result = interpolate_at(data, index)
    Share.new(
      shares.first.id,
      threshold.first,
      CHARSET[result[5]],
      array_to_bech32(result[6..])
    )
  end

  # Convert array to bech32 string.
  # @param [Array(Integer)] data An array.
  # @return [String] bech32 string.
  # @raise ArgumentError
  def array_to_bech32(data)
    data.map { |d| CHARSET[d] }.join
  end

  # @param [Array(Integer)] data
  # @return [Array(Integer)]
  def polymod(data)
    generators = [
      0x19dc500ce73fde210,
      0x1bfae00def77fe529,
      0x1fbd920fffe7bee52,
      0x1739640bdeee3fdad,
      0x07729a039cfc75f5a
    ]
    residue = 0x23181b3
    data.each do |d|
      b = residue >> 60
      residue = (residue & 0x0fffffffffffffff) << 5 ^ d
      5.times { |i| residue ^= ((b >> i) & 1).zero? ? 0 : generators[i] }
    end
    residue
  end

  # @param [Array(Integer)] data
  # @return [Array(Integer)]
  def long_polymod(data)
    generators = [
      0x3d59d273535ea62d897,
      0x7a9becb6361c6c51507,
      0x543f9b7e6c38d8a2a0e,
      0x0c577eaeccf1990d13c,
      0x1887f74f8dc71b10651
    ]
    residue = 0x23181b3
    data.each do |d|
      b = residue >> 70
      residue = (residue & 0x3fffffffffffffffff) << 5 ^ d
      5.times { |i| residue ^= ((b >> i) & 1).zero? ? 0 : generators[i] }
    end
    residue
  end

  # Convert a +data+ where each byte is encoding +from+ bits to a byte slice where each byte is encoding +to+ bits.
  # @param [Array] data
  # @param [Integer] from
  # @param [Integer] to
  # @param [Boolean] padding
  # @return [Array]
  def convert_bits(data, from, to, padding: true)
    acc = 0
    bits = 0
    ret = []
    maxv = (1 << to) - 1
    max_acc = (1 << (from + to - 1)) - 1
    data.each do |v|
      return nil if v.negative? || (v >> from) != 0
      acc = ((acc << from) | v) & max_acc
      bits += from
      while bits >= to
        bits -= to
        ret << ((acc >> bits) & maxv)
      end
    end
    ret << ((acc << (to - bits)) & maxv) if padding && bits != 0
    ret
  end

  # Interpolate a set of shares to derive a share at a specific index.
  # @param [Array(Integer)] data A set of shares.
  # Each share is an array of the following data transformed in a bech32 table:
  # threshold + id + index + payload.
  # @param [Integer] x index value.
  def interpolate_at(data, x)
    indices = data.map { |d| d[5] }
    w = bech32_lagrange(indices, x)
    data.first.length.times.map do |i|
      n = 0
      data.length.times { |j| n ^= bech32_mul(w[j], data[j][i]) }
      n
    end
  end

  # Check whether checksum is valid or not.
  # @param [Array(Integer)] data A part as a list of integers representing the characters converted.
  # @return [Boolean]
  def valid_checksum?(data)
    if data.length <= 93
      polymod(data) == MS32_CONST
    elsif data.length >= 96
      long_polymod(data) == MS32_LONG_CONST
    else
      false
    end
  end

  def bech32_lagrange(data, x)
    n = 1
    c = []
    data.each do |i|
      n = bech32_mul(n, i ^ x)
      m = 1
      data.each { |j| m = bech32_mul(m, (i == j ? x : i) ^ j) }
      c << m
    end
    c.map { |i| bech32_mul(n, BECH32_INV[i]) }
  end

  def bech32_mul(a, b)
    result = 0
    5.times do |i|
      result ^= ((b >> i) & 1).zero? ? 0 : a
      a *= 2
      a ^= a >= 32 ? 41 : 0
    end
    result
  end
end
