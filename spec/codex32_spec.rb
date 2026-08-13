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

  describe "#generate_share" do
    let(:name_shares) do
      %w[
        MS12NAMEA320ZYXWVUTSRQPNMLKJHGFEDCAXRPP870HKKQRM
        MS12NAMECACDEFGHJKLMNPQRSTUVWXYZ023FTR2GDZMPY6PN
      ].map { |s| described_class.parse(s) }
    end
    let(:cash_shares) do
      %w[
        ms13cashsllhdmn9m42vcsamx24zrxgs3qqjzqud4m0d6nln
        ms13casha320zyxwvutsrqpnmlkjhgfedca2a8d0zehn8a0t
        ms13cashcacdefghjklmnpqrstuvwxyz023949xq35my48dr
      ].map { |s| described_class.parse(s) }
    end

    context "when the requested index collides with an existing share" do
      it "raises DuplicateShareIndex instead of returning an all-zero share" do
        error = Codex32::Errors::DuplicateShareIndex
        # The index of the first share, of a later share, and an upper case one.
        %w[a c A].each do |i|
          expect { described_class.generate_share(name_shares, i) }.to(
            raise_error(error)
          )
        end
        # Recovering the secret while the secret share itself is supplied.
        expect { described_class.generate_share(cash_shares, "s") }.to(
          raise_error(error)
        )
        # A fresh index still works.
        expect(described_class.generate_share(name_shares, "d").to_s).to eq(
          "MS12NAMEDLL4F8JLH4E5VDVULDLFXU2JHDNLSM97XVENRXEG".downcase
        )
      end
    end

    context "when the identifiers do not match" do
      it "raises a rescuable Codex32 error" do
        shares = [name_shares.first, cash_shares.first]
        expect { described_class.generate_share(shares, "d") }.to raise_error(
          Codex32::Errors::IdentifierMismatch
        )
        expect { described_class.generate_share(shares, "d") }.to raise_error(
          Codex32::Errors::Error
        )
      end
    end

    context "when fewer shares than the threshold are given" do
      it "raises InsufficientShares even if the first share has threshold 0" do
        zero = Codex32::Share.new("cash", 0, "s", cash_shares[1].payload)
        shares = [zero, cash_shares[2]]
        expect { described_class.generate_share(shares, "d") }.to raise_error(
          Codex32::Errors::InsufficientShares
        )
      end
    end

    context "when payload lengths differ" do
      it "raises PayloadLengthMismatch regardless of the share order" do
        error = Codex32::Errors::PayloadLengthMismatch
        short = Codex32::Share.new("cash", 2, "a", "q" * 26)
        long = Codex32::Share.new("cash", 2, "c", "p" * 52)
        expect { described_class.generate_share([short, long], "d") }.to(
          raise_error(error)
        )
        expect { described_class.generate_share([long, short], "d") }.to(
          raise_error(error)
        )
      end
    end

    context "when shares is empty" do
      it do
        expect { described_class.generate_share([], "d") }.to raise_error(
          ArgumentError
        )
      end
    end
  end

  describe "#parse with a trailing separator" do
    it "rejects data appended after another separator" do
      valid = "ms10testsxxxxxxxxxxxxxxxxxxxxxxxxxx4nzvca9cmczlw"
      expect { described_class.parse("#{valid}1deadbeef") }.to raise_error(
        Codex32::Errors::InvalidHRP
      )
      # Padding a too-short data part up to the minimum overall length.
      padded = "ms10tests40xsggfh7z73p7l8a1xxxxxxxxxxxxxxxxxxxxx"
      expect { described_class.parse(padded) }.to raise_error(
        Codex32::Errors::InvalidHRP
      )
    end
  end

  describe "#from" do
    let(:seed) { "ff" * 16 }

    def build(seed, id: "test", index: Codex32::SECRET_INDEX)
      described_class.from(seed: seed, id: id, share_index: index, threshold: 0)
    end

    context "when the seed is not a valid master seed" do
      it "raises InvalidSeed" do
        # Non hexadecimal, an odd length, and out of the 128..512 bit range.
        ["z" * 32, "3" * 31, "", "abcd", "ab" * 128].each do |s|
          expect { build(s) }.to raise_error(Codex32::Errors::InvalidSeed)
        end
      end
    end

    context "when the identifier contains a non bech32 character" do
      it do
        expect { build(seed, id: "b1io") }.to raise_error(
          Codex32::Errors::InvalidBech32Character
        )
      end
    end

    context "when the share index is upper case" do
      it "is accepted and normalized" do
        share = build(seed, id: "TEST", index: "S")
        expect(share.index).to eq("s")
        expect(described_class.parse(share.to_s).data).to eq(seed)
      end
    end
  end

  describe "#split" do
    let(:seed) { "ffeeddccbbaa99887766554433221100" }

    def split(indexes, threshold: 3, seed: "ffeeddccbbaa99887766554433221100")
      described_class.split(
        seed: seed,
        id: "test",
        threshold: threshold,
        share_indexes: indexes
      )
    end

    it "creates shares which recover the seed with any threshold subset" do
      shares = split(%w[a c d e f])
      expect(shares.map(&:index)).to eq(%w[a c d e f])
      expect(shares.map(&:threshold).uniq).to eq([3])
      shares.combination(3) do |c|
        secret = described_class.generate_share(c, Codex32::SECRET_INDEX)
        expect(secret.data).to eq(seed)
      end
      # Every share is a valid codex32 string.
      shares.each do |share|
        expect(described_class.parse(share.to_s).payload).to eq(share.payload)
      end
    end

    it "supports a 512 bit seed" do
      long = "ab" * 64
      shares = split(%w[a c], threshold: 2, seed: long)
      expect(shares.first.to_s.length).to eq(127)
      secret = described_class.generate_share(shares, Codex32::SECRET_INDEX)
      expect(secret.data).to eq(long)
    end

    it "uses fresh randomness for each call" do
      first = split(%w[a c], threshold: 2).map(&:to_s)
      second = split(%w[a c], threshold: 2).map(&:to_s)
      expect(first).not_to eq(second)
    end

    context "when the arguments are invalid" do
      it do
        [0, 1, 10, "3"].each do |t|
          expect { split(%w[a c d], threshold: t) }.to raise_error(
            Codex32::Errors::InvalidThreshold
          )
        end
        # Fewer shares than the threshold.
        expect { split(%w[a c]) }.to raise_error(
          Codex32::Errors::InsufficientShares
        )
        # The secret index can not be used as a share index.
        expect { split(%w[a c s]) }.to raise_error(
          Codex32::Errors::InvalidShareIndex
        )
        expect { split(%w[a c c]) }.to raise_error(ArgumentError)
        expect { split(%w[a c b]) }.to raise_error(
          Codex32::Errors::InvalidBech32Character
        )
        expect { split(%w[a c d], seed: "zz") }.to raise_error(
          Codex32::Errors::InvalidSeed
        )
      end
    end
  end
end
