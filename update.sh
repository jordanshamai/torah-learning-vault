#!/bin/zsh
# Copies the note system (no personal notes) from your vault into this repo.
# Run: ./update.sh   then commit and push.
set -e
SRC="/Users/jordan/Obsidian/Machon Yaakov/Machon"
DST="${0:A:h}"
cd "$SRC"

files=(
  Home.md Index.base
  Chumash/Chumash.base Lectures/Lectures.base
  Hebrew/Hebrew.base "Loshon Hakodesh/Loshon Hakodesh.base"
  Torah/Torah.base Mefarshim/Rashi.md
  .obsidian/{app,appearance,backlink,community-plugins,core-plugins,graph,hotkeys,types}.json
)
for f in "${files[@]}"; do mkdir -p "$DST/${f:h}"; cp "$f" "$DST/$f"; done

# Sefer and parasha notes (not pasuk notes)
for s in Bereishis Shemos Vayikra Bamidbar Devarim; do
  mkdir -p "$DST/Torah/$s"
  cp "Torah/$s/$s.md" "$DST/Torah/$s/"
  rsync -a --delete "Torah/$s/Parshiyos/" "$DST/Torah/$s/Parshiyos/"
done

rsync -a --delete --exclude .DS_Store Templates/ "$DST/Templates/"
rsync -a --delete --exclude .DS_Store .obsidian/plugins/ "$DST/.obsidian/plugins/"

# Empty folders the templates expect
for d in Chumash Lectures Hebrew/Words "Loshon Hakodesh/Lessons" "Loshon Hakodesh/Words" Concepts; do
  mkdir -p "$DST/$d" && touch "$DST/$d/.gitkeep"
done
echo "Updated $DST"
