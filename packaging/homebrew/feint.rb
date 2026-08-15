class Feint < Formula
  desc "Deterministic, Postgres-native synthetic test data"
  homepage "https://ewry.net/feint/"
  version "0.2.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/immanuwell/feint/releases/download/0.2.0/feint-0.2.0-aarch64-apple-darwin.tar.gz"
      sha256 "9ed464f4edf7b0b08ca056f499e6c31428949330f353df8173ec6a33a6926ff6"
    end
    on_intel do
      odie "feint does not have an Intel Mac (x86_64-apple-darwin) build yet. " \
           "See https://github.com/immanuwell/feint/issues for status, or build from source."
    end
  end

  on_linux do
    url "https://github.com/immanuwell/feint/releases/download/0.2.0/feint-0.2.0-x86_64-unknown-linux-gnu.tar.gz"
    sha256 "3c01f285ce4ff917b1ac00de8bc8dfda6aae88a7e99cb14956ec3bb0b9e909e6"
  end

  def install
    bin.install "feint"
  end

  test do
    assert_match "feint", shell_output("#{bin}/feint --version")
  end
end
