# frozen_string_literal: true
module Codex32
  module Errors
    class Error < StandardError
    end

    class InvalidChecksum < Error
    end

    class InvalidLength < Error
    end

    class IncompleteGroup < Error
    end

    class InvalidBech32Character < Error
    end

    class InvalidThreshold < Error
    end

    class InvalidHRP < Error
    end

    class SeparatorNotFound < Error
    end

    class InvalidIdentifier < Error
    end

    class ThresholdMismatch < Error
    end

    class InsufficientShares < Error
    end

    class DuplicateShareIndex < Error
    end

    class IdentifierMismatch < Error
    end

    class InvalidShareIndex < Error
    end

    class InvalidCase < Error
    end
  end
end
