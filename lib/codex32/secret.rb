# frozen_string_literal: true

module Codex32
  # Codex32 secret class.
  class Secret < Base
    # share index of secret
    INDEX = "s"

    def index
      INDEX
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
