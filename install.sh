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
if ! command -v git >/dev/null; then
  echo "Needs git. On a Mac run: xcode-select --install"
  exit 1
fi
git clone --quiet "https://github.com/$REPO.git" "$DEST" </dev/null
rm -f "$DEST/update.sh"
DEST="$(cd "$DEST" && pwd)"

# Add it to Obsidian's vault list (Obsidian must be closed while we edit it)
if [ "$(uname)" = Darwin ]; then
  CFG="$HOME/Library/Application Support/obsidian"
  if pgrep -xq Obsidian; then echo "Closing Obsidian..."; osascript -e 'quit app "Obsidian"'; sleep 3; fi
else
  CFG="${XDG_CONFIG_HOME:-$HOME/.config}/obsidian"
  pkill -x obsidian 2>/dev/null && sleep 3
fi
mkdir -p "$CFG"
JS='const [cfg, dest] = ARGS;
let o = {}; try { o = JSON.parse(READ(cfg)); } catch (e) {}
o.vaults = o.vaults || {};
for (const v of Object.values(o.vaults)) delete v.open;
let id = ""; for (let i = 0; i < 16; i++) id += "0123456789abcdef"[Math.floor(Math.random() * 16)];
o.vaults[id] = { path: dest, ts: Date.now(), open: true };
WRITE(cfg, JSON.stringify(o));'
if [ "$(uname)" = Darwin ]; then
  osascript -l JavaScript - "$CFG/obsidian.json" "$DEST" >/dev/null <<JXA
function run(ARGS) {
  const READ = p => \$.NSString.stringWithContentsOfFileEncodingError(p, \$.NSUTF8StringEncoding, null).js;
  const WRITE = (p, t) => \$(t).writeToFileAtomicallyEncodingError(p, true, \$.NSUTF8StringEncoding, null);
  $JS
}
JXA
else
  python3 - "$CFG/obsidian.json" "$DEST" <<'PY'
import json, sys, time, secrets
cfg, dest = sys.argv[1:]
try: o = json.load(open(cfg))
except Exception: o = {}
v = o.setdefault("vaults", {})
for x in v.values(): x.pop("open", None)
v[secrets.token_hex(8)] = {"path": dest, "ts": int(time.time() * 1000), "open": True}
json.dump(o, open(cfg, "w"))
PY
fi

# Open in Obsidian (this also adds it to the vault list)
enc() { local s="$1" o="" c i; for ((i=0; i<${#s}; i++)); do c="${s:i:1}"
  case "$c" in [a-zA-Z0-9/._~-]) o+="$c";; *) o+=$(printf '%%%02X' "'$c");; esac; done; echo "$o"; }
URL="obsidian://open?path=$(enc "$DEST")"
if [ -z "$NO_OPEN" ]; then
  if command -v open >/dev/null; then open -a Obsidian; sleep 2; open "$URL"; else xdg-open "$URL"; fi
fi

cat <<MSG

Installed. In Obsidian:
  1. Click "Trust author and enable plugins".
  2. Settings > Templater: turn on "Trigger Templater on new file creation".
MSG
