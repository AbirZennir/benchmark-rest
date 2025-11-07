# Script PowerShell pour démarrer l'infrastructure de monitoring

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Benchmark REST - Infrastructure  " -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier que Docker est en cours d'exécution
Write-Host "Vérification de Docker..." -ForegroundColor Yellow
$dockerRunning = docker info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERREUR: Docker n'est pas démarré!" -ForegroundColor Red
    Write-Host "Veuillez démarrer Docker Desktop et réessayer." -ForegroundColor Red
    exit 1
}
Write-Host "✓ Docker est actif" -ForegroundColor Green
Write-Host ""

# Se placer dans le répertoire infra
Set-Location $PSScriptRoot

# Démarrer les services
Write-Host "Démarrage des services..." -ForegroundColor Yellow
docker-compose up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✓ Infrastructure démarrée avec succès!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Services disponibles:" -ForegroundColor Cyan
    Write-Host "  - PostgreSQL:  http://localhost:5432" -ForegroundColor White
    Write-Host "  - PgAdmin:     http://localhost:5050" -ForegroundColor White
    Write-Host "  - Prometheus:  http://localhost:9090" -ForegroundColor White
    Write-Host "  - InfluxDB:    http://localhost:8086" -ForegroundColor White
    Write-Host "  - Grafana:     http://localhost:3001" -ForegroundColor White
    Write-Host ""
    Write-Host "Credentials:" -ForegroundColor Cyan
    Write-Host "  - Grafana:     admin / admin" -ForegroundColor White
    Write-Host "  - InfluxDB:    admin / adminpassword" -ForegroundColor White
    Write-Host "  - PgAdmin:     admin@local / admin" -ForegroundColor White
    Write-Host ""
    Write-Host "Pour voir les logs: docker-compose logs -f" -ForegroundColor Yellow
    Write-Host "Pour arrêter:       docker-compose down" -ForegroundColor Yellow
} else {
    Write-Host "ERREUR lors du démarrage des services!" -ForegroundColor Red
    exit 1
}
