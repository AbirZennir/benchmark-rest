# Script helper pour exécuter des tests JMeter en ligne de commande

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("read_heavy", "join_filter", "mixed", "heavy_body")]
    [string]$Scenario,
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("A", "C", "D")]
    [string]$Variant,
    
    [int]$LoopMinutes = 10,
    [int]$Stage1Users = 50,
    [int]$Stage2Users = 100,
    [int]$Stage3Users = 200
)

$ErrorActionPreference = "Stop"

$jmeterBin = "C:\tools\apache-jmeter-5.6.3\bin\jmeter.bat"

# Vérifier que JMeter existe
if (-not (Test-Path $jmeterBin)) {
    Write-Host "[ERREUR] JMeter n'est pas installé dans C:\tools\apache-jmeter-5.6.3" -ForegroundColor Red
    exit 1
}

# Chemins
$planPath = "plans\$Scenario.jmx"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$resultsPath = "results\${Scenario}_variant${Variant}_${timestamp}.jtl"

# Vérifier que le plan existe
if (-not (Test-Path $planPath)) {
    Write-Host "[ERREUR] Plan de test non trouvé : $planPath" -ForegroundColor Red
    exit 1
}

# Créer le dossier results s'il n'existe pas
if (-not (Test-Path "results")) {
    New-Item -ItemType Directory -Path "results" | Out-Null
}

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Exécution du test JMeter" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Scénario      : $Scenario" -ForegroundColor White
Write-Host "Variante      : $Variant" -ForegroundColor White
Write-Host "Plan          : $planPath" -ForegroundColor Gray
Write-Host "Résultats     : $resultsPath" -ForegroundColor Gray
Write-Host ""
Write-Host "Paramètres :" -ForegroundColor Yellow
Write-Host "  Loop minutes : $LoopMinutes min par palier" -ForegroundColor White
Write-Host "  Stage 1      : $Stage1Users utilisateurs" -ForegroundColor White
Write-Host "  Stage 2      : $Stage2Users utilisateurs" -ForegroundColor White
Write-Host "  Stage 3      : $Stage3Users utilisateurs" -ForegroundColor White
Write-Host ""

# Estimer la durée totale
$estimatedMinutes = (60/60) + ($LoopMinutes * 3) # ramp-up + 3 stages
Write-Host "Durée estimée : ~$estimatedMinutes minutes" -ForegroundColor Yellow
Write-Host ""

# Demander confirmation
$response = Read-Host "Lancer le test ? (Y/n)"
if ($response -eq "n" -or $response -eq "N") {
    Write-Host "Test annulé." -ForegroundColor Gray
    exit 0
}

Write-Host ""
Write-Host "Démarrage du test..." -ForegroundColor Green
Write-Host "(Pour arrêter : Ctrl+C)" -ForegroundColor Gray
Write-Host ""

# Construire la commande JMeter
$jmeterArgs = @(
    "-n"  # non-GUI mode
    "-t", $planPath
    "-l", $resultsPath
    "-Jvariant=$Variant"
    "-JloopMinutesPerStage=$LoopMinutes"
    "-Jstage1Users=$Stage1Users"
    "-Jstage2Users=$Stage2Users"
    "-Jstage3Users=$Stage3Users"
)

# Exécuter JMeter
try {
    & $jmeterBin $jmeterArgs
    
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  Test terminé !" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Résultats sauvegardés dans : $resultsPath" -ForegroundColor Green
    Write-Host ""
    Write-Host "Pour visualiser les résultats :" -ForegroundColor Yellow
    Write-Host "  1. Ouvrir Grafana : http://localhost:3001" -ForegroundColor White
    Write-Host "  2. Ou ouvrir le fichier .jtl dans JMeter GUI" -ForegroundColor White
    
} catch {
    Write-Host ""
    Write-Host "[ERREUR] Le test a échoué : $_" -ForegroundColor Red
    exit 1
}
