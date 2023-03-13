# frozen_string_literal: true

module Codex32
  # Codex32 secret class.
  class Secret < Base
    # share index of secret
    INDEX = "s"

    def index
      INDEX
    end

    # Decode payload as secret.
    # @return [String] A secret with hex format.
    def secret
      convert_bits(bech32_to_array(payload), 5, 8, padding: false).pack(
        "C*"
      ).unpack1("H*")
    end

    def share?
      false
    end

    def secret?
      true
    end

    def threshold
      0
    end
  end
end
