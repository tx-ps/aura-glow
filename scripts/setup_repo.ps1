Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function New-Dir([string]$p){ if(-not (Test-Path $p)){ New-Item -ItemType Directory -Force -Path $p | Out-Null } }
function Write-Utf8NoBom([string]$path,[string]$content){
  $dir = Split-Path -Parent $path
  if($dir){ New-Dir $dir }
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($path, $content, $enc)
}
function Download-Text([string[]]$Urls){
  try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13 } catch {}
  foreach($u in $Urls){
    try {
      $r = Invoke-WebRequest -Uri $u -Method Get -Headers @{ "User-Agent"="AuraGlow-Setup/1.0" }
      if($r.Content -and $r.Content.Length -gt 1000){ return $r.Content }
    } catch { }
  }
  throw "Unable to download content from GNU endpoints."
}

$RepoName = "aura-glow"
$GitHubUser = "crasofuentes-hub"
$Year = (Get-Date -Format yyyy)

Write-Utf8NoBom "NOTICE" @"
Aura Glow — Edge-First Virtual Try-On (On-Device)

Created by: Oscar Fuentes (GitHub: $GitHubUser)

Copyright (c) $Year Oscar Fuentes

This project is licensed under AGPL-3.0-or-later. You must preserve this NOTICE
file in source distributions and, where practicable, in binary distributions.

Attribution requirement (practical):
- Retain this NOTICE and all copyright headers.
- Public references should credit: Oscar Fuentes ($GitHubUser).
- Academic/technical citations should use CITATION.cff.
'@\s*Write-Utf8NoBom "CITATION.cff" @"
cff-version: 1.2.0
message: "If you use this software, please cite it as below."
title: "Aura Glow"
type: software
authors:
  - family-names: "Fuentes"
    given-names: "Oscar"
repository-code: "https://github.com/$GitHubUser/$RepoName"
license: "AGPL-3.0-or-later"
'@\s*Write-Utf8NoBom "docs/LEGAL.md" @"
# LEGAL — AGPL + NOTICE + CITATION (Attribution & Reuse)

## License
This project is licensed under **GNU Affero General Public License v3.0 or later (AGPL-3.0-or-later)**.
See \`LICENSE\` for the full text.

## What you can do
You may use, modify, and redistribute this software (including commercially) under AGPL terms.

## What you must do (AGPL triggers)
AGPL obligations apply when you:
- **Distribute** the software (source or binaries), or
- **Run a modified version as a network service** that users interact with.

In those cases you must:
1. Provide the **Corresponding Source** of the version you distribute/run.
2. Preserve notices and attribution (see below).

## NOTICE (must be preserved)
This repository includes a \`NOTICE\` file.
You must keep it in redistributions and preserve existing copyright headers.

## CITATION (recommended)
For academic/technical citation, use \`CITATION.cff\`.

## Practical attribution guidance
Minimum (required in distributions):
- Include \`LICENSE\` + \`NOTICE\`
- Preserve file headers

Recommended (public references):
- “Aura Glow — Created by Oscar Fuentes (crasofuentes-hub)”
'@\s*Write-Utf8NoBom "docs/COMPLIANCE.md" @"
# COMPLIANCE — Release & Contribution Checklist

## Licensing
- [ ] \`LICENSE\` contains full AGPL-3.0 text (not a stub)
- [ ] \`NOTICE\` present and preserved
- [ ] \`CITATION.cff\` present

## Third-party
- [ ] Dependency licenses reviewed and compatible with AGPL
- [ ] Models/datasets provenance documented

## Privacy (biometrics)
- [ ] No raw frames uploaded by default
- [ ] No sensitive logs (frames/embeddings/masks)

## Security
- [ ] No secrets committed
- [ ] Least-privilege rules for any backend

## Build hygiene
- [ ] CI runs checks
- [ ] Deterministic-enough builds (pinned deps where feasible)
'@\s*Write-Utf8NoBom "README.md" @"
# Aura Glow — Edge-First Virtual Try-On (On-Device) • AGPL-3.0-or-later

Aura Glow is an edge-first virtual try-on architecture (hair color, makeup, keratin sheen, cut preview) optimized for:
- privacy-by-design (no cloud frames),
- predictable performance budgets,
- auditability (legal + compliance docs included).

## Repository guarantees
- \`LICENSE\`: AGPL-3.0-or-later (full text)
- \`NOTICE\`: required attribution preservation
- \`CITATION.cff\`: recommended citation metadata
- \`docs/LEGAL.md\`: AGPL + NOTICE + CITATION guidance
- \`docs/COMPLIANCE.md\`: release checklist

## License & attribution
- License: AGPL-3.0-or-later (see \`LICENSE\`)
- Preserve \`NOTICE\` and existing copyright notices.
'@\s*# Write LICENSE from GNU
$urls = @(
  "https://www.gnu.org/licenses/agpl-3.0.txt",
  "https://www.gnu.org/licenses/agpl.txt"
)
$text = Download-Text -Urls $urls
$text = $text -replace "`r`n","`n" -replace "`r","`n"
if($text.Length -lt 20000){ throw "LICENSE download too short." }
if($text -notmatch "GNU AFFERO GENERAL PUBLIC LICENSE"){ throw "LICENSE header mismatch." }
if(-not $text.EndsWith("`n")){ $text += "`n" }
Write-Utf8NoBom "LICENSE" $text

Write-Utf8NoBom "scripts/verify.ps1" @'
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
param([switch]$Strict)

function Fail([string]$m){ Write-Error $m; exit 1 }

$required = @('LICENSE','NOTICE','CITATION.cff','docs/LEGAL.md','docs/COMPLIANCE.md','README.md')
foreach($f in $required){ if(-not (Test-Path $f)){ Fail "Missing: $f" } }

$lic = Get-Content 'LICENSE' -Raw
if($Strict){
  if($lic.Length -lt 20000){ Fail 'LICENSE too short.' }
  if($lic -notmatch 'GNU AFFERO GENERAL PUBLIC LICENSE'){ Fail 'LICENSE header mismatch.' }
}
Write-Host 'OK'
'@\s*Write-Host "Setup complete."

