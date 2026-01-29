# --- FASE 1: ADMIN & GHOST MODE ---
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}
$code = '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);'
$type = Add-Type -MemberDefinition $code -Name Window -Namespace Console -PassThru
$type::ShowWindow((Get-Process -Id $pid).MainWindowHandle, 0)

Add-Type -AssemblyName PresentationFramework, System.Windows.Forms

# --- GUI DESIGN (V68.1 BASE) ---
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Herningsholm IT Support - V68.1" Height="750" Width="600" Background="#0A0A0A" WindowStartupLocation="CenterScreen" ResizeMode="NoResize">
    <Grid Margin="15">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <Border Grid.Row="0" Background="#1A1A1A" CornerRadius="5" Padding="15" Margin="0,0,0,15" BorderBrush="#FFD700" BorderThickness="0,0,0,3">
            <StackPanel>
                <TextBlock Text="HERNINGSHOLM IT" FontSize="26" FontWeight="Black" Foreground="#FFD700" HorizontalAlignment="Center"/>
                <TextBlock Text="IT SUPPORT ELEV - V68.1 ULTIMATE" FontSize="11" Foreground="#00FF00" HorizontalAlignment="Center" FontWeight="Bold"/>
            </StackPanel>
        </Border>

        <UniformGrid Grid.Row="1" Columns="2">
            <Button Name="BtnInstall" Content="SOFTWARE VÆLGER" Background="#880E4F" Foreground="White" FontWeight="Bold" Margin="4"/>
            <Button Name="BtnTeams" Content="OFFICE / TEAMS FIX" Background="#0D47A1" Foreground="White" FontWeight="Bold" Margin="4"/>
            <Button Name="BtnWifi" Content="NETVÆRKS DOKTOR" Background="#006064" Foreground="White" FontWeight="Bold" Margin="4"/>
            <Button Name="BtnUI" Content="FIX START-MENU" Background="#4A148C" Foreground="White" FontWeight="Bold" Margin="4"/>
            <Button Name="BtnAsset" Content="PC INFO + SERIENR" Background="#E65100" Foreground="White" FontWeight="Bold" Margin="4"/>
            <Button Name="BtnNet" Content="TJEK IP ADRESSE" Background="#1B5E20" Foreground="White" FontWeight="Bold" Margin="4"/>
            <Button Name="BtnUpdate" Content="TVING UPDATES" Background="#B71C1C" Foreground="White" FontWeight="Bold" Margin="4"/>
            <Button Name="BtnCloud" Content="ONEDRIVE RESET" Background="#01579B" Foreground="White" FontWeight="Bold" Margin="4"/>
            <Button Name="BtnClean" Content="RYD OP I SKRALD" Background="#37474F" Foreground="White" FontWeight="Bold" Margin="4"/>
            <Button Name="BtnDisk" Content="TJEK DISK-PLADS" Background="#455A64" Foreground="White" FontWeight="Bold" Margin="4"/>
            <Button Name="BtnPerf" Content="RAM OVERVÅGNING" Background="#212121" Foreground="White" FontWeight="Bold" Margin="4"/>
            <Button Name="BtnKaisai" Content="TID OG DOMÆNE SYNC" Background="#311B92" Foreground="White" FontWeight="Bold" Margin="4"/>
            <Button Name="BtnChrome" Content="NUKE CHROME CACHE" Background="#C62828" Foreground="White" FontWeight="Bold" Margin="4"/>
            <Button Name="BtnPrint" Content="PRINTER REPARATION" Background="#2E7D32" Foreground="White" FontWeight="Bold" Margin="4"/>
        </UniformGrid>

        <Grid Grid.Row="2" Margin="0,15,0,0">
            <TextBlock Text="Klar til næste elev..." Foreground="#44FF44" VerticalAlignment="Center" HorizontalAlignment="Left" FontSize="10" FontWeight="Bold"/>
            <Button Name="BtnExit" Content="LUK" Background="#222222" Width="85" Height="25" HorizontalAlignment="Right" Foreground="#AAAAAA" FontSize="10"/>
        </Grid>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Forbindelse af knapper
$nodes = "BtnInstall","BtnTeams","BtnWifi","BtnUI","BtnAsset","BtnNet","BtnUpdate","BtnCloud","BtnClean","BtnDisk","BtnPerf","BtnKaisai","BtnChrome","BtnPrint","BtnExit"
foreach($node in $nodes) { Set-Variable -Name $node -Value $window.FindName($node) }

function Run-Task ([scriptblock]$Code, $ArgsList) {
    $Encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($Code.ToString()))
    Start-Process powershell.exe -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-EncodedCommand", $Encoded -Wait
}

# --- SOFTWARE VÆLGER GUI ---
$BtnInstall.Add_Click({
    [xml]$swX = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="Vælg Software" Height="350" Width="300" Background="#111111" WindowStartupLocation="CenterOwner" ResizeMode="NoResize">
        <StackPanel Margin="20">
            <TextBlock Text="INSTALLATION" Foreground="#FFD700" FontSize="18" FontWeight="Bold" Margin="0,0,0,10"/>
            <CheckBox Name="c1" Content="Microsoft Office 365" Foreground="White" Margin="5" FontSize="14"/>
            <CheckBox Name="c2" Content="Google Chrome" Foreground="White" Margin="5" FontSize="14"/>
            <CheckBox Name="c3" Content="Microsoft Teams" Foreground="White" Margin="5" FontSize="14"/>
            <CheckBox Name="c4" Content="VLC Player" Foreground="White" Margin="5" FontSize="14"/>
            <Button Name="bInst" Content="START INSTALL" Margin="0,20,0,0" Height="40" Background="#2E7D32" Foreground="White" FontWeight="Bold"/>
        </StackPanel>
    </Window>
"@
    $swWin = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $swX))
    $swWin.FindName("bInst").Add_Click({
        $list = @()
        if($swWin.FindName("c1").IsChecked){$list += "Microsoft.Office"}
        if($swWin.FindName("c2").IsChecked){$list += "Google.Chrome"}
        if($swWin.FindName("c3").IsChecked){$list += "Microsoft.Teams"}
        if($swWin.FindName("c4").IsChecked){$list += "VideoLAN.VLC"}
        $swWin.Close()
        Run-Task { foreach($app in $args){ Write-Host "Installerer $app..."; winget install --id $app -e --silent --accept-package-agreements }; pause } -ArgsList $list
    })
    $swWin.Owner = $window; $swWin.ShowDialog() | Out-Null
})

# --- ØVRIGE FUNKTIONER ---
$BtnTeams.Add_Click({ Run-Task { Stop-Process -Name "winword","excel","ms-teams","Teams" -Force -EA SilentlyContinue; Remove-Item "HKCU:\Software\Microsoft\Office\16.0\Common\Identity\Identities\*" -Recurse -Force -EA SilentlyContinue; pause } })
$BtnWifi.Add_Click({ Run-Task { netsh winsock reset; netsh int ip reset; ipconfig /flushdns; pause } })
$BtnUI.Add_Click({ Run-Task { Stop-Process -Name explorer -Force; Start-Process explorer } })
$BtnAsset.Add_Click({ Run-Task { Write-Host "PC: $env:COMPUTERNAME"; Write-Host "SN: $((Get-CimInstance Win32_Bios).SerialNumber)"; pause } })
$BtnNet.Add_Click({ Run-Task { Get-NetIPAddress -AddressFamily IPv4 | Where-Object InterfaceAlias -notlike "*Loop*" | ft; pause } })
$BtnUpdate.Add_Click({ Run-Task { winget upgrade --all; pause } })
$BtnCloud.Add_Click({ Run-Task { if(Test-Path "$env:LocalAppData\Microsoft\OneDrive\onedrive.exe"){& "$env:LocalAppData\Microsoft\OneDrive\onedrive.exe" /reset}; pause } })
$BtnClean.Add_Click({ Run-Task { Remove-Item "$env:TEMP\*" -Recurse -Force -EA SilentlyContinue; pause } })
$BtnDisk.Add_Click({ Run-Task { $d=Get-CimInstance Win32_LogicalDisk|Where DeviceID -eq "C:"; Write-Host "Ledig: $([math]::Round($d.FreeSpace/1GB,2)) GB"; pause } })
$BtnPerf.Add_Click({ Run-Task { Get-Process|Sort WorkingSet64 -Desc|Select -First 10 Name, @{N='MB';E={$_.WorkingSet64/1MB}}|ft; pause } })
$BtnKaisai.Add_Click({ Run-Task { w32tm /resync; gpupdate /force; pause } })
$BtnChrome.Add_Click({ Run-Task { Stop-Process -Name chrome -Force -EA SilentlyContinue; Remove-Item "$env:LocalAppData\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -EA SilentlyContinue; pause } })
$BtnPrint.Add_Click({ Run-Task { Restart-Service Spooler -Force; pause } })

$BtnExit.Add_Click({ $window.Close() })
$window.ShowDialog() | Out-Null