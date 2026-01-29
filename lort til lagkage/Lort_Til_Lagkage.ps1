# --- FASE 1: AUTO-BYPASS & ADMIN CHECK ---
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # Hvis ikke admin, genstart sig selv med Bypass og Admin rettigheder
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# Sætter policien for den nuværende session så alt kører glat
Set-ExecutionPolicy Bypass -Scope Process -Force

Add-Type -AssemblyName PresentationFramework, System.Windows.Forms, System.Drawing

# --- GUI DESIGN ---
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Herningsholm IT - Lort Til Lagkage V12" Height="600" Width="500" Background="#1E1E1E">
    <Window.Resources>
        <Style TargetType="Button">
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="Margin" Value="0,5"/>
            <Setter Property="Height" Value="45"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderThickness" Value="0"/>
        </Style>
    </Window.Resources>
    <Grid Margin="20">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        
        <StackPanel Grid.Row="0">
            <TextBlock Text="Lort Til Lagkage" FontSize="30" FontWeight="Bold" Foreground="#FFD700" HorizontalAlignment="Center"/>
            <TextBlock Text="ExpertBook Recovery Suite - IT Support" FontSize="12" Foreground="#AAAAAA" HorizontalAlignment="Center" Margin="0,0,0,15"/>
        </StackPanel>

        <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto">
            <StackPanel VerticalAlignment="Center">
                <Button Name="BtnUpdate" Content="1. TOTAL OPDATERING (Apps &amp; Drivere)" Background="#007ACC"/>
                <Button Name="BtnClean" Content="2. DYB SYSTEM RENS (SFC &amp; DISM)" Background="#2E7D32"/>
                <Button Name="BtnDebloat" Content="3. FJERN BLOATWARE &amp; ANTIVIRUS" Background="#C62828"/>
                <Button Name="BtnNet" Content="4. NETVÆRKS DIAGNOSE (IP/DNS Fix)" Background="#673AB7"/>
                <Button Name="BtnPower" Content="5. TVING MAX PERFORMANCE" Background="#F9A825" Foreground="Black"/>
            </StackPanel>
        </ScrollViewer>

        <StackPanel Grid.Row="2">
            <TextBlock Name="StatusTxt" Text="Status: Klar til at fixe lortet" Foreground="#61D6D6" HorizontalAlignment="Center" Margin="0,15" FontSize="14"/>
        </StackPanel>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

$BtnUpdate = $window.FindName("BtnUpdate")
$BtnClean = $window.FindName("BtnClean")
$BtnDebloat = $window.FindName("BtnDebloat")
$BtnNet = $window.FindName("BtnNet")
$BtnPower = $window.FindName("BtnPower")
$StatusTxt = $window.FindName("StatusTxt")

# --- EXECUTION ENGINE ---
function Run-Job ([scriptblock]$Code) {
    $ScriptString = $Code.ToString()
    $Encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($ScriptString))
    Start-Process powershell.exe -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-EncodedCommand", $Encoded
}

# --- FUNKTIONER ---

$BtnUpdate.Add_Click({
    $StatusTxt.Text = "Status: Opdaterer..."
    Run-Job {
        Write-Host "--- TOTAL OPDATERING ---" -ForegroundColor Cyan
        winget upgrade --all --accept-package-agreements --accept-source-agreements
        if (-not (Get-Module -ListAvailable PSWindowsUpdate)) {
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false
            Install-Module PSWindowsUpdate -Force -Confirm:$false -Scope CurrentUser
        }
        Import-Module PSWindowsUpdate
        Get-WindowsUpdate -Install -AcceptAll -IgnoreReboot
        Write-Host "`nFÆRDIG! Tryk ENTER." -ForegroundColor Green
        Read-Host
    }
})

$BtnClean.Add_Click({
    $StatusTxt.Text = "Status: Renser systemet..."
    Run-Job {
        Write-Host "--- DYB SYSTEM RENS ---" -ForegroundColor Green
        sfc /scannow
        dism /online /cleanup-image /restorehealth
        Write-Host "`nFÆRDIG! Tryk ENTER." -ForegroundColor Green
        Read-Host
    }
})

$BtnDebloat.Add_Click({
    $StatusTxt.Text = "Status: Fjerner junk..."
    Run-Job {
        Write-Host "--- TOTAL DEBLOAT ---" -ForegroundColor Red
        $apps = @("TikTok", "Instagram", "Facebook", "Disney", "Netflix", "CandyCrush", "Solitaire", "Minecraft", "Roblox", "BingNews", "BingWeather", "YourPhone", "LinkedIn", "PowerAutomate", "McAfee", "Norton", "Avast", "AVG", "Malwarebytes", "Panda", "Kaspersky", "Asus", "Acer", "Lenovo", "HPDesktop", "Dell")
        foreach ($name in $apps) {
            Write-Host "Fjerner: $name" -ForegroundColor Yellow
            Get-AppxPackage "*$name*" -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
        }
        Get-Process "*Asus*", "*McAfee*", "*Norton*", "*Avast*", "*AVG*", "*Malwarebytes*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Write-Host "`nLAGKAGEN ER KLAR! Tryk ENTER." -ForegroundColor Green
        Read-Host
    }
})

$BtnNet.Add_Click({
    $StatusTxt.Text = "Status: Tjekker netværk..."
    Run-Job {
        Write-Host "--- NETVÆRKS DIAGNOSE ---" -ForegroundColor Magenta
        ipconfig /all | Select-String "IPv4", "Subnet Mask", "Default Gateway", "DNS Servers"
        Write-Host "`nTester forbindelse..."
        Test-Connection -ComputerName 8.8.8.8 -Count 2
        ipconfig /flushdns
        netsh winsock reset
        Write-Host "`nFÆRDIG! Tryk ENTER." -ForegroundColor Green
        Read-Host
    }
})

$BtnPower.Add_Click({
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    $StatusTxt.Text = "Status: Ultimate Performance Aktiv!"
    [System.Windows.MessageBox]::Show("PC'en er nu optimeret til max hastighed!", "Lort Til Lagkage")
})

$window.ShowDialog() | Out-Null