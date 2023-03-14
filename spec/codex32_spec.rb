# frozen_string_literal: true

RSpec.describe Codex32 do
  describe "Test Vector 1" do
    it do
      secret =
        described_class.parse(
          "ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxx4nzvca9cmczlw"
        )
      expect(secret).to be_a(Codex32::Share)
      expect(secret.id).to eq("test")
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
        described_class.generate_share([share1, share2], Codex32::SECRET_INDEX)
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

  describe "Test Vector 3" do
    it do
      shares = [
        described_class.parse(
          "ms13cashsllhdmn9m42vcsamx24zrxgs3qqjzqud4m0d6nln"
        ),
        described_class.parse(
          "ms13casha320zyxwvutsrqpnmlkjhgfedca2a8d0zehn8a0t"
        ),
        described_class.parse(
          "ms13cashcacdefghjklmnpqrstuvwxyz023949xq35my48dr"
        )
      ]
      gen_shares = [
        described_class.generate_share(shares, "d"),
        described_class.generate_share(shares, "e"),
        described_class.generate_share(shares, "f")
      ]
      expect(gen_shares[0].to_s).to eq(
        "ms13cashd0wsedstcdcts64cd7wvy4m90lm28w4ffupqs7rm"
      )
      expect(gen_shares[1].to_s).to eq(
        "ms13casheekgpemxzshcrmqhaydlp6yhms3ws7320xyxsar9"
      )
      expect(gen_shares[2].to_s).to eq(
        "ms13cashf8jh6sdrkpyrsp5ut94pj8ktehhw2hfvyrj48704"
      )
      test_shares = shares[1..] + gen_shares
      test_shares.combination(3) do |c|
        secret = described_class.generate_share(c, Codex32::SECRET_INDEX)
        expect(secret.to_s).to eq(
          "ms13cashsllhdmn9m42vcsamx24zrxgs3qqjzqud4m0d6nln"
        )
      end
    end
  end

  describe "Test Vector 4" do
    it do
      seed = "ffeeddccbbaa99887766554433221100ffeeddccbbaa99887766554433221100"
      secret =
        described_class.from(
          seed: seed,
          id: "leet",
          threshold: 0,
          share_index: Codex32::SECRET_INDEX
        )
      expect(secret.to_s).to eq(
        "ms10leetsllhdmn9m42vcsamx24zrxgs3qrl7ahwvhw4fnzrhve25gvezzyqqtum9pgv99ycma"
      )
      alt_encodings = %w[
        ms10leetsllhdmn9m42vcsamx24zrxgs3qrl7ahwvhw4fnzrhve25gvezzyqqtum9pgv99ycma
        ms10leetsllhdmn9m42vcsamx24zrxgs3qrl7ahwvhw4fnzrhve25gvezzyqpj82dp34u6lqtd
        ms10leetsllhdmn9m42vcsamx24zrxgs3qrl7ahwvhw4fnzrhve25gvezzyqzsrs4pnh7jmpj5
        ms10leetsllhdmn9m42vcsamx24zrxgs3qrl7ahwvhw4fnzrhve25gvezzyqrfcpap2w8dqezy
        ms10leetsllhdmn9m42vcsamx24zrxgs3qrl7ahwvhw4fnzrhve25gvezzyqy5tdvphn6znrf0
        ms10leetsllhdmn9m42vcsamx24zrxgs3qrl7ahwvhw4fnzrhve25gvezzyq9dsuypw2ragmel
        ms10leetsllhdmn9m42vcsamx24zrxgs3qrl7ahwvhw4fnzrhve25gvezzyqx05xupvgp4v6qx
        ms10leetsllhdmn9m42vcsamx24zrxgs3qrl7ahwvhw4fnzrhve25gvezzyq8k0h5p43c2hzsk
        ms10leetsllhdmn9m42vcsamx24zrxgs3qrl7ahwvhw4fnzrhve25gvezzyqgum7hplmjtr8ks
        ms10leetsllhdmn9m42vcsamx24zrxgs3qrl7ahwvhw4fnzrhve25gvezzyqf9q0lpxzt5clxq
        ms10leetsllhdmn9m42vcsamx24zrxgs3qrl7ahwvhw4fnzrhve25gvezzyq28y48pyqfuu7le
        ms10leetsllhdmn9m42vcsamx24zrxgs3qrl7ahwvhw4fnzrhve25gvezzyqt7ly0paesr8x0f
        ms10leetsllhdmn9m42vcsamx24zrxgs3qrl7ahwvhw4fnzrhve25gvezzyqvrvg7pqydv5uyz
        ms10leetsllhdmn9m42vcsamx24zrxgs3qrl7ahwvhw4fnzrhve25gvezzyqd6hekpea5n0y5j
        ms10leetsllhdmn9m42vcsamx24zrxgs3qrl7ahwvhw4fnzrhve25gvezzyqwcnrwpmlkmt9dt
        ms10leetsllhdmn9m42vcsamx24zrxgs3qrl7ahwvhw4fnzrhve25gvezzyq0pgjxpzx0ysaam
      ]
      alt_encodings.each do |s|
        secret = described_class.parse(s)
        expect(secret.data).to eq(seed)
      end
    end
  end
end
