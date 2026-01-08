# Contributing

Thanks for your interest in contributing.

## Ground rules
- Keep changes minimal and well-scoped.
- Prefer deterministic, reproducible behavior.
- All scripts must be PowerShell compatible on Windows.
- All builds must be CI-friendly.

## Required checks
Before opening a PR, run:
- pwsh -NoProfile -ExecutionPolicy Bypass -File scripts\verify.ps1 -Strict
- (optional) scripts\doctor.ps1
- scripts\demo.ps1 (with MSVC environment)

## Attribution
By contributing, you agree your contribution is licensed under AGPL-3.0-or-later and you preserve NOTICE + CITATION requirements.
