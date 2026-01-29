# Fix Update handler
$filePath = "c:\Users\MAJS\OneDrive - Herningsholm Erhvervsskole\mine skripts\herningsholm-it-majs\herningsholm-IT-Tool\herningsholm-it-tool.ps1"
$content = Get-Content $filePath -Raw
$lines = ($content -split "`r?`n")

# Part 1: Lines 1-884 (indices 0-883)
$part1 = $lines[0..883] -join "`n"

# New Update handler
$newHandler = @'
$BtnUpdate.Add_Click({
    Run-Task {
        $out = "════════ OPDATERINGER ════════`n`n"
        $cs = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue
        $vendor = $cs.Manufacturer
        $model = $cs.Model
        $out += "Maskine: $vendor - $model`n`n"

        # Windows Update
        $out += "[1/3] Windows Update...`n"
        try {
            $wuService = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
            if ($wuService) { Start-Service -Name wuauserv -ErrorAction SilentlyContinue }
            $out += "  - Starter scan...`n"
            try { & usoclient StartScan 2>&1 | Out-Null } catch { }
            Start-Sleep -Seconds 2
            $out += "  - Installerer tilgængelige opdateringer...`n"
            try { & usoclient StartInstall 2>&1 | Out-Null } catch { }
            $out += "  ✓ Windows Update trigget`n`n"
        } catch {
            $out += "  ⚠ Windows Update fejl: $_`n`n"
        }

        # Winget updates
        $out += "[2/3] App opdateringer (winget)...`n"
        try {
            if (Get-Command winget -ErrorAction SilentlyContinue) {
                $out += "  - Finder opdateringer...`n"
                & winget upgrade --all --accept-package-agreements --accept-source-agreements --silent 2>&1 | Out-Null
                $out += "  ✓ App opdateringer kørt`n`n"
            } else {
                $out += "  ⚠ winget ikke tilgængelig`n`n"
            }
        } catch {
            $out += "  ⚠ App update fejl: $_`n`n"
        }

        # Cleanup
        $out += "[3/3] Rydder op...`n"
        try {
            Remove-Item 'C:\\Windows\\Temp\\*' -Recurse -Force -ErrorAction SilentlyContinue
            ipconfig /flushdns 2>&1 | Out-Null
            $out += "  ✓ Temp + DNS ryddet`n`n"
        } catch {
            $out += "  ⚠ Cleanup fejl: $_`n"
        }

        $out += "════════ DONE ════════`nOpdateringer kørt."
        Write-Output $out
    }
})
'@

# Part 2: Lines 1073+ (index 1072+)
$part2 = $lines[1072..($lines.Count-1)] -join "`n"

# Combine
$newContent = $part1 + "`n" + $newHandler + "`n" + $part2

# Save
Set-Content $filePath $newContent -Encoding UTF8 -NoNewline

Write-Host "Fixed!"
