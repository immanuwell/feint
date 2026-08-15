# Homebrew formula template for feint.
#
# This is not live yet — it needs a real release to fill in the sha256
# checksums below. See packaging/homebrew/README.md for the full setup
# process (creating the tap repo, computing checksums, publishing).
class Feint < Formula
  desc "Deterministic, Postgres-native synthetic test data"
  homepage "https://github.com/immanuwell/feint"
  version "0.2.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/immanuwell/feint/releases/download/0.2.0/feint-0.2.0-aarch64-apple-darwin.tar.gz"
      sha256 "REPLACE_WITH_REAL_SHA256"
    end
    on_intel do
      url "https://github.com/immanuwell/feint/releases/download/0.2.0/feint-0.2.0-x86_64-apple-darwin.tar.gz"
      sha256 "REPLACE_WITH_REAL_SHA256"
    end
  end

  on_linux do
    url "https://github.com/immanuwell/feint/releases/download/0.2.0/feint-0.2.0-x86_64-unknown-linux-gnu.tar.gz"
    sha256 "REPLACE_WITH_REAL_SHA256"
  end

  def install
    bin.install "feint"
  end

  test do
    assert_match "feint", shell_output("#{bin}/feint --version")
  end
end
