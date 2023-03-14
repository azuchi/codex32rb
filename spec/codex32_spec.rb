# frozen_string_literal: true

RSpec.describe Codex32 do
  describe "Test Vector 1" do
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
      expect(secret.data).to eq("318c6318c6318c6318c6318c6318c631")
    end
  end

  describe "Test Vector 2" do
    it do
      share1 =
        described_class.parse(
          "MS12NAMEA320ZYXWVUTSRQPNMLKJHGFEDCAXRPP870HKKQRM"
        )
      share2 =
        described_class.parse(
          "MS12NAMECACDEFGHJKLMNPQRSTUVWXYZ023FTR2GDZMPY6PN"
        )
      secret =
        described_class.generate_share([share1, share2], Codex32::Secret::INDEX)
      expect(secret.data).to eq("d1808e096b35b209ca12132b264662a5")
      expect(secret.to_s).to eq(
        "MS12NAMES6XQGUZTTXKEQNJSJZV4JV3NZ5K3KWGSPHUH6EVW".downcase
      )
      share3 = described_class.generate_share([share1, share2], "d")
      expect(share3.to_s).to eq(
        "MS12NAMEDLL4F8JLH4E5VDVULDLFXU2JHDNLSM97XVENRXEG".downcase
      )
    end
  end
end
