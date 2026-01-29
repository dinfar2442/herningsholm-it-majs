# ============================================================
# OFFICE & LOGIN REPAIR MODULE
# ============================================================
# Add this button click handler to your main script where other buttons are defined
# Integration point: After $BtnElevPrint.Add_Click({ ... }) and before $BtnExit.Add_Click({ ... })
# ============================================================

$BtnOfficeRepair.Add_Click({
    try {
        # XAML GUI Definition
        [xml]$officeRepairX = @"
        <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
                Title="Office & Login Repair" Height="550" Width="600" 
                Background="#F5F5F5" WindowStartupLocation="CenterOwner" Topmost="True" 
                ResizeMode="CanResize" MinHeight="500" MinWidth="550">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <!-- Header -->
                <Border Grid.Row="0" Background="#1976D2" Padding="20,15,20,15">
                    <TextBlock Text="🔧 OFFICE &amp; LOGIN REPAIR" 
                               Foreground="White" FontSize="14" FontWeight="Bold" 
                               HorizontalAlignment="Center"/>
                </Border>

                <!-- Mode Selection -->
                <StackPanel Grid.Row="1" Margin="20" VerticalAlignment="Top">
                    <!-- Auto Mode -->
                    <Border BorderBrush="#E0E0E0" BorderThickness="1" Padding="15" CornerRadius="5" Margin="0,0,0,15" Background="#FAFAFA">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>
                            <RadioButton Grid.Column="0" Name="radAutoRepair" IsChecked="True" 
                                        VerticalAlignment="Top" Margin="0,2,15,0"/>
                            <StackPanel Grid.Column="1">
                                <TextBlock Text="🚀 Automatisk - Fix Alt" FontWeight="Bold" FontSize="12" Margin="0,0,0,5"/>
                                <TextBlock Text="Kører alle reparationer automatisk i én omgang (anbefalet)" 
                                          FontSize="11" Foreground="#666" TextWrapping="Wrap"/>
                            </StackPanel>
                        </Grid>
                    </Border>

                    <!-- Manual Mode -->
                    <Border BorderBrush="#E0E0E0" BorderThickness="1" Padding="15" CornerRadius="5" Background="#FAFAFA">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>
                            <RadioButton Grid.Column="0" Name="radManualRepair" VerticalAlignment="Top" Margin="0,2,15,0"/>
                            <StackPanel Grid.Column="1">
                                <TextBlock Text="⚙️  Manuelt - Vælg selv" FontWeight="Bold" FontSize="12" Margin="0,0,0,5"/>
                                <TextBlock Text="Vælg hvilke fixes du vil køre" FontSize="11" Foreground="#666" TextWrapping="Wrap"/>
                                <StackPanel Name="manualOptions" Margin="0,10,0,0" Visibility="Collapsed">
                                    <CheckBox Name="chkTeams" Margin="0,5">
                                        <TextBlock Text="Teams Cache &amp; Login Fix (sletter cache, nulstiller login)" FontSize="11"/>
                                    </CheckBox>
                                    <CheckBox Name="chkOneDrive" Margin="0,5">
                                        <TextBlock Text="OneDrive Reset (synkronisering &amp; legitimation)" FontSize="11"/>
                                    </CheckBox>
                                    <CheckBox Name="chkOfficeRepair" Margin="0,5" IsChecked="True">
                                        <TextBlock Text="Office Quick Repair (lydløs reparation)" FontSize="11"/>
                                    </CheckBox>
                                    <CheckBox Name="chkOutlook" Margin="0,5">
                                        <TextBlock Text="Outlook Profil-rens (midlertidige filer)" FontSize="11"/>
                                    </CheckBox>
                                </StackPanel>
                            </StackPanel>
                        </Grid>
                    </Border>
                </StackPanel>

                <!-- Status/Log Area -->
                <Border Grid.Row="2" BorderBrush="#DDD" BorderThickness="0,1,0,0" Padding="20,10,20,10" Background="#F9F9F9">
                    <TextBlock Name="statusText" Text="Vælg tilstanden ovenfor og klik 'Start Reparation'" 
                               FontSize="10" Foreground="#666" TextWrapping="Wrap"/>
                </Border>

                <!-- Buttons -->
                <StackPanel Grid.Row="3" Orientation="Horizontal" Margin="20,15,20,20" HorizontalAlignment="Right">
                    <Button Name="btnStartRepair" Content="🔄 Start Reparation" Width="140" Height="35" 
                            Background="#4CAF50" Foreground="White" FontWeight="Bold" Margin="0,0,10,0"/>
                    <Button Name="btnCloseRepair" Content="Luk" Width="100" Height="35" 
                            Background="#999" Foreground="White" FontWeight="Bold"/>
                </StackPanel>
            </Grid>
        </Window>
"@

        # Load XAML
        $reader = [System.Xml.XmlNodeReader]::new($officeRepairX.DocumentElement)
        $officeWin = [Windows.Markup.XamlReader]::Load($reader)

        # Get controls
        $radAutoRepair = $officeWin.FindName("radAutoRepair")
        $radManualRepair = $officeWin.FindName("radManualRepair")
        $manualOptions = $officeWin.FindName("manualOptions")
        $chkTeams = $officeWin.FindName("chkTeams")
        $chkOneDrive = $officeWin.FindName("chkOneDrive")
        $chkOfficeRepair = $officeWin.FindName("chkOfficeRepair")
        $chkOutlook = $officeWin.FindName("chkOutlook")
        $statusText = $officeWin.FindName("statusText")
        $btnStartRepair = $officeWin.FindName("btnStartRepair")
        $btnCloseRepair = $officeWin.FindName("btnCloseRepair")

        # Toggle manual options when radio button changes
        $radManualRepair.Add_Checked({
            $manualOptions.Visibility = "Visible"
        })
        $radAutoRepair.Add_Checked({
            $manualOptions.Visibility = "Collapsed"
        })

        # Close button
        $btnCloseRepair.Add_Click({ $officeWin.Close() })

        # Start Repair button logic
        $btnStartRepair.Add_Click({
            $statusText.Text = "🔄 Reparation i gang..."
            $statusText.Foreground = [System.Windows.Media.Brushes]::DodgerBlue
            $btnStartRepair.IsEnabled = $false
            [System.Windows.Forms.Application]::DoEvents()

            $repairLog = ""

            try {
                # Determine what to fix
                if ($radAutoRepair.IsChecked) {
                    # Auto mode: run all fixes
                    $repairLog += "=== AUTOMATISK REPARATION ===`n`n"
                    
                    # Teams Fix
                    $repairLog += "1️⃣  Teams Cache & Login Fix...`n"
                    try {
                        Stop-Process -Name "Teams", "ms-teams" -Force -EA SilentlyContinue
                        Start-Sleep -Seconds 1
                        Remove-Item "HKCU:\Software\Microsoft\Office\16.0\Common\Identity\Identities\*" -Recurse -Force -EA SilentlyContinue
                        Get-ChildItem -Path "$env:AppData\Microsoft\Teams" -ErrorAction SilentlyContinue | ForEach-Object {
                            Remove-Item $_.FullName -Recurse -Force -EA SilentlyContinue
                        }
                        $repairLog += "   ✓ Teams cache ryddet og legitimation nulstillet`n`n"
                    } catch {
                        $repairLog += "   ⚠ Teams fix fejlede: $($_.Exception.Message)`n`n"
                    }

                    # OneDrive Reset
                    $repairLog += "2️⃣  OneDrive Reset...`n"
                    try {
                        Stop-Process -Name "OneDrive" -Force -EA SilentlyContinue
                        Start-Sleep -Seconds 1
                        & "$env:LocalAppData\Microsoft\OneDrive\onedrive.exe" /reset 2>&1 | Out-Null
                        Start-Sleep -Seconds 2
                        # Clear Windows Credentials
                        & cmdkey /list 2>&1 | ForEach-Object {
                            if ($_ -match "Target: (.+)") {
                                $target = $matches[1]
                                if ($target -like "*OneDrive*" -or $target -like "*Microsoft*") {
                                    & cmdkey /delete:$target 2>&1 | Out-Null
                                }
                            }
                        }
                        $repairLog += "   ✓ OneDrive nulstillet og legitimation ryddet`n`n"
                    } catch {
                        $repairLog += "   ⚠ OneDrive reset fejlede: $($_.Exception.Message)`n`n"
                    }

                    # Office Quick Repair
                    $repairLog += "3️⃣  Office Quick Repair...`n"
                    try {
                        $officeC2R = "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe"
                        if (Test-Path $officeC2R) {
                            & $officeC2R /update user updatetoversion=16.0 | Out-Null
                            Start-Sleep -Seconds 3
                            $repairLog += "   ✓ Office Quick Repair kørt`n`n"
                        } else {
                            $repairLog += "   ⚠ Office ClickToRun ikke fundet (muligvis ikke installeret)`n`n"
                        }
                    } catch {
                        $repairLog += "   ⚠ Office repair fejlede: $($_.Exception.Message)`n`n"
                    }

                    # Outlook Clean
                    $repairLog += "4️⃣  Outlook Profil-rens...`n"
                    try {
                        $outlookTemp = "$env:LocalAppData\Microsoft\Outlook"
                        if (Test-Path $outlookTemp) {
                            Get-ChildItem -Path "$outlookTemp\*.ost" -ErrorAction SilentlyContinue | Remove-Item -Force -EA SilentlyContinue
                            Get-ChildItem -Path "$outlookTemp\Cache" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -EA SilentlyContinue
                        }
                        $repairLog += "   ✓ Outlook midlertidige filer ryddet`n`n"
                    } catch {
                        $repairLog += "   ⚠ Outlook rens fejlede: $($_.Exception.Message)`n`n"
                    }

                } else {
                    # Manual mode: run only selected fixes
                    $repairLog += "=== MANUEL REPARATION ===`n`n"

                    if ($chkTeams.IsChecked) {
                        $repairLog += "✓ Teams Cache & Login Fix...`n"
                        try {
                            Stop-Process -Name "Teams", "ms-teams" -Force -EA SilentlyContinue
                            Start-Sleep -Seconds 1
                            Remove-Item "HKCU:\Software\Microsoft\Office\16.0\Common\Identity\Identities\*" -Recurse -Force -EA SilentlyContinue
                            Get-ChildItem -Path "$env:AppData\Microsoft\Teams" -ErrorAction SilentlyContinue | ForEach-Object {
                                Remove-Item $_.FullName -Recurse -Force -EA SilentlyContinue
                            }
                            $repairLog += "  ✓ Teams cache ryddet`n`n"
                        } catch {
                            $repairLog += "  ⚠ Fejl: $($_.Exception.Message)`n`n"
                        }
                    }

                    if ($chkOneDrive.IsChecked) {
                        $repairLog += "✓ OneDrive Reset...`n"
                        try {
                            Stop-Process -Name "OneDrive" -Force -EA SilentlyContinue
                            Start-Sleep -Seconds 1
                            & "$env:LocalAppData\Microsoft\OneDrive\onedrive.exe" /reset 2>&1 | Out-Null
                            $repairLog += "  ✓ OneDrive nulstillet`n`n"
                        } catch {
                            $repairLog += "  ⚠ Fejl: $($_.Exception.Message)`n`n"
                        }
                    }

                    if ($chkOfficeRepair.IsChecked) {
                        $repairLog += "✓ Office Quick Repair...`n"
                        try {
                            $officeC2R = "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe"
                            if (Test-Path $officeC2R) {
                                & $officeC2R /update user updatetoversion=16.0 | Out-Null
                                $repairLog += "  ✓ Office repareret`n`n"
                            } else {
                                $repairLog += "  ⚠ Office ikke fundet`n`n"
                            }
                        } catch {
                            $repairLog += "  ⚠ Fejl: $($_.Exception.Message)`n`n"
                        }
                    }

                    if ($chkOutlook.IsChecked) {
                        $repairLog += "✓ Outlook Profil-rens...`n"
                        try {
                            $outlookTemp = "$env:LocalAppData\Microsoft\Outlook"
                            if (Test-Path $outlookTemp) {
                                Get-ChildItem -Path "$outlookTemp\*.ost" -ErrorAction SilentlyContinue | Remove-Item -Force -EA SilentlyContinue
                                Get-ChildItem -Path "$outlookTemp\Cache" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -EA SilentlyContinue
                            }
                            $repairLog += "  ✓ Outlook ryddet`n`n"
                        } catch {
                            $repairLog += "  ⚠ Fejl: $($_.Exception.Message)`n`n"
                        }
                    }
                }

                $repairLog += "`n════════════════════════════════════`n"
                $repairLog += "✓ REPARATION AFSLUTTET`n"
                $repairLog += "Genstart anbefales for at anvende alle ændringer"

                $statusText.Text = $repairLog
                $statusText.Foreground = [System.Windows.Media.Brushes]::DarkGreen

            } catch {
                $repairLog += "`n⚠ Uventet fejl: $($_.Exception.Message)"
                $statusText.Text = $repairLog
                $statusText.Foreground = [System.Windows.Media.Brushes]::Red
            } finally {
                $btnStartRepair.IsEnabled = $true
            }
        })

        $officeWin.Owner = $window
        $officeWin.ShowDialog() | Out-Null

    } catch {
        [System.Windows.MessageBox]::Show("Fejl i Office & Login Repair modul:`n`n$($_.Exception.Message)", "Fejl", "OK", "Error")
    }
})
