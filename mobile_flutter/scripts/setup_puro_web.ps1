# One-time (idempotent) setup: materialize Puro flutter_web_sdk for web builds.
# Safe to run repeatedly; skips work when already fixed.

[CmdletBinding()]
param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot

. (Join-Path $PSScriptRoot 'puro-env.ps1')

if (-not (Test-PuroProject -ProjectRoot $ProjectRoot)) {
    Write-Host 'This project is not configured for Puro (.puro.json / .puro not found, and flutter is not from .puro).'
    Write-Host 'No setup needed.'
    exit 0
}

$flutterRoot = Get-PuroFlutterRoot -ProjectRoot $ProjectRoot
Write-Host "Puro Flutter SDK: $flutterRoot"

$changed = Repair-PuroWebSdk -FlutterRoot $flutterRoot -Force:$Force
if ($changed) {
    Write-Host 'Setup complete. Web builds should now work with Puro.'
}
else {
    Write-Host 'Setup already applied (or flutter_web_sdk is a real directory).'
}

exit 0
