@echo off
cls
powershell -Command "Set-ExecutionPolicy Restricted -Scope CurrentUser -Force; Set-ExecutionPolicy Restricted -Scope LocalMachine -Force -ErrorAction SilentlyContinue; $n = Get-ExecutionPolicy; if ($n -eq 'Restricted') { Write-Host '--- STATUS: LAAST (SIKKERHED OK) ---' -ForegroundColor Green } else { Write-Host '--- ADVARSEL: IKKE HELT LAAST ---' -ForegroundColor Red }"
echo.
echo Aktuel status:
powershell -Command "Get-ExecutionPolicy -List"
pause