# Torah Learning Vault

An Obsidian vault for yeshiva notes. Chumash lectures link to each pasuk and Rashi, and each pasuk note collects the Hebrew text, the Metsudah translation, Rashi, and everything you've written on it.

## Setup
You need Obsidian installed.

**Mac:** open Terminal and run
```
curl -fsSL https://raw.githubusercontent.com/jordanshamai/torah-learning-vault/main/install.sh | bash
```

**Windows:** download `install.ps1`, then in PowerShell run
```
powershell -ExecutionPolicy Bypass -File $HOME\Downloads\install.ps1
```

The vault goes in `Documents/Torah Learning Vault` and opens in Obsidian. Then:
1. Click **Trust author and enable plugins**.
2. **Settings → Templater:** turn on **Trigger Templater on new file creation**. This setting is per device, so it can't be included here.

**Manual:** Code → Download ZIP, unzip, then in Obsidian **Open folder as vault**, and do steps 1 and 2.

## Use
- **New Chumash lecture:** right-click `Chumash` → New note. Pick the parasha, the pasuk, and which Rashi.
- **Another Rashi:** put the cursor above *Additional Notes*, press **Option+E** (Alt+E), pick **Add Rashi**.
- **Pasuk notes** are created in `Torah/<Sefer>/` with text from Sefaria. Their *From Lectures* section shows your notes on that pasuk.
- **Home** links to every section. Each folder has a base (table) to sort and filter its notes.

## Folders
| Folder | What goes there |
|---|---|
| Chumash | One note per Chumash lecture |
| Lectures | General lectures |
| Hebrew, Loshon Hakodesh | Lessons and vocab (one note per word) |
| Torah | Sefer, parasha, and pasuk notes |
| Mefarshim, Concepts | Hub notes that collect everything linking to them |
| Templates | Templates and scripts |

Plugins included: Templater, Dataview, Advanced Tables.
