# Script helper pour lancer JMeter GUI facilement

param(
    [string]$PlanFile = ""
)

$jmeterBin = "C:\tools\apache-jmeter-5.6.3\bin\jmeter.bat"

# Vérifier que JMeter existe
if (-not (Test-Path $jmeterBin)) {
    Write-Host "[ERREUR] JMeter n'est pas installé dans C:\tools\apache-jmeter-5.6.3" -ForegroundColor Red
    Write-Host "Vérifiez le chemin d'installation de JMeter." -ForegroundColor Yellow
    exit 1
}

Write-Host "Lancement de JMeter GUI..." -ForegroundColor Green

if ($PlanFile) {
    # Lancer avec un plan spécifique
    $fullPath = Resolve-Path $PlanFile -ErrorAction SilentlyContinue
    if ($fullPath) {
        Write-Host "Ouverture du plan : $fullPath" -ForegroundColor Yellow
        & $jmeterBin -t $fullPath
    } else {
        Write-Host "[ERREUR] Fichier non trouvé : $PlanFile" -ForegroundColor Red
        exit 1
    }
} else {
    # Lancer JMeter vide
    & $jmeterBin
}
