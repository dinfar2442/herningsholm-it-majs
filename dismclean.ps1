<#
.SYNOPSIS
    DISM Deep Clean med Auto-Admin og Progress Bar.
#>

# --- AUTO-ELEVATION TIL ADMIN ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
    $newProcess.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"";
    $newProcess.Verb = "runas";
    [System.Diagnostics.Process]::Start($newProcess);
    exit
}

Clear-Host
$TotalSteps = 4
$CurrentStep = 0

function Update-MyProgress {
    param($Status, $StepName)
    $script:CurrentStep++
    $Percent = ($script:CurrentStep / $TotalSteps) * 100
    Write-Progress -Activity "DISM System Deep Clean" -Status $Status -PercentComplete $Percent -CurrentOperation $StepName
}

# --- START PÅ OPGAVER ---

# Trin 1: Analyse
Update-MyProgress -Status "Trin 1 af $TotalSteps" -StepName "Analyserer Component Store..."
dism.exe /Online /Cleanup-Image /AnalyzeComponentStore

# Trin 2: Component Cleanup
Update-MyProgress -Status "Trin 2 af $TotalSteps" -StepName "Rydder op i komponenter (StartComponentCleanup)..."
dism.exe /Online /Cleanup-Image /StartComponentCleanup

# Trin 3: Deep Clean (ResetBase)
Update-MyProgress -Status "Trin 3 af $TotalSteps" -StepName "Dyb rensning (ResetBase) - Dette kan tage tid..."
dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase

# Trin 4: System File Check
Update-MyProgress -Status "Trin 4 af $TotalSteps" -StepName "Kører SFC Scannow (Verificerer systemfiler)..."
sfc /scannow

# Afslutning
Write-Progress -Activity "DISM System Deep Clean" -Status "Færdig!" -PercentComplete 100
Write-Host "`nOprydning fuldført med succes!" -ForegroundColor Green

Write-Host "`nTryk på en vilkårlig tast for at lukke..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")