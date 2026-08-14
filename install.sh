#!/bin/sh
# Installs the latest feint release binary for your platform.
#
#   curl -fsSL https://raw.githubusercontent.com/immanuwell/feint/main/install.sh | sh
#
# Set FEINT_VERSION to pin a version (e.g. FEINT_VERSION=v0.1.0). Set
# FEINT_INSTALL_DIR to install somewhere other than ~/.local/bin.

set -eu

REPO="immanuwell/feint"
VERSION="${FEINT_VERSION:-latest}"
INSTALL_DIR="${FEINT_INSTALL_DIR:-$HOME/.local/bin}"

os() {
  case "$(uname -s)" in
    Linux) echo "unknown-linux-gnu" ;;
    Darwin) echo "apple-darwin" ;;
    *)
      echo "error: unsupported OS $(uname -s). Build from source instead: see README.md" >&2
      exit 1
      ;;
  esac
}

arch() {
  case "$(uname -m)" in
    x86_64 | amd64) echo "x86_64" ;;
    arm64 | aarch64) echo "aarch64" ;;
    *)
      echo "error: unsupported architecture $(uname -m). Build from source instead: see README.md" >&2
      exit 1
      ;;
  esac
}

target="$(arch)-$(os)"
# aarch64 Linux binaries aren't published yet.
if [ "$target" = "aarch64-unknown-linux-gnu" ]; then
  echo "error: no prebuilt binary for $target yet. Build from source instead: see README.md" >&2
  exit 1
fi

if [ "$VERSION" = "latest" ]; then
  # GitHub's "latest" alias doesn't apply to individual asset URLs, so
  # resolve the actual tag first.
  VERSION="$(curl -fsSL "https://github.com/$REPO/releases/latest" -o /dev/null -w '%{url_effective}' | sed 's#.*/tag/##')"
fi

asset="feint-$VERSION-$target.tar.gz"
url="https://github.com/$REPO/releases/download/$VERSION/$asset"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

echo "Downloading $asset..."
curl -fsSL "$url" -o "$tmp_dir/$asset"

tar xzf "$tmp_dir/$asset" -C "$tmp_dir"
mkdir -p "$INSTALL_DIR"
install -m 755 "$tmp_dir/feint-$VERSION-$target/feint" "$INSTALL_DIR/feint"

echo "Installed feint $VERSION to $INSTALL_DIR/feint"

case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *)
    echo ""
    echo "$INSTALL_DIR is not on your PATH. Add this to your shell profile:"
    echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
    ;;
esac
