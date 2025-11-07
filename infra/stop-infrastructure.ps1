# Script PowerShell pour arrêter l'infrastructure de monitoring

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Arrêt de l'infrastructure        " -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Se placer dans le répertoire infra
Set-Location $PSScriptRoot

# Demander si on veut supprimer les volumes
Write-Host "Voulez-vous supprimer les volumes (données) ? [y/N]" -ForegroundColor Yellow
$response = Read-Host
$removeVolumes = $response -eq "y" -or $response -eq "Y"

if ($removeVolumes) {
    Write-Host "Arrêt et suppression des volumes..." -ForegroundColor Yellow
    docker-compose down -v
    Write-Host "✓ Infrastructure arrêtée et volumes supprimés" -ForegroundColor Green
} else {
    Write-Host "Arrêt des services (conservation des données)..." -ForegroundColor Yellow
    docker-compose down
    Write-Host "✓ Infrastructure arrêtée (données conservées)" -ForegroundColor Green
}

Write-Host ""
Write-Host "Pour redémarrer: .\start-infrastructure.ps1" -ForegroundColor Yellow
