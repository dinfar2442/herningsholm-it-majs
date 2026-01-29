# --- AUTO-ADMIN (Kør altid som administrator) ---
param([switch]$Ghost)

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    if ($Ghost) {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`" -Ghost" -Verb RunAs -WindowStyle Hidden
    } else {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    }
    Exit
}

# Hvis -Ghost parameter er sat, start GUI minimeret/skjult
if ($Ghost) {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
} else {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
}

# Skjul PowerShell-konsollen for renere oplevelse
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@
[Win32]::ShowWindow([Win32]::GetConsoleWindow(), 0) | Out-Null

# GUI elements (restyled, resizable)
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Bloatware & AV Removal - Herningsholm'
$form.Size = New-Object System.Drawing.Size(800,540)
$form.MinimumSize = New-Object System.Drawing.Size(700,460)
$form.StartPosition = 'CenterScreen'
$form.TopMost = $false
$form.BackColor = [System.Drawing.ColorTranslator]::FromHtml('#0B1422')
$form.FormBorderStyle = 'Sizable'
$form.MaximizeBox = $true
$form.Font = New-Object System.Drawing.Font('Segoe UI', 9)

# Header bar (dock top)
$header = New-Object System.Windows.Forms.Panel
$header.Dock = 'Top'
$header.Height = 64
$header.BackColor = [System.Drawing.ColorTranslator]::FromHtml('#0097A7')
$form.Controls.Add($header)

$title = New-Object System.Windows.Forms.Label
$title.Text = 'HERNINGSHOLM · BLOATWARE & AV REMOVAL'
$title.AutoSize = $true
$title.ForeColor = 'White'
$title.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 12, [System.Drawing.FontStyle]::Bold)
$title.Location = New-Object System.Drawing.Point(16,20)
$header.Controls.Add($title)

# Main area
$main = New-Object System.Windows.Forms.Panel
$main.Dock = 'Fill'
$main.Padding = '15,12,15,12'
$main.BackColor = [System.Drawing.ColorTranslator]::FromHtml('#0B1422')
$form.Controls.Add($main)

# Log container
$card = New-Object System.Windows.Forms.Panel
$card.Dock = 'Fill'
$card.Padding = '10'
$card.BackColor = [System.Drawing.ColorTranslator]::FromHtml('#0F1C2E')
$card.BorderStyle = 'FixedSingle'
$main.Controls.Add($card)

$txtLog = New-Object System.Windows.Forms.TextBox
$txtLog.Dock = 'Fill'
$txtLog.Multiline = $true
$txtLog.ScrollBars = 'Vertical'
$txtLog.ReadOnly = $true
$txtLog.BackColor = [System.Drawing.ColorTranslator]::FromHtml('#0F1C2E')
$txtLog.ForeColor = [System.Drawing.ColorTranslator]::FromHtml('#E4ECF5')
$txtLog.BorderStyle = 'None'
$txtLog.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$card.Controls.Add($txtLog)

# Status panel
$statusPanel = New-Object System.Windows.Forms.Panel
$statusPanel.Dock = 'Bottom'
$statusPanel.Height = 80
$statusPanel.Padding = '0,10,0,0'
$statusPanel.BackColor = [System.Drawing.ColorTranslator]::FromHtml('#0B1422')
$main.Controls.Add($statusPanel)

$lbl = New-Object System.Windows.Forms.Label
$lbl.Dock = 'Top'
$lbl.Height = 18
$lbl.Text = 'Klar til oprydning.'
$lbl.ForeColor = [System.Drawing.ColorTranslator]::FromHtml('#E4ECF5')
$statusPanel.Controls.Add($lbl)

$progress = New-Object System.Windows.Forms.ProgressBar
$progress.Dock = 'Top'
$progress.Height = 20
$progress.Style = 'Continuous'
$progress.Minimum = 0
$progress.Maximum = 100
$statusPanel.Controls.Add($progress)

# Buttons bar
$buttonPanel = New-Object System.Windows.Forms.Panel
$buttonPanel.Dock = 'Bottom'
$buttonPanel.Height = 68
$buttonPanel.Padding = '15,10,15,10'
$buttonPanel.BackColor = [System.Drawing.ColorTranslator]::FromHtml('#0B1422')
$form.Controls.Add($buttonPanel)

function New-FlatButton([string]$text, [string]$colorHex, [int]$width=170) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Height = 36
    $btn.Width = $width
    $btn.BackColor = [System.Drawing.ColorTranslator]::FromHtml($colorHex)
    $btn.ForeColor = 'White'
    $btn.FlatStyle = 'Flat'
    $btn.FlatAppearance.BorderSize = 0
    $btn.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9, [System.Drawing.FontStyle]::Bold)
    return $btn
}

$startBtn = New-FlatButton 'START OPRYDNING' '#1E8E5B'
$closeBtn = New-FlatButton 'LUK' '#455A64'

$buttonPanel.Controls.Add($startBtn)
$buttonPanel.Controls.Add($closeBtn)

$buttonPanel.Add_Resize({
    $startBtn.Location = New-Object System.Drawing.Point(0, ($buttonPanel.Height - $startBtn.Height) / 2)
    $closeBtn.Location = New-Object System.Drawing.Point($buttonPanel.Width - $closeBtn.Width, ($buttonPanel.Height - $closeBtn.Height) / 2)
})

# Hvis ghost mode, start minimeret
if ($Ghost) {
    $form.WindowState = 'Minimized'
    $form.ShowInTaskbar = $false
}

function Update-UI {
    param(
        [int]$Percent,
        [string]$Message
    )
    if ($Percent -gt 100) { $Percent = 100 }
    $progress.Value = $Percent
    $lbl.Text = $Message
    $txtLog.AppendText((Get-Date -Format 'HH:mm:ss') + ' - ' + $Message + "`r`n")
    [System.Windows.Forms.Application]::DoEvents()
}

function Run-Cleanup {
    # Counters
    $SuccessCount = 0
    $FailCount = 0

    Update-UI -Percent 2 -Message 'Starter oprydning...'

    # --- 1) Fjern Windows Store Apps (AppX) ---
    Update-UI -Percent 5 -Message '[1/7] Fjerner Windows Store bloatware'
    $AppXToRemove = @(
        '*CandyCrush*','*Facebook*','*Spotify*','*BubbleWitch*','*MarchofEmpires*',
        '*Solitaire*','*Twitter*','*Minecraft*','*Royal Revolt*','*ActiproSoftware*',
        '*king.com*','*Disney*','*Netflix*','*Duolingo*','*EclipseManager*',
        '*PandoraMedia*','*Xbox*','*BingNews*','*BingSports*','*BingWeather*'
    )
    foreach ($Pattern in $AppXToRemove) {
        Get-AppxPackage -Name $Pattern -AllUsers -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction Stop
                Update-UI -Percent ($progress.Value + 1) -Message "Fjernet AppX: $($_.Name)"
                $SuccessCount++
            } catch {
                Update-UI -Percent ($progress.Value) -Message "Kunne ikke fjerne: $($_.Name)"
            }
        }
    }

    # --- 2) Stop processer ---
    Update-UI -Percent 12 -Message '[2/7] Stopper kendte processer'
    $ProcessesToKill = @(
        'McAfee*','WebAdvisor*','McUICnt*','mcshield*','mfemms*','ModuleCoreService*',
        'Norton*','NortonLifeLock*','ccSvcHst*','NortonVPN*','LifeLock*',
        'PlanetVPN*','Avast*','AVG*','Kaspersky*','Bitdefender*',
        'Trend*','ESET*','Sophos*','CandyCrush*','King.CandyCrush*',
        'Facebook*','Spotify*','OneDrive*','Teams*','VPNService*'
    )
    foreach ($Pattern in $ProcessesToKill) {
        Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.Name -like $Pattern -and ![string]::IsNullOrWhiteSpace($_.Name) } | ForEach-Object {
            try { 
                Stop-Process -Id $_.Id -Force -ErrorAction Stop
                Update-UI -Percent ($progress.Value + 1) -Message "Stopper: $($_.Name)" 
            } catch { 
                Update-UI -Percent ($progress.Value) -Message "Kunne ikke stoppe: $($_.Name)" 
            }
        }
    }

    # --- 3) Stop McAfee & Norton services ---
    Update-UI -Percent 18 -Message '[3/7] Stopper McAfee & Norton services'
    $McAfeeServices = @('McAfeeFramework','McShield','McTaskManager','mfemms','mfevtp','mfefire','mfemms','HomeNetSvc','McAPExe','Mfeavsvc')
    $NortonServices = @('NortonVPN','NortonLifeLock','ccSvcHst','n360','N360','NPF','NF','NLSF')
    $AllServices = $McAfeeServices + $NortonServices
    foreach ($Svc in $AllServices) {
        if (Get-Service -Name $Svc -ErrorAction SilentlyContinue) {
            try {
                Stop-Service -Name $Svc -Force -ErrorAction Stop
                Set-Service -Name $Svc -StartupType Disabled -ErrorAction Stop
                Update-UI -Percent ($progress.Value + 1) -Message "Stoppet service: $Svc"
            } catch {
                Update-UI -Percent ($progress.Value) -Message "Kunne ikke stoppe service: $Svc"
            }
        }
    }

    # --- 4) Deaktiver Windows Defender (midlertidigt) ---
    Update-UI -Percent 22 -Message '[4/7] Deaktiverer real-time monitorering (midlertidigt)'
    try {
        Set-MpPreference -DisableRealtimeMonitoring $true -DisableIOAVProtection $true -Force -ErrorAction Stop
        Update-UI -Percent 26 -Message 'Windows Defender midlertidigt deaktiveret'
    } catch { 
        Update-UI -Percent 26 -Message 'Note: Windows Defender kunne ikke deaktiveres (ikke admin eller ikke supporteret på dette system)'
    }

    # --- 5) Afinstaller via winget ---
    Update-UI -Percent 28 -Message '[5/7] Afinstallerer via winget (hvis tilgængelig)'
    $AppsToRemove = @(
        'McAfee.WBC','McAfee.McAfeeLiveSafe','McAfee.Agent','Norton.LifeLock','Norton.AntiVirus','NortonLifeLock.NortonLifeLock','G Data.Total Security','K7TotalSecurity.K7TotalSecurity','Kaspersky.KasperskyInternetSecurity','Bitdefender.InternetSecurity',
        'PlanetVPN.PlanetVPN','CyberGhost.CyberGhost','ExpressVPN.ExpressVPN','NordVPN.NordVPN',
        'King.CandyCrushSaga','King.CandyCrushSodaSaga','Zynga.PetShopStory','Facebook.Facebook','Spotify.Spotify',
        'Microsoft.GetHelp','Microsoft.Getstarted','Microsoft.MicrosoftSolitaire','Microsoft.News','Microsoft.Weather','Microsoft.Maps','Microsoft.ZuneMusic','Microsoft.ZuneVideo','Microsoft.3DBuilder','Microsoft.Paint3D','Microsoft.MixedReality.Portal'
    )

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        foreach ($App in $AppsToRemove) {
            Update-UI -Percent ($progress.Value + 1) -Message "Prøver at fjerne: $App"
            try {
                $output = winget uninstall --id "$App" --silent --accept-source-agreements --disable-interactivity 2>&1
                if ($LASTEXITCODE -eq 0) { 
                    $SuccessCount++ 
                    Update-UI -Percent ($progress.Value + 1) -Message "Fjernet: $App" 
                } else { 
                    $FailCount++ 
                    Update-UI -Percent ($progress.Value) -Message "Ikke fundet: $App" 
                }
            } catch { 
                $FailCount++
                Update-UI -Percent ($progress.Value) -Message "Fejl ved fjernelse: $App" 
            }
        }
    } else {
        Update-UI -Percent 40 -Message 'winget ikke fundet — springer afinstallation over'
    }

    # --- 6) McAfee Consumer Product Removal Tool ---
    Update-UI -Percent 44 -Message '[6/8] Downloader McAfee removal tool (hvis McAfee findes)'
    if ((Test-Path "$env:ProgramFiles\McAfee") -or (Test-Path "${env:ProgramFiles(x86)}\McAfee") -or (Test-Path "$env:ProgramData\McAfee")) {
        try {
            $mcprUrl = "https://download.mcafee.com/molbin/iss-loc/SupportTools/MCPR/MCPR.exe"
            $mcprPath = "$env:TEMP\MCPR.exe"
            Update-UI -Percent 45 -Message 'Downloader McAfee MCPR tool...'
            Invoke-WebRequest -Uri $mcprUrl -OutFile $mcprPath -UseBasicParsing -ErrorAction Stop
            
            Update-UI -Percent 46 -Message 'Kører McAfee MCPR tool (dette kan tage et par minutter)...'
            $mcprProc = Start-Process -FilePath $mcprPath -ArgumentList "-p StopServices,MFSY,PEF,MXD,CSP,Sustainability,MOCP,MFP,APPSTATS,Auth,EMproxy,FWdpl,PwdMgr,EmailProxy,VUL,WMIRemover,RESIDUE -v -s" -Wait -PassThru -NoNewWindow -ErrorAction Stop
            
            if ($mcprProc.ExitCode -eq 0) {
                Update-UI -Percent 48 -Message 'McAfee MCPR afsluttet succesfuldt'
                $SuccessCount += 5
            } else {
                Update-UI -Percent 48 -Message "McAfee MCPR afsluttet med kode: $($mcprProc.ExitCode)"
            }
            
            Remove-Item $mcprPath -Force -ErrorAction SilentlyContinue
        } catch {
            Update-UI -Percent 48 -Message 'Kunne ikke downloade/køre McAfee MCPR tool'
        }
    } else {
        Update-UI -Percent 48 -Message 'McAfee ikke fundet - springer MCPR over'
    }

    # --- 7) Fjern via registry-uninstall strings ---
    Update-UI -Percent 50 -Message '[7/8] Forsøger at fjerne via registry uninstall strings'
    $UninstallPaths = @( 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall', 'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall' )
    $KeywordsToRemove = @('McAfee','Norton','LifeLock','NortonVPN','Avast','AVG','Kaspersky','Bitdefender','PlanetVPN','CyberGhost','ExpressVPN','NordVPN','CandyCrush','Spotify','Facebook','King','Solitaire','Getstarted','WebAdvisor')

    foreach ($Path in $UninstallPaths) {
        Get-ChildItem -Path $Path -ErrorAction SilentlyContinue | ForEach-Object {
            $DisplayName = $_.GetValue('DisplayName')
            if ($DisplayName) {
                foreach ($Keyword in $KeywordsToRemove) {
                    if ($DisplayName -like "*$Keyword*") {
                        $UninstallString = $_.GetValue('UninstallString')
                        $QuietUninstallString = $_.GetValue('QuietUninstallString')
                        
                        # Brug QuietUninstallString hvis tilgængelig
                        if ($QuietUninstallString) {
                            Update-UI -Percent ($progress.Value + 1) -Message "Stille afinstallation: $DisplayName"
                            try { 
                                # Kør med WindowStyle Hidden for at skjule GUI
                                $psi = New-Object System.Diagnostics.ProcessStartInfo
                                $psi.FileName = "powershell.exe"
                                $psi.Arguments = "-WindowStyle Hidden -Command `"& {$QuietUninstallString}`""
                                $psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
                                $psi.CreateNoWindow = $true
                                $proc = [System.Diagnostics.Process]::Start($psi)
                                $proc.WaitForExit(120000) # 2 min timeout
                                
                                $SuccessCount++
                                Update-UI -Percent ($progress.Value) -Message "Fjernet: $DisplayName"
                            } catch { 
                                $FailCount++
                            }
                        } elseif ($UninstallString) {
                            # Parse uninstall string for exe og args
                            $exePath = ""
                            $args = ""
                            
                            if ($UninstallString -match '^"([^"]+)"\s*(.*)$') {
                                $exePath = $matches[1]
                                $args = $matches[2]
                            } elseif ($UninstallString -match '^([^\s]+\.exe)\s*(.*)$') {
                                $exePath = $matches[1]
                                $args = $matches[2]
                            } else {
                                $exePath = $UninstallString
                            }
                            
                            # Tilføj silent flags baseret på type
                            if ($UninstallString -like "*msiexec*") {
                                if ($args -notlike "*/quiet*" -and $args -notlike "*/qn*") {
                                    $args += " /quiet /norestart"
                                }
                            } elseif ($exePath -like "*.exe") {
                                # Prøv forskellige silent flag kombinationer
                                if ($args -notlike "*/S*" -and $args -notlike "*/silent*") {
                                    $args += " /S /VERYSILENT /SUPPRESSMSGBOXES /NORESTART"
                                }
                            }
                            
                            Update-UI -Percent ($progress.Value + 1) -Message "Afinstallerer: $DisplayName"
                            try {
                                $psi = New-Object System.Diagnostics.ProcessStartInfo
                                $psi.FileName = $exePath
                                $psi.Arguments = $args
                                $psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
                                $psi.CreateNoWindow = $true
                                $proc = [System.Diagnostics.Process]::Start($psi)
                                $proc.WaitForExit(120000) # 2 min timeout
                                
                                $SuccessCount++
                                Update-UI -Percent ($progress.Value) -Message "Fjernet: $DisplayName"
                            } catch { 
                                $FailCount++
                                Update-UI -Percent ($progress.Value) -Message "Fejl: $DisplayName - $($_.Exception.Message)"
                            }
                        }
                    }
                }
            }
        }
    }

    # --- 8) Fjern mapper & rester ---
    Update-UI -Percent 78 -Message '[8/8] Sletter kendte mapper og rester'
    $FoldersToRemove = @(
        "$env:ProgramFiles\McAfee", "${env:ProgramFiles(x86)}\McAfee", "$env:ProgramData\McAfee",
        "$env:ProgramFiles\Norton", "${env:ProgramFiles(x86)}\Norton", "$env:ProgramFiles\NortonLifeLock", "${env:ProgramFiles(x86)}\NortonLifeLock", "$env:ProgramData\Norton", "$env:ProgramData\NortonLifeLock", "$env:AppData\NortonLifeLock",
        "$env:ProgramFiles\Avast", "${env:ProgramFiles(x86)}\Avast",
        "$env:ProgramFiles\AVG", "${env:ProgramFiles(x86)}\AVG",
        "$env:AppData\PlanetVPN", "$env:AppData\CyberGhost", "$env:AppData\ExpressVPN", 
        "$env:AppData\Spotify", "$env:AppData\Candy Crush",
        "$env:LocalAppData\King.CandyCrushSodaSaga", "$env:LocalAppData\Packages\*CandyCrush*",
        "C:\Program Files\Common Files\McAfee", "C:\Program Files (x86)\Common Files\McAfee"
    )
    foreach ($Folder in $FoldersToRemove) {
        try {
            if (Test-Path $Folder) { 
                Remove-Item -Path $Folder -Recurse -Force -ErrorAction Stop
                Update-UI -Percent ($progress.Value + 1) -Message "Slettet: $Folder"
                $SuccessCount++
            }
        } catch { 
            Update-UI -Percent ($progress.Value) -Message "Kunne ikke slette: $Folder"
        }
    }

    # Ryd McAfee registry keys
    Update-UI -Percent 88 -Message 'Rydder McAfee registry keys'
    $RegKeysToRemove = @(
        'HKLM:\Software\McAfee',
        'HKLM:\Software\Wow6432Node\McAfee',
        'HKCU:\Software\McAfee',
        'HKLM:\Software\Norton',
        'HKLM:\Software\Wow6432Node\Norton',
        'HKCU:\Software\Norton',
        'HKLM:\Software\NortonLifeLock',
        'HKLM:\Software\Wow6432Node\NortonLifeLock',
        'HKCU:\Software\NortonLifeLock'
    )
    foreach ($RegKey in $RegKeysToRemove) {
        if (Test-Path $RegKey) {
            try {
                Remove-Item -Path $RegKey -Recurse -Force -ErrorAction Stop
                Update-UI -Percent ($progress.Value + 1) -Message "Slettet registry: $RegKey"
            } catch {
                Update-UI -Percent ($progress.Value) -Message "Kunne ikke slette registry: $RegKey"
            }
        }
    }

    # --- 9) Genaktiver Windows Defender ---
    Update-UI -Percent 92 -Message 'Genaktiverer Windows Defender (anbefalet)'
    try {
        Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction Stop
        Update-UI -Percent 97 -Message 'Windows Defender genaktiveret'
    } catch { 
        Update-UI -Percent 97 -Message 'Kunne ikke genaktivere Windows Defender'
    }

    # --- Færdig / Summary ---
    Update-UI -Percent 99 -Message 'Afslutter og opsummerer resultater'
    $summary = "═══ OPRYDNING FÆRDIG ═══`r`n`r`nSucces: $SuccessCount komponenter fjernet`r`nIkke fundet/fejl: $FailCount`r`n`r`nAnbefaling: Genstart PC for at fuldføre fjernelsen"
    Update-UI -Percent 100 -Message 'Færdig - Genstart anbefales'
    $txtLog.AppendText("`r`n--- SUMMARY ---`r`n" + $summary + "`r`n")
    [System.Windows.Forms.MessageBox]::Show($summary, 'Oprydning færdig', 'OK', 'Information')
}

$startBtn.Add_Click({
    $startBtn.Enabled = $false
    Run-Cleanup
    $startBtn.Enabled = $true
})

$closeBtn.Add_Click({ $form.Close() })

[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::Run($form)
