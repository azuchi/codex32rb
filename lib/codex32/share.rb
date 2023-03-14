# frozen_string_literal: true

module Codex32
  # Codex32 share class.
  class Share
    include Codex32
    attr_reader :id, :payload, :index, :threshold

    # @param [String] id Identifier of this share.
    # @param [Integer] threshold Threshold.
    # @param [String] index Share index.
    # @param [String] payload Share payload.
    def initialize(id, threshold, index, payload)
      unless CHARSET.include?(index.downcase)
        raise ArgumentError, "Invalid index character specified."
      end
      unless threshold.zero? || (threshold > 1 && threshold < 10)
        raise ArgumentError,
              "The threshold value must be 0 or a number between 2 and 9."
      end
      @id = id.downcase
      @payload = payload.downcase
      @index = index.downcase
      @threshold = threshold
    end

    # Calculate checksum.
    # @return [String]
    def checksum
      data = bech32_to_array(content)
      poly_value = polymod(data + [0] * 13) ^ MS32_CONST
      result = 13.times.map { |i| (poly_value >> 5 * (12 - i)) & 31 }
      array_to_bech32(result)
    end

    # Return decoded payload.
    # @return [String] Decoded payload.
    def data
      convert_bits(bech32_to_array(payload), 5, 8, padding: false).pack(
        "C*"
      ).unpack1("H*")
    end

    # Return bech32 string.
    # @return [String]
    def to_s
      HRP + SEPARATOR + content + checksum
    end

    private

    def content
      threshold.to_s + id + index + payload
    end
  end
end
