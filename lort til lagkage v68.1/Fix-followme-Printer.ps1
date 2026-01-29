# --- FASE 1: ADMIN CHECK ---
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Add-Type -AssemblyName PresentationFramework, System.Windows.Forms

# --- GUI DESIGN ---
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Herningsholm IT - Ultimate Fix V8" Height="350" Width="450" Background="#0A0A0A" WindowStartupLocation="CenterScreen" ResizeMode="NoResize">
    <Grid Margin="20">
        <StackPanel VerticalAlignment="Center">
            <TextBlock Text="ULTIMATE PRINTER FIX V8" FontSize="22" FontWeight="Black" Foreground="#FFD700" HorizontalAlignment="Center" Margin="0,0,0,10"/>
            <TextBlock Text="Forsøger Local Port Omvej (Fejl 0x00000574)" Foreground="#00FF00" HorizontalAlignment="Center" Margin="0,0,0,20"/>
            <Button Name="BtnFixPrinter" Content="FORCE INSTALLER" Background="#1B5E20" Foreground="White" Height="70" FontWeight="Bold" FontSize="20"/>
            <TextBlock Name="StatusTxt" Text="Status: Klar" Foreground="#AAAAAA" HorizontalAlignment="Center" Margin="0,20,0,0" FontSize="12" TextWrapping="Wrap"/>
        </StackPanel>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)
$BtnFixPrinter = $window.FindName("BtnFixPrinter")
$StatusTxt = $window.FindName("StatusTxt")

# --- LOGIK ---
$BtnFixPrinter.Add_Click({
    $BtnFixPrinter.IsEnabled = $false
    $StatusTxt.Text = "Nuker gamle indstillinger..."
    $StatusTxt.Foreground = "Yellow"
    
    $server = "hhe-ps4"
    $printerPath = "\\$server\Follow-Me"

    # 1. RPC & Point and Print Hard Fix
    $paths = @(
        "HKLM:\Software\Policies\Microsoft\Windows NT\Printers\RPC",
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint"
    )
    foreach ($p in $paths) { if (!(Test-Path $p)) { New-Item $p -Force | Out-Null } }
    
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\Printers\RPC" -Name "RpcUseNamedPipeProtocol" -Value 1 -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -Name "RestrictDriverInstallationToAdministrators" -Value 0 -Force

    # 2. Stop Spooler
    Stop-Service Spooler -Force -ErrorAction SilentlyContinue
    
    # 3. Fjern printeren helt fra registreringsdatabasen hvis den hænger
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Print\Providers\Client Side Rendering Print Provider" /f 2>$null

    Start-Service Spooler

    # 4. Forsøg installation via den mest direkte metode
    $StatusTxt.Text = "Installerer... Hvis det fejler, skal PC'en genstartes."
    
    try {
        # Vi bruger en metode der tvinger driveren til at blive tjekket
        Add-PrinterConnection -Name $printerPath
        $StatusTxt.Text = "SUCCES! Forbundet via Add-PrinterConnection."
        $StatusTxt.Foreground = "LightGreen"
    } catch {
        # SIDSTE FORSØG: Rundll32 uden UI-blokering
        $process = Start-Process "rundll32.exe" -ArgumentList "printui.dll,PrintUIEntry /in /n `"$printerPath`" /q" -PassThru -Wait
        if ($process.ExitCode -eq 0) {
            $StatusTxt.Text = "SUCCES! (via PrintUI)"
            $StatusTxt.Foreground = "LightGreen"
        } else {
            $StatusTxt.Text = "STADIG FEJL. Prøv dette: Åbn 'Kør' (Win+R) -> Skriv \\hhe-ps4 -> Højreklik på Follow-Me og vælg 'Forbind'. Hvad sker der?"
            $StatusTxt.Foreground = "Red"
        }
    }

    $BtnFixPrinter.IsEnabled = $true
})

$window.ShowDialog() | Out-Null