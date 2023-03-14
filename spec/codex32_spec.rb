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

  describe "Test Vector 5" do
    it do
      # rubocop:disable Layout/LineLength
      secret =
        described_class.parse(
          "MS100C8VSM32ZXFGUHPCHTLUPZRY9X8GF2TVDW0S3JN54KHCE6MUA7LQPZYGSFJD6AN074RXVCEMLH8WU3TK925ACDEFGHJKLMNPQRSTUVWXY06FHPV80UNDVARHRAK"
        )
      expect(secret.data).to eq(
        "dc5423251cb87175ff8110c8531d0952d8d73e1194e95b5f19d6f9df7c01111104c9baecdfea8cccc677fb9ddc8aec5553b86e528bcadfdcc201c17c638c47e9"
      )
      # rubocop:enable Layout/LineLength
    end
  end

  describe "Invalid Test Vector" do
    context "when incorrect checksum" do
      it do
        # rubocop:disable Layout/LineLength
        targets = %w[
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxxxmazxdp4sx5q
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxxq70v3y94304t
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxxxg4m2aylswft
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxxxght46zhq0x4
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxxl8jqrdhvqkc4
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxxxepvjkxnc9wu
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxxxcakee32853f
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxx4nknfgj6u67a
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx3n5n5gyweuvq3
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxjqllfg3pf3fv4
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxn0c66xf2j0kjn
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxh73jw8glx8fpk
          ms10testsyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyymjljntsznrq3mv
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0p99y5vsmt84t
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxj4r3qrklkmtsz
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx8kp950klmrlsm
        ]
        # rubocop:enable Layout/LineLength
        targets.each do |t|
          expect { described_class.parse(t) }.to raise_error(
            Codex32::Errors::InvalidChecksum
          )
        end
      end
    end

    context "when invalid length checksum" do
      it do
        # rubocop:disable Layout/LineLength
        invalid_checksums = %w[
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxx372x3mkc5m8sa0q
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxx82zvxjc02rt0vnl
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxyc57nnpvpcnhggt
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxf9e2wxsusjgmlws
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxdpu39xl2lkru3g4
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxqelpaxwk0jz4e
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxncdn5kjxq7grt
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxhq00y08vc7gjg
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxdckj6wn4z7r3p
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxjl32g6u3wgg8j
        ]
        invalid_lengths = %w[
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxx8ty2gx0n6rnaa
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxus2h522w7u6vq
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxpsx45vtf9n2uk5h
          ms12testxxxxxxxxxxxxxxxxxxxxxxxxxtn5jkk94ayuqc
          ms12testxxxxxxxxxxxxxxxxxxxxxxxxxxvspjygypsrrkl
          ms12testxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxcpkhsxdrp05hymv
        ]
        # rubocop:enable Layout/LineLength
        invalid_checksums.each do |t|
          expect { described_class.parse(t) }.to raise_error(
            Codex32::Errors::InvalidChecksum
          )
        end
        invalid_lengths.each do |t|
          expect { described_class.parse(t) }.to raise_error(
            Codex32::Errors::InvalidLength
          )
        end
      end
    end

    context "when invalid improper length" do
      it do
        # rubocop:disable Layout/LineLength
        targets = %w[
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxxc8d60uanwukvn
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxwaaaq5yk0vfeg
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxu9cfgk0a4muxaam
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxzu2kdncfaew65ae
          ms12testxxxxxxxxxxxxxxxxxxxxxxxxxxxxqmufxffdkzfac
          ms12testxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxmgr4z3c807ml7
          ms12testxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx4q3s54t8ejm8dfj
          ms12testxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxr0wzwtfvgh3th2
        ]
        # rubocop:enable Layout/LineLength
        targets.each do |t|
          expect { described_class.parse(t) }.to raise_error(
            Codex32::Errors::IncompleteGroup
          )
        end
      end
    end

    context 'when "0" threshold with a non-"s" index' do
      it do
        target = "ms10testxxxxxxxxxxxxxxxxxxxxxxxxxxxx3wq9mzgrwag9"
        expect { described_class.parse(target) }.to raise_error(
          Codex32::Errors::InvalidShareIndex
        )
      end
    end

    context "when a threshold that is not a digit" do
      it do
        target = "ms1testxxxxxxxxxxxxxxxxxxxxxxxxxxxxs9lz3we7s9wh4"
        expect { described_class.parse(target) }.to raise_error(
          Codex32::Errors::InvalidThreshold
        )
      end
    end

    context 'when do not begin with the required "ms" or "MS" prefix and/or are missing the "1" separator' do
      it do
        targets = %w[
          0testsxxxxxxxxxxxxxxxxxxxxxxxxxx4nzvca9cmczlw
          10testsxxxxxxxxxxxxxxxxxxxxxxxxxx4nzvca9cmczlw
          mstestsxxxxxxxxxxxxxxxxxxxxxxxxxx4nzvca9cmczlw
          m10testsxxxxxxxxxxxxxxxxxxxxxxxxxx4nzvca9cmczlw
          s10testsxxxxxxxxxxxxxxxxxxxxxxxxxx4nzvca9cmczlw
          0testsxxxxxxxxxxxxxxxxxxxxxxxxxx79f08v7ucwmh5
          10testsxxxxxxxxxxxxxxxxxxxxxxxxxx79f08v7ucwmh5
          m10testsxxxxxxxxxxxxxxxxxxxxxxxxxxwcwavvypcxrvm
          s10testsxxxxxxxxxxxxxxxxxxxxxxxxxx7kf489ztk44gz
        ]
        targets.each do |t|
          expect { described_class.parse(t) }.to raise_error(
            Codex32::Errors::InvalidHRP
          )
        end
      end
    end

    context "when invalid case" do
      it do
        targets = %w[
          MS10testsxxxxxxxxxxxxxxxxxxxxxxxxxx4nzvca9cmczlw
          ms10TESTsxxxxxxxxxxxxxxxxxxxxxxxxxx4nzvca9cmczlw
          ms10testSxxxxxxxxxxxxxxxxxxxxxxxxxx4nzvca9cmczlw
          ms10testsXXXXXXXXXXXXXXXXXXXXXXXXXX4nzvca9cmczlw
          ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxx4NZVCA9CMCZLW
        ]
        targets.each do |t|
          expect { described_class.parse(t) }.to raise_error(
            Codex32::Errors::InvalidCase
          )
        end
      end
    end
  end
end
