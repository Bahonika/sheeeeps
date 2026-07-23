# Build the web client, pointing it at your live server (Windows PowerShell).
# Usage:  .\scripts\build-web.ps1 wss://pasture.example.com
#   (use ws://localhost:8080 for a local server during development)
param(
    [Parameter(Mandatory = $true)]
    [string]$Url
)

flutter build web `
    --release `
    -t lib/main_pasture.dart `
    --dart-define=PASTURE_URL=$Url

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Built build/web  (server URL baked in: $Url)"
    Write-Host "Deploy the contents of build/web to Cloudflare Pages (see DEPLOY.md)."
}
