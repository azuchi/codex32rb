# frozen_string_literal: true

module Codex32
  # Codex32 share class.
  class Share < Base
    attr_reader :index, :threshold

    # @param [String] id Identifier of this share.
    # @param [Integer] threshold Threshold.
    # @param [String] index Share index.
    # @param [String] payload Share payload.
    def initialize(id, threshold, index, payload)
      super(id, payload)
      unless CHARSET.include?(index.downcase)
        raise ArgumentError, "Invalid index character specified."
      end
      if index.downcase == Secret::INDEX
        raise ArgumentError, "s is secret index."
      end
      unless threshold.zero? || (threshold > 1 && threshold < 10)
        raise ArgumentError,
              "The threshold value must be 0 or a number between 2 and 9."
      end

      @index = index
      @threshold = threshold
    end

    def share?
      true
    end

    def secret?
      false
    end
  end
end
