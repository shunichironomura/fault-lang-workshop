#!/usr/bin/env bash
set -euo pipefail

version="${FAULT_VERSION:-v1.0.0}"
install_dir="${INSTALL_DIR:-$HOME/.local/bin}"

case "$(uname -s)" in
  Darwin|Linux) os=$(uname -s) ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

case "$(uname -m)" in
  arm64|aarch64) arch=arm64 ;;
  x86_64|amd64) arch=x86_64 ;;
  i386|i686) arch=i386 ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

if ! command -v z3 >/dev/null 2>&1; then
  case "$os" in
    Darwin)
      if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew is required to install Z3: https://brew.sh" >&2
        exit 1
      fi
      brew install z3
      ;;
    Linux)
      if ! command -v apt-get >/dev/null 2>&1; then
        echo "Install Z3 first: https://github.com/Z3Prover/z3/releases" >&2
        exit 1
      fi
      sudo apt-get update
      sudo apt-get install -y z3
      ;;
  esac
fi

asset="fault_${os}_${arch}.tar.gz"
base="https://github.com/Fault-lang/Fault/releases/download/$version"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

curl -fsSL "$base/$asset" -o "$tmp/$asset"
curl -fsSL "$base/checksums.txt" -o "$tmp/checksums.txt"

expected=$(awk -v asset="$asset" '$2 == asset { print $1 }' "$tmp/checksums.txt")
case "$os" in
  Darwin) actual=$(shasum -a 256 "$tmp/$asset" | awk '{ print $1 }') ;;
  Linux) actual=$(sha256sum "$tmp/$asset" | awk '{ print $1 }') ;;
esac

if [[ -z "$expected" || "$actual" != "$expected" ]]; then
  echo "Checksum verification failed for $asset" >&2
  exit 1
fi

tar -xzf "$tmp/$asset" -C "$tmp"
mkdir -p "$install_dir"
install -m 755 "$tmp/fault" "$install_dir/fault"
"$install_dir/fault" config --solvercmd z3 --solverarg=-in

printf 'Installed %s\n' "$("$install_dir/fault" --version)"
printf 'Z3: %s\n' "$(z3 --version)"

case ":$PATH:" in
  *":$install_dir:"*) ;;
  *)
    printf '\nAdd Fault to PATH for this shell:\n'
    printf '  export PATH="%s:$PATH"\n' "$install_dir"
    ;;
esac
