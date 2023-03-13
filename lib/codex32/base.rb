# frozen_string_literal: true

module Codex32
  # Codex32 abstract class.
  class Base
    include Codex32
    attr_reader :id, :payload

    def initialize(id, payload)
      @id = id
      @payload = payload
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

    def index
      raise NotImplementedError
    end

    def share?
      raise NotImplementedError
    end

    def secret?
      raise NotImplementedError
    end

    def threshold
      raise NotImplementedError
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
