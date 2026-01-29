@echo off
cls
powershell -Command "$p = Get-ExecutionPolicy; Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force; $n = Get-ExecutionPolicy; if ($n -eq 'Unrestricted') { Write-Host '--- STATUS: UNLOCKED (KLAR TIL KAGE) ---' -ForegroundColor Green } else { Write-Host '--- FEJL: STADIG LAAST ---' -ForegroundColor Red; Write-Host 'PROEV AT HOEJREKLIKKE OG KOER SOM ADMIN' -ForegroundColor Yellow }"
echo.
echo Aktuel status:
powershell -Command "Get-ExecutionPolicy -List"
pause