# frozen_string_literal: true

RSpec.describe Codex32 do
  describe "Test Vector1" do
    it do
      secret =
        described_class.parse(
          "ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxx4nzvca9cmczlw"
        )
      expect(secret).to be_a(Codex32::Secret)
      expect(secret.id).to eq("test")
      expect(secret.secret?).to be true
      expect(secret.share?).to be false
      expect(secret.checksum).to eq("4nzvca9cmczlw")
      expect(secret.index).to eq("s")
      expect(secret.secret).to eq("318c6318c6318c6318c6318c6318c631")
    end
  end
end
