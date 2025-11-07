# Script pour démarrer une variante REST

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("A", "C", "D")]
    [string]$Variant
)

$ErrorActionPreference = "Stop"

# Mapping des variantes
$variants = @{
    "A" = @{
        Name = "variant-a-jersey"
        Port = 8082
        Description = "JAX-RS (Jersey) + JPA/Hibernate"
    }
    "C" = @{
        Name = "variant-c-springmvc"
        Port = 8083
        Description = "Spring Boot @RestController + JPA"
    }
    "D" = @{
        Name = "variant-d-springdata-rest"
        Port = 8084
        Description = "Spring Boot + Spring Data REST"
    }
}

$selectedVariant = $variants[$Variant]

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Démarrage Variante $Variant - $($selectedVariant.Description)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier que PostgreSQL est accessible
Write-Host "Vérification de PostgreSQL..." -ForegroundColor Yellow
try {
    $null = Test-NetConnection -ComputerName localhost -Port 5432 -WarningAction SilentlyContinue
    Write-Host "[OK] PostgreSQL est accessible" -ForegroundColor Green
} catch {
    Write-Host "[ERREUR] PostgreSQL n'est pas accessible sur le port 5432" -ForegroundColor Red
    Write-Host "Démarrez l'infrastructure : cd infra && .\start-infrastructure.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Vérifier que le port n'est pas déjà utilisé
Write-Host "Vérification du port $($selectedVariant.Port)..." -ForegroundColor Yellow
$portInUse = Get-NetTCPConnection -LocalPort $selectedVariant.Port -ErrorAction SilentlyContinue
if ($portInUse) {
    Write-Host "[ATTENTION] Le port $($selectedVariant.Port) est déjà utilisé !" -ForegroundColor Red
    Write-Host "Une instance de la variante $Variant est peut-être déjà en cours d'exécution." -ForegroundColor Yellow
    Write-Host ""
    $response = Read-Host "Voulez-vous continuer quand même ? (y/N)"
    if ($response -ne "y" -and $response -ne "Y") {
        exit 0
    }
}

Write-Host ""
Write-Host "Démarrage de la variante $Variant..." -ForegroundColor Yellow
Write-Host "Répertoire : $($selectedVariant.Name)" -ForegroundColor Gray
Write-Host "Port : $($selectedVariant.Port)" -ForegroundColor Gray
Write-Host ""

# Se déplacer dans le répertoire de la variante
$variantPath = Join-Path $PSScriptRoot $selectedVariant.Name
Set-Location $variantPath

# Vérifier que mvnw existe
if (-not (Test-Path "mvnw.cmd")) {
    Write-Host "[ERREUR] mvnw.cmd n'existe pas dans $variantPath" -ForegroundColor Red
    exit 1
}

Write-Host "Lancement de Maven Spring Boot..." -ForegroundColor Green
Write-Host "(Cela peut prendre quelques instants pour le premier démarrage)" -ForegroundColor Gray
Write-Host ""

# Démarrer l'application
.\mvnw.cmd spring-boot:run

# Note: Le script s'arrête ici tant que l'application tourne
# Pour arrêter : Ctrl+C
