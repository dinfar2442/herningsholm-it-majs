Write-Host "Testing herningsholm-it-tool.ps1" -ForegroundColor Cyan

$scriptContent = Get-Content -Raw ".\herningsholm-it-tool.ps1"
Write-Host "File size: $($scriptContent.Length) bytes"

try {
    $null = [scriptblock]::Create($scriptContent)
    Write-Host "OK - Parser passed" -ForegroundColor Green
}
catch {
    Write-Host "ERROR - Parse failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}


ind