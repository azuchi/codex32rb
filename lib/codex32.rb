# frozen_string_literal: true

require_relative "codex32/version"
require_relative "codex32/base"
require_relative "codex32/secret"
require_relative "codex32/share"

# Codex32 library.
module Codex32
  class Error < StandardError
  end

  HRP = "ms"

  SEPARATOR = "1"

  # stree-ignore
  CHARSET = %w[q p z r y 9 x 8 g f 2 t v d w 0 s 3 j n 5 4 k h c e 6 m u a 7 l].freeze

  MS32_CONST = 0x10ce0795c2fd1e62a

  module_function

  # Parse codex32 string.
  # @param [String] codex32 Codex32 string
  # @return [Codex32::Share | Codex32::Secret]
  # @raise [ArgumentError]
  def parse(codex32)
    hrp, remain = codex32.split(SEPARATOR)
    if remain.nil?
      raise ArgumentError, "codex32 string dose not include separator."
    end
    raise ArgumentError, "Invalid hrp specified." unless hrp.downcase == HRP

    remain = remain.chars
    threshold = remain[0].to_i
    id = remain[1..4].join
    share_index = remain[5]
    payload_end = remain.length - 13
    payload = remain[6...payload_end].join
    checksum = remain[-13..].join
    result =
      if share_index == Secret::INDEX
        if threshold != 0
          raise ArgumentError, "The threshold value of the secret must be zero."
        end
        Secret.new(id, payload)
      else
        Share.new(id, threshold, share_index, payload)
      end
    unless checksum == result.checksum
      raise ArgumentError, "The checksum is incorrect."
    end
    result
  end

  # Convert bech32 string to array.
  # @param [String] bech32_str bech32 string.
  # @return [Array(Integer)] array of bech32 data.
  # @raise ArgumentError
  def bech32_to_array(bech32_str)
    bech32_str.each_char.map do |c|
      i = CHARSET.index(c)
      # raise ArgumentError, "#{c} is an invalid bech32 character." if i.nil?
      i
    end
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
end
