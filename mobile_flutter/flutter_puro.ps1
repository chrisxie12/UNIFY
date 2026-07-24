# Puro-aware Flutter wrapper for UNIFY (Windows).
# Fixes Dart web compiler failures when Puro junctions break SDK path resolution.
#
# Usage:
#   .\flutter_puro.ps1 run -d chrome
#   .\flutter_puro.ps1 build web

# Do not use [CmdletBinding()] — PowerShell binds `-d` to the common -Debug
# parameter, which breaks `flutter run -d chrome`.
$ErrorActionPreference = 'Stop'
$ProjectRoot = $PSScriptRoot

. (Join-Path $ProjectRoot 'scripts\puro-env.ps1')

$flutterExe = $null
if (Test-PuroProject -ProjectRoot $ProjectRoot) {
    $flutterRoot = Initialize-PuroFlutter -ProjectRoot $ProjectRoot
    if ($flutterRoot) {
        $flutterExe = Join-Path $flutterRoot 'bin\flutter.bat'
    }
}

if (-not $flutterExe -or -not (Test-Path $flutterExe)) {
    $flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
    if ($flutterCmd) {
        $flutterExe = $flutterCmd.Source
    }
    else {
        throw 'Could not find flutter executable.'
    }
}

& $flutterExe @args
exit $LASTEXITCODE
