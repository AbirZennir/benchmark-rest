# Script pour télécharger et installer JMeter automatiquement

$ErrorActionPreference = "Stop"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Téléchargement et installation de Apache JMeter" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$jmeterVersion = "5.6.3"
$jmeterUrl = "https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-$jmeterVersion.zip"
$installPath = "C:\apache-jmeter-$jmeterVersion"
$downloadPath = "$env:TEMP\apache-jmeter-$jmeterVersion.zip"

# Vérifier si déjà installé
if (Test-Path $installPath) {
    Write-Host "[INFO] JMeter $jmeterVersion est déjà installé dans $installPath" -ForegroundColor Yellow
    Write-Host ""
    $response = Read-Host "Voulez-vous réinstaller ? (y/N)"
    if ($response -ne "y" -and $response -ne "Y") {
        Write-Host "Installation annulée." -ForegroundColor Gray
        Write-Host ""
        Write-Host "Pour lancer JMeter :" -ForegroundColor Yellow
        Write-Host "  $installPath\bin\jmeter.bat" -ForegroundColor White
        exit 0
    }
}

# Vérifier Java
Write-Host "Vérification de Java..." -ForegroundColor Yellow
try {
    $javaVersion = java -version 2>&1 | Select-Object -First 1
    Write-Host "[OK] $javaVersion" -ForegroundColor Green
} catch {
    Write-Host "[ERREUR] Java n'est pas installé !" -ForegroundColor Red
    Write-Host "JMeter nécessite Java 8 ou supérieur." -ForegroundColor Yellow
    Write-Host "Téléchargez Java depuis : https://adoptium.net/" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Télécharger JMeter
Write-Host "Téléchargement de JMeter $jmeterVersion..." -ForegroundColor Yellow
Write-Host "URL : $jmeterUrl" -ForegroundColor Gray
Write-Host "Destination : $downloadPath" -ForegroundColor Gray
Write-Host "(Cela peut prendre quelques minutes...)" -ForegroundColor Gray
Write-Host ""

try {
    # Créer un WebClient avec barre de progression
    $webClient = New-Object System.Net.WebClient
    
    # Événement pour afficher la progression
    Register-ObjectEvent -InputObject $webClient -EventName DownloadProgressChanged -SourceIdentifier WebClient.DownloadProgressChanged -Action {
        Write-Progress -Activity "Téléchargement de JMeter" -Status "$($EventArgs.ProgressPercentage)% complété" -PercentComplete $EventArgs.ProgressPercentage
    } | Out-Null
    
    # Télécharger
    $webClient.DownloadFile($jmeterUrl, $downloadPath)
    
    # Nettoyer les événements
    Unregister-Event -SourceIdentifier WebClient.DownloadProgressChanged
    
    Write-Host "[OK] Téléchargement terminé" -ForegroundColor Green
} catch {
    Write-Host "[ERREUR] Échec du téléchargement : $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Vous pouvez télécharger manuellement depuis :" -ForegroundColor Yellow
    Write-Host "  https://jmeter.apache.org/download_jmeter.cgi" -ForegroundColor White
    exit 1
}

Write-Host ""

# Extraire le fichier
Write-Host "Extraction de JMeter..." -ForegroundColor Yellow
Write-Host "Destination : C:\" -ForegroundColor Gray

try {
    Expand-Archive -Path $downloadPath -DestinationPath "C:\" -Force
    Write-Host "[OK] Extraction terminée" -ForegroundColor Green
} catch {
    Write-Host "[ERREUR] Échec de l'extraction : $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Vérifier l'installation
Write-Host "Vérification de l'installation..." -ForegroundColor Yellow

if (Test-Path "$installPath\bin\jmeter.bat") {
    Write-Host "[OK] JMeter installé avec succès !" -ForegroundColor Green
    
    # Tester la version
    try {
        $version = & "$installPath\bin\jmeter.bat" --version 2>&1 | Select-Object -First 1
        Write-Host "[OK] $version" -ForegroundColor Green
    } catch {
        Write-Host "[ATTENTION] Installation OK mais impossible de vérifier la version" -ForegroundColor Yellow
    }
} else {
    Write-Host "[ERREUR] Installation échouée" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Nettoyer le fichier téléchargé
Write-Host "Nettoyage..." -ForegroundColor Yellow
Remove-Item $downloadPath -Force
Write-Host "[OK] Fichier temporaire supprimé" -ForegroundColor Green

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Installation terminée !" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "JMeter est installé dans :" -ForegroundColor White
Write-Host "  $installPath" -ForegroundColor Cyan
Write-Host ""

Write-Host "Pour lancer JMeter GUI :" -ForegroundColor White
Write-Host "  $installPath\bin\jmeter.bat" -ForegroundColor Cyan
Write-Host ""

Write-Host "Pour exécuter un test en ligne de commande :" -ForegroundColor White
Write-Host "  cd ..\plans" -ForegroundColor Gray
Write-Host "  $installPath\bin\jmeter.bat -n -t read_heavy.jmx -l results.jtl" -ForegroundColor Cyan
Write-Host ""

# Proposer d'ajouter au PATH
Write-Host "Voulez-vous ajouter JMeter au PATH ? (y/N)" -ForegroundColor Yellow
Write-Host "(Cela permettra de lancer 'jmeter' depuis n'importe où)" -ForegroundColor Gray
$addToPath = Read-Host

if ($addToPath -eq "y" -or $addToPath -eq "Y") {
    try {
        # Obtenir le PATH actuel de l'utilisateur
        $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
        
        # Vérifier si déjà dans le PATH
        if ($userPath -notlike "*$installPath\bin*") {
            # Ajouter au PATH
            $newPath = "$userPath;$installPath\bin"
            [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
            
            Write-Host "[OK] JMeter ajouté au PATH utilisateur" -ForegroundColor Green
            Write-Host "Redémarrez votre terminal pour que les changements prennent effet." -ForegroundColor Yellow
        } else {
            Write-Host "[INFO] JMeter est déjà dans le PATH" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "[ERREUR] Impossible d'ajouter au PATH : $_" -ForegroundColor Red
        Write-Host "Vous pouvez l'ajouter manuellement via les variables d'environnement Windows." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Installation complète ! 🎉" -ForegroundColor Green
