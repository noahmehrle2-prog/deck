#!/usr/bin/env bash
# deck installer — drops the `deck` command on your PATH.
# Usage:  curl -fsSL https://raw.githubusercontent.com/noahmehrle2-prog/deck/main/install.sh | bash
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/noahmehrle2-prog/deck/main/deck"

echo "Installing deck…"

# 0. sanity checks
if [ "$(uname)" != "Darwin" ]; then
  echo "deck only works on macOS (it controls Terminal.app via AppleScript)." >&2
  exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "Python 3 is required but not found. Install it (e.g. 'xcode-select --install')." >&2
  exit 1
fi

# 1. choose an install dir on PATH that we can write to
choose_dir() {
  for d in /usr/local/bin "$HOME/.local/bin"; do
    case ":$PATH:" in *":$d:"*) ;; *) continue ;; esac   # must be on PATH
    if [ -d "$d" ] && [ -w "$d" ]; then echo "$d"; return; fi
  done
  # not on PATH or not writable yet — fall back to ~/.local/bin and fix PATH
  mkdir -p "$HOME/.local/bin"
  echo "$HOME/.local/bin"
}
BIN_DIR="$(choose_dir)"

# 2. fetch (or copy, if run from a clone) the script
TARGET="$BIN_DIR/deck"
if [ -f "$(dirname "$0")/deck" ]; then
  cp "$(dirname "$0")/deck" "$TARGET"
else
  curl -fsSL "$REPO_RAW" -o "$TARGET"
fi
chmod +x "$TARGET"
echo "  → installed to $TARGET"

# 3. make sure BIN_DIR is on PATH for future shells
case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *)
    for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
      touch "$rc"
      if ! grep -q "# added by deck installer" "$rc" 2>/dev/null; then
        printf '\n# added by deck installer\nexport PATH="%s:$PATH"\n' "$BIN_DIR" >> "$rc"
      fi
    done
    echo "  → added $BIN_DIR to your PATH (restart your shell or 'source ~/.zshrc')"
    ;;
esac

echo
echo "✓ Done. Try:"
echo "    deck          # list your Terminal windows"
echo "    deck tile     # arrange them into a grid"
echo "    deck follow   # click any window to make it big"
echo
echo "First run may prompt: System Settings → Privacy & Security → Automation → allow Terminal."
