# Installs the Torah Learning Vault and opens it in Obsidian (Windows).
# Usage: powershell -ExecutionPolicy Bypass -File install.ps1 [folder]
param([string]$Dest = "$HOME\Documents\Torah Learning Vault")
$ErrorActionPreference = "Stop"
$Repo = "jordanshamai/torah-learning-vault"

if (Test-Path $Dest) { Write-Host "$Dest already exists. Pass another folder."; exit 1 }

Write-Host "Downloading to $Dest"
if ((Get-Command gh -ErrorAction SilentlyContinue) -and (gh auth status 2>$null; $?)) {
  gh repo clone $Repo $Dest -- --quiet
} elseif (Get-Command git -ErrorAction SilentlyContinue) {
  git clone --quiet "https://github.com/$Repo.git" $Dest
} else { Write-Host "Needs git (git-scm.com) or the GitHub CLI (cli.github.com)."; exit 1 }
Remove-Item "$Dest\update.sh" -ErrorAction SilentlyContinue

Start-Process ("obsidian://open?path=" + [uri]::EscapeDataString((Resolve-Path $Dest).Path))

Write-Host "`nInstalled. In Obsidian:"
Write-Host "  1. Click 'Trust author and enable plugins'."
Write-Host "  2. Settings > Templater: turn on 'Trigger Templater on new file creation'."
