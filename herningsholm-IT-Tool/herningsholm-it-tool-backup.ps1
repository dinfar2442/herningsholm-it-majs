# --- FASE 1: ADMIN & GHOST MODE ---
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}
$code = '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);'
$type = Add-Type -MemberDefinition $code -Name Window -Namespace Console -PassThru
$type::ShowWindow((Get-Process -Id $pid).MainWindowHandle, 0)

Add-Type -AssemblyName PresentationFramework, System.Windows.Forms

# Wrap entire startup in try/catch to capture any initialization errors to a log file
try {

# --- HOVED GUI (V68.2.1 - MODERN LIGHT MODE) ---
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Herningsholm IT Tool v68.2.1" Height="820" Width="960" MinHeight="620" MinWidth="760" Background="#FAFAFA" WindowStartupLocation="CenterScreen" ResizeMode="CanResize" FontFamily="Segoe UI">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="120"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="55"/>
        </Grid.RowDefinitions>

        <!-- PREMIUM HEADER -->
        <Border Grid.Row="0" Background="#6B5B95" Padding="25,15,25,15">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <StackPanel Grid.Column="0" VerticalAlignment="Center">
                    <TextBlock Text="⚙  HERNINGSHOLM IT SUPPORT" FontFamily="Segoe UI Semibold" FontSize="26" FontWeight="SemiBold" Foreground="White" Margin="0,0,0,5"/>
                    <TextBlock Text="Advanced System Management • v68.2.1" FontFamily="Segoe UI" FontSize="10" Foreground="#E8D5FF" FontWeight="Normal"/>
                </StackPanel>
                <StackPanel Grid.Column="1" VerticalAlignment="Center" HorizontalAlignment="Right">
                    <TextBlock Text="● SYSTEMET ER KLAR" FontFamily="Segoe UI" FontSize="10" Foreground="#66FF66" FontWeight="SemiBold"/>
                </StackPanel>
            </Grid>
        </Border>

        <!-- MAIN CONTENT -->
        <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto" Background="#FAFAFA" Margin="0,10,0,0">
            <StackPanel Margin="18,10,18,10">
                <!-- SYSTEM & INFO -->
                <TextBlock Text="📊 SYSTEM &amp; INFORMATION" FontFamily="Segoe UI Semibold" FontSize="11" FontWeight="SemiBold" Foreground="#2C3E50" Margin="0,0,0,8" Padding="3,0,0,0"/>
                <UniformGrid Columns="4" Margin="0,0,0,12">
                    <Button Name="BtnAsset" Content="PC INFO" Background="#00BCD4" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Viser PC navn og hardware serienummer"/>
                    <Button Name="BtnNet" Content="IP ADRESSE" Background="#0097A7" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Viser alle netværk IP-adresser og interface information"/>
                    <Button Name="BtnDisk" Content="DISK PLADS" Background="#26A69A" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Viser ledig og brugt diskplads på C: drevet"/>
                    <Button Name="BtnPerf" Content="RAM MONITOR" Background="#00897B" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Viser top 10 processer sorteret efter RAM forbrug"/>
                </UniformGrid>

                <!-- NETWORK -->
                <TextBlock Text="🌍 NETVÆRK &amp; FORBINDELSE" FontFamily="Segoe UI Semibold" FontSize="11" FontWeight="SemiBold" Foreground="#2C3E50" Margin="0,0,0,8" Padding="3,0,0,0"/>
                <UniformGrid Columns="4" Margin="0,0,0,12">
                    <Button Name="BtnWifiFix" Content="WIFI FIX" Background="#2196F3" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Fuld netværksreparation: Winsock, IP, DNS, DHCP og adapter reset"/>
                    <Button Name="BtnPortal" Content="PORTALER" Background="#1976D2" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Åbner Office 365 og Herningsholm UMS portaler i browser"/>
                    <Button Name="BtnCloud" Content="ONEDRIVE" Background="#1565C0" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Nulstiller OneDrive og fjerner login credentials/cache"/>
                    <Button Name="BtnKaisai" Content="TID SYNC" Background="#0D47A1" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Synkroniserer systemtid og opdaterer Group Policy (GPO)"/>
                </UniformGrid>

                <!-- CLEANING -->
                <TextBlock Text="🧹 RENGØRING &amp; OPTIMERING" FontFamily="Segoe UI Semibold" FontSize="11" FontWeight="SemiBold" Foreground="#2C3E50" Margin="0,0,0,8" Padding="3,0,0,0"/>
                <UniformGrid Columns="4" Margin="0,0,0,12">
                    <Button Name="BtnDeepClean" Content="DEEP CLEAN" Background="#E91E63" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Komplet IT optimering: DISM repair, SFC scan, cleanup, disk check, Office repair, virus scan, credentials reset"/>
                    <Button Name="BtnChrome" Content="CHROME" Background="#F44336" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Rydder Google Chrome cache og lukker alle Chrome processer"/>
                    <Button Name="BtnBloat" Content="BLOATWARE" Background="#FF6F00" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Fjerner bloatware: McAfee, Candy Crush, VPN og uønskede apps"/>
                    <Button Name="BtnUpdate" Content="PC UPDATE" Background="#AB47BC" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Opdaterer Windows, BIOS (HP/Lenovo), drivere og installerede apps"/>
                </UniformGrid>

                <!-- OFFICE -->
                <TextBlock Text="📄 OFFICE &amp; VÆRKTØJER" FontFamily="Segoe UI Semibold" FontSize="11" FontWeight="SemiBold" Foreground="#2C3E50" Margin="0,0,0,8" Padding="3,0,0,0"/>
                <UniformGrid Columns="4" Margin="0,0,0,12">
                    <Button Name="BtnTeams" Content="TEAMS FIX" Background="#6B5B95" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Reparerer Microsoft Teams og Office login problemer"/>
                    <Button Name="BtnInstall" Content="SOFTWARE" Background="#7E57C2" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Installer software: Office 365, Chrome, Teams, VLC, Adobe Reader m.fl."/>
                    <Button Name="BtnPrint" Content="PRINTER" Background="#4CAF50" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Genstarter print spooler service for at løse printer problemer"/>
                    <Button Name="BtnElevPrint" Content="ELEV PRINT" Background="#388E3C" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Downloader Herningsholm printer konfiguration til elever"/>
                </UniformGrid>

                <!-- MAINTENANCE -->
                <TextBlock Text="🔧 SYSTEM VEDLIGEHOLD" FontFamily="Segoe UI Semibold" FontSize="11" FontWeight="SemiBold" Foreground="#2C3E50" Margin="0,0,0,8" Padding="3,0,0,0"/>
                <Button Name="BtnUI" Content="FIX MENU" Background="#9C27B0" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" Width="145" HorizontalAlignment="Left" ToolTip="Genstarter Windows Explorer for at reparere frossen startmenu/taskbar"/>
            </StackPanel>
        </ScrollViewer>

        <!-- PREMIUM FOOTER -->
        <Border Grid.Row="2" Background="#2C3E50" Padding="18,0,18,0">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <TextBlock Grid.Column="0" Text="🚀 Herningsholm IT Tool • Professional Support Dashboard" FontFamily="Segoe UI" Foreground="#ECF0F1" VerticalAlignment="Center" FontSize="10" FontWeight="Normal"/>
                <Button Name="BtnExit" Grid.Column="1" Content="LUK" Background="#E74C3C" Foreground="White" FontFamily="Segoe UI Semibold" FontSize="10" FontWeight="SemiBold" Width="85" Height="38" Margin="0" ToolTip="Luk Herningsholm IT Support Tool"/>
            </Grid>
        </Border>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Forbindelse af alle knapper
$nodes = "BtnInstall","BtnPortal","BtnBloat","BtnTeams","BtnWifiFix","BtnAsset","BtnNet","BtnUpdate","BtnCloud","BtnDisk","BtnPerf","BtnKaisai","BtnChrome","BtnDeepClean","BtnPrint","BtnElevPrint","BtnUI","BtnExit"
foreach($node in $nodes) { Set-Variable -Name $node -Value $window.FindName($node) }

function Invoke-Task ([scriptblock]$Code, $ArgsList) {
    # Build scriptblock with injected args as $taskArgs (avoid $args override)
    $scriptText = $Code.ToString()
    
    # If we have args, inject them as $taskArgs variable at the top
    if ($ArgsList -and $ArgsList.Count -gt 0) {
        # Create JSON representation safely
        $jsonArgs = @()
        foreach ($arg in $ArgsList) {
            $jsonArgs += "`"$($arg -replace '"', '\"')`""
        }
        $argsDeclaration = "`$taskArgs = @($($jsonArgs -join ','))`n"
        $scriptText = $argsDeclaration + $scriptText
    }
    
    # Encode and run
    $Encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($scriptText))
    $argList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-EncodedCommand", $Encoded)
    Start-Process powershell.exe -ArgumentList $argList -Wait
}
Set-Alias -Name Run-Task -Value Invoke-Task

# --- SOFTWARE VÆLGER ---
$BtnInstall.Add_Click({
    [xml]$swX = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="Installer" Height="300" Width="300" Background="#111111" WindowStartupLocation="CenterOwner" Topmost="True">
        <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
            <TextBlock Grid.Row="0" Text="INSTALLER" Foreground="#FFD700" HorizontalAlignment="Center" Margin="10" FontWeight="Bold"/>
            <ScrollViewer Grid.Row="1" Margin="10,0"><StackPanel>
                <CheckBox Name="c1" Content="Office 365" Foreground="White" Margin="0,5"/><CheckBox Name="c2" Content="Chrome" Foreground="White" Margin="0,5"/>
                <CheckBox Name="c3" Content="Teams" Foreground="White" Margin="0,5"/><CheckBox Name="c4" Content="VLC" Foreground="White" Margin="0,5"/>
                <CheckBox Name="c5" Content="Adobe Reader" Foreground="White" Margin="0,5"/><CheckBox Name="c6" Content="7-Zip" Foreground="White" Margin="0,5"/>
                <CheckBox Name="c7" Content="WordMat" Foreground="White" Margin="0,5"/>
            </StackPanel></ScrollViewer>
            <Button Grid.Row="2" Name="bInst" Content="INSTALLER" Margin="15" Height="30" Background="#2E7D32" Foreground="White"/>
        </Grid>
    </Window>
"@
    $swWin = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $swX))
    $swWin.FindName("bInst").Add_Click({
        $list = @(); $installWordMat = $false
        if($swWin.FindName("c1").IsChecked){$list+="Microsoft.Office"}
        if($swWin.FindName("c2").IsChecked){$list+="Google.Chrome"}
        if($swWin.FindName("c3").IsChecked){$list+="Microsoft.Teams"}
        if($swWin.FindName("c4").IsChecked){$list+="VideoLAN.VLC"}
        if($swWin.FindName("c5").IsChecked){$list+="Adobe.AdobeReader"}
        if($swWin.FindName("c6").IsChecked){$list+="7zip.7zip"}
        if($swWin.FindName("c7").IsChecked){ $installWordMat = $true }
        $swWin.Close()
        if ($list.Count -gt 0) { Run-Task { foreach($app in $taskArgs){ winget install --id $app -e --silent --accept-package-agreements --accept-source-agreements } } -ArgsList $list }
        if ($installWordMat) {
            Run-Task {
                $url = $script:WordMatUrl
                if ([string]::IsNullOrWhiteSpace($url)) {
                    Write-Host "WordMat URL ikke konfigureret. Åbner websted for manuel download..."
                    Start-Process "https://www.wordmat.org"
                    exit
                }
                $out = Join-Path $env:TEMP 'WordMatSetup.exe'
                try { Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing -ErrorAction Stop; Start-Process -FilePath $out -ArgumentList '/S' -Wait -ErrorAction SilentlyContinue } catch { Write-Host "WordMat installation fejlede: $_" }
            }
        }
    })
    $swWin.Owner = $window; $swWin.ShowDialog() | Out-Null
})

# --- BLOATWARE REMOVER ---
$BtnBloat.Add_Click({
    # Vælg mellem manuel og automatisk sletning
    [xml]$modeXaml = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="Bloatware Removal Mode" Height="280" Width="480" Background="#111111" WindowStartupLocation="CenterOwner" Topmost="True">
        <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
            <TextBlock Grid.Row="0" Text="VÆLG SLETNINGSMETODE" Foreground="#FFD700" HorizontalAlignment="Center" Margin="10" FontWeight="Bold" FontSize="14"/>
            <StackPanel Grid.Row="1" Margin="20" VerticalAlignment="Center">
                <RadioButton Name="radManual" Content="MANUEL VALG - Vælg hvad der skal slettes" Foreground="White" Margin="0,10" FontSize="12" IsChecked="True"/>
                <RadioButton Name="radAuto" Content="AUTOMATISK - Slet ALT kendt bloatware" Foreground="White" Margin="0,10" FontSize="12"/>
            </StackPanel>
            <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Right" Margin="10">
                <Button Name="btnOk" Content="FORTSÆT" Margin="5" Padding="15,5" Background="#2E7D32" Foreground="White" FontWeight="Bold"/>
                <Button Name="btnCancel" Content="ANNULLER" Margin="5" Padding="15,5" Background="#666666" Foreground="White"/>
            </StackPanel>
        </Grid>
    </Window>
"@
    
    $modeWin = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $modeXaml))
    $radManual = $modeWin.FindName("radManual")
    $btnOk = $modeWin.FindName("btnOk")
    $btnCancel = $modeWin.FindName("btnCancel")
    
    $btnCancel.Add_Click({ $modeWin.Close() })
    
    $btnOk.Add_Click({
        if($radManual.IsChecked) {
            $modeWin.Close()
            # MANUEL MODE - Vis checkboxes
            [xml]$manualX = @"
            <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="Vælg hvad der skal fjernes" Height="400" Width="320" Background="#111111" WindowStartupLocation="CenterOwner" Topmost="True">
                <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                    <TextBlock Grid.Row="0" Text="VÆLG APPS" Foreground="#FF3D00" HorizontalAlignment="Center" Margin="10" FontWeight="Bold"/>
                    <ScrollViewer Grid.Row="1" Margin="10,0"><StackPanel>
                        <TextBlock Text="Antivirus" Foreground="#FFD700" Margin="0,5" FontWeight="Bold"/>
                        <CheckBox Name="m1" Content="McAfee (ALT)" Foreground="White" Margin="5,2"/><CheckBox Name="m2" Content="Norton" Foreground="White" Margin="5,2"/>
                        <CheckBox Name="m3" Content="Avast" Foreground="White" Margin="5,2"/><CheckBox Name="m4" Content="AVG" Foreground="White" Margin="5,2"/>
                        <CheckBox Name="m5" Content="Kaspersky" Foreground="White" Margin="5,2"/><CheckBox Name="m6" Content="Bitdefender" Foreground="White" Margin="5,2"/>
                        <TextBlock Text="VPN &amp; Tjenester" Foreground="#FFD700" Margin="0,10,0,5" FontWeight="Bold"/>
                        <CheckBox Name="m7" Content="Planet VPN" Foreground="White" Margin="5,2"/><CheckBox Name="m8" Content="CyberGhost" Foreground="White" Margin="5,2"/>
                        <CheckBox Name="m9" Content="ExpressVPN" Foreground="White" Margin="5,2"/>
                        <TextBlock Text="Bloatware" Foreground="#FFD700" Margin="0,10,0,5" FontWeight="Bold"/>
                        <CheckBox Name="m10" Content="Candy Crush" Foreground="White" Margin="5,2"/><CheckBox Name="m11" Content="Spotify" Foreground="White" Margin="5,2"/>
                        <CheckBox Name="m12" Content="Facebook" Foreground="White" Margin="5,2"/>
                    </StackPanel></ScrollViewer>
                    <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Right" Margin="10">
                        <Button Name="mOk" Content="SLET" Margin="5" Padding="15,5" Background="#B71C1C" Foreground="White" FontWeight="Bold"/>
                        <Button Name="mCancel" Content="ANNULLER" Margin="5" Padding="15,5" Background="#666666" Foreground="White"/>
                    </StackPanel>
                </Grid>
            </Window>
"@
            $manualWin = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $manualX))
            
            $mOk = $manualWin.FindName("mOk")
            $mCancel = $manualWin.FindName("mCancel")
            
            $mCancel.Add_Click({ $manualWin.Close() })
            $mOk.Add_Click({
                $selected = @()
                $appMap = @{
                    'm1' = @('McAfee*','*McAfee*','WebAdvisor*','McAfeeLiveSafe*')
                    'm2' = @('Norton*','NortonLifeLock*')
                    'm3' = @('Avast*')
                    'm4' = @('AVG*')
                    'm5' = @('Kaspersky*')
                    'm6' = @('Bitdefender*','Trend*','ESET*','Sophos*')
                    'm7' = @('PlanetVPN*')
                    'm8' = @('CyberGhost*')
                    'm9' = @('ExpressVPN*','NordVPN*')
                    'm10' = @('CandyCrush*','King.CandyCrush*')
                    'm11' = @('Spotify*')
                    'm12' = @('Facebook*')
                    'm13' = @('ccleaner*', 'ccleaner browser*')
                }
                
                for($i=1; $i -le 13; $i++) {
                    $cb = $manualWin.FindName("m$i")
                    if($cb.IsChecked) {
                        $selected += $appMap["m$i"]
                    }
                }
                
                if($selected.Count -eq 0) {
                    [System.Windows.MessageBox]::Show('Vælg mindst én app.','Ingen valg') | Out-Null
                    return
                }
                
                $manualWin.Close()
                Run-Task { 
                    Write-Host "--- STARTER MANUEL BLOATWARE SLETNING ---" -ForegroundColor Red
                    foreach ($app in $taskArgs[0]) {
                        Write-Host "Søger efter: $app"
                        $pkg = Get-Package -Name $app -ErrorAction SilentlyContinue
                        if ($pkg) {
                            Write-Host "Finder og sletter: $($pkg.Name)" -ForegroundColor Yellow
                            $pkg | Uninstall-Package -Force -ErrorAction SilentlyContinue
                        }
                    }
                    Write-Host "`n--- SLETNING AFSLUTTET ---" -ForegroundColor Green
                } -ArgsList @(,$selected)
            })
            
            $manualWin.Owner = $window
            $manualWin.ShowDialog() | Out-Null
        }
        else {
            # AUTOMATISK MODE - Åbn det eksterne bloatware script
            $modeWin.Close()
            $scriptPath = Join-Path (Split-Path -Parent $PSCommandPath) "herningshom-bloutremove.ps1"
            if (Test-Path $scriptPath) {
                Write-Host "Åbner Bloatware Removal Script..." -ForegroundColor Green
                Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
            } else {
                [System.Windows.MessageBox]::Show("Kunne ikke finde bloatware script på: $scriptPath", "Fejl", "OK", "Error") | Out-Null
            }
        }
    })
    
    $modeWin.Owner = $window
    $modeWin.ShowDialog() | Out-Null
})

# --- FUNKTIONER ---
function Invoke-DismWithProgress {
    param([string]$Arguments)
    Write-Host "Kører: dism.exe $Arguments"
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "dism.exe"
    $psi.Arguments = $Arguments
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi
    $proc.Start() | Out-Null

    $stdout = $proc.StandardOutput
    while (-not $stdout.EndOfStream) {
        $line = $stdout.ReadLine()
        if ($null -eq $line) { continue }
        if ($line -match '(\d{1,3}(\.\d+)?)%') {
            $percent = [math]::Round([double]$matches[1])
            Write-Progress -Activity "DISM" -Status $line -PercentComplete $percent
        } else {
            Write-Host $line
        }
    }
    $proc.WaitForExit()
    Write-Progress -Activity "DISM" -Completed
    if ($proc.ExitCode -ne 0) {
        $err = $proc.StandardError.ReadToEnd()
        Write-Host "DISM afsluttet med fejl (ExitCode $($proc.ExitCode))"
        if ($err) { Write-Host $err }
    }
}
# Konfigurerbart printer-placering (blank = ikke kopier automatisk)
$ElevPrintPrinterPath = ""

# WordMat download URL (leave empty to open website instead)
$WordMatUrl = "https://www.eduap.com/download/download.php?f=WordMatP.exe"


$BtnCloud.Add_Click({ Run-Task { Stop-Process -Name "OneDrive" -Force -EA SilentlyContinue; if(Test-Path "$env:LocalAppData\Microsoft\OneDrive\onedrive.exe"){& "$env:LocalAppData\Microsoft\OneDrive\onedrive.exe" /reset}; Remove-Item "$env:LocalAppData\Microsoft\OneDrive\settings" -Recurse -Force -EA SilentlyContinue; cmdkey /list | ForEach-Object { if($_ -like "*OneDrive*") { cmdkey /delete ($_ -split " ")[-1] } } } })
$BtnTeams.Add_Click({ Run-Task { Stop-Process -Name "winword","excel","ms-teams","Teams" -Force -EA SilentlyContinue; Remove-Item "HKCU:\Software\Microsoft\Office\16.0\Common\Identity\Identities\*" -Recurse -Force -EA SilentlyContinue } })

$BtnWifiFix.Add_Click({
    [xml]$wifiX = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="WiFi Fix Pro" Height="450" Width="600" Background="#FFFFFF" WindowStartupLocation="CenterOwner" Topmost="True">
        <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
            <Border Grid.Row="0" Background="#2196F3" Padding="15,10,15,10">
                <TextBlock Text="📡 WIFI FIX PRO - NETVÆRKSREPARATION" Foreground="White" HorizontalAlignment="Center" FontWeight="Bold" FontSize="12"/>
            </Border>
            <TextBox Grid.Row="1" Name="wifiLog" Margin="15" Background="#F5F5F5" Foreground="#333333" FontFamily="Segoe UI Mono" FontSize="10" IsReadOnly="True" VerticalScrollBarVisibility="Auto" TextWrapping="Wrap"/>
            <Button Grid.Row="2" Name="wifiClose" Content="LUK" Margin="15,10,15,10" Height="35" Background="#2196F3" Foreground="White" HorizontalAlignment="Right" Width="100" FontWeight="Bold"/>
        </Grid>
    </Window>
"@
    $wifiWin = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $wifiX))
    $wifiLog = $wifiWin.FindName("wifiLog")
    $wifiClose = $wifiWin.FindName("wifiClose")
    $wifiClose.Add_Click({ $wifiWin.Close() })
    
    $output = "═══ WIFI FIX PRO - FULD NETVÆRKSREPARATION ═══`n`n"
    
    $output += "[1/8] Scanner netværksadaptere...`n"
    $wifi = Get-NetAdapter | Where-Object { $_.InterfaceDescription -match 'Wireless|wi-?fi|wifi|wlan' -or $_.Name -match 'Wi-Fi|WiFi|WLAN' }
    $ethernet = Get-NetAdapter | Where-Object { $_.InterfaceDescription -match 'Ethernet' -and $_.Status -eq 'Up' }
    $output += "✓ Fundet $($wifi.Count) Wi-Fi og $($ethernet.Count) Ethernet adapter(e)`n`n"
    
    $output += "[2/8] Genstarter trådløs service...`n"
    try { Restart-Service -Name WlanSvc -Force -ErrorAction Stop; $output += "✓ WlanSvc genstartet`n`n" } catch { $output += "⚠ WlanSvc ikke tilgængelig`n`n" }
    
    $output += "[3/8] Geninitialiserer Wi-Fi adaptere...`n"
    foreach($a in $wifi){
        $output += "  > $($a.Name)`n"
        Disable-NetAdapter -Name $a.Name -Confirm:$false -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 500
        Enable-NetAdapter -Name $a.Name -Confirm:$false -ErrorAction SilentlyContinue
        $output += "  ✓ Genstartet`n"
    }
    $output += "`n"
    
    $output += "[4/8] Nulstiller Winsock...`n"
    netsh winsock reset | Out-Null
    $output += "✓ Winsock nulstillet`n`n"
    
    $output += "[5/8] Nulstiller IP stack...`n"
    netsh int ip reset | Out-Null
    $output += "✓ IP stack nulstillet`n`n"
    
    $output += "[6/8] Tømmer DNS cache...`n"
    ipconfig /flushdns | Out-Null
    $output += "✓ DNS cache tømt`n`n"
    
    $output += "[7/8] Aktiverer DHCP på alle adaptere...`n"
    foreach($a in $wifi + $ethernet){
        netsh interface ipv4 set address name="$($a.Name)" source=dhcp 2>&1 | Out-Null
        netsh interface ipv4 set dns name="$($a.Name)" source=dhcp 2>&1 | Out-Null
        $output += "  ✓ $($a.Name)`n"
    }
    $output += "`n"
    
    $output += "[8/8] Færdiggør...`n"
    $output += "✓ Alle trin afsluttet`n`n"
    $output += "═══════════════════════════════════════════`n"
    $output += "✓ WiFi Fix afsluttet!`n"
    $output += "⚠ TIP: Genstart PC hvis problemer fortsætter"
    
    $wifiLog.Text = $output
    $wifiWin.Owner = $window
    $wifiWin.ShowDialog() | Out-Null
})

# --- TOTAL DEEP CLEAN (HURTIGERE PC NU!) ---
$BtnDeepClean.Add_Click({
    # Progress Dialog
    [xml]$progressX = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="Deep Clean Pro" Height="220" Width="500" Background="#FFFFFF" WindowStartupLocation="CenterOwner" Topmost="True" ResizeMode="NoResize">
        <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/></Grid.RowDefinitions>
            <Border Grid.Row="0" Background="#E91E63" Padding="15,10,15,10">
                <TextBlock Text="🔥 DEEP CLEAN PRO - ARBEJDER..." Foreground="White" HorizontalAlignment="Center" FontWeight="Bold" FontSize="12"/>
            </Border>
            <StackPanel Grid.Row="1" Margin="20" VerticalAlignment="Center">
                <TextBlock Name="progressText" Text="Starter optimering..." FontFamily="Segoe UI" FontSize="11" Foreground="#333" Margin="0,0,0,10"/>
                <ProgressBar Name="progressBar" Height="25" Minimum="0" Maximum="100" Value="0"/>
                <TextBlock Name="progressPercent" Text="0%" FontFamily="Segoe UI Semibold" FontSize="10" Foreground="#E91E63" HorizontalAlignment="Center" Margin="0,8,0,0"/>
            </StackPanel>
        </Grid>
    </Window>
"@
    $progressWin = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $progressX))
    $progressText = $progressWin.FindName("progressText")
    $progressBar = $progressWin.FindName("progressBar")
    $progressPercent = $progressWin.FindName("progressPercent")
    $progressWin.Owner = $window
    
    # Show progress window
    $progressWin.Show()
    [System.Windows.Forms.Application]::DoEvents()
    
    $output = "═══ DEEP CLEAN PRO - KOMPLET SYSTEM OPTIMERING ═══`n`n"
    
    # Step 1
    $progressText.Text = "[1/14] Aktiverer Ultimate Performance mode..."
    $progressBar.Value = 7
    $progressPercent.Text = "7%"
    [System.Windows.Forms.Application]::DoEvents()
    
    $output += "[1/14] Aktiverer Ultimate Performance mode...`n"
    $pGuid = "e9a42b02-d5df-448d-aa00-03f14749eb61"
    powercfg -duplicatescheme $pGuid 2>&1 | Out-Null
    powercfg -setactive $pGuid 2>&1 | Out-Null
    $output += "✓ Performance mode aktiveret`n`n"
    
    # Step 2
    $progressText.Text = "[2/14] Lukker alle åbne programmer..."
    $progressBar.Value = 14
    $progressPercent.Text = "14%"
    [System.Windows.Forms.Application]::DoEvents()
    
    $output += "[2/14] Lukker alle åbne programmer...`n"
    $KeepSafe = @("explorer", "powershell", "svchost", "wininit", "lsass", "System", "Idle")
    $AllProcs = Get-Process | Where-Object { $_.MainWindowTitle -ne "" }
    foreach ($p in $AllProcs) {
        if ($KeepSafe -notcontains $p.ProcessName) {
            Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
        }
    }
    $output += "✓ Programmer lukket`n`n"
    
    # Step 3
    $progressText.Text = "[3/14] Stopper Telemetry services..."
    $progressBar.Value = 21
    $progressPercent.Text = "21%"
    [System.Windows.Forms.Application]::DoEvents()
    
    $output += "[3/14] Stopper Telemetry services...`n"
    $Services = @("DiagTrack", "dmwappushsvc", "SysMain", "WSearch")
    foreach ($s in $Services) {
        if (Get-Service $s -ErrorAction SilentlyContinue) {
            Stop-Service -Name $s -Force -ErrorAction SilentlyContinue
            Set-Service -Name $s -StartupType Disabled -ErrorAction SilentlyContinue
            $output += "  ✓ $s stoppet`n"
        }
    }
    $output += "`n"
    
    # Step 4
    $progressText.Text = "[4/14] Rydder Windows komponenter (DISM)..."
    $progressBar.Value = 29
    $progressPercent.Text = "29%"
    [System.Windows.Forms.Application]::DoEvents()
    
    $output += "[4/14] Rydder Windows komponenter (DISM)...`n"
    Start-Process -FilePath "dism.exe" -ArgumentList "/online","/Cleanup-Image","/StartComponentCleanup" -NoNewWindow -Wait -ErrorAction SilentlyContinue
    $output += "✓ DISM cleanup afsluttet`n"
    $output += "  - Windows Update cache ryddet`n"
    Remove-Item 'C:\Windows\Temp\*' -Recurse -Force -ErrorAction SilentlyContinue
    $output += "  - Windows Temp ryddet`n"
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    $output += "  - Bruger Temp ryddet`n"
    Remove-Item "$env:LocalAppData\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
    $output += "  - Browser cache ryddet`n"
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    $output += "  - Papirkurv tømt`n`n"
    
    # Step 5
    $progressText.Text = "[5/14] Tømmer DNS cache..."
    $progressBar.Value = 36
    $progressPercent.Text = "36%"
    [System.Windows.Forms.Application]::DoEvents()
    
    $output += "[5/14] Tømmer DNS cache...`n"
    ipconfig /flushdns 2>&1 | Out-Null
    $output += "✓ DNS cache tømt`n`n"
    
    # Step 6
    $progressText.Text = "[6/14] Disk Health Check (SMART)..."
    $progressBar.Value = 43
    $progressPercent.Text = "43%"
    [System.Windows.Forms.Application]::DoEvents()
    
    $output += "[6/14] Disk Health Check (SMART)...`n"
    try {
        $disks = Get-PhysicalDisk -ErrorAction Stop
        foreach ($disk in $disks) {
            $health = $disk.HealthStatus
            $output += "  Disk $($disk.FriendlyName): $health"
            if ($health -eq 'Healthy') { $output += " ✓`n" }
            else { $output += " ⚠ ADVARSEL!`n" }
        }
    } catch {
        $output += "  ⚠ Kunne ikke tjekke disk health`n"
    }
    $output += "`n"
    
    # Step 7
    $progressText.Text = "[7/14] Battery Report (kun bærbare)..."
    $progressBar.Value = 50
    $progressPercent.Text = "50%"
    [System.Windows.Forms.Application]::DoEvents()
    
    $output += "[7/14] Battery Report (kun bærbare)...`n"
    try {
        $battery = Get-WmiObject -Class Win32_Battery -ErrorAction SilentlyContinue
        if ($battery) {
            $designCapacity = $battery.DesignCapacity
            $fullChargeCapacity = $battery.FullChargeCapacity
            if ($fullChargeCapacity -and $designCapacity -and $designCapacity -gt 0) {
                $healthPercent = [math]::Round(($fullChargeCapacity / $designCapacity) * 100, 1)
                $output += "  ✓ Batteri kapacitet: $healthPercent%"
                if ($healthPercent -ge 80) { $output += " (Excellent)`n" }
                elseif ($healthPercent -ge 60) { $output += " (God)`n" }
                elseif ($healthPercent -ge 40) { $output += " (Middel - overvej udskiftning)`n" }
                else { $output += " (Dårlig - udskift batteri)`n" }
            } else {
                $output += "  ⚠ Kunne ikke beregne batteri kapacitet`n"
            }
        } else {
            $output += "  ℹ Ingen batteri fundet (stationær PC)`n"
        }
    } catch {
        $output += "  ℹ Ingen batteri fundet (stationær PC)`n"
    }
    $output += "`n"
    
    # Step 8
    $progressText.Text = "[8/14] Rydder unødvendige startup programmer..."
    $progressBar.Value = 57
    $progressPercent.Text = "57%"
    [System.Windows.Forms.Application]::DoEvents()
    
    $output += "[8/14] Rydder unødvendige startup programmer...`n"
    try {
        $disabledCount = 0
        $startupApps = Get-CimInstance Win32_StartupCommand -ErrorAction SilentlyContinue
        $bloatStartup = @('*OneDrive*','*Spotify*','*Discord*','*Teams*','*Skype*','*Adobe*','*iTunes*')
        foreach ($app in $startupApps) {
            foreach ($pattern in $bloatStartup) {
                if ($app.Command -like $pattern) {
                    # Disable via registry or task scheduler
                    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
                    $name = $app.Name
                    if (Get-ItemProperty -Path $regPath -Name $name -ErrorAction SilentlyContinue) {
                        Remove-ItemProperty -Path $regPath -Name $name -Force -ErrorAction SilentlyContinue
                        $output += "  ✓ Deaktiveret: $name`n"
                        $disabledCount++
                    }
                }
            }
        }
        if ($disabledCount -eq 0) { $output += "  ℹ Ingen bloatware startup apps fundet`n" }
        else { $output += "  ✓ $disabledCount startup items deaktiveret`n" }
    } catch {
        $output += "  ⚠ Startup cleanup fejlede`n"
    }
    $output += "`n"
    
    # Step 9
    $progressText.Text = "[9/14] Office Repair (Quick Repair)..."
    $progressBar.Value = 64
    $progressPercent.Text = "64%"
    [System.Windows.Forms.Application]::DoEvents()
    
    $output += "[9/14] Office Repair (Quick Repair)...`n"
    try {
        $officeC2R = "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe"
        if (Test-Path $officeC2R) {
            $output += "  Kører Office Quick Repair (kan tage 2-5 min)...`n"
            Start-Process -FilePath $officeC2R -ArgumentList "/update user updatetoversion=16.0" -NoNewWindow -Wait -ErrorAction SilentlyContinue
            $output += "  ✓ Office reparation kørt`n"
        } else {
            $output += "  ℹ Office ikke installeret eller ikke Click-to-Run version`n"
        }
    } catch {
        $output += "  ⚠ Office repair fejlede`n"
    }
    $output += "`n"
    
    # Step 10
    $progressText.Text = "[10/14] Windows Defender Quick Scan..."
    $progressBar.Value = 71
    $progressPercent.Text = "71%"
    [System.Windows.Forms.Application]::DoEvents()
    
    $output += "[10/14] Windows Defender Quick Scan...`n"
    try {
        $output += "  Starter hurtig virus-scan...`n"
        Start-MpScan -ScanType QuickScan -ErrorAction Stop
        $output += "  ✓ Defender Quick Scan kørt`n"
        $threats = Get-MpThreatDetection -ErrorAction SilentlyContinue
        if ($threats) {
            $output += "  ⚠ ADVARSEL: $($threats.Count) trusler fundet!`n"
        } else {
            $output += "  ✓ Ingen trusler fundet`n"
        }
    } catch {
        $output += "  ⚠ Defender scan fejlede (kræver evt. admin)`n"
    }
    $output += "`n"
    
    # Step 11 - DISM Health Check
    $progressText.Text = "[11/14] DISM Windows Image Health Check..."
    $progressBar.Value = 79
    $progressPercent.Text = "79%"
    [System.Windows.Forms.Application]::DoEvents()
    
    $output += "[11/14] DISM Windows Image Health Check...`n"
    try {
        $output += "  Scanner Windows system image...`n"
        $dismScan = & dism.exe /Online /Cleanup-Image /ScanHealth 2>&1
        if ($dismScan -match "No component store corruption detected") {
            $output += "  ✓ Ingen korruption fundet`n"
        } else {
            $output += "  ⚠ Mulig korruption - reparerer...`n"
            & dism.exe /Online /Cleanup-Image /RestoreHealth /NoRestart 2>&1 | Out-Null
            $output += "  ✓ DISM reparation kørt`n"
        }
    } catch {
        $output += "  ⚠ DISM check fejlede`n"
    }
    $output += "`n"
    
    # Step 12 - SFC System File Check
    $progressText.Text = "[12/14] System File Checker (SFC)..."
    $progressBar.Value = 86
    $progressPercent.Text = "86%"
    [System.Windows.Forms.Application]::DoEvents()
    
    $output += "[12/14] System File Checker (SFC)...`n"
    try {
        $output += "  Scanner systemfiler (kan tage 5-10 min)...`n"
        $sfcResult = & sfc /scannow 2>&1
        if ($sfcResult -match "did not find any integrity violations") {
            $output += "  ✓ Alle systemfiler er OK`n"
        } elseif ($sfcResult -match "successfully repaired") {
            $output += "  ✓ Korrupte filer repareret`n"
        } else {
            $output += "  ⚠ SFC kørt - tjek CBS.log for detaljer`n"
        }
    } catch {
        $output += "  ⚠ SFC scan fejlede`n"
    }
    $output += "`n"
    
    # Step 13 - Windows Store & Credentials Reset
    $progressText.Text = "[13/14] Windows Store & Credentials reset..."
    $progressBar.Value = 93
    $progressPercent.Text = "93%"
    [System.Windows.Forms.Application]::DoEvents()
    
    $output += "[13/14] Windows Store & Credentials reset...`n"
    try {
        # Reset Windows Store
        $output += "  Nulstiller Windows Store...`n"
        & wsreset.exe -i 2>&1 | Out-Null
        $output += "  ✓ Windows Store cache ryddet`n"
        
        # Clear cached credentials (kan løse login problemer)
        $output += "  Rydder gamle credentials...`n"
        & cmdkey /list 2>&1 | ForEach-Object {
            if ($_ -match "Target: (.+)") {
                $target = $matches[1]
                # Kun slet gamle/ubrugte credentials, behold vigtige
                if ($target -notmatch "Office|Microsoft|Teams|OneDrive") {
                    cmdkey /delete:$target 2>&1 | Out-Null
                }
            }
        }
        $output += "  ✓ Gamle credentials ryddet`n"
    } catch {
        $output += "  ⚠ Credentials cleanup delvist fejlet`n"
    }
    $output += "`n"
    
    # Step 14 - Network Profile & Final Cleanup
    $progressText.Text = "[14/14] Netværksprofil & Final cleanup..."
    $progressBar.Value = 100
    $progressPercent.Text = "100%"
    [System.Windows.Forms.Application]::DoEvents()
    
    $output += "[14/14] Netværksprofil & Final cleanup...`n"
    try {
        # Fjern gamle Windows Update logs
        $output += "  Rydder Windows Update logs...`n"
        Remove-Item "C:\Windows\Logs\CBS\*.log" -Force -ErrorAction SilentlyContinue
        Remove-Item "C:\Windows\Logs\DISM\*.log" -Force -ErrorAction SilentlyContinue
        $output += "  ✓ Update logs ryddet`n"
        
        # Reset netværksprofil cache (kan hjælpe med domæne login)
        $output += "  Opdaterer netværksprofiler...`n"
        Get-NetConnectionProfile -ErrorAction SilentlyContinue | ForEach-Object {
            Set-NetConnectionProfile -InterfaceIndex $_.InterfaceIndex -NetworkCategory Private -ErrorAction SilentlyContinue
        }
        $output += "  ✓ Netværksprofiler opdateret`n"
    } catch {
        $output += "  ⚠ Final cleanup delvist fejlet`n"
    }
    $output += "`n"
    
    $output += "═══════════════════════════════════════════`n"
    $output += "✓ DEEP CLEAN PRO AFSLUTTET!`n"
    $output += "PC er nu fuldt optimeret, repareret og scannet`n"
    $output += "⚠ TIP: Genstart PC for optimal performance"
    
    # Close progress window
    $progressWin.Close()
    
    # Show results dialog
    [xml]$cleanX = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="Deep Clean Pro - Rapport" Height="650" Width="650" Background="#FFFFFF" WindowStartupLocation="CenterOwner" Topmost="True">
        <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
            <Border Grid.Row="0" Background="#4CAF50" Padding="15,10,15,10">
                <TextBlock Text="✓ DEEP CLEAN PRO - AFSLUTTET" Foreground="White" HorizontalAlignment="Center" FontWeight="Bold" FontSize="12"/>
            </Border>
            <TextBox Grid.Row="1" Name="cleanLog" Margin="15" Background="#F5F5F5" Foreground="#333333" FontFamily="Segoe UI Mono" FontSize="9" IsReadOnly="True" VerticalScrollBarVisibility="Auto" TextWrapping="Wrap"/>
            <Button Grid.Row="2" Name="cleanClose" Content="LUK" Margin="15,10,15,10" Height="35" Background="#4CAF50" Foreground="White" HorizontalAlignment="Right" Width="100" FontWeight="Bold"/>
        </Grid>
    </Window>
"@
    $cleanWin = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $cleanX))
    $cleanLog = $cleanWin.FindName("cleanLog")
    $cleanClose = $cleanWin.FindName("cleanClose")
    $cleanClose.Add_Click({ $cleanWin.Close() })
    
    $cleanLog.Text = $output
    $cleanWin.Owner = $window
    $cleanWin.ShowDialog() | Out-Null
})

$BtnAsset.Add_Click({
    [xml]$assetX = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="PC Information" Height="420" Width="550" Background="#FFFFFF" WindowStartupLocation="CenterOwner" Topmost="True">
        <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
            <Border Grid.Row="0" Background="#00BCD4" Padding="15,10,15,10">
                <TextBlock Text="💻 PC INFORMATION" Foreground="White" HorizontalAlignment="Center" FontWeight="Bold" FontSize="12"/>
            </Border>
            <TextBox Grid.Row="1" Name="assetLog" Margin="15" Background="#F5F5F5" Foreground="#1A237E" FontFamily="Segoe UI Mono" FontSize="10" IsReadOnly="True" VerticalScrollBarVisibility="Auto" TextWrapping="Wrap"/>
            <Button Grid.Row="2" Name="assetClose" Content="LUK" Margin="15,10,15,10" Height="35" Background="#00BCD4" Foreground="White" HorizontalAlignment="Right" Width="100" FontWeight="Bold"/>
        </Grid>
    </Window>
"@
    $assetWin = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $assetX))
    $assetLog = $assetWin.FindName("assetLog")
    $assetClose = $assetWin.FindName("assetClose")
    $assetClose.Add_Click({ $assetWin.Close() })
    
    $output = "═══════════ PC INFORMATION ═══════════`n`n"
    
    $cs = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue
    $bios = Get-CimInstance Win32_Bios -ErrorAction SilentlyContinue
    $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
    $cpu = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue
    
    $output += "PC NAVN:           $env:COMPUTERNAME`n"
    $output += "SERIENUMMER:       $($bios.SerialNumber)`n`n"
    
    $output += "FABRIKANT:         $($cs.Manufacturer)`n"
    $output += "MODEL:             $($cs.Model)`n`n"
    
    $output += "WINDOWS VERSION:   $($os.Caption)`n"
    $output += "BUILD:             $($os.Version)`n`n"
    
    $output += "PROCESSOR:         $($cpu.Name)`n"
    $totalRAM = [math]::Round($cs.TotalPhysicalMemory/1GB, 2)
    $output += "RAM:               $totalRAM GB`n`n"
    
    $output += "BRUGER:            $env:USERNAME`n"
    $output += "DOMÆNE:            $($cs.Domain)`n`n"
    
    $output += "═══════════════════════════════════════════"
    
    $assetLog.Text = $output
    $assetWin.Owner = $window
    $assetWin.ShowDialog() | Out-Null
})
$BtnPortal.Add_Click({
    [xml]$portalX = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="Åbn Portaler" Height="280" Width="480" Background="#FFFFFF" WindowStartupLocation="CenterOwner" Topmost="True">
        <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
            <Border Grid.Row="0" Background="#1976D2" Padding="15,10,15,10">
                <TextBlock Text="🔗 ÅBN PORTALER" Foreground="White" HorizontalAlignment="Center" FontWeight="Bold" FontSize="12"/>
            </Border>
            <TextBox Grid.Row="1" Name="portalLog" Margin="15" Background="#F5F5F5" Foreground="#333333" FontFamily="Segoe UI" FontSize="11" IsReadOnly="True" VerticalScrollBarVisibility="Auto" TextWrapping="Wrap"/>
            <Button Grid.Row="2" Name="portalClose" Content="LUK" Margin="15,10,15,10" Height="35" Background="#1976D2" Foreground="White" HorizontalAlignment="Right" Width="100" FontWeight="Bold"/>
        </Grid>
    </Window>
"@
    $portalWin = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $portalX))
    $portalLog = $portalWin.FindName("portalLog")
    $portalClose = $portalWin.FindName("portalClose")
    $portalClose.Add_Click({ $portalWin.Close() })
    
    $output = "Åbner Portaler`n"
    $output += "═══════════════`n`n"
    $output += "Åbner Office 365 Portal...`n"
    Start-Process "https://portal.office.com"
    $output += "✓ Office 365 åbnet`n`n"
    
    $output += "Åbner UMS Portal...`n"
    Start-Process "https://ums.herningsholm.dk"
    $output += "✓ UMS åbnet`n"
    
    $portalLog.Text = $output
    $portalWin.Owner = $window
    $portalWin.ShowDialog() | Out-Null
})
$BtnNet.Add_Click({
    [xml]$netX = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="IP Adresser" Height="450" Width="600" Background="#FFFFFF" WindowStartupLocation="CenterOwner" Topmost="True">
        <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
            <Border Grid.Row="0" Background="#0097A7" Padding="15,10,15,10">
                <TextBlock Text="🌐 IP ADRESSER" Foreground="White" HorizontalAlignment="Center" FontWeight="Bold" FontSize="12"/>
            </Border>
            <TextBox Grid.Row="1" Name="netLog" Margin="15" Background="#F5F5F5" Foreground="#1A237E" FontFamily="Segoe UI Mono" FontSize="10" IsReadOnly="True" VerticalScrollBarVisibility="Auto" TextWrapping="Wrap"/>
            <Button Grid.Row="2" Name="netClose" Content="LUK" Margin="15,10,15,10" Height="35" Background="#0097A7" Foreground="White" HorizontalAlignment="Right" Width="100" FontWeight="Bold"/>
        </Grid>
    </Window>
"@
    $netWin = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $netX))
    $netLog = $netWin.FindName("netLog")
    $netClose = $netWin.FindName("netClose")
    $netClose.Add_Click({ $netWin.Close() })
    
    $output = "═══════════ NETVÆRK IP ADRESSER ═══════════`n`n"
    
    $adapters = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loop*" }
    
    foreach ($adapter in $adapters) {
        $output += "INTERFACE:         $($adapter.InterfaceAlias)`n"
        $output += "IP ADRESSE:        $($adapter.IPAddress)`n"
        $output += "PREFIX LENGTH:     $($adapter.PrefixLength)`n"
        $output += "STATUS:            $($adapter.AddressState)`n"
        $output += "─────────────────────────────────────────`n"
    }
    
    $output += "`n═══════════════════════════════════════════"
    
    $netLog.Text = $output
    $netWin.Owner = $window
    $netWin.ShowDialog() | Out-Null
})
$BtnPrint.Add_Click({ Run-Task { Restart-Service Spooler -Force } })
$BtnChrome.Add_Click({ Run-Task { Stop-Process -Name chrome -Force -EA SilentlyContinue; Remove-Item "$env:LocalAppData\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -EA SilentlyContinue } })
$BtnUI.Add_Click({ Run-Task { Stop-Process -Name explorer -Force; Start-Process explorer } })
$BtnUpdate.Add_Click({
    try {
        # Progress window (like Deep Clean)
        [xml]$progressX = @"
        <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="Opdateringer - Arbejder..." Height="220" Width="500" Background="#FFFFFF" WindowStartupLocation="CenterOwner" Topmost="True" ResizeMode="NoResize">
            <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/></Grid.RowDefinitions>
                <Border Grid.Row="0" Background="#AB47BC" Padding="15,10,15,10">
                    <TextBlock Text="⬆ OPDATERINGER &amp; DRIVERE - ARBEJDER..." Foreground="White" HorizontalAlignment="Center" FontWeight="Bold" FontSize="12"/>
                </Border>
                <StackPanel Grid.Row="1" Margin="20" VerticalAlignment="Center">
                    <TextBlock Name="progressText" Text="Starter opdateringer..." FontFamily="Segoe UI" FontSize="11" Foreground="#333" Margin="0,0,0,10"/>
                    <ProgressBar Name="progressBar" Height="25" Minimum="0" Maximum="100" Value="0"/>
                    <TextBlock Name="progressPercent" Text="0%" FontFamily="Segoe UI Semibold" FontSize="10" Foreground="#AB47BC" HorizontalAlignment="Center" Margin="0,8,0,0"/>
                </StackPanel>
            </Grid>
        </Window>
        "@

        $progressWin = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $progressX))
        $progressText = $progressWin.FindName("progressText")
        $progressBar = $progressWin.FindName("progressBar")
        $progressPercent = $progressWin.FindName("progressPercent")
        $progressWin.Owner = $window
        $progressWin.Show()
        [System.Windows.Forms.Application]::DoEvents()

        $out = "════════ OPPDATERINGER ════════`n`n"
        $cs = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue
        $vendor = $cs.Manufacturer
        $model = $cs.Model
        $out += "Maskine: $vendor - $model`n`n"

        # 1) Windows Update
        $progressText.Text = "[1/4] Windows Update..."
        $progressBar.Value = 10
        $progressPercent.Text = "10%"
        [System.Windows.Forms.Application]::DoEvents()
        $out += "[1/4] Windows Update...`n"
        try {
        $wuService = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
        if ($wuService) { Start-Service -Name wuauserv -ErrorAction SilentlyContinue }
        $out += "  - Starter scan...`n"
        try { & usoclient StartScan 2>&1 | Out-Null } catch { }
        Start-Sleep -Seconds 2
        $out += "  - Installerer tilgængelige opdateringer...`n"
        try { & usoclient StartInstall 2>&1 | Out-Null } catch { }
        $out += "  ✓ Windows Update trigget (kan køre i baggrunden)`n`n"
        } catch {
            $out += "  ⚠ Windows Update fejl: $($_.Exception.Message)`n`n"
        }

        # 2) OEM/BIOS/Driver
        $out += "[2/4] OEM BIOS/Driver...`n"
        if ($vendor -match 'HP') {
            $progressText.Text = "[2/4] OEM BIOS/Driver..."
            $progressBar.Value = 40
            $progressPercent.Text = "40%"
            [System.Windows.Forms.Application]::DoEvents()
            $out += "[2/4] OEM BIOS/Driver...`n"
        $hpiaExe = "C:\\Program Files\\HP\\HPIA\\HPImageAssistant.exe"
        $hpiaInstalled = Test-Path $hpiaExe
        if (-not $hpiaInstalled -and (Get-Command winget -ErrorAction SilentlyContinue)) {
            $out += "    • Installerer HP Image Assistant via winget...`n"
            try {
                winget install --id "HP.HPIA" --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
                $hpiaInstalled = Test-Path $hpiaExe
                if ($hpiaInstalled) { $out += "    ✓ HPIA installeret`n" } else { $out += "    ⚠ HPIA kunne ikke installeres`n" }
            } catch {
                $out += "    ⚠ HPIA installation fejlede: $($_.Exception.Message)`n"
            }
        }

        if ($hpiaInstalled) {
            $reportDir = Join-Path $env:TEMP "HPIAReports"
            if (-not (Test-Path $reportDir)) { New-Item -ItemType Directory -Path $reportDir -Force | Out-Null }
            $logFile = Join-Path $reportDir "HPIA.log"
            $hpiaArgs = "/Operation:Analyze /Category:BIOS,Driver,Firmware,Software,Security /Selection:All /Action:Install /Silent /BIOS:Install /ReportFolder:`"$reportDir`" /OutputLog:`"$logFile`""
            $out += "    • Kører HPIA (5-15 min)...`n"
            try {
                $proc = Start-Process -FilePath $hpiaExe -ArgumentList $hpiaArgs -NoNewWindow -Wait -PassThru -ErrorAction Stop
                $out += "    ✓ HPIA færdig (ExitCode: $($proc.ExitCode))`n"
                $out += "    Rapporter: $reportDir`n`n"
            } catch {
                $out += "    ⚠ HPIA fejl: $($_.Exception.Message)`n`n"
            }
        } else {
            $out += "    ⚠ HPIA ikke installeret - springer HP BIOS/driver over`n`n"
        }
    } elseif ($vendor -match 'Lenovo') {
        $out += "  - Lenovo maskine opdaget -> prøver Lenovo System Update`n"
        $lenovoExe = "C:\\Program Files (x86)\\Lenovo\\System Update\\tvsu.exe"
        $lenovoInstalled = Test-Path $lenovoExe
        if (-not $lenovoInstalled -and (Get-Command winget -ErrorAction SilentlyContinue)) {
            $out += "    • Installerer Lenovo System Update via winget...`n"
            try {
                winget install --id "Lenovo.SystemUpdate" --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
                $lenovoInstalled = Test-Path $lenovoExe
                if ($lenovoInstalled) { $out += "    ✓ System Update installeret`n" } else { $out += "    ⚠ System Update ikke installeret`n" }
            } catch {
                $out += "    ⚠ Installation fejlede: $($_.Exception.Message)`n"
            }
        }

        if ($lenovoInstalled) {
            $out += "    • Kører Lenovo System Update (kan åbne UI/ta lidt tid)...`n"
            try {
                $proc = Start-Process -FilePath $lenovoExe -ArgumentList "/CM" -NoNewWindow -PassThru -ErrorAction Stop
                $proc.WaitForExit(900000) # 15 min timeout
                $out += "    ✓ Lenovo System Update kørt (ExitCode: $($proc.ExitCode))`n`n"
            } catch {
                $out += "    ⚠ Lenovo System Update fejl: $($_.Exception.Message)`n`n"
            }
        } else {
            $out += "    ⚠ Lenovo System Update ikke tilgængelig - brug Vantage/System Update manuelt for BIOS/driver`n`n"
        }
    } elseif ($vendor -match 'Acer') {
        $out += "  - Acer maskine (ingen silent OEM-værktøj tilgængelig). Brug Acer Care Center/manual BIOS hvis krævet.`n`n"
    } elseif ($vendor -match 'ASUS') {
        $out += "  - ASUS maskine (ingen silent OEM-værktøj tilgængelig). Brug MyASUS/Support site for BIOS/driver hvis krævet.`n`n"
    } else {
        $out += "  - OEM ikke kendt/specificeret (vendor: $vendor). Brug Windows Update + winget (allerede kørt) for drivere/apps.`n`n"
    }

    # 3) Winget app updates
    $out += "[3/4] App opdateringer (winget)...`n"
    try {
        $progressText.Text = "[3/4] App opdateringer (winget)..."
        $progressBar.Value = 70
        $progressPercent.Text = "70%"
        [System.Windows.Forms.Application]::DoEvents()
        $out += "[3/4] App opdateringer (winget)...`n"
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            $out += "  - Finder opdateringer...`n"
            & winget upgrade --all --accept-package-agreements --accept-source-agreements --silent 2>&1 | Out-Null
            $out += "  ✓ App opdateringer kørt`n`n"
        } else {
            $out += "  ⚠ winget ikke tilgængelig`n`n"
        }
    } catch {
        $out += "  ⚠ App update fejl: $($_.Exception.Message)`n`n"
    }

    # 4) Cleanup
    $out += "[4/4] Rydder op...`n"
    try {
        $progressText.Text = "[4/4] Rydder op..."
        $progressBar.Value = 100
        $progressPercent.Text = "100%"
        [System.Windows.Forms.Application]::DoEvents()
        $out += "[4/4] Rydder op...`n"
        Remove-Item 'C:\\Windows\\Temp\\*' -Recurse -Force -ErrorAction SilentlyContinue
        try { Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue } catch { }
        try { Remove-Item 'C:\\Windows\\SoftwareDistribution\\Download\\*' -Recurse -Force -ErrorAction SilentlyContinue } catch { }
        try { Start-Service -Name wuauserv -ErrorAction SilentlyContinue } catch { }
        ipconfig /flushdns 2>&1 | Out-Null
        $out += "  ✓ Temp + DNS ryddet`n"
    } catch {
        $out += "  ⚠ Cleanup fejl: $($_.Exception.Message)`n"
    }

    $out += "`n════════ DONE ════════`nGenstart anbefales for BIOS/driver ændringer."

        # Close progress and show final log dialog
        $progressWin.Close()

        [xml]$updX = @"
        <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="Opdateringer" Height="520" Width="550" Background="#FFFFFF" WindowStartupLocation="CenterOwner" Topmost="True">
            <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                <Border Grid.Row="0" Background="#AB47BC" Padding="15,10,15,10">
                    <TextBlock Text="⬆ OPDATERINGER &amp; DRIVERE (OEM/HP BIOS)" Foreground="White" HorizontalAlignment="Center" FontWeight="Bold" FontSize="12"/>
                </Border>
                <TextBox Grid.Row="1" Name="updLog" Margin="15" Background="#F5F5F5" Foreground="#1A237E" FontFamily="Segoe UI Mono" FontSize="10" IsReadOnly="True" VerticalScrollBarVisibility="Auto" TextWrapping="Wrap"/>
                <Button Grid.Row="2" Name="updClose" Content="LUK" Margin="15,10,15,10" Height="35" Background="#AB47BC" Foreground="White" HorizontalAlignment="Right" Width="100" FontWeight="Bold"/>
            </Grid>
        </Window>
        "@

        $updWin = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $updX))
        $updLog = $updWin.FindName("updLog")
        $updClose = $updWin.FindName("updClose")
        $updClose.Add_Click({ $updWin.Close() })
        $updLog.Text = $out
        $updWin.Owner = $window
        $updWin.ShowDialog() | Out-Null
    } catch {
        [System.Windows.MessageBox]::Show("Der opstod en fejl under opdatering:`n`n$($_.Exception.Message)", "Fejl", "OK", "Error")
    }
})
$BtnDisk.Add_Click({
    [xml]$diskX = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="Disk Plads" Height="420" Width="550" Background="#FFFFFF" WindowStartupLocation="CenterOwner" Topmost="True">
        <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
            <Border Grid.Row="0" Background="#26A69A" Padding="15,10,15,10">
                <TextBlock Text="💾 DISK PLADS" Foreground="White" HorizontalAlignment="Center" FontWeight="Bold" FontSize="12"/>
            </Border>
            <TextBox Grid.Row="1" Name="diskLog" Margin="15" Background="#F5F5F5" Foreground="#1A237E" FontFamily="Segoe UI Mono" FontSize="10" IsReadOnly="True" VerticalScrollBarVisibility="Auto" TextWrapping="Wrap"/>
            <Button Grid.Row="2" Name="diskClose" Content="LUK" Margin="15,10,15,10" Height="35" Background="#26A69A" Foreground="White" HorizontalAlignment="Right" Width="100" FontWeight="Bold"/>
        </Grid>
    </Window>
"@
    $diskWin = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $diskX))
    $diskLog = $diskWin.FindName("diskLog")
    $diskClose = $diskWin.FindName("diskClose")
    $diskClose.Add_Click({ $diskWin.Close() })
    
    $output = "═══════════ DISK PLADS OVERSIGT ═══════════`n`n"
    
    $disks = Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
    
    foreach ($disk in $disks) {
        $freeGB = [math]::Round($disk.FreeSpace/1GB, 2)
        $totalGB = [math]::Round($disk.Size/1GB, 2)
        $usedGB = [math]::Round(($disk.Size - $disk.FreeSpace)/1GB, 2)
        $percentFree = [math]::Round(($disk.FreeSpace / $disk.Size) * 100, 1)
        
        $output += "DREV:              $($disk.DeviceID)`n"
        $output += "TOTAL STØRRELSE:   $totalGB GB`n"
        $output += "BRUGT:             $usedGB GB`n"
        $output += "LEDIG:             $freeGB GB ($percentFree%)`n"
        
        if ($percentFree -lt 10) {
            $output += "STATUS:            ⚠ KRITISK LAV PLADS!`n"
        } elseif ($percentFree -lt 20) {
            $output += "STATUS:            ⚠ LAV PLADS`n"
        } else {
            $output += "STATUS:            ✓ OK`n"
        }
        
        $output += "─────────────────────────────────────────`n"
    }
    
    $output += "`n═══════════════════════════════════════════"
    
    $diskLog.Text = $output
    $diskWin.Owner = $window
    $diskWin.ShowDialog() | Out-Null
})
$BtnPerf.Add_Click({
    [xml]$perfX = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="RAM Monitor" Height="420" Width="550" Background="#FFFFFF" WindowStartupLocation="CenterOwner" Topmost="True">
        <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
            <Border Grid.Row="0" Background="#00897B" Padding="15,10,15,10">
                <TextBlock Text="📈 RAM MONITOR - TOP 10 PROCESSER" Foreground="White" HorizontalAlignment="Center" FontWeight="Bold" FontSize="12"/>
            </Border>
            <TextBox Grid.Row="1" Name="perfLog" Margin="15" Background="#F5F5F5" Foreground="#1A237E" FontFamily="Segoe UI Mono" FontSize="10" IsReadOnly="True" VerticalScrollBarVisibility="Auto" TextWrapping="Wrap"/>
            <Button Grid.Row="2" Name="perfClose" Content="LUK" Margin="15,10,15,10" Height="35" Background="#00897B" Foreground="White" HorizontalAlignment="Right" Width="100" FontWeight="Bold"/>
        </Grid>
    </Window>
"@
    $perfWin = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $perfX))
    $perfLog = $perfWin.FindName("perfLog")
    $perfClose = $perfWin.FindName("perfClose")
    
    $perfClose.Add_Click({ $perfWin.Close() })
    
    # Hent processer og vis
    $output = "TOP 10 PROCESSER (RAM FORBRUG)`n"
    $output += "════════════════════════════════════════`n`n"
    $procs = Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 10
    foreach($p in $procs) {
        $mb = [math]::Round($p.WorkingSet64/1MB, 2)
        $output += "$($p.Name.PadRight(28)) : $($mb.ToString().PadLeft(8)) MB`n"
    }
    $output += "════════════════════════════════════════`n`n"
    $totalMB = [math]::Round(($procs | Measure-Object WorkingSet64 -Sum).Sum/1MB, 2)
    $output += "Total af Top 10 : $totalMB MB"
    
    $perfLog.Text = $output
    $perfWin.Owner = $window
    $perfWin.ShowDialog() | Out-Null
})
$BtnKaisai.Add_Click({ Run-Task { Write-Host '=== TID & DOMÆNE SYNC ===' -ForegroundColor Cyan; Write-Host '[1/2] Synkroniserer systemtid...'; w32tm /resync; Write-Host '✓ Tid synkroniseret' -ForegroundColor Green; Write-Host '[2/2] Opdaterer Group Policy...'; gpupdate /force; Write-Host '✓ GPO opdateret' -ForegroundColor Green } })

# --- ELEV PRINT (Download known-hosts, copy to Downloads, optionally copy to printer path, then open) ---
$BtnElevPrint.Add_Click({
    Run-Task {
        $url = 'https://papercut.herningsholm.dk:9164/known-hosts/windows'
        $fileName = 'known-hosts-windows'
        $out = Join-Path $env:TEMP $fileName
        Write-Host "Downloader $url -> $out"
        try {
            Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing -ErrorAction Stop
            Write-Host "Download færdig: $out"

            # Kopier til Brugerens Overførsler (Downloads)
            $downloads = Join-Path $env:USERPROFILE 'Downloads'
            if (-not (Test-Path $downloads)) { New-Item -ItemType Directory -Path $downloads | Out-Null }
            $dest = Join-Path $downloads $fileName
            try {
                Copy-Item -Path $out -Destination $dest -Force -ErrorAction Stop
                Write-Host "Kopieret til Overførsler: $dest"
            } catch {
                Write-Host "Kopi til Overførsler fejlede: $_"
            }

            # Valgfrit: kopier til konfigureret printer-path (script-variablen)
            if ($ElevPrintPrinterPath -and ($ElevPrintPrinterPath -ne '')) {
                try {
                    Copy-Item -Path $out -Destination $ElevPrintPrinterPath -Force -ErrorAction Stop
                    Write-Host "Kopieret til printer-sti: $ElevPrintPrinterPath"
                } catch {
                    Write-Host "Kopi til printer-sti fejlede: $_"
                }
            }

            # Åbn filen i standardapplikationen
            try { Start-Process -FilePath $dest -ErrorAction SilentlyContinue } catch { }
        } catch {
            Write-Host "Download fejlede: $_"
        }
    }
})

$BtnExit.Add_Click({ $window.Close() })
    $window.ShowDialog() | Out-Null
} catch {
    try {
        $log = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'herningsholm_launch_error.txt'
        $_ | Out-String | Out-File -FilePath $log -Force
        Write-Host "Fejl ved start. Se log: $log"
    } catch {
        Write-Host "Fejl ved start, men kunne ikke skrive log: $_"
    }
    throw
}