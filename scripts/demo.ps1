Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail([string]$m){ Write-Error $m; exit 1 }

$root  = (Resolve-Path ".").Path
$build = Join-Path $root "build\demo"

New-Item -ItemType Directory -Force $build | Out-Null

cmake -S $root -B $build -G "Visual Studio 17 2022" -A x64 -DAURAGLOW_BUILD_DEMO=ON
if($LASTEXITCODE -ne 0){ Fail "CMake configure failed." }

cmake --build $build --config Release
if($LASTEXITCODE -ne 0){ Fail "CMake build failed." }

# Ruta esperada por VS multi-config (lo que te mostró MSBuild)
$exe1 = Join-Path $build "apps\demo\Release\auraglow_demo.exe"

# Fallback: buscar el exe en cualquier subcarpeta de Release
$exe2 = Get-ChildItem -Path $build -Recurse -File -Filter "auraglow_demo.exe" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -match "\\Release\\" } |
        Select-Object -First 1 -ExpandProperty FullName

$exe = $null
if(Test-Path $exe1){ $exe = $exe1 }
elseif($exe2){ $exe = $exe2 }

if(-not $exe){ Fail "Demo executable not found under build folder. Tried: $exe1" }

Push-Location (Split-Path -Parent $exe)
& $exe
Pop-Location
