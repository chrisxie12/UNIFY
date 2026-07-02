@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0flutter_puro.ps1" %*
exit /B %ERRORLEVEL%
