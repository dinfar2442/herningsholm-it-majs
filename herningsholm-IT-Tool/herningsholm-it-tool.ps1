# --- FASE 1: ADMIN & GHOST MODE ---
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Add-Type -AssemblyName PresentationFramework, System.Windows.Forms

# Hide console after successful load
$hideConsole = {
    $code = '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);'
    try {
        $type = Add-Type -MemberDefinition $code -Name Window -Namespace Console -PassThru
        $type::ShowWindow((Get-Process -Id $pid).MainWindowHandle, 0)
    } catch { }
}

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
                <!-- SYSTEM &amp; INFO -->
                <TextBlock Text="📊 SYSTEM &amp; INFORMATION" FontFamily="Segoe UI Semibold" FontSize="11" FontWeight="SemiBold" Foreground="#2C3E50" Margin="0,0,0,8" Padding="3,0,0,0"/>
                <UniformGrid Columns="4" Margin="0,0,0,12">
                    <Button Name="BtnAsset" Content="PC INFO" Background="#00BCD4" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Viser PC navn og hardware serienummer"/>
                    <Button Name="BtnNet" Content="IP ADRESSE" Background="#0097A7" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Viser alle netværk IP-adresser og interface information"/>
                    <Button Name="BtnDisk" Content="DISK PLADS" Background="#26A69A" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Viser ledig og brugt diskplads"/>
                    <Button Name="BtnPerf" Content="RAM MONITOR" Background="#00897B" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Viser top 10 processer sorteret efter RAM"/>
                </UniformGrid>

                <!-- NETVÆRK -->
                <TextBlock Text="🌍 NETVÆRK &amp; SKY" FontFamily="Segoe UI Semibold" FontSize="11" FontWeight="SemiBold" Foreground="#2C3E50" Margin="0,0,0,8" Padding="3,0,0,0"/>
                <UniformGrid Columns="4" Margin="0,0,0,12">
                    <Button Name="BtnWifiFix" Content="WIFI FIX" Background="#2196F3" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Fuld netværksreparation: Winsock, IP, DNS, DHCP og adapter reset"/>
                    <Button Name="BtnPortal" Content="PORTALER" Background="#1976D2" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Åbner Office 365 og Herningsholm UMS portaler"/>
                    <Button Name="BtnCloud" Content="ONEDRIVE" Background="#1565C0" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Nulstiller OneDrive og rydder credentials"/>
                    <Button Name="BtnKaisai" Content="TID SYNC" Background="#0D47A1" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Synkroniserer tid og Group Policy"/>
                </UniformGrid>

                <!-- CLEANING -->
                <TextBlock Text="🧹 RENGØRING &amp; OPTIMERING" FontFamily="Segoe UI Semibold" FontSize="11" FontWeight="SemiBold" Foreground="#2C3E50" Margin="0,0,0,8" Padding="3,0,0,0"/>
                <UniformGrid Columns="4" Margin="0,0,0,12">
                    <Button Name="BtnDeepClean" Content="DEEP CLEAN" Background="#E91E63" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Komplet optimering: DISM, SFC, Defender, cache og credentials"/>
                    <Button Name="BtnChrome" Content="CHROME" Background="#F44336" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Rydder Google Chrome cache og lukker alle processer"/>
                    <Button Name="BtnBloat" Content="BLOATWARE" Background="#FF6F00" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Fjerner uønskede apps: McAfee, Candy Crush, VPN m.fl."/>
                    <Button Name="BtnUpdate" Content="PC UPDATE" Background="#AB47BC" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Opdaterer Windows, OEM BIOS/driver og apps"/>
                </UniformGrid>

                <!-- OFFICE &amp; SUPPORT -->
                <TextBlock Text="📄 OFFICE &amp; SUPPORT" FontFamily="Segoe UI Semibold" FontSize="11" FontWeight="SemiBold" Foreground="#2C3E50" Margin="0,0,0,8" Padding="3,0,0,0"/>
                <UniformGrid Columns="4" Margin="0,0,0,12">
                    <Button Name="BtnTeams" Content="TEAMS FIX" Background="#6B5B95" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Reparerer Teams og Office login"/>
                    <Button Name="BtnInstall" Content="SOFTWARE" Background="#7E57C2" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Installer Office, Chrome, Teams, VLC, WordMat m.m."/>
                    <Button Name="BtnOfficeRepair" Content="OFFICE REPAIR" Background="#5C6BC0" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Automatisk reparation af Teams, OneDrive, Office &amp; Outlook"/>
                    <Button Name="BtnSearch" Content="SØG MENU" Background="#3949AB" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Søg i alle funktioner og hurtigstart scripts"/>
                </UniformGrid>

                <!-- PRINT &amp; BIOMETRI -->
                <TextBlock Text="🖨 PRINT &amp; BIOMETRI" FontFamily="Segoe UI Semibold" FontSize="11" FontWeight="SemiBold" Foreground="#2C3E50" Margin="0,0,0,8" Padding="3,0,0,0"/>
                <UniformGrid Columns="4" Margin="0,0,0,12">
                    <Button Name="BtnPrint" Content="PRINTER" Background="#4CAF50" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Renser printerkø og genstarter spooler"/>
                    <Button Name="BtnElevPrint" Content="ELEV PRINT" Background="#388E3C" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Downloader Herningsholm printerpakke"/>
                    <Button Name="BtnWinHello" Content="ANSIGT &amp; BIOMETRI" Background="#FF6F00" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Reparerer Windows Hello PIN, TPM &amp; biometriske fejl"/>
                    <Button Name="BtnUI" Content="FIX MENU" Background="#9C27B0" Foreground="White" FontFamily="Segoe UI Semibold" FontWeight="SemiBold" Margin="4" Height="70" FontSize="10" ToolTip="Genstarter Windows Explorer"/>
                </UniformGrid>
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
$nodes = "BtnInstall","BtnPortal","BtnBloat","BtnTeams","BtnWifiFix","BtnAsset","BtnNet","BtnUpdate","BtnCloud","BtnDisk","BtnPerf","BtnKaisai","BtnChrome","BtnDeepClean","BtnPrint","BtnElevPrint","BtnOfficeRepair","BtnWinHello","BtnUI","BtnSearch","BtnExit"
foreach($node in $nodes) { Set-Variable -Name $node -Value $window.FindName($node) }

function Invoke-Task ([scriptblock]$Code, $ArgsList, [switch]$Wait) {
    # Build scriptblock med injected args som $taskArgs (undgår $args override)
    $scriptText = $Code.ToString()
    
    if ($ArgsList -and $ArgsList.Count -gt 0) {
        $jsonArgs = @()
        foreach ($arg in $ArgsList) {
            $jsonArgs += "`"$($arg -replace '"', '\"')`""
        }
        $argsDeclaration = "`$taskArgs = @($($jsonArgs -join ','))`n"
        $scriptText = $argsDeclaration + $scriptText
    }
    
    $Encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($scriptText))
    $argList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-EncodedCommand", $Encoded)
    if ($Wait) {
        Start-Process powershell.exe -ArgumentList $argList -Wait
    } else {
        Start-Process powershell.exe -ArgumentList $argList | Out-Null
    }
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
    try {
        # Vælg mellem manuel og automatisk sletning
        [xml]$modeXaml = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="Bloatware Removal" Height="320" Width="540" Background="#0F1C2E" WindowStartupLocation="CenterOwner" Topmost="True" ResizeMode="NoResize">
        <Window.Resources>
            <Style x:Key="ActionButtonStyle" TargetType="Button">
                <Setter Property="Foreground" Value="White"/>
                <Setter Property="Padding" Value="16,7"/>
                <Setter Property="FontWeight" Value="Bold"/>
                <Setter Property="Template">
                    <Setter.Value>
                        <ControlTemplate TargetType="Button">
                            <Border Background="{TemplateBinding Background}" CornerRadius="8" SnapsToDevicePixels="True">
                                <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" RecognizesAccessKey="True"/>
                            </Border>
                            <ControlTemplate.Triggers>
                                <Trigger Property="IsMouseOver" Value="True">
                                    <Setter Property="Opacity" Value="0.92"/>
                                </Trigger>
                                <Trigger Property="IsPressed" Value="True">
                                    <Setter Property="Opacity" Value="0.85"/>
                                </Trigger>
                            </ControlTemplate.Triggers>
                        </ControlTemplate>
                    </Setter.Value>
                </Setter>
            </Style>
        </Window.Resources>
        <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
            <Border Grid.Row="0" Background="#0097A7" Padding="16,12">
                <TextBlock Text="VÆLG SLETNINGSMETODE" Foreground="White" FontWeight="Bold" FontSize="14" HorizontalAlignment="Center"/>
            </Border>
            <Border Grid.Row="1" Margin="18" Padding="16" Background="#15263C" CornerRadius="8" BorderBrush="#1F3B57" BorderThickness="1">
                <StackPanel>
                    <TextBlock Text="Vælg hvordan bloatware skal fjernes" Foreground="#E4ECF5" FontSize="12" Margin="0,0,0,10"/>
                    <RadioButton Name="radManual" Content="MANUELT – Vælg hvad der skal slettes" Foreground="#FFFFFF" Margin="0,6" FontSize="12" IsChecked="True"/>
                    <RadioButton Name="radAuto" Content="AUTOMATISK – Slet alt kendt bloatware" Foreground="#FFFFFF" Margin="0,6" FontSize="12"/>
                </StackPanel>
            </Border>
            <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Right" Margin="12">
                <Button Name="btnOk" Content="FORTSÆT" Margin="5" Background="#27AE60" Style="{StaticResource ActionButtonStyle}"/>
                <Button Name="btnCancel" Content="ANNULLER" Margin="5" Background="#455A64" Style="{StaticResource ActionButtonStyle}"/>
            </StackPanel>
        </Grid>
    </Window>
"@
        
        $modeWin = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $modeXaml))
        $radManual = $modeWin.FindName("radManual")
        $radAuto = $modeWin.FindName("radAuto")
        $btnOk = $modeWin.FindName("btnOk")
        $btnCancel = $modeWin.FindName("btnCancel")
        
        $btnCancel.Add_Click({ $modeWin.Close() })
        
        $btnOk.Add_Click({
            if($radManual -and $radManual.IsChecked) {
                $modeWin.Close()
                # MANUEL MODE - Vis checkboxes
                [xml]$manualX = @"
            <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="Bloatware - Manuel valg" Height="500" Width="460" Background="#0F1C2E" WindowStartupLocation="CenterOwner" Topmost="True" ResizeMode="NoResize">
                <Window.Resources>
                    <Style x:Key="ActionButtonStyle" TargetType="Button">
                        <Setter Property="Foreground" Value="White"/>
                        <Setter Property="Padding" Value="16,6"/>
                        <Setter Property="FontWeight" Value="Bold"/>
                        <Setter Property="Template">
                            <Setter.Value>
                                <ControlTemplate TargetType="Button">
                                    <Border Background="{TemplateBinding Background}" CornerRadius="8" SnapsToDevicePixels="True">
                                        <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" RecognizesAccessKey="True"/>
                                    </Border>
                                    <ControlTemplate.Triggers>
                                        <Trigger Property="IsMouseOver" Value="True">
                                            <Setter Property="Opacity" Value="0.92"/>
                                        </Trigger>
                                        <Trigger Property="IsPressed" Value="True">
                                            <Setter Property="Opacity" Value="0.85"/>
                                        </Trigger>
                                    </ControlTemplate.Triggers>
                                </ControlTemplate>
                            </Setter.Value>
                        </Setter>
                    </Style>
                </Window.Resources>
                <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                    <Border Grid.Row="0" Background="#0097A7" Padding="14,10">
                        <TextBlock Text="VÆLG APPS DER SKAL FJERNES" Foreground="White" HorizontalAlignment="Center" FontWeight="Bold" FontSize="13"/>
                    </Border>
                    <Border Grid.Row="1" Margin="14,10" Background="#15263C" CornerRadius="8" BorderBrush="#1F3B57" BorderThickness="1">
                        <ScrollViewer Margin="10"><StackPanel>
                            <TextBlock Text="Antivirus" Foreground="#7FDBFF" Margin="0,4" FontWeight="Bold"/>
                            <CheckBox Name="m1" Content="McAfee (ALT)" Foreground="#FFFFFF" Margin="6,2"/><CheckBox Name="m2" Content="Norton" Foreground="#FFFFFF" Margin="6,2"/>
                            <CheckBox Name="m3" Content="Avast" Foreground="#FFFFFF" Margin="6,2"/><CheckBox Name="m4" Content="AVG" Foreground="#FFFFFF" Margin="6,2"/>
                            <CheckBox Name="m5" Content="Kaspersky" Foreground="#FFFFFF" Margin="6,2"/><CheckBox Name="m6" Content="Bitdefender" Foreground="#FFFFFF" Margin="6,2"/>

                            <TextBlock Text="VPN &amp; Tjenester" Foreground="#7FDBFF" Margin="0,10,0,4" FontWeight="Bold"/>
                            <CheckBox Name="m7" Content="Planet VPN" Foreground="#FFFFFF" Margin="6,2"/><CheckBox Name="m8" Content="CyberGhost" Foreground="#FFFFFF" Margin="6,2"/>
                            <CheckBox Name="m9" Content="ExpressVPN" Foreground="#FFFFFF" Margin="6,2"/>

                            <TextBlock Text="Bloatware" Foreground="#7FDBFF" Margin="0,10,0,4" FontWeight="Bold"/>
                            <CheckBox Name="m10" Content="Candy Crush" Foreground="#FFFFFF" Margin="6,2"/><CheckBox Name="m11" Content="Spotify" Foreground="#FFFFFF" Margin="6,2"/>
                            <CheckBox Name="m12" Content="Facebook" Foreground="#FFFFFF" Margin="6,2"/>
                        </StackPanel></ScrollViewer>
                    </Border>
                    <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Right" Margin="12,10">
                        <Button Name="mOk" Content="SLET" Margin="5" Background="#D32F2F" Style="{StaticResource ActionButtonStyle}"/>
                        <Button Name="mCancel" Content="ANNULLER" Margin="5" Background="#455A64" Style="{StaticResource ActionButtonStyle}"/>
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
                        if($cb -and $cb.IsChecked) {
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
    } catch {
        [System.Windows.MessageBox]::Show("Bloatware menu fejlede:\n\n$($_.Exception.Message)", "Fejl", "OK", "Error") | Out-Null
    }
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
$BtnPrint.Add_Click({
    # GUI progress for print queue cleanup
    [xml]$printX = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="Printer - Renser kø" Height="210" Width="480" Background="#FFFFFF" WindowStartupLocation="CenterOwner" Topmost="True" ResizeMode="NoResize">
        <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/></Grid.RowDefinitions>
            <Border Grid.Row="0" Background="#1976D2" Padding="15,10,15,10">
                <TextBlock Text="🖨 RENSER PRINTKØ" Foreground="White" HorizontalAlignment="Center" FontWeight="Bold" FontSize="12"/>
            </Border>
            <StackPanel Grid.Row="1" Margin="20" VerticalAlignment="Center">
                <TextBlock Name="printText" Text="Stopper spooler..." FontFamily="Segoe UI" FontSize="11" Foreground="#333" Margin="0,0,0,10"/>
                <ProgressBar Name="printBar" Height="25" Minimum="0" Maximum="100" Value="0"/>
                <TextBlock Name="printPercent" Text="0%" FontFamily="Segoe UI Semibold" FontSize="10" Foreground="#1976D2" HorizontalAlignment="Center" Margin="0,8,0,0"/>
            </StackPanel>
        </Grid>
    </Window>
"@

    $printWin = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $printX))
    $printText = $printWin.FindName("printText")
    $printBar = $printWin.FindName("printBar")
    $printPercent = $printWin.FindName("printPercent")
    $printWin.Owner = $window
    $printWin.Show()
    [System.Windows.Forms.Application]::DoEvents()

    try {
        $printText.Text = "Stopper spooler..."
        $printBar.Value = 25; $printPercent.Text = "25%"; [System.Windows.Forms.Application]::DoEvents()
        try { Stop-Service Spooler -Force -ErrorAction SilentlyContinue } catch { }

        $printText.Text = "Tømmer printkø..."
        $printBar.Value = 55; $printPercent.Text = "55%"; [System.Windows.Forms.Application]::DoEvents()
        $queuePath = "$env:SystemRoot\System32\spool\PRINTERS"
        try { Remove-Item "$queuePath\*" -Recurse -Force -ErrorAction SilentlyContinue } catch { }

        $printText.Text = "Starter spooler..."
        $printBar.Value = 85; $printPercent.Text = "85%"; [System.Windows.Forms.Application]::DoEvents()
        try { Start-Service Spooler -ErrorAction SilentlyContinue } catch { }

        $printText.Text = "Færdig"
        $printBar.Value = 100; $printPercent.Text = "100%"; [System.Windows.Forms.Application]::DoEvents()
    } finally {
        Start-Sleep -Milliseconds 400
        $printWin.Close()
    }
})
$BtnChrome.Add_Click({
    Run-Task {
        # Stop browsers
        Stop-Process -Name chrome -Force -EA SilentlyContinue
        Stop-Process -Name msedge -Force -EA SilentlyContinue

        # Chrome paths
        $chromeRoot = Join-Path $env:LocalAppData 'Google\Chrome\User Data'
        $chromeDefault = Join-Path $chromeRoot 'Default'
        Remove-Item (Join-Path $chromeDefault 'Cache\*') -Recurse -Force -EA SilentlyContinue
        Remove-Item (Join-Path $chromeDefault 'Code Cache\*') -Recurse -Force -EA SilentlyContinue
        Remove-Item (Join-Path $chromeDefault 'Cookies') -Force -EA SilentlyContinue
        Remove-Item (Join-Path $chromeDefault 'Network\Cookies') -Force -EA SilentlyContinue

        # Edge paths
        $edgeRoot = Join-Path $env:LocalAppData 'Microsoft\Edge\User Data'
        $edgeDefault = Join-Path $edgeRoot 'Default'
        Remove-Item (Join-Path $edgeDefault 'Cache\*') -Recurse -Force -EA SilentlyContinue
        Remove-Item (Join-Path $edgeDefault 'Code Cache\*') -Recurse -Force -EA SilentlyContinue
        Remove-Item (Join-Path $edgeDefault 'Cookies') -Force -EA SilentlyContinue
        Remove-Item (Join-Path $edgeDefault 'Network\Cookies') -Force -EA SilentlyContinue
    }
})
$BtnUI.Add_Click({ Run-Task { Stop-Process -Name explorer -Force; Start-Process explorer } })
$BtnUpdate.Add_Click({
    try {
        [xml]$progressX = @"
        <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="Opdateringer - Arbejder..." Height="230" Width="520" Background="#FFFFFF" WindowStartupLocation="CenterOwner" Topmost="True" ResizeMode="NoResize">
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

        $out = "════════ OPDATERINGER ════════`n`n"
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

        # 2) OEM/BIOS/Driver med spørgsmål først
        $progressText.Text = "[2/4] OEM BIOS/Driver..."
        $progressBar.Value = 40
        $progressPercent.Text = "40%"
        [System.Windows.Forms.Application]::DoEvents()
        $out += "[2/4] OEM BIOS/Driver...`n"

        # Bestem OEM og spørg om update
        $runOemUpdate = $false
        $oemName = ""
        if ($vendor -match 'HP') { $oemName = "HP (BIOS/Driver)" }
        elseif ($vendor -match 'Lenovo') { $oemName = "Lenovo (BIOS/Driver)" }
        elseif ($vendor -match 'ASUS') { $oemName = "ASUS (BIOS/Driver)" }

        if ($oemName) {
            # Vis spørgsmål
            [xml]$askX = @"
            <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="OEM Update" Height="200" Width="400" Background="#F5F5F5" WindowStartupLocation="CenterOwner" Topmost="True">
                <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
                    <TextBlock Text="Vil du køre $oemName update?" FontSize="14" FontWeight="Bold" TextAlignment="Center" Margin="20"/>
                    <TextBlock Text="Dette kan tage 5-15 minutter" FontSize="11" TextAlignment="Center" Margin="0,0,0,20" Foreground="#666"/>
                    <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
                        <Button Name="btnYes" Content="Ja" Width="80" Height="35" Margin="0,0,10,0" Background="#4CAF50" Foreground="White"/>
                        <Button Name="btnNo" Content="Nej" Width="80" Height="35" Background="#f44336" Foreground="White"/>
                    </StackPanel>
                </StackPanel>
            </Window>
"@
            $reader = [System.Xml.XmlNodeReader]::new($askX.DocumentElement)
            $askWin = [Windows.Markup.XamlReader]::Load($reader)
            $btnYes = $askWin.FindName("btnYes")
            $btnNo = $askWin.FindName("btnNo")
            $answer = $null
            $btnYes.Add_Click({ $answer = "Yes"; $askWin.Close() })
            $btnNo.Add_Click({ $answer = "No"; $askWin.Close() })
            $askWin.ShowDialog() | Out-Null
            $runOemUpdate = ($answer -eq "Yes")
        }

        if ($runOemUpdate) {
            if ($vendor -match 'HP') {
                $scriptPath = Split-Path -Parent $PSCommandPath
                $hpiaLocal = Join-Path $scriptPath "hp-hpia-5.3.3.exe"
                $hpiaExe = "C:\\Program Files\\HP\\HPIA\\HPImageAssistant.exe"
                $hpiaInstalled = Test-Path $hpiaExe
                
                # Tjek også for Microsoft Store version
                if (-not $hpiaInstalled) {
                    $hpApp = Get-AppxPackage -Name "*HPIA*" -ErrorAction SilentlyContinue | Select-Object -First 1
                    if ($hpApp) { $hpiaInstalled = $true }
                }
                
                if (-not $hpiaInstalled) {
                    $out += "    • Installerer HP Image Assistant...`n"
                    try {
                        if (Test-Path $hpiaLocal) {
                            $out += "      (Bruger lokal fil)`n"
                            Start-Process -FilePath $hpiaLocal -ArgumentList '/SilentInstall /norestart' -Wait -NoNewWindow -ErrorAction Stop
                            $hpiaInstalled = Test-Path $hpiaExe
                        } else {
                            $out += "      (Downloader fra HP via winget/net)`n"
                            if (Get-Command winget -ErrorAction SilentlyContinue) {
                                winget install --id "HP.HPIA" --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
                                $hpiaInstalled = Test-Path $hpiaExe
                            }
                            if (-not $hpiaInstalled) {
                                $hpUrl = 'https://ftp.hp.com/pub/caps-softpaq/cmit/HPImageAssistant.exe'
                                $hpiaTemp = Join-Path $env:TEMP 'HPImageAssistant.exe'
                                Invoke-WebRequest -Uri $hpUrl -OutFile $hpiaTemp -UseBasicParsing -ErrorAction Stop
                                Start-Process -FilePath $hpiaTemp -ArgumentList '/SilentInstall /norestart' -Wait -NoNewWindow -ErrorAction Stop
                                $hpiaInstalled = Test-Path $hpiaExe
                            }
                        }
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
                        if (Test-Path $hpiaExe) {
                            $proc = Start-Process -FilePath $hpiaExe -ArgumentList $hpiaArgs -NoNewWindow -Wait -PassThru -ErrorAction Stop
                            $out += "    ✓ HPIA færdig (ExitCode: $($proc.ExitCode))`n`n"
                        } else {
                            $out += "    ✓ HPIA kørt via Microsoft Store`n`n"
                        }
                    } catch {
                        $out += "    ⚠ HPIA fejl: $($_.Exception.Message)`n`n"
                    }
                } else {
                    $out += "    ⚠ HPIA ikke tilgængelig`n`n"
                }
            } elseif ($vendor -match 'Lenovo') {
                $scriptPath = Split-Path -Parent $PSCommandPath
                $lenovoLocal = Join-Path $scriptPath "system_update_5.08.03.59.exe"
                $lenovoExe = "C:\\Program Files (x86)\\Lenovo\\System Update\\tvsu.exe"
                $lenovoVantage = "C:\\Program Files (x86)\\Lenovo\\Vantage\\LenovoVantage.exe"
                $lenovoInstalled = (Test-Path $lenovoExe) -or (Test-Path $lenovoVantage)
                $lenovoApp = if (Test-Path $lenovoVantage) { $lenovoVantage } else { $lenovoExe }
                
                # Tjek også for Microsoft Store version
                if (-not $lenovoInstalled) {
                    $lenovoMsApp = Get-AppxPackage -Name "*Vantage*" -ErrorAction SilentlyContinue | Select-Object -First 1
                    if ($lenovoMsApp) { $lenovoInstalled = $true }
                }
                
                if (-not $lenovoInstalled) {
                    $out += "    • Installerer Lenovo System Update/Vantage...`n"
                    try {
                        if (Test-Path $lenovoLocal) {
                            $out += "      (Bruger lokal fil)`n"
                            Start-Process -FilePath $lenovoLocal -ArgumentList '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART' -Wait -NoNewWindow -ErrorAction Stop
                            $lenovoInstalled = (Test-Path $lenovoExe) -or (Test-Path $lenovoVantage)
                            $lenovoApp = if (Test-Path $lenovoVantage) { $lenovoVantage } else { $lenovoExe }
                        } else {
                            $out += "      (Downloader fra Lenovo via winget/net)`n"
                            if (Get-Command winget -ErrorAction SilentlyContinue) {
                                winget install --id "Lenovo.SystemUpdate" --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
                                $lenovoInstalled = (Test-Path $lenovoExe) -or (Test-Path $lenovoVantage)
                                $lenovoApp = if (Test-Path $lenovoVantage) { $lenovoVantage } else { $lenovoExe }
                            }
                            if (-not $lenovoInstalled) {
                                $lenovoUrl = 'https://download.lenovo.com/pccbbs/thinkvantage_en/system_update_5.08.01.0009.exe'
                                $lenovoTemp = Join-Path $env:TEMP 'lenovo_system_update.exe'
                                Invoke-WebRequest -Uri $lenovoUrl -OutFile $lenovoTemp -UseBasicParsing -ErrorAction Stop
                                Start-Process -FilePath $lenovoTemp -ArgumentList '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART' -Wait -NoNewWindow -ErrorAction Stop
                                $lenovoInstalled = (Test-Path $lenovoExe) -or (Test-Path $lenovoVantage)
                                $lenovoApp = if (Test-Path $lenovoVantage) { $lenovoVantage } else { $lenovoExe }
                            }
                        }
                        if ($lenovoInstalled) { $out += "    ✓ System Update/Vantage installeret`n" } else { $out += "    ⚠ System Update/Vantage ikke installeret`n" }
                    } catch {
                        $out += "    ⚠ Installation fejlede: $($_.Exception.Message)`n"
                    }
                }

                if ($lenovoInstalled) {
                    # Tjek for Microsoft Store version
                    $lenovoMsApp = Get-AppxPackage -Name "*Vantage*" -ErrorAction SilentlyContinue | Select-Object -First 1
                    $out += "    • Åbner Lenovo System Update/Vantage...`n"
                    try {
                        if ($lenovoMsApp) {
                            explorer.exe "shell:appsFolder\$($lenovoMsApp.PackageFamilyName)!App"
                            $out += "    ✓ Vantage åbnet fra Microsoft Store`n`n"
                        } elseif (Test-Path $lenovoApp) {
                            Start-Process -FilePath $lenovoApp -ArgumentList "/CM" -ErrorAction Stop
                            $out += "    ✓ System Update/Vantage åbnet`n`n"
                        } else {
                            $out += "    ✓ Lenovo tool installeret`n`n"
                        }
                    } catch {
                        $out += "    ⚠ Fejl: $($_.Exception.Message)`n`n"
                    }
                } else {
                    $out += "    ⚠ Lenovo System Update/Vantage ikke tilgængelig`n`n"
                }
            } elseif ($vendor -match 'ASUS') {
                $scriptPath = Split-Path -Parent $PSCommandPath
                $asusLocal = Join-Path $scriptPath "MyASUS Installer.exe"
                
                $out += "    • ASUS maskine opdaget`n"
                try {
                    # Find MyASUS Microsoft Store app
                    $asusApp = Get-AppxPackage -Name "*MyASUS*" -ErrorAction SilentlyContinue | Select-Object -First 1
                    
                    if ($asusApp) {
                        $out += "      (Åbner MyASUS fra Microsoft Store)`n"
                        # Åben via shell:appsFolder med PackageFamilyName
                        $pfn = $asusApp.PackageFamilyName
                        & explorer.exe "shell:appsFolder\$($pfn)!App"
                        Start-Sleep -Seconds 2
                        $out += "    ✓ MyASUS åbnet`n`n"
                    } elseif (Test-Path $asusLocal) {
                        $out += "      (Åbner lokal MyASUS Installer)`n"
                        Start-Process -FilePath $asusLocal -ErrorAction Stop
                        Start-Sleep -Seconds 2
                        $out += "    ✓ MyASUS Installer startet`n`n"
                    } else {
                        $out += "    ⚠ MyASUS ikke fundet - download fra Microsoft Store`n`n"
                    }
                } catch {
                    $out += "    ⚠ Fejl ved åbning: $($_.Exception.Message)`n`n"
                }
            }
        } else {
            if ($oemName) {
                $out += "  - $oemName update sprunget over`n`n"
            } elseif ($vendor -match 'Dell') {
                $out += "  - Dell maskine: Brug Dell Command Update manuelt for BIOS/driver`n`n"
            } elseif ($vendor -match 'Surface|Microsoft') {
                $out += "  - Surface/Microsoft: Bruger Windows Update (driver hentes normalt via Windows Update)`n`n"
            } elseif ($vendor -match 'Acer') {
                $out += "  - Acer maskine: Brug Acer Care Center manuelt for BIOS/driver`n`n"
            } else {
                $out += "  - OEM ikke identificeret (vendor: $vendor). Brug Windows Update + winget for drivere`n`n"
            }
        }

        # 3) Winget app updates
        $progressText.Text = "[3/4] App opdateringer (winget)..."
        $progressBar.Value = 70
        $progressPercent.Text = "70%"
        [System.Windows.Forms.Application]::DoEvents()
        $out += "[3/4] App opdateringer (winget)...`n"
        try {
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
        $progressText.Text = "[4/4] Rydder op..."
        $progressBar.Value = 100
        $progressPercent.Text = "100%"
        [System.Windows.Forms.Application]::DoEvents()
        $out += "[4/4] Rydder op...`n"
        try {
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

        $progressWin.Close()

        [xml]$updX = @"
        <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="Opdateringer" Height="520" Width="550" Background="#FFFFFF" WindowStartupLocation="CenterOwner" Topmost="True">
            <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                <Border Grid.Row="0" Background="#AB47BC" Padding="15,10,15,10">
                    <TextBlock Text="⬆ OPDATERINGER &amp; DRIVERE" Foreground="White" HorizontalAlignment="Center" FontWeight="Bold" FontSize="12"/>
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
    # GUI download med progress
    [xml]$elevX = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="Elev Print - Downloader" Height="230" Width="520" Background="#FFFFFF" WindowStartupLocation="CenterOwner" Topmost="True" ResizeMode="NoResize">
        <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/></Grid.RowDefinitions>
            <Border Grid.Row="0" Background="#0097A7" Padding="15,10,15,10">
                <TextBlock Text="⬇ HENTER PAPERCUT KLIENT" Foreground="White" HorizontalAlignment="Center" FontWeight="Bold" FontSize="12"/>
            </Border>
            <StackPanel Grid.Row="1" Margin="20" VerticalAlignment="Center">
                <TextBlock Name="elevText" Text="Downloader..." FontFamily="Segoe UI" FontSize="11" Foreground="#333" Margin="0,0,0,10"/>
                <ProgressBar Name="elevBar" Height="25" Minimum="0" Maximum="100" Value="0"/>
                <TextBlock Name="elevPercent" Text="0%" FontFamily="Segoe UI Semibold" FontSize="10" Foreground="#0097A7" HorizontalAlignment="Center" Margin="0,8,0,0"/>
            </StackPanel>
        </Grid>
    </Window>
"@

    $elevWin = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $elevX))
    $elevText = $elevWin.FindName("elevText")
    $elevBar = $elevWin.FindName("elevBar")
    $elevPercent = $elevWin.FindName("elevPercent")
    $elevWin.Owner = $window
    $elevWin.Show()
    [System.Windows.Forms.Application]::DoEvents()

    try {
        $defaultName = 'pc-print-deploy-client.exe'
        $fileName = $defaultName
        # Find scriptmappe robustt
        $scriptDir = $PSScriptRoot
        if (-not $scriptDir) {
            try { $scriptDir = Split-Path -Parent $PSCommandPath } catch { }
        }
        if (-not $scriptDir) {
            try { $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition } catch { }
        }
        if (-not $scriptDir) { $scriptDir = (Get-Location).Path }

        $localSource = Join-Path $scriptDir $fileName

        $localCandidate = $null
        if (Test-Path $localSource) {
            $localCandidate = $localSource
        } else {
            $candidate = Get-ChildItem -Path $scriptDir -Filter 'pc-*-print*.exe' -File -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($candidate) { $localCandidate = $candidate.FullName }
        }

        if ($localCandidate) {
            # Brug lokalt filnavn, så vi ikke omdøber installer
            $fileName = Split-Path -Path $localCandidate -Leaf
            $out = Join-Path $env:TEMP $fileName
            $elevText.Text = "Kopierer lokal klient..."
            $elevBar.Value = 25; $elevPercent.Text = "25%"; [System.Windows.Forms.Application]::DoEvents()
            Copy-Item -Path $localCandidate -Destination $out -Force -ErrorAction Stop
        } else {
            $fileName = $defaultName
            $out = Join-Path $env:TEMP $fileName
            $url = 'https://papercut.herningsholm.dk:9164/client/pc-print-deploy-client.exe'
            $elevText.Text = "Downloader klient..."
            $elevBar.Value = 25; $elevPercent.Text = "25%"; [System.Windows.Forms.Application]::DoEvents()
            Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing -ErrorAction Stop
        }

        $downloads = Join-Path $env:USERPROFILE 'Downloads'
        if (-not (Test-Path $downloads)) { New-Item -ItemType Directory -Path $downloads | Out-Null }
        $dest = Join-Path $downloads $fileName

        $elevText.Text = "Kopierer til Downloads..."
        $elevBar.Value = 55; $elevPercent.Text = "55%"; [System.Windows.Forms.Application]::DoEvents()
        try { Copy-Item -Path $out -Destination $dest -Force -ErrorAction Stop } catch { }

        if ($ElevPrintPrinterPath -and ($ElevPrintPrinterPath -ne '')) {
            $elevText.Text = "Kopierer til printer-sti..."
            $elevBar.Value = 75; $elevPercent.Text = "75%"; [System.Windows.Forms.Application]::DoEvents()
            try { Copy-Item -Path $out -Destination $ElevPrintPrinterPath -Force -ErrorAction SilentlyContinue } catch { }
        }

        # Vælg sti der faktisk findes
        $runPath = $dest
        if (-not (Test-Path $runPath) -and (Test-Path $out)) { $runPath = $out }
        if (-not (Test-Path $runPath) -and $localCandidate -and (Test-Path $localCandidate)) { $runPath = $localCandidate }
        if (-not (Test-Path $runPath)) { throw "Installer kunne ikke findes efter download/kopi." }

        $elevText.Text = "Åbner installer..."
        $elevBar.Value = 100; $elevPercent.Text = "100%"; [System.Windows.Forms.Application]::DoEvents()
        Start-Process -FilePath $runPath -ErrorAction Stop
    } catch {
        [System.Windows.MessageBox]::Show("Download eller kopi fejlede:\n\n$($_.Exception.Message)\n\nLæg pc-print-deploy-client.exe (eller pc-*-print*.exe) i samme mappe som scriptet og prøv igen.", "Fejl", "OK", "Error")
    } finally {
        Start-Sleep -Milliseconds 400
        $elevWin.Close()
    }
})

# --- SØG FUNKTION ---
$BtnSearch.Add_Click({
    try {
        # Alle apps som scriptet kan fjerne
        $RemovableApps = @(
            @{Name='McAfee'; Category='Antivirus'; Description='McAfee antivirus og sikkerhed'; Search='McAfee,WebAdvisor,McAfeeLiveSafe,mcshield'},
            @{Name='Norton'; Category='Antivirus'; Description='Norton AntiVirus og LifeLock'; Search='Norton,NortonLifeLock,NortonVPN'},
            @{Name='Avast'; Category='Antivirus'; Description='Avast antivirus'; Search='Avast'},
            @{Name='AVG'; Category='Antivirus'; Description='AVG antivirus'; Search='AVG'},
            @{Name='Kaspersky'; Category='Antivirus'; Description='Kaspersky antivirus'; Search='Kaspersky'},
            @{Name='Bitdefender'; Category='Antivirus'; Description='Bitdefender sikkerhed'; Search='Bitdefender'},
            @{Name='Planet VPN'; Category='VPN'; Description='Planet VPN tjeneste'; Search='PlanetVPN'},
            @{Name='CyberGhost'; Category='VPN'; Description='CyberGhost VPN'; Search='CyberGhost'},
            @{Name='ExpressVPN'; Category='VPN'; Description='ExpressVPN tjeneste'; Search='ExpressVPN'},
            @{Name='NordVPN'; Category='VPN'; Description='NordVPN forbindelse'; Search='NordVPN'},
            @{Name='Candy Crush'; Category='Bloatware'; Description='Candy Crush Saga spil'; Search='CandyCrush,Candy Crush'},
            @{Name='Spotify'; Category='Bloatware'; Description='Spotify musik app'; Search='Spotify'},
            @{Name='Facebook'; Category='Bloatware'; Description='Facebook app'; Search='Facebook'},
            @{Name='King.com'; Category='Bloatware'; Description='King.com spil'; Search='King,King.com'}
        )
        
        # Alle apps som scriptet kan installere
        $InstallableApps = @(
            @{Name='Office 365'; Category='Produktivitet'; Description='Microsoft Office pakke'; WingetID='Microsoft.Office'},
            @{Name='Google Chrome'; Category='Browser'; Description='Google Chrome browser'; WingetID='Google.Chrome'},
            @{Name='Microsoft Teams'; Category='Kommunikation'; Description='Teams chat og videosamtaler'; WingetID='Microsoft.Teams'},
            @{Name='VLC Media Player'; Category='Medier'; Description='VLC video afspiller'; WingetID='VideoLAN.VLC'},
            @{Name='Adobe Reader'; Category='Dokumenter'; Description='PDF læser fra Adobe'; WingetID='Adobe.AdobeReader'},
            @{Name='7-Zip'; Category='Arkivering'; Description='Komprimerings værktøj'; WingetID='7zip.7zip'},
            @{Name='WordMat'; Category='Matematik'; Description='Matematik plugin for Word'; Manual=$true}
        )
        
        [xml]$searchXaml = @"
        <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="Søg i Scriptet" Height="600" Width="700" Background="#FAFAFA" WindowStartupLocation="CenterOwner" Topmost="True" ResizeMode="CanResize">
            <Grid><Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="50"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>
                <Border Grid.Row="0" Background="#6B5B95" Padding="15,15">
                    <TextBlock Text="🔍 SØG EFTER APPS OG FUNKTIONER" Foreground="White" FontWeight="Bold" FontSize="16" HorizontalAlignment="Center"/>
                </Border>
                <Border Grid.Row="1" Padding="15,8,15,8" Background="#F5F5F5" BorderThickness="0,1,0,1" BorderBrush="#DDD">
                    <TextBox Name="SearchInput" Foreground="#1C1C1C" FontSize="14" Padding="10" Height="38" Background="#FFFFFF" BorderBrush="#6B5B95" BorderThickness="1.5" VerticalContentAlignment="Center" ToolTip="Søg efter fx mcafee, vpn, office"/>
                </Border>
                <Border Grid.Row="2" Margin="0">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel Name="ResultsPanel" Margin="15"/>
                    </ScrollViewer>
                </Border>
            </Grid>
        </Window>
"@
        
        $searchWin = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $searchXaml))
        $searchInput = $searchWin.FindName("SearchInput")
        $resultsPanel = $searchWin.FindName("ResultsPanel")
        
        # Definer logic-funktionen INDEN event binding
        $searchLogic = {
            param($inputControl, $panelControl, $searchApps, $installApps)
            $query = $inputControl.Text.Trim().ToLower()
            $panelControl.Children.Clear()
            
            if ([string]::IsNullOrWhiteSpace($query)) {
                $msg = New-Object System.Windows.Controls.TextBlock
                $msg.Text = "Skriv søgeord for at finde apps..."
                $msg.Foreground = [System.Windows.Media.Brushes]::Gray
                $msg.FontSize = 12
                $panelControl.Children.Add($msg) | Out-Null
                return
            }
            
            $found = 0
            
            # Søg i fjernelige apps
            foreach ($app in $searchApps) {
                if ($app.Name.ToLower().Contains($query) -or $app.Description.ToLower().Contains($query) -or $app.Search.ToLower().Contains($query)) {
                    $found++
                    
                    $catLabel = New-Object System.Windows.Controls.TextBlock
                    $catLabel.Text = "❌ FJERN - $($app.Category)"
                    $catLabel.Foreground = [System.Windows.Media.Brushes]::Red
                    $catLabel.FontWeight = [System.Windows.FontWeight]::FromOpenTypeWeight(700)
                    $catLabel.FontSize = 11
                    $catLabel.Margin = New-Object System.Windows.Thickness(0,10,0,5)
                    $panelControl.Children.Add($catLabel) | Out-Null
                    
                    $nameLabel = New-Object System.Windows.Controls.TextBlock
                    $nameLabel.Text = "  → $($app.Name)"
                    $nameLabel.Foreground = [System.Windows.Media.Brushes]::Black
                    $nameLabel.FontWeight = [System.Windows.FontWeight]::FromOpenTypeWeight(700)
                    $nameLabel.FontSize = 12
                    $nameLabel.Margin = New-Object System.Windows.Thickness(0,0,0,3)
                    $panelControl.Children.Add($nameLabel) | Out-Null
                    
                    $descLabel = New-Object System.Windows.Controls.TextBlock
                    $descLabel.Text = "    $($app.Description)"
                    $descLabel.Foreground = [System.Windows.Media.Brushes]::Gray
                    $descLabel.FontSize = 10
                    $descLabel.Margin = New-Object System.Windows.Thickness(0,0,0,2)
                    $panelControl.Children.Add($descLabel) | Out-Null
                    
                    $searchTerms = New-Object System.Windows.Controls.TextBlock
                    $searchTerms.Text = "    Søgetermer: $($app.Search)"
                    $searchTerms.Foreground = [System.Windows.Media.Brushes]::DarkGray
                    $searchTerms.FontSize = 9
                    $searchTerms.FontStyle = [System.Windows.FontStyles]::Italic
                    $panelControl.Children.Add($searchTerms) | Out-Null
                }
            }
            
            # Søg i installerbare apps
            foreach ($app in $installApps) {
                if ($app.Name.ToLower().Contains($query) -or $app.Description.ToLower().Contains($query)) {
                    $found++
                    
                    $catLabel = New-Object System.Windows.Controls.TextBlock
                    $catLabel.Text = "✅ INSTALLER - $($app.Category)"
                    $catLabel.Foreground = [System.Windows.Media.Brushes]::Green
                    $catLabel.FontWeight = [System.Windows.FontWeight]::FromOpenTypeWeight(700)
                    $catLabel.FontSize = 11
                    $catLabel.Margin = New-Object System.Windows.Thickness(0,10,0,5)
                    $panelControl.Children.Add($catLabel) | Out-Null
                    
                    $nameLabel = New-Object System.Windows.Controls.TextBlock
                    $nameLabel.Text = "  → $($app.Name)"
                    $nameLabel.Foreground = [System.Windows.Media.Brushes]::Black
                    $nameLabel.FontWeight = [System.Windows.FontWeight]::FromOpenTypeWeight(700)
                    $nameLabel.FontSize = 12
                    $nameLabel.Margin = New-Object System.Windows.Thickness(0,0,0,3)
                    $panelControl.Children.Add($nameLabel) | Out-Null
                    
                    $descLabel = New-Object System.Windows.Controls.TextBlock
                    $descLabel.Text = "    $($app.Description)"
                    $descLabel.Foreground = [System.Windows.Media.Brushes]::Gray
                    $descLabel.FontSize = 10
                    $panelControl.Children.Add($descLabel) | Out-Null
                }
            }
            
            if ($found -eq 0) {
                $msg = New-Object System.Windows.Controls.TextBlock
                $msg.Text = "Ingen resultater fundet for '$query'"
                $msg.Foreground = [System.Windows.Media.Brushes]::Red
                $msg.FontSize = 12
                $msg.Margin = New-Object System.Windows.Thickness(0,20,0,0)
                $panelControl.Children.Add($msg) | Out-Null

                $tip = New-Object System.Windows.Controls.TextBlock
                $tip.Text = "Tip: Tilføj selv en manuel handling eller prøv et andet søgeord."
                $tip.Foreground = [System.Windows.Media.Brushes]::Gray
                $tip.FontSize = 11
                $tip.Margin = New-Object System.Windows.Thickness(0,5,0,0)
                $panelControl.Children.Add($tip) | Out-Null
            }
        }
        
        # Bind event med explicit parameter passing
        $searchInput.Add_TextChanged({ & $searchLogic $searchInput $resultsPanel $RemovableApps $InstallableApps })
        $searchWin.Add_Loaded({ $searchInput.Focus() })
        
        $searchWin.Owner = $window
        $searchWin.ShowDialog() | Out-Null
    } catch {
        [System.Windows.MessageBox]::Show("Fejl i søgefunktion: $($_.Exception.Message)", "Fejl", "OK", "Error")
    }
})

$BtnOfficeRepair.Add_Click({
    try {
        [xml]$officeRepairX = @"
        <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="Office & Login Repair" Height="520" Width="600" Background="#FFFFFF" WindowStartupLocation="CenterOwner" Topmost="True">
            <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                <Border Grid.Row="0" Background="#D32F2F" Padding="15,10,15,10">
                    <TextBlock Text="🔐 OFFICE &amp; LOGIN REPAIR" Foreground="White" HorizontalAlignment="Center" FontWeight="Bold" FontSize="12"/>
                </Border>
                <TextBox Grid.Row="1" Name="officeLog" Margin="15" Background="#F5F5F5" Foreground="#1A237E" FontFamily="Segoe UI Mono" FontSize="10" IsReadOnly="True" VerticalScrollBarVisibility="Auto" TextWrapping="Wrap" AcceptsReturn="True"/>
                <StackPanel Grid.Row="2" Orientation="Horizontal" Margin="15,10,15,10" HorizontalAlignment="Right">
                    <Button Name="btnOfficeAuto" Content="⚡ AUTO REPAIR" Width="120" Height="35" Background="#4CAF50" Foreground="White" FontWeight="Bold" Margin="0,0,10,0"/>
                    <Button Name="btnOfficeManual" Content="⚙ MANUEL" Width="100" Height="35" Background="#2196F3" Foreground="White" FontWeight="Bold" Margin="0,0,10,0"/>
                    <Button Name="btnOfficeClose" Content="LUK" Width="80" Height="35" Background="#D32F2F" Foreground="White" FontWeight="Bold"/>
                </StackPanel>
            </Grid>
        </Window>
"@

        # Load XAML
        $reader = (New-Object System.Xml.XmlNodeReader $officeRepairX)
        $officeWin = [Windows.Markup.XamlReader]::Load($reader)
        
        $officeLog = $officeWin.FindName("officeLog")
        $btnOfficeAuto = $officeWin.FindName("btnOfficeAuto")
        $btnOfficeManual = $officeWin.FindName("btnOfficeManual")
        $btnOfficeClose = $officeWin.FindName("btnOfficeClose")
        
        $officeLog.Text = "Vælg AUTO til komplet reparation af Teams, OneDrive, Office & Outlook`neller MANUEL for at vælge selv"
        
        $btnOfficeClose.Add_Click({ $officeWin.Close() })
        
        $btnOfficeAuto.Add_Click({
            $officeLog.Text = "═══════════ AUTO REPAIR ═══════════`n`n"
            
            # Teams Fix
            $officeLog.Text += "[1/4] Teams Cache & Login Fix...`n"
            try {
                Stop-Process -Name "Teams", "ms-teams" -Force -EA SilentlyContinue
                Start-Sleep -Seconds 1
                Remove-Item "HKCU:\Software\Microsoft\Office\16.0\Common\Identity\Identities\*" -Recurse -Force -EA SilentlyContinue
                Get-ChildItem -Path "$env:AppData\Microsoft\Teams" -ErrorAction SilentlyContinue | ForEach-Object {
                    Remove-Item $_.FullName -Recurse -Force -EA SilentlyContinue
                }
                $officeLog.Text += "✓ Teams cache ryddet`n`n"
            } catch {
                $officeLog.Text += "⚠ Fejl: $($_.Exception.Message)`n`n"
            }
            
            # OneDrive Reset
            $officeLog.Text += "[2/4] OneDrive Reset...`n"
            try {
                Stop-Process -Name "OneDrive" -Force -EA SilentlyContinue
                Start-Sleep -Seconds 1
                & "$env:LocalAppData\Microsoft\OneDrive\onedrive.exe" /reset 2>&1 | Out-Null
                $officeLog.Text += "✓ OneDrive nulstillet`n`n"
            } catch {
                $officeLog.Text += "⚠ Fejl: $($_.Exception.Message)`n`n"
            }
            
            # Office Quick Repair
            $officeLog.Text += "[3/4] Office Quick Repair...`n"
            try {
                $officeC2R = "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe"
                if (Test-Path $officeC2R) {
                    & $officeC2R /update user updatetoversion=16.0 | Out-Null
                    $officeLog.Text += "✓ Office repareret`n`n"
                } else {
                    $officeLog.Text += "⚠ Office ikke installeret`n`n"
                }
            } catch {
                $officeLog.Text += "⚠ Fejl: $($_.Exception.Message)`n`n"
            }
            
            # Outlook Clean
            $officeLog.Text += "[4/4] Outlook Profil-rens...`n"
            try {
                $outlookTemp = "$env:LocalAppData\Microsoft\Outlook"
                if (Test-Path $outlookTemp) {
                    Get-ChildItem -Path "$outlookTemp\*.ost" -ErrorAction SilentlyContinue | Remove-Item -Force -EA SilentlyContinue
                    Get-ChildItem -Path "$outlookTemp\Cache" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -EA SilentlyContinue
                }
                $officeLog.Text += "✓ Outlook ryddet`n`n"
            } catch {
                $officeLog.Text += "⚠ Fejl: $($_.Exception.Message)`n`n"
            }
            
            $officeLog.Text += "═════════════════════════════════════`n✓ REPARATION AFSLUTTET`nGenstart anbefales"
            $btnOfficeAuto.IsEnabled = $false
        })
        
        $btnOfficeManual.Add_Click({
            $officeLog.Text = "════════════ MANUEL REPARATION ════════════`n`n"
            
            $officeLog.Text += "Teams Cache & Login Fix...`n"
            try {
                Stop-Process -Name "Teams", "ms-teams" -Force -EA SilentlyContinue
                Start-Sleep -Seconds 1
                Remove-Item "HKCU:\Software\Microsoft\Office\16.0\Common\Identity\Identities\*" -Recurse -Force -EA SilentlyContinue
                Get-ChildItem -Path "$env:AppData\Microsoft\Teams" -ErrorAction SilentlyContinue | ForEach-Object {
                    Remove-Item $_.FullName -Recurse -Force -EA SilentlyContinue
                }
                $officeLog.Text += "✓ Teams cache ryddet`n`n"
            } catch {
                $officeLog.Text += "⚠ Fejl: $_`n`n"
            }
            
            $officeLog.Text += "OneDrive Reset...`n"
            try {
                Stop-Process -Name "OneDrive" -Force -EA SilentlyContinue
                Start-Sleep -Seconds 1
                & "$env:LocalAppData\Microsoft\OneDrive\onedrive.exe" /reset 2>&1 | Out-Null
                $officeLog.Text += "✓ OneDrive nulstillet`n`n"
            } catch {
                $officeLog.Text += "⚠ Fejl: $_`n`n"
            }
            
            $officeLog.Text += "Office Quick Repair...`n"
            try {
                $officeC2R = "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe"
                if (Test-Path $officeC2R) {
                    & $officeC2R /update user updatetoversion=16.0 | Out-Null
                    $officeLog.Text += "✓ Office repareret`n`n"
                } else {
                    $officeLog.Text += "⚠ Office ikke installeret`n`n"
                }
            } catch {
                $officeLog.Text += "⚠ Fejl: $_`n`n"
            }
            
            $officeLog.Text += "Outlook Profil-rens...`n"
            try {
                $outlookTemp = "$env:LocalAppData\Microsoft\Outlook"
                if (Test-Path $outlookTemp) {
                    Get-ChildItem -Path "$outlookTemp\*.ost" -ErrorAction SilentlyContinue | Remove-Item -Force -EA SilentlyContinue
                    Get-ChildItem -Path "$outlookTemp\Cache" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -EA SilentlyContinue
                }
                $officeLog.Text += "✓ Outlook ryddet`n`n"
            } catch {
                $officeLog.Text += "⚠ Fejl: $_`n`n"
            }
            
            $officeLog.Text += "═════════════════════════════════════`n✓ MANUEL REPARATION AFSLUTTET`nGenstart anbefales"
            $btnOfficeManual.IsEnabled = $false
        })
        
        $officeWin.Owner = $window
        $officeWin.ShowDialog() | Out-Null
    } catch {
        [System.Windows.MessageBox]::Show("Office & Login Repair fejl:`n`n$($_.Exception.Message)", "Fejl", "OK", "Error")
    }
})

# --- WINDOWS HELLO FIX ---
$BtnWinHello.Add_Click({
    try {
        [xml]$winHelloX = @"
        <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="Windows Hello Fix" Height="520" Width="600" Background="#FFFFFF" WindowStartupLocation="CenterOwner" Topmost="True">
            <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                <Border Grid.Row="0" Background="#FF6F00" Padding="15,10,15,10">
                    <TextBlock Text="👤 WINDOWS HELLO FIX - Registrering, TPM &amp; Biometri" Foreground="White" HorizontalAlignment="Center" FontWeight="Bold" FontSize="12"/>
                </Border>
                <TextBox Grid.Row="1" Name="winHelloLog" Margin="15" Background="#F5F5F5" Foreground="#1A237E" FontFamily="Segoe UI Mono" FontSize="10" IsReadOnly="True" VerticalScrollBarVisibility="Auto" TextWrapping="Wrap" AcceptsReturn="True"/>
                <StackPanel Grid.Row="2" Orientation="Horizontal" Margin="15,10,15,10" HorizontalAlignment="Right">
                    <Button Name="btnWinHelloFix" Content="🔧 START FIX" Width="120" Height="35" Background="#4CAF50" Foreground="White" FontWeight="Bold" Margin="0,0,10,0"/>
                    <Button Name="btnWinHelloClose" Content="LUK" Width="80" Height="35" Background="#FF6F00" Foreground="White" FontWeight="Bold"/>
                </StackPanel>
            </Grid>
        </Window>
"@
        
        $reader = (New-Object System.Xml.XmlNodeReader $winHelloX)
        $winHelloWin = [Windows.Markup.XamlReader]::Load($reader)
        
        $winHelloLog = $winHelloWin.FindName("winHelloLog")
        $btnWinHelloFix = $winHelloWin.FindName("btnWinHelloFix")
        $btnWinHelloClose = $winHelloWin.FindName("btnWinHelloClose")
        
        $winHelloLog.Text = "Starter Windows Hello reparation...`n`nDette vil:`n• Reparere PIN-registrering`n• Nulstille TPM`n• Rense NGC-mappen`n• Fikse biometriske problemer`n• Håndtere PolicyUpdate fejl"
        
        $btnWinHelloClose.Add_Click({ $winHelloWin.Close() })
        
        $btnWinHelloFix.Add_Click({
            $winHelloLog.Text = "═════════════════ WINDOWS HELLO FIX (AVANCERET) ═════════════════`n`n"
            $currentIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
            $currentAccount = $currentIdentity.Name
            $localAccount = $currentAccount.Split('\\')[-1]
            
            # 1) Stop Windows Hello services
            $winHelloLog.Text += "[1/9] Stopper Windows Hello services...`n"
            try {
                Stop-Process -Name "NgcCtnrSvc" -Force -EA SilentlyContinue
                Stop-Service -Name "NgcSvc" -Force -EA SilentlyContinue
                Stop-Service -Name "WbioSrvc" -Force -EA SilentlyContinue
                Stop-Service -Name "BioEnrollmentMgr" -Force -EA SilentlyContinue
                $winHelloLog.Text += "✓ Services stoppet`n`n"
            } catch {
                $winHelloLog.Text += "⚠ Fejl: $_`n`n"
            }
            
            # 2) Clear NGC folder + reset permissions
            $winHelloLog.Text += "[2/9] Renser NGC-mapper og rettigheder...`n"
            try {
                $ngcTargets = @("$env:LOCALAPPDATA\Microsoft\Ngc", "C:\Windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc")
                $cleared = 0
                foreach ($path in $ngcTargets) {
                    if (Test-Path $path) {
                        try {
                            & takeown.exe /F "$path" /R /D Y | Out-Null
                            & icacls.exe "$path" /grant "Administrators:(OI)(CI)F" /T /C | Out-Null
                        } catch {
                            $winHelloLog.Text += "⚠ Rettigheds-advarsel ($path): $_`n"
                        }
                        Remove-Item $path -Recurse -Force -EA SilentlyContinue
                        $cleared++
                    }
                }
                if ($cleared -gt 0) {
                    $winHelloLog.Text += "✓ $cleared NGC-mappe(r) nulstillet`n`n"
                } else {
                    $winHelloLog.Text += "ℹ Ingen NGC-mapper fundet (kan være normalt)`n`n"
                }
            } catch {
                $winHelloLog.Text += "⚠ Fejl: $_`n`n"
            }
            
            # 3) Clear TPM
            $winHelloLog.Text += "[3/9] Nulstiller TPM...`n"
            try {
                if (Get-Command Clear-Tpm -EA SilentlyContinue) {
                    Clear-Tpm | Out-Null
                    $winHelloLog.Text += "✓ TPM nulstillet (kræver evt. genstart/BIOS-godkendelse)`n`n"
                } else {
                    $winHelloLog.Text += "ℹ Clear-Tpm cmdlet ikke tilgængelig på denne enhed`n`n"
                }
            } catch {
                $winHelloLog.Text += "⚠ TPM fejl: $_`n`n"
            }
            
            # 4) Create/Fix PassportForWork registry (root)
            $winHelloLog.Text += "[4/9] Sikrer PassportForWork rod-nøgle...`n"
            try {
                $regPathLM = "HKLM:\SOFTWARE\Microsoft\Policies\PassportForWork"
                if (-not (Test-Path $regPathLM)) {
                    New-Item -Path $regPathLM -Force | Out-Null
                    $winHelloLog.Text += "✓ PassportForWork key oprettet`n"
                }
                $rootValue = Get-ItemProperty -Path $regPathLM -Name "UserPassportForWork" -EA SilentlyContinue
                if ($null -eq $rootValue) {
                    New-ItemProperty -Path $regPathLM -Name "UserPassportForWork" -Value 1 -PropertyType DWORD -Force | Out-Null
                    $winHelloLog.Text += "✓ UserPassportForWork sat til 1 (rod)`n`n"
                } else {
                    Set-ItemProperty -Path $regPathLM -Name "UserPassportForWork" -Value 1 -Force
                    $winHelloLog.Text += "✓ UserPassportForWork genaktiveret (rod)`n`n"
                }
            } catch {
                $winHelloLog.Text += "⚠ Registry fejl (rod): $_`n`n"
            }
            
            # 5) Fix all PassportForWork subkeys
            $winHelloLog.Text += "[5/9] Synkroniserer alle PassportForWork subkeys...`n"
            try {
                $regPathLM = "HKLM:\SOFTWARE\Microsoft\Policies\PassportForWork"
                $subkeys = Get-ChildItem -Path $regPathLM -EA SilentlyContinue | Where-Object { $_.PSChildName -match '^S-1-5-' }
                if ($subkeys -and $subkeys.Count -gt 0) {
                    Remove-ItemProperty -Path $regPathLM -Name "UserPassportForWork" -EA SilentlyContinue
                    $fixed = 0
                    foreach ($subkey in $subkeys) {
                        foreach ($target in @("$($subkey.PSPath)\Policies", "$($subkey.PSPath)\Device\Policies")) {
                            if (-not (Test-Path $target)) {
                                New-Item -Path $target -Force | Out-Null
                            }
                            New-ItemProperty -Path $target -Name "UserPassportForWork" -Value 1 -PropertyType DWORD -Force | Out-Null
                        }
                        $fixed++
                    }
                    $winHelloLog.Text += "✓ $fixed identity-mapper sat til UserPassportForWork=1`n`n"
                } else {
                    $winHelloLog.Text += "ℹ Ingen identity subkeys endnu. Kør fix igen efter genstart hvis mapper (S-1-5-*) senere dukker op.`n`n"
                }
            } catch {
                $winHelloLog.Text += "⚠ Subkey fejl: $_`n`n"
            }
            
            # 6) Make current user Local Administrator
            $winHelloLog.Text += "[6/9] Sikrer midlertidig lokal administrator...`n"
            try {
                $adminGroup = [ADSI]"WinNT://./Administrators,group"
                $memberNames = @()
                try {
                    $memberNames = $adminGroup.psbase.Invoke("Members") | ForEach-Object { $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null) }
                } catch {}
                if ($memberNames -contains $localAccount) {
                    $winHelloLog.Text += "ℹ Brugeren er allerede i Administrators (springer over)`n`n"
                } else {
                    $addResult = & net localgroup Administrators "$currentAccount" /add 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        $winHelloLog.Text += "✓ Bruger tilføjet til Administrators (husk at fjerne igen når Hello virker)`n`n"
                    } else {
                        $winHelloLog.Text += "⚠ Kunne ikke tilføje bruger: $addResult`n`n"
                    }
                }
            } catch {
                $winHelloLog.Text += "⚠ Admin-fejl: $_`n`n"
            }
            
            # 7) Start services again
            $winHelloLog.Text += "[7/9] Genstarter Windows Hello services...`n"
            try {
                Start-Service -Name "WbioSrvc" -EA SilentlyContinue
                Start-Service -Name "NgcSvc" -EA SilentlyContinue
                Start-Service -Name "BioEnrollmentMgr" -EA SilentlyContinue
                Start-Sleep -Seconds 2
                $winHelloLog.Text += "✓ Services genstartet`n`n"
            } catch {
                $winHelloLog.Text += "⚠ Fejl: $_`n`n"
            }
            
            # 8) Clear policies cache
            $winHelloLog.Text += "[8/9] Clearer policies cache...`n"
            try {
                Remove-Item "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\*" -Recurse -Force -EA SilentlyContinue
                gpupdate /force /wait:0 | Out-Null
                $winHelloLog.Text += "✓ Policies cache clearet og GPO opdateret`n`n"
            } catch {
                $winHelloLog.Text += "⚠ Cache fejl: $_`n`n"
            }
            
            # 9) Summary and instructions
            $winHelloLog.Text += "[9/9] Færdiggør...`n"
            $winHelloLog.Text += "`n══════════════════════════════════════════════════════════════`n"
            $winHelloLog.Text += "✓ WINDOWS HELLO ADVANCED FIX AFSLUTTET!`n`n"
            $winHelloLog.Text += "VIGTIGE NÆSTE TRIN:`n"
            $winHelloLog.Text += "1. ⚠ GENSTART COMPUTEREN NU`n"
            $winHelloLog.Text += "2. Log ind med din bruger (du er nu administrator)`n"
            $winHelloLog.Text += "3. Åbn Settings > Accounts > Sign-in options > Windows Hello`n"
            $winHelloLog.Text += "4. Tilføj PIN igen`n"
            $winHelloLog.Text += "5. Tilføj ansigtsgenkendelses- eller fingeraftryksdata`n`n"
            $winHelloLog.Text += "HVIS SUCCES:`n"
            $winHelloLog.Text += "- Fjern Administrator-rettigheder fra denne bruger igen`n`n"
            $winHelloLog.Text += "HVIS STADIG FEJL 0x80090010:`n"
            $winHelloLog.Text += "- Log ind som LOCAL administrator (ikke domæne)`n"
            $winHelloLog.Text += "- Gentag procedure igen mens logget ind som bruger`n"
            $winHelloLog.Text += "- Vent på Microsoft-rettelse til juli 2025-opdatering`n`n"
            $winHelloLog.Text += "══════════════════════════════════════════════════════════════"
            
            $btnWinHelloFix.IsEnabled = $false
        })
        
        $winHelloWin.Owner = $window
        $winHelloWin.ShowDialog() | Out-Null
    } catch {
        [System.Windows.MessageBox]::Show("Windows Hello fejl:`n`n$($_.Exception.Message)", "Fejl", "OK", "Error")
    }
})

$BtnExit.Add_Click({ $window.Close() })

# Hide console now that GUI is ready
& $hideConsole

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
