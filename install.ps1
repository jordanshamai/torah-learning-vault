# Installs the Torah Learning Vault and opens it in Obsidian (Windows).
# Usage: powershell -ExecutionPolicy Bypass -File install.ps1 [folder]
param([string]$Dest = "$HOME\Documents\Torah Learning Vault")
$ErrorActionPreference = "Stop"
$Repo = "jordanshamai/torah-learning-vault"

if (Test-Path $Dest) { Write-Host "$Dest already exists. Pass another folder."; exit 1 }

Write-Host "Downloading to $Dest"
if (Get-Command git -ErrorAction SilentlyContinue) {
  git clone --quiet "https://github.com/$Repo.git" $Dest
} else { Write-Host "Needs git: install from git-scm.com."; exit 1 }
Remove-Item "$Dest\update.sh" -ErrorAction SilentlyContinue

# Add it to Obsidian's vault list (Obsidian must be closed while we edit it)
$DestFull = (Resolve-Path $Dest).Path
$Cfg = "$env:APPDATA\obsidian\obsidian.json"
Get-Process Obsidian -ErrorAction SilentlyContinue | Stop-Process; Start-Sleep 3
New-Item -ItemType Directory -Force (Split-Path $Cfg) | Out-Null
$o = $null; if (Test-Path $Cfg) { try { $o = Get-Content $Cfg -Raw | ConvertFrom-Json } catch {} }
if (-not $o) { $o = [pscustomobject]@{} }
if (-not $o.vaults) { $o | Add-Member -Force vaults ([pscustomobject]@{}) }
foreach ($v in $o.vaults.PSObject.Properties) { $v.Value.PSObject.Properties.Remove("open") }
$id = -join ((1..16) | ForEach-Object { "0123456789abcdef"[(Get-Random 16)] })
$ts = [DateTimeOffset]::Now.ToUnixTimeMilliseconds()
$o.vaults | Add-Member $id ([pscustomobject]@{ path = $DestFull; ts = $ts; open = $true })
[IO.File]::WriteAllText($Cfg, ($o | ConvertTo-Json -Depth 10 -Compress))

Start-Process ("obsidian://open?path=" + [uri]::EscapeDataString($DestFull))

Write-Host "`nInstalled. In Obsidian:"
Write-Host "  1. Click 'Trust author and enable plugins'."
Write-Host "  2. Settings > Templater: turn on 'Trigger Templater on new file creation'."
