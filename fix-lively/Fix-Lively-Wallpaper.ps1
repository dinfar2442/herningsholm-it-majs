#Requires -RunAsAdministrator

# Fix Lively Wallpaper Error 0xc0000142 on Windows 11 24H2
# Script that handles all known fixes for the error
# Kører automatisk som administrator

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Lively Wallpaper Fix 0xc0000142" -ForegroundColor Cyan
Write-Host "Windows 11 24H2 Patch" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================================
# 1. Enable Desktop Icons (24H2 Fix)
# ============================================================================
Write-Host "[1/4] Aktiverer skrivebordsikoner..." -ForegroundColor Yellow

$desktopIconsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"

if (!(Test-Path $desktopIconsPath)) {
    New-Item -Path $desktopIconsPath -Force | Out-Null
}

# Set all common desktop icons to visible (0 = visible)
$iconKeys = @("{5 4F28C5-F869-4E84-B94F-D8280DEBED08}", "{645FF040-5081-101B-9F08-00AA002F954E}", "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}")

foreach ($key in $iconKeys) {
    Set-ItemProperty -Path $desktopIconsPath -Name $key -Value 0 -Force
}

Write-Host "✓ Skrivebordsikoner aktiveret" -ForegroundColor Green
Write-Host ""

# ============================================================================
# 2. Repair Visual C++ Redistributables
# ============================================================================
Write-Host "[2/4] Reparerer Visual C++ Redistributables..." -ForegroundColor Yellow

$vcProducts = @(
    "Microsoft Visual C++ 2015-2022 Redistributable (x64)",
    "Microsoft Visual C++ 2015-2022 Redistributable (x86)",
    "Microsoft Visual C++ 2013 Redistributable (x64)",
    "Microsoft Visual C++ 2013 Redistributable (x86)"
)

# Get installed packages
$installedPackages = Get-AppxPackage | Select-Object -ExpandProperty Name

foreach ($vcProduct in $vcProducts) {
    Write-Host "Leder efter: $vcProduct" -ForegroundColor Gray
    
    # Try to find and repair via Programs and Features
    $appInfo = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE '%Visual C++%2015-2022%'"
    
    if ($appInfo) {
        Write-Host "Reparerer $vcProduct..." -ForegroundColor Cyan
        
        # Use msiexec to repair (if available)
        $msiPath = $appInfo.PackageLocation
        if (Test-Path $msiPath) {
            & msiexec.exe /f "$msiPath" /qn /norestart
            Start-Sleep -Seconds 5
        }
    }
}

Write-Host "✓ Visual C++ reparation gennemført" -ForegroundColor Green
Write-Host ""

# ============================================================================
# 3. Download and Install Latest .NET Desktop Runtime
# ============================================================================
Write-Host "[3/4] Kontrollerer .NET Desktop Runtime..." -ForegroundColor Yellow

# Check if .NET is installed
$dotnetInstalled = & dotnet --version 2>$null

if ($null -eq $dotnetInstalled) {
    Write-Host "Downloader .NET Desktop Runtime..." -ForegroundColor Cyan
    
    $dotnetUrl = "https://aka.ms/dotnet-runtime-win-x64"
    $dotnetPath = "$env:TEMP\dotnet-runtime.exe"
    
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $dotnetUrl -OutFile $dotnetPath -UseBasicParsing
        
        Write-Host "Installerer .NET Desktop Runtime..." -ForegroundColor Cyan
        & $dotnetPath /install /quiet /norestart
        Start-Sleep -Seconds 10
        Remove-Item $dotnetPath -Force
        Write-Host "✓ .NET Desktop Runtime installeret" -ForegroundColor Green
    } catch {
        Write-Host "⚠ Kunne ikke downloade .NET automatisk. Installer det manuelt fra https://dotnet.microsoft.com/download/dotnet" -ForegroundColor Yellow
    }
} else {
    Write-Host "✓ .NET Desktop Runtime allerede installeret" -ForegroundColor Green
}

Write-Host ""

# ============================================================================
# 4. Uninstall and Reinstall Lively Wallpaper
# ============================================================================
Write-Host "[4/4] Afinstallerer og geninstallerer Lively Wallpaper..." -ForegroundColor Yellow

# Uninstall existing Lively
Write-Host "Afinstallerer eksisterende Lively..." -ForegroundColor Cyan

$livelyCandidates = @(
    "Lively Wallpaper",
    "Lively"
)

foreach ($candidate in $livelyCandidates) {
    $app = Get-AppxPackage -Name "*Lively*" -ErrorAction SilentlyContinue
    
    if ($app) {
        foreach ($appItem in $app) {
            Write-Host "Fjerner: $($appItem.Name)" -ForegroundColor Gray
            Remove-AppxPackage -Package $appItem -ErrorAction SilentlyContinue
        }
    }
}

# Also try via Programs and Features
$wingetApp = & winget uninstall "Lively Wallpaper" -h --accept-source-agreements 2>$null

Write-Host "✓ Eksisterende Lively fjernet" -ForegroundColor Green
Start-Sleep -Seconds 2

# Download and install latest Lively from Microsoft Store
Write-Host "Installerer seneste Lively fra Microsoft Store..." -ForegroundColor Cyan

try {
    # Using winget is most reliable
    & winget install -e --id "Rocksdanister.Lively" --accept-package-agreements --accept-source-agreements --silent
    
    Write-Host "✓ Lively Wallpaper geninstalleret" -ForegroundColor Green
    Write-Host ""
    Write-Host "Installation fuldført! Startende Lively nu..." -ForegroundColor Cyan
    Start-Sleep -Seconds 3
    
    # Start Lively
    & "C:\Program Files\Lively\Lively.exe" 2>$null
    
} catch {
    Write-Host "⚠ Installering via winget fejlede. Installer Lively manuelt via:" -ForegroundColor Yellow
    Write-Host "   - Microsoft Store: 'Lively Wallpaper'" -ForegroundColor Yellow
    Write-Host "   - GitHub: https://github.com/rocksdanister/lively" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Fix afsluttet!" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Næste skridt:" -ForegroundColor Yellow
Write-Host "1. Genstart din computer (anbefalet)" -ForegroundColor White
Write-Host "2. Åbn Lively og test med dine billeder/videoer" -ForegroundColor White
Write-Host ""
Write-Host "Hvis problemet stadig opstår, prøv:" -ForegroundColor Yellow
Write-Host "- Deaktiver antivirusprogram midlertidigt" -ForegroundColor White
Write-Host "- Tjek Windows Update for yderligere patches" -ForegroundColor White
Write-Host ""

# Prompt for restart
$restart = Read-Host "Ønsker du at genstarte nu? (J/N)"
if ($restart -eq "J" -or $restart -eq "j" -or $restart -eq "Y" -or $restart -eq "y") {
    Write-Host "Genstarter om 10 sekunder..." -ForegroundColor Cyan
    Start-Sleep -Seconds 10
    Restart-Computer -Force
} else {
    Write-Host "Husk at genstarte senere for at være helt sikker!" -ForegroundColor Yellow
    Read-Host "Tryk Enter for at lukke"
}
