# Herningsholm IT Majs

En samling PowerShell- og batchværktøjer til fejlfinding, vedligeholdelse og klargøring af Windows-computere på Herningsholm.

Repoet indeholder flere separate scripts og værktøjer, som kan bruges af IT-supportere til at løse typiske problemer med opdateringer, drivere, systemfiler, netværk, printere, Windows-komponenter og brugerprogrammer.

> **Bemærk:** Værktøjerne er primært udviklet til Windows-miljøer og kan foretage ændringer i systemet. Kør kun scripts, du forstår, og gennemgå altid koden før brug på en produktionscomputer.

## Funktioner

### Herningsholm IT Tool

`herningsholm-IT-Tool/herningsholm-it-tool.ps1` er det primære grafiske supportværktøj. Det starter automatisk med administratorrettigheder og indeholder funktioner til blandt andet:

- Visning af system- og hardwareoplysninger
- Windows- og programopdateringer
- Installation eller opdatering via `winget`, når det er tilgængeligt
- Oprydning af midlertidige filer og DNS-cache
- Reparation af Windows-komponenter med SFC og DISM
- Netværksdiagnose og fejlfinding
- Ydelsesrelaterede systemindstillinger
- Fjernelse eller håndtering af udvalgt bloatware og antivirussoftware
- Diverse hjælpefunktioner til klargøring og support

### Lort Til Lagkage

Mapperne `lort til lagkage`, `lort til lagkage v68.1` og `lort til lagkageV68.2.1` indeholder forskellige versioner af et grafisk recovery- og supportværktøj.

Værktøjet er målrettet hurtig fejlfinding på bærbare computere og kan blandt andet bruges til:

- Samlet opdatering af Windows, programmer og drivere
- Dyb systemrensning med SFC og DISM
- Netværksdiagnose og nulstilling af netværksrelaterede indstillinger
- Optimering af strøm- og ydelsesindstillinger
- Håndtering af udvalgte uønskede programmer
- Reparation af Follow-Me-printeren

Filerne `1_Unlock.bat.bat` og `2_Lock.bat.bat` ændrer PowerShell Execution Policy for den aktuelle bruger eller maskine. Brug **Unlock** før scripts, hvis Windows blokerer for kørsel, og brug **Lock** bagefter for at gendanne en mere restriktiv indstilling.

### System- og Windows-reparation

- `dismclean.ps1` analyserer Windows Component Store, udfører DISM-oprydning og kører derefter `sfc /scannow`.
- `fix-lively/Fix-Lively-Wallpaper.ps1` indeholder reparationer til Lively Wallpaper-problemer, herunder fejl `0xc0000142` på Windows 11 24H2.
- `herningsholm-IT-Tool/wordmat-install-fix.ps1` hjælper med installation eller reparation af WordMat.
- `herningsholm-IT-Tool/auto-office-login-repair.ps1` er beregnet til fejlfinding af Office-login.

### Printer- og hardwareværktøjer

- `lort til lagkageV68.2.1/Fix-followme-Printer.ps1` forsøger at reparere og geninstallere Follow-Me-printeren.
- `herningsholm-IT-Tool/fix-update-handler.ps1` indeholder en opdateret opdateringsfunktion til hovedværktøjet.
- Repoet indeholder desuden hjælpeprogrammer til blandt andet HP-opdateringer, MyASUS og pc-mobilitetsprint.

## Kom i gang

### Krav

- Windows 10 eller Windows 11
- Windows PowerShell 5.1 eller nyere
- Administratorrettigheder for de fleste funktioner
- `winget` for programopdateringer via Windows Package Manager
- Internetforbindelse til opdateringer, downloads og enkelte reparationsfunktioner

### Kør hovedværktøjet

1. Download eller klon repositoryet.
2. Åbn mappen `herningsholm-IT-Tool`.
3. Højreklik på `herningsholm-it-tool.ps1`.
4. Vælg **Kør med PowerShell**.
5. Godkend UAC-prompten, hvis den vises.

Alternativt kan scriptet startes fra PowerShell:

```powershell
cd .\\herningsholm-IT-Tool
.\\herningsholm-it-tool.ps1
```

### Kør Lort Til Lagkage

1. Åbn den ønskede versionsmappe.
2. Højreklik på `1_Unlock.bat.bat` og vælg **Kør som administrator**, hvis scripts er blokeret.
3. Kør derefter `Lort_Til_Lagkage.ps1` eller `lort til lagkage.ps1` fra den relevante mappe.
4. Når du er færdig, kan du køre `2_Lock.bat.bat` for at sætte Execution Policy tilbage til en restriktiv indstilling.

Eksempel:

```powershell
cd .\\lort til lagkage
.\\Lort_Til_Lagkage.ps1
```

### Kør DISM-oprydning

`dismclean.ps1` kræver administratorrettigheder og genstarter automatisk med elevation, hvis det er nødvendigt:

```powershell
.\\dismclean.ps1
```

Scriptet udfører følgende trin:

1. Analyse af Windows Component Store
2. DISM Component Cleanup
3. Dyb oprydning med `ResetBase`
4. Kontrol og reparation af systemfiler med `sfc /scannow`

## Sikkerhed og vigtige advarsler

Scripts i dette repository kan:

- Ændre Windows Registry
- Ændre PowerShell Execution Policy
- Installere, reparere eller fjerne software
- Ændre printer-, netværks- og systemindstillinger
- Slette midlertidige filer
- Køre kommandoer med administratorrettigheder

Derfor anbefales det at:

1. Tage backup af vigtige data før brug.
2. Oprette et gendannelsespunkt, når det er muligt.
3. Kontrollere at scriptet passer til den konkrete computer.
4. Køre scripts med administratorrettigheder kun, når det er nødvendigt.
5. Kontrollere ændringer i Registry, printeropsætning og sikkerhedsindstillinger efter kørsel.
6. Bruge den korrekte version af værktøjet og læse eventuelle `hvordan.txt`-filer først.

## Struktur

```text
.
├── dismclean.ps1                         # DISM- og SFC-baseret systemrens
├── fix-lively/
│   └── Fix-Lively-Wallpaper.ps1          # Reparation af Lively Wallpaper
├── herningsholm-IT-Tool/
│   ├── herningsholm-it-tool.ps1          # Primært grafisk IT-supportværktøj
│   ├── herningsholm-it-tool-backup.ps1   # Backupversion af hovedværktøjet
│   ├── auto-office-login-repair.ps1      # Office-loginreparation
│   ├── fix-update-handler.ps1            # Hjælpescript til opdateringsfunktion
│   └── wordmat-install-fix.ps1           # WordMat-relateret installation/reparation
├── lort til lagkage/
│   └── Lort_Til_Lagkage.ps1              # Recovery- og supportværktøj
├── lort til lagkage v68.1/                # Ældre version
└── lort til lagkageV68.2.1/               # Nyere version med printerfix
```

## Status

Repositoryet er et internt værktøjssæt under løbende udvikling. Funktioner og scripts kan ændre sig mellem versioner, og enkelte værktøjer kan være målrettet specifik hardware, software eller Herningsholms interne miljø.

## Licens

Der er endnu ikke angivet en licens for repositoryet. Kontakt repository-ejeren, hvis du vil bruge eller videredistribuere værktøjerne uden for det oprindelige miljø.
