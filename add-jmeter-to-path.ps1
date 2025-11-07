# Script pour ajouter JMeter au PATH utilisateur

$ErrorActionPreference = "Stop"

$jmeterPath = "C:\tools\apache-jmeter-5.6.3\bin"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Ajout de JMeter au PATH utilisateur" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier que JMeter existe
if (-not (Test-Path $jmeterPath)) {
    Write-Host "[ERREUR] JMeter n'existe pas dans : $jmeterPath" -ForegroundColor Red
    exit 1
}

Write-Host "JMeter trouvé dans : $jmeterPath" -ForegroundColor Green
Write-Host ""

# Obtenir le PATH actuel de l'utilisateur
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

# Vérifier si déjà dans le PATH
if ($currentPath -like "*$jmeterPath*") {
    Write-Host "[INFO] JMeter est déjà dans le PATH utilisateur !" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Si la commande 'jmeter' ne fonctionne toujours pas :" -ForegroundColor Yellow
    Write-Host "  1. Fermez TOUS les terminaux PowerShell ouverts" -ForegroundColor White
    Write-Host "  2. Rouvrez un nouveau terminal" -ForegroundColor White
    Write-Host "  3. Tapez : jmeter --version" -ForegroundColor White
    exit 0
}

# Ajouter au PATH
Write-Host "Ajout de JMeter au PATH..." -ForegroundColor Yellow
try {
    $newPath = if ($currentPath) { "$currentPath;$jmeterPath" } else { $jmeterPath }
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "[OK] JMeter ajouté au PATH utilisateur" -ForegroundColor Green
} catch {
    Write-Host "[ERREUR] Impossible d'ajouter au PATH : $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Ajoutez-le manuellement :" -ForegroundColor Yellow
    Write-Host "  1. Windows > Rechercher 'variables d'environnement'" -ForegroundColor White
    Write-Host "  2. Variables d'environnement utilisateur > PATH > Modifier" -ForegroundColor White
    Write-Host "  3. Nouveau > Ajouter : $jmeterPath" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Configuration terminée !" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "IMPORTANT :" -ForegroundColor Yellow
Write-Host "  1. Fermez TOUS les terminaux PowerShell ouverts" -ForegroundColor White
Write-Host "  2. Rouvrez un NOUVEAU terminal" -ForegroundColor White
Write-Host "  3. Tapez : jmeter --version" -ForegroundColor White
Write-Host ""
Write-Host "Vous pourrez ensuite lancer JMeter avec :" -ForegroundColor Green
Write-Host "  jmeter" -ForegroundColor Cyan
Write-Host "  jmeter -t plans\read_heavy.jmx" -ForegroundColor Cyan
