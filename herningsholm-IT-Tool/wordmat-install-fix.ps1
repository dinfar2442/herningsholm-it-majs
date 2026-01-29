# --- AUTO-ADMIN (Sørger for rettigheder til installation) ---
param([switch]$Ghost)

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    if ($Ghost) {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`" -Ghost" -Verb RunAs -WindowStyle Hidden
    } else {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    }
    Exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Find WordMat fil lokalt
$scriptDir = Split-Path -Parent $PSCommandPath
$localWordMatFile = Get-ChildItem -Path $scriptDir -Filter "WordMat*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1

# Opret GUI vindue
$form = New-Object System.Windows.Forms.Form
$form.Text = 'WordMat Manager - Herningsholm'
$form.Size = New-Object System.Drawing.Size(500, 550)
$form.StartPosition = 'CenterScreen'
$form.BackColor = [System.Drawing.Color]::FromArgb(15, 15, 15)
$form.ForeColor = [System.Drawing.Color]::White

# Hvis ghost mode, start minimeret
if ($Ghost) {
    $form.WindowState = 'Minimized'
    $form.ShowInTaskbar = $false
}

# Logo panel
$logoPnl = New-Object System.Windows.Forms.Panel
$logoPnl.Location = New-Object System.Drawing.Point(0, 0)
$logoPnl.Size = New-Object System.Drawing.Size(500, 80)
$logoPnl.BackColor = [System.Drawing.Color]::FromArgb(26, 26, 26)
$logoPnl.BorderStyle = 'FixedSingle'
$form.Controls.Add($logoPnl)

# Logo tekst (Herningsholm)
$logoLbl = New-Object System.Windows.Forms.Label
$logoLbl.Text = 'HERNINGSHOLM'
$logoLbl.Location = New-Object System.Drawing.Point(20, 15)
$logoLbl.Size = New-Object System.Drawing.Size(300, 30)
$logoLbl.Font = New-Object System.Drawing.Font('Arial', 18, [System.Drawing.FontStyle]::Bold)
$logoLbl.ForeColor = [System.Drawing.Color]::FromArgb(255, 215, 0)
$logoPnl.Controls.Add($logoLbl)

# Undertekst
$subLbl = New-Object System.Windows.Forms.Label
$subLbl.Text = 'Erhvervsskole & Gymnasier'
$subLbl.Location = New-Object System.Drawing.Point(20, 45)
$subLbl.Size = New-Object System.Drawing.Size(300, 20)
$subLbl.Font = New-Object System.Drawing.Font('Arial', 10)
$subLbl.ForeColor = [System.Drawing.Color]::FromArgb(170, 170, 170)
$logoPnl.Controls.Add($subLbl)

# Status label
$statusLbl = New-Object System.Windows.Forms.Label
$statusLbl.Location = New-Object System.Drawing.Point(20, 95)
$statusLbl.Size = New-Object System.Drawing.Size(450, 30)
$statusLbl.Text = if ($localWordMatFile) { "✓ Lokal WordMat fil fundet: $($localWordMatFile.Name)" } else { "Klar til installation af WordMat" }
$statusLbl.Font = New-Object System.Drawing.Font('Arial', 10)
$statusLbl.ForeColor = if ($localWordMatFile) { [System.Drawing.Color]::FromArgb(100, 200, 100) } else { [System.Drawing.Color]::FromArgb(100, 200, 100) }
$form.Controls.Add($statusLbl)

# Info tekstboks
$infoPnl = New-Object System.Windows.Forms.GroupBox
$infoPnl.Location = New-Object System.Drawing.Point(20, 130)
$infoPnl.Size = New-Object System.Drawing.Size(450, 130)
$infoPnl.Text = 'Information'
$infoPnl.ForeColor = [System.Drawing.Color]::FromArgb(200, 200, 200)
$form.Controls.Add($infoPnl)

$infoTxt = New-Object System.Windows.Forms.TextBox
$infoTxt.Location = New-Object System.Drawing.Point(10, 20)
$infoTxt.Size = New-Object System.Drawing.Size(420, 100)
$infoTxt.Multiline = $true
$infoTxt.ReadOnly = $true
$infoTxt.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$infoTxt.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)

$infoText = "WordMat - Matematik plugin til Microsoft Word`n`n"
if ($localWordMatFile) {
    $infoText += "✓ LOKAL FIL FUNDET`nFil: $($localWordMatFile.Name)`nKlar til installation fra lokal fil`n`n"
}
$infoText += "Installation kræver:`n• Microsoft Word (2016+)`n• Administrator-rettigheder"
$infoTxt.Text = $infoText
$infoPnl.Controls.Add($infoTxt)

# Progress bar
$progress = New-Object System.Windows.Forms.ProgressBar
$progress.Location = New-Object System.Drawing.Point(20, 275)
$progress.Size = New-Object System.Drawing.Size(450, 25)
$progress.Minimum = 0
$progress.Maximum = 100
$progress.Value = 0
$form.Controls.Add($progress)

# Log tekstboks
$logLbl = New-Object System.Windows.Forms.Label
$logLbl.Location = New-Object System.Drawing.Point(20, 305)
$logLbl.Size = New-Object System.Drawing.Size(100, 20)
$logLbl.Text = 'Log:'
$logLbl.ForeColor = [System.Drawing.Color]::FromArgb(200, 200, 200)
$form.Controls.Add($logLbl)

$logTxt = New-Object System.Windows.Forms.TextBox
$logTxt.Location = New-Object System.Drawing.Point(20, 325)
$logTxt.Size = New-Object System.Drawing.Size(450, 80)
$logTxt.Multiline = $true
$logTxt.ScrollBars = 'Vertical'
$logTxt.ReadOnly = $true
$logTxt.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
$logTxt.ForeColor = [System.Drawing.Color]::FromArgb(100, 255, 100)
$form.Controls.Add($logTxt)

# Buttons
$installBtn = New-Object System.Windows.Forms.Button
$installBtn.Location = New-Object System.Drawing.Point(20, 415)
$installBtn.Size = New-Object System.Drawing.Size(140, 35)
$installBtn.Text = if ($localWordMatFile) { 'Installer fra Lokal Fil' } else { 'Installer WordMat' }
$installBtn.BackColor = [System.Drawing.Color]::FromArgb(46, 125, 50)
$installBtn.ForeColor = [System.Drawing.Color]::White
$installBtn.Font = New-Object System.Drawing.Font('Arial', 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($installBtn)

# Uninstall knap
$uninstallBtn = New-Object System.Windows.Forms.Button
$uninstallBtn.Location = New-Object System.Drawing.Point(170, 415)
$uninstallBtn.Size = New-Object System.Drawing.Size(140, 35)
$uninstallBtn.Text = 'Afinstaller WordMat'
$uninstallBtn.BackColor = [System.Drawing.Color]::FromArgb(179, 28, 28)
$uninstallBtn.ForeColor = [System.Drawing.Color]::White
$uninstallBtn.Font = New-Object System.Drawing.Font('Arial', 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($uninstallBtn)

$closeBtn = New-Object System.Windows.Forms.Button
$closeBtn.Location = New-Object System.Drawing.Point(320, 415)
$closeBtn.Size = New-Object System.Drawing.Size(150, 35)
$closeBtn.Text = 'Luk'
$closeBtn.BackColor = [System.Drawing.Color]::FromArgb(68, 68, 68)
$closeBtn.ForeColor = [System.Drawing.Color]::White
$closeBtn.Font = New-Object System.Drawing.Font('Arial', 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($closeBtn)

function Update-Log {
    param([string]$Message, [string]$Type = 'Info')
    $timestamp = Get-Date -Format 'HH:mm:ss'
    switch ($Type) {
        'Success' { $logTxt.ForeColor = [System.Drawing.Color]::FromArgb(100, 255, 100); $prefix = '[✓]' }
        'Error'   { $logTxt.ForeColor = [System.Drawing.Color]::FromArgb(255, 100, 100); $prefix = '[✗]' }
        'Warning' { $logTxt.ForeColor = [System.Drawing.Color]::FromArgb(255, 200, 100); $prefix = '[!]' }
        default   { $logTxt.ForeColor = [System.Drawing.Color]::FromArgb(100, 255, 100); $prefix = '[*]' }
    }
    $logTxt.AppendText("$timestamp $prefix $Message`r`n")
    [System.Windows.Forms.Application]::DoEvents()
}

function Update-Status {
    param([string]$Message, [int]$Percent)
    $statusLbl.Text = $Message
    $progress.Value = [Math]::Min($Percent, 100)
    [System.Windows.Forms.Application]::DoEvents()
}

$installBtn.Add_Click({
    $installBtn.Enabled = $false
    $uninstallBtn.Enabled = $false
    $closeBtn.Enabled = $false
    $logTxt.Clear()
    $progress.Value = 0

    Update-Log 'Starter WordMat installation...'
    Update-Status 'Kontrollerer system...' 10

    # Tjek om Word er åben
    $WordProc = Get-Process -Name "WINWORD" -ErrorAction SilentlyContinue
    if ($WordProc) {
        Update-Log 'Microsoft Word er åben - lukker nu...' 'Warning'
        try {
            Stop-Process -Name "WINWORD" -Force
            Start-Sleep -Seconds 2
            Update-Log 'Word blev lukket' 'Success'
        } catch {
            Update-Log "Kunne ikke lukke Word: $_" 'Error'
        }
    } else {
        Update-Log 'Microsoft Word ikke åben - fortsætter' 'Success'
    }

    # Hvis lokal fil findes, brug den
    if ($localWordMatFile) {
        Update-Status 'Bruger lokal WordMat fil...' 30
        Update-Log "Bruger: $($localWordMatFile.FullName)"
        
        try {
            Update-Log 'Starter installatør (lydløs installation)...'
            $proc = Start-Process -FilePath $localWordMatFile.FullName -ArgumentList '/S', '/VERYSILENT' -Wait -PassThru -ErrorAction SilentlyContinue
            
            if ($null -eq $proc -or $proc.ExitCode -ne 0) {
                Update-Log 'Kører normal installatør...'
                $proc = Start-Process -FilePath $localWordMatFile.FullName -Wait -PassThru
            }
            
            Update-Log 'WordMat installation påbegyndt' 'Success'
            Update-Status 'Afslutter...' 90
            Start-Sleep -Seconds 2
            
            Update-Log 'Installation færdig! Genstart Word for at bruge WordMat' 'Success'
            Update-Status 'Færdig - WordMat er installeret' 100
            [System.Windows.Forms.MessageBox]::Show('WordMat installation er færdig!`n`nGenstart Microsoft Word for at bruge det.', 'Succes', 'OK', 'Information')
        } catch {
            Update-Log "Fejl under installation: $_" 'Error'
            Update-Status 'Installation fejlede' 0
        }
    } else {
        # Fallback til download hvis lokal fil ikke findes
        Update-Log 'Ingen lokal WordMat fil fundet - downloader...' 'Warning'
        Update-Status 'Downloader WordMat...' 30

        $downloadUrls = @(
            @{ Url = 'https://eduap.com/download/1744/'; Name = 'eduap.com (direkte)'; MinSize = 5 },
            @{ Url = 'https://github.com/Mikael-Skov/WordMat/releases/latest'; Name = 'GitHub (fallback)'; MinSize = 1 }
        )

        $tempPath = Join-Path $env:TEMP 'WordMatInstaller.exe'
        $downloaded = $false

        foreach ($source in $downloadUrls) {
            try {
                Update-Log "Downloader fra: $($source.Name)"
                
                $webClient = New-Object System.Net.WebClient
                $webClient.Proxy = [System.Net.GlobalProxySelection]::GetEmptyWebProxy()
                
                if ($source.Name -like '*GitHub*') {
                    Update-Log 'Prøver at hente direkte GitHub-link...'
                    $githubPage = Invoke-WebRequest -Uri 'https://github.com/Mikael-Skov/WordMat/releases/latest' -UseBasicParsing
                    $downloadLink = $githubPage.Links | Where-Object { $_.href -match 'WordMat.*\.exe' } | Select-Object -First 1 -ExpandProperty href
                    
                    if ($downloadLink) {
                        if (!$downloadLink.StartsWith('http')) {
                            $downloadLink = 'https://github.com' + $downloadLink
                        }
                        Update-Log "GitHub link fundet"
                        $webClient.DownloadFile($downloadLink, $tempPath)
                    } else {
                        throw "Kunne ikke finde .exe fil på GitHub"
                    }
                } else {
                    $webClient.DownloadFile($source.Url, $tempPath)
                }
                
                if (Test-Path $tempPath) {
                    $fileSizeMB = (Get-Item $tempPath).Length / 1MB
                    if ($fileSizeMB -ge $source.MinSize) {
                        Update-Log "Downloaded: $([math]::Round($fileSizeMB, 2)) MB ✓" 'Success'
                        $downloaded = $true
                        break
                    } else {
                        Update-Log "Filen var for lille ($fileSizeMB MB)" 'Warning'
                        Remove-Item $tempPath -Force -ErrorAction SilentlyContinue
                    }
                }
            } catch {
                Update-Log "Fejl: $($_.Exception.Message)" 'Warning'
                continue
            }
        }

        if ($downloaded) {
            Update-Status 'Installerer WordMat...' 60
            Update-Log 'Starter installatør...'
            
            try {
                $proc = Start-Process -FilePath $tempPath -ArgumentList '/S', '/VERYSILENT' -Wait -PassThru -ErrorAction SilentlyContinue
                
                if ($null -eq $proc -or $proc.ExitCode -ne 0) {
                    Update-Log 'Kører normal installatør...'
                    $proc = Start-Process -FilePath $tempPath -Wait -PassThru
                }
                
                Update-Log 'Installation påbegyndt' 'Success'
                Start-Sleep -Seconds 2
                
                Remove-Item $tempPath -Force -ErrorAction SilentlyContinue
                
                Update-Log 'Installation færdig!' 'Success'
                Update-Status 'Færdig' 100
                [System.Windows.Forms.MessageBox]::Show('WordMat installation er færdig!`n`nGenstart Microsoft Word.', 'Succes', 'OK', 'Information')
            } catch {
                Update-Log "Fejl under installation: $_" 'Error'
            }
        } else {
            Update-Log 'Kunne ikke hente WordMat - prøver Winget' 'Error'
            if (Get-Command winget -ErrorAction SilentlyContinue) {
                try {
                    Update-Log 'Installerer via Winget...'
                    $proc = Start-Process -FilePath winget -ArgumentList 'install', '--id', 'Eduap.WordMat', '--silent' -NoNewWindow -Wait -PassThru
                    if ($proc.ExitCode -eq 0) {
                        Update-Log 'Installeret via Winget!' 'Success'
                    }
                } catch {
                    Update-Log "Winget fejl: $_" 'Error'
                }
            }
        }
    }

    $installBtn.Enabled = $true
    $uninstallBtn.Enabled = $true
    $closeBtn.Enabled = $true
})

$uninstallBtn.Add_Click({
    $uninstallBtn.Enabled = $false
    $installBtn.Enabled = $false
    $closeBtn.Enabled = $false
    $logTxt.Clear()
    $progress.Value = 0

    Update-Log 'Starter WordMat afinstallation...'
    Update-Status 'Søger efter WordMat installation...' 20

    # Søg i Registry efter WordMat
    $uninstallKeys = @(
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall',
        'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
    )

    $found = $false
    foreach ($key in $uninstallKeys) {
        $items = Get-ChildItem -Path $key -ErrorAction SilentlyContinue
        foreach ($item in $items) {
            $displayName = $item.GetValue('DisplayName')
            if ($displayName -like '*WordMat*') {
                $found = $true
                Update-Log "Fundet: $displayName"
                
                try {
                    $uninstallString = $item.GetValue('UninstallString')
                    if ($uninstallString) {
                        Update-Log "Kører afinstallation..."
                        Update-Status 'Afinstallerer...' 60
                        
                        # Prøv normal uninstall først
                        if ($uninstallString -like '*.exe*') {
                            Start-Process -FilePath 'cmd.exe' -ArgumentList '/c', $uninstallString -NoNewWindow -Wait
                        } else {
                            Invoke-Expression $uninstallString
                        }
                        
                        Update-Log "Afinstallation færdig!" 'Success'
                        Update-Status 'Afinstallation færdig' 100
                        [System.Windows.Forms.MessageBox]::Show('WordMat er afinstalleret!', 'Succes', 'OK', 'Information')
                    }
                } catch {
                    Update-Log "Fejl ved afinstallation: $_" 'Error'
                }
                break
            }
        }
        if ($found) { break }
    }

    if (!$found) {
        Update-Log "WordMat blev ikke fundet på systemet" 'Warning'
        Update-Status 'WordMat ikke installeret' 100
        [System.Windows.Forms.MessageBox]::Show('WordMat blev ikke fundet på systemet.', 'Information', 'OK', 'Information')
    }

    $uninstallBtn.Enabled = $true
    $installBtn.Enabled = $true
    $closeBtn.Enabled = $true
})

$closeBtn.Add_Click({ $form.Close() })

[System.Windows.Forms.Application]::EnableVisualStyles()
$form.ShowDialog() | Out-Null
