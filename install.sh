#!/bin/bash
# Installs the Torah Learning Vault and opens it in Obsidian (macOS or Linux).
# Usage: ./install.sh [folder]   default: ~/Documents/Torah Learning Vault
set -e
REPO="jordanshamai/torah-learning-vault"
DEST="${1:-$HOME/Documents/Torah Learning Vault}"

if [ -e "$DEST" ]; then
  echo "$DEST already exists. Pick another folder: ./install.sh \"/path/to/folder\""
  exit 1
fi

echo "Downloading to $DEST"
if command -v gh >/dev/null && gh auth status >/dev/null 2>&1; then
  gh repo clone "$REPO" "$DEST" -- --quiet
elif command -v git >/dev/null; then
  git clone --quiet "https://github.com/$REPO.git" "$DEST"
else
  echo "Needs git or the GitHub CLI (gh). On a Mac run: xcode-select --install"
  exit 1
fi
rm -f "$DEST/update.sh"

# Open in Obsidian (this also adds it to the vault list)
enc() { local s="$1" o="" c i; for ((i=0; i<${#s}; i++)); do c="${s:i:1}"
  case "$c" in [a-zA-Z0-9/._~-]) o+="$c";; *) o+=$(printf '%%%02X' "'$c");; esac; done; echo "$o"; }
URL="obsidian://open?path=$(enc "$DEST")"
if [ -z "$NO_OPEN" ]; then
  if command -v open >/dev/null; then open "$URL"; else xdg-open "$URL"; fi
fi

cat <<MSG

Installed. In Obsidian:
  1. Click "Trust author and enable plugins".
  2. Settings > Templater: turn on "Trigger Templater on new file creation".
MSG
