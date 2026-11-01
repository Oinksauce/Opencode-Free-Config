#!/usr/bin/env bash
# Set up OpenCode with the free-team config on macOS or Linux. Safe to rerun.
# Links config/ into the OpenCode config folder, so `git pull` updates it.
# Test somewhere else first: XDG_CONFIG_HOME=~/.config-freeteam ./install.sh
set -euo pipefail
REPO="$(cd "$(dirname "$0")" && pwd)"
TARGET="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
STAMP="$(date +%Y%m%d-%H%M%S)"

if ! command -v opencode >/dev/null && [ ! -x "$HOME/.opencode/bin/opencode" ]; then
  echo "Installing OpenCode..."
  curl -fsSL https://opencode.ai/install | bash
fi

mkdir -p "$TARGET"
# Sibling names that would also be read and could override ours.
for f in opencode.json opencode.jsonc tui.json tui.jsonc oh-my-opencode-slim.json oh-my-opencode-slim.jsonc; do
  p="$TARGET/$f"
  if [ -e "$p" ] || [ -L "$p" ]; then
    [ "$(readlink "$p" 2>/dev/null)" = "$REPO/config/$f" ] && continue
    mv "$p" "$p.bak-$STAMP" && echo "Backed up $p"
  fi
done
for src in "$REPO"/config/*; do
  ln -sfn "$src" "$TARGET/$(basename "$src")"
done
echo "Linked free-team config into $TARGET"

echo
echo "Active preset: free (no keys needed). To use more providers, add keys with"
echo "  opencode auth login        (NVIDIA, OpenRouter, ...)"
echo "then pick a matching preset in $TARGET/oh-my-opencode-slim.jsonc or with /preset in OpenCode."
echo "Check everything works: $(dirname "$0")/test.sh"
