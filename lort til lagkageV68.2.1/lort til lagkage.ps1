# --- FASE 1: ADMIN & GHOST MODE ---
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}
$code = '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);'
$type = Add-Type -MemberDefinition $code -Name Window -Namespace Console -PassThru
$type::ShowWindow((Get-Process -Id $pid).MainWindowHandle, 0)

Add-Type -AssemblyName PresentationFramework, System.Windows.Forms

# --- HOVED GUI (V68.2.1 - ALLE 15 KNAPPER) ---
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Herningsholm IT Support - V68.2.1" Height="700" Width="650" Background="#0A0A0A" WindowStartupLocation="CenterScreen" ResizeMode="CanResize">
    <Grid Margin="15">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <Border Grid.Row="0" Background="#1A1A1A" CornerRadius="5" Padding="15" Margin="0,0,0,15" BorderBrush="#FFD700" BorderThickness="0,0,0,3">
            <StackPanel>
                <TextBlock Text="HERNINGSHOLM IT" FontSize="26" FontWeight="Black" Foreground="#FFD700" HorizontalAlignment="Center"/>
                <TextBlock Text="IT SUPPORT ELEV - VERSION V68.2.1 (FULL TOOLSET)" FontSize="11" Foreground="#00FF00" HorizontalAlignment="Center" FontWeight="Bold"/>
            </StackPanel>
        </Border>

        <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto">
            <UniformGrid Columns="2" VerticalAlignment="Top">
                <Button Name="BtnInstall" Content="SOFTWARE VÆLGER" Background="#880E4F" Foreground="White" FontWeight="Bold" Margin="4" Height="70" ToolTip="Installer standard programmer."/>
                <Button Name="BtnBloat" Content="BLOATWARE REMOVER" Background="#B71C1C" Foreground="White" FontWeight="Bold" Margin="4" Height="70" ToolTip="Fjern antivirus og lorteprogrammer."/>
                <Button Name="BtnTeams" Content="OFFICE / TEAMS FIX" Background="#0D47A1" Foreground="White" FontWeight="Bold" Margin="4" Height="70" ToolTip="Rens Office identity cache."/>
                <Button Name="BtnWifi" Content="NETVÆRKS DOKTOR" Background="#006064" Foreground="White" FontWeight="Bold" Margin="4" Height="70" ToolTip="Reset IP/DNS/Winsock."/>
                <Button Name="BtnAsset" Content="PC INFO + SERIENR" Background="#E65100" Foreground="White" FontWeight="Bold" Margin="4" Height="70" ToolTip="Vis Serienummer og Navn."/>
                <Button Name="BtnNet" Content="TJEK IP ADRESSE" Background="#1B5E20" Foreground="White" FontWeight="Bold" Margin="4" Height="70" ToolTip="Viser lokal IP."/>
                <Button Name="BtnUpdate" Content="TVING UPDATES" Background="#5D4037" Foreground="White" FontWeight="Bold" Margin="4" Height="70" ToolTip="Kør Winget Upgrade."/>
                <Button Name="BtnCloud" Content="ONEDRIVE DEEP CLEAN" Background="#01579B" Foreground="White" FontWeight="Bold" Margin="4" Height="70" ToolTip="Nulstil alt OneDrive."/>
                <Button Name="BtnClean" Content="RYD OP I SKRALD" Background="#37474F" Foreground="White" FontWeight="Bold" Margin="4" Height="70" ToolTip="Slet Temp filer."/>
                <Button Name="BtnDisk" Content="TJEK DISK-PLADS" Background="#455A64" Foreground="White" FontWeight="Bold" Margin="4" Height="70" ToolTip="Tjek plads på C:."/>
                <Button Name="BtnPerf" Content="RAM OVERVÅGNING" Background="#212121" Foreground="White" FontWeight="Bold" Margin="4" Height="70" ToolTip="Tjek RAM forbrug."/>
                <Button Name="BtnKaisai" Content="TID OG DOMÆNE SYNC" Background="#311B92" Foreground="White" FontWeight="Bold" Margin="4" Height="70" ToolTip="Sync tid og GPO."/>
                <Button Name="BtnChrome" Content="NUKE CHROME CACHE" Background="#C62828" Foreground="White" FontWeight="Bold" Margin="4" Height="70" ToolTip="Rens Chrome helt."/>
                <Button Name="BtnPrint" Content="PRINTER REPARATION" Background="#2E7D32" Foreground="White" FontWeight="Bold" Margin="4" Height="70" ToolTip="Restart Spooler."/>
                <Button Name="BtnUI" Content="FIX START-MENU" Background="#4A148C" Foreground="White" FontWeight="Bold" Margin="4" Height="70" ToolTip="Genstart Explorer."/>
            </UniformGrid>
        </ScrollViewer>

        <Grid Grid.Row="2" Margin="0,15,0,0">
            <TextBlock Text="Support Elev - Alle 15 værktøjer indlæst." Foreground="#44FF44" VerticalAlignment="Center" HorizontalAlignment="Left" FontSize="10" FontWeight="Bold"/>
            <Button Name="BtnExit" Content="LUK V68.2.1" Background="#222222" Width="95" Height="25" HorizontalAlignment="Right" Foreground="#AAAAAA" FontSize="10"/>
        </Grid>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Forbindelse af alle 15 knapper
$nodes = "BtnInstall","BtnBloat","BtnTeams","BtnWifi","BtnAsset","BtnNet","BtnUpdate","BtnCloud","BtnClean","BtnDisk","BtnPerf","BtnKaisai","BtnChrome","BtnPrint","BtnUI","BtnExit"
foreach($node in $nodes) { Set-Variable -Name $node -Value $window.FindName($node) }

function Run-Task ([scriptblock]$Code, $ArgsList) {
    $Encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($Code.ToString()))
    Start-Process powershell.exe -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-EncodedCommand", $Encoded -Wait
}

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
            </StackPanel></ScrollViewer>
            <Button Grid.Row="2" Name="bInst" Content="INSTALLER" Margin="15" Height="30" Background="#2E7D32" Foreground="White"/>
        </Grid>
    </Window>
"@
    $swWin = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $swX))
    $swWin.FindName("bInst").Add_Click({
        $list = @(); if($swWin.FindName("c1").IsChecked){$list+="Microsoft.Office"}; if($swWin.FindName("c2").IsChecked){$list+="Google.Chrome"}; if($swWin.FindName("c3").IsChecked){$list+="Microsoft.Teams"}
        $swWin.Close(); Run-Task { foreach($app in $args){ winget install --id $app -e --silent --accept-package-agreements }; pause } -ArgsList $list
    })
    $swWin.Owner = $window; $swWin.ShowDialog() | Out-Null
})

# --- BLOATWARE REMOVER ---
$BtnBloat.Add_Click({
    [xml]$blX = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="Fjern Bloat" Height="350" Width="300" Background="#111111" WindowStartupLocation="CenterOwner" Topmost="True">
        <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
            <TextBlock Grid.Row="0" Text="FJERN LORT" Foreground="#FF3D00" HorizontalAlignment="Center" Margin="10" FontWeight="Bold"/>
            <ScrollViewer Grid.Row="1" Margin="10,0"><StackPanel>
                <TextBlock Text="Antivirus" Foreground="#FFD700" Margin="0,5"/>
                <CheckBox Name="b1" Content="McAfee" Foreground="White" Margin="5,2"/><CheckBox Name="b2" Content="Norton" Foreground="White" Margin="5,2"/>
                <CheckBox Name="b3" Content="Avast" Foreground="White" Margin="5,2"/><CheckBox Name="b4" Content="AVG" Foreground="White" Margin="5,2"/>
                <TextBlock Text="Bloat" Foreground="#FFD700" Margin="0,10,0,5"/>
                <CheckBox Name="b5" Content="Candy Crush" Foreground="White" Margin="5,2"/><CheckBox Name="b7" Content="Disney+" Foreground="White" Margin="5,2"/>
                <CheckBox Name="b8" Content="Spotify" Foreground="White" Margin="5,2"/>
            </StackPanel></ScrollViewer>
            <Button Grid.Row="2" Name="bRem" Content="FJERNE VALGTE" Margin="15" Height="30" Background="#B71C1C" Foreground="White"/>
        </Grid>
    </Window>
"@
    $blWin = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $blX))
    $blWin.FindName("bRem").Add_Click({
        $list = @(); if($blWin.FindName("b1").IsChecked){$list+="McAfee.McAfee"}; if($blWin.FindName("b2").IsChecked){$list+="NortonLifeLock.NortonSecurity"}; if($blWin.FindName("b3").IsChecked){$list+="Avast.AvastFreeAntivirus"}
        $blWin.Close(); Run-Task { foreach($app in $args){ Write-Host "Fjerner $app..."; winget uninstall --id $app --silent }; pause } -ArgsList $list
    })
    $blWin.Owner = $window; $blWin.ShowDialog() | Out-Null
})

# --- FUNKTIONER ---
$BtnCloud.Add_Click({ Run-Task { Stop-Process -Name "OneDrive" -Force -EA SilentlyContinue; if(Test-Path "$env:LocalAppData\Microsoft\OneDrive\onedrive.exe"){& "$env:LocalAppData\Microsoft\OneDrive\onedrive.exe" /reset}; Remove-Item "$env:LocalAppData\Microsoft\OneDrive\settings" -Recurse -Force -EA SilentlyContinue; cmdkey /list | ForEach-Object { if($_ -like "*OneDrive*") { cmdkey /delete ($_ -split " ")[-1] } }; pause } })
$BtnTeams.Add_Click({ Run-Task { Stop-Process -Name "winword","excel","ms-teams","Teams" -Force -EA SilentlyContinue; Remove-Item "HKCU:\Software\Microsoft\Office\16.0\Common\Identity\Identities\*" -Recurse -Force -EA SilentlyContinue; pause } })
$BtnWifi.Add_Click({ Run-Task { netsh winsock reset; netsh int ip reset; ipconfig /flushdns; pause } })
$BtnAsset.Add_Click({ Run-Task { Write-Host "PC: $env:COMPUTERNAME`nSN: $((Get-CimInstance Win32_Bios).SerialNumber)"; pause } })
$BtnNet.Add_Click({ Run-Task { Get-NetIPAddress -AddressFamily IPv4 | Where-Object InterfaceAlias -notlike "*Loop*" | ft; pause } })
$BtnClean.Add_Click({ Run-Task { Remove-Item "$env:TEMP\*" -Recurse -Force -EA SilentlyContinue; pause } })
$BtnPrint.Add_Click({ Run-Task { Restart-Service Spooler -Force; pause } })
$BtnChrome.Add_Click({ Run-Task { Stop-Process -Name chrome -Force -EA SilentlyContinue; Remove-Item "$env:LocalAppData\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -EA SilentlyContinue; pause } })
$BtnUI.Add_Click({ Run-Task { Stop-Process -Name explorer -Force; Start-Process explorer } })
$BtnUpdate.Add_Click({ Run-Task { winget upgrade --all; pause } })
$BtnDisk.Add_Click({ Run-Task { $d=Get-CimInstance Win32_LogicalDisk|Where DeviceID -eq "C:"; Write-Host "Ledig: $([math]::Round($d.FreeSpace/1GB,2)) GB"; pause } })
$BtnPerf.Add_Click({ Run-Task { Get-Process|Sort WorkingSet64 -Desc|Select -First 10 Name, @{N='MB';E={$_.WorkingSet64/1MB}}|ft; pause } })
$BtnKaisai.Add_Click({ Run-Task { w32tm /resync; gpupdate /force; pause } })

$BtnExit.Add_Click({ $window.Close() })
$window.ShowDialog() | Out-Null