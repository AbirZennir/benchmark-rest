# Script PowerShell pour générer les datasets CSV pour JMeter
# - 2000 categories (IDs 1-2000)
# - 100000 items (IDs 1-100000)

$CATEGORIES_COUNT = 2000
$ITEMS_COUNT = 100000

# Se placer dans le répertoire du script
Set-Location $PSScriptRoot

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Génération des datasets JMeter pour Benchmark REST" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Générer categories.csv
Write-Host "Génération de categories.csv..." -ForegroundColor Yellow
$categoriesFile = "categories.csv"
$content = "id`n"
for ($i = 1; $i -le $CATEGORIES_COUNT; $i++) {
    $content += "$i`n"
}
$content | Out-File -FilePath $categoriesFile -Encoding utf8 -NoNewline
Write-Host "✓ $CATEGORIES_COUNT categories générées" -ForegroundColor Green
Write-Host ""

# 2. Générer items.csv
Write-Host "Génération de items.csv..." -ForegroundColor Yellow
$itemsFile = "items.csv"
$sw = [System.IO.StreamWriter]::new($itemsFile, $false, [System.Text.Encoding]::UTF8)
$sw.WriteLine("id,categoryId")

for ($i = 1; $i -le $ITEMS_COUNT; $i++) {
    # Distribution: ((i - 1) % 2000) + 1
    $categoryId = (($i - 1) % $CATEGORIES_COUNT) + 1
    $sw.WriteLine("$i,$categoryId")
    
    # Afficher progression tous les 10000 items
    if ($i % 10000 -eq 0) {
        Write-Host "  -> $i items generes..." -ForegroundColor Gray
    }
}

$sw.Close()
Write-Host "✓ $ITEMS_COUNT items générés" -ForegroundColor Green
Write-Host ""

# 3. Générer categories_payloads.csv (500 payloads)
Write-Host "Génération de categories_payloads.csv..." -ForegroundColor Yellow
$categoriesPayloadsFile = "categories_payloads.csv"
$categoryNames = @("Electronics", "Clothing", "Books", "Home", "Sports", 
                   "Toys", "Food", "Beauty", "Automotive", "Garden",
                   "Office", "Pet", "Health", "Music", "Video Games")

$sw = [System.IO.StreamWriter]::new($categoriesPayloadsFile, $false, [System.Text.Encoding]::UTF8)
$sw.WriteLine("code,name")

for ($i = 1; $i -le 500; $i++) {
    $code = "CAT" + $i.ToString("D4")
    $randomName = $categoryNames | Get-Random
    $randomNumber = Get-Random -Minimum 1 -Maximum 999
    $name = "$randomName $randomNumber"
    $sw.WriteLine("`"$code`",`"$name`"")
}

$sw.Close()
Write-Host "✓ 500 payloads de categories générés" -ForegroundColor Green
Write-Host ""

# 4. Générer payloads_1KB.csv (500 payloads ~1KB)
Write-Host "Génération de payloads_1KB.csv..." -ForegroundColor Yellow
$payloads1kbFile = "payloads_1KB.csv"
$itemNames = @("Laptop", "Smartphone", "Tablet", "Monitor", "Keyboard",
               "Mouse", "Headphones", "Speaker", "Camera", "Printer",
               "Router", "Smartwatch", "TV", "Console", "Drone")

$sw = [System.IO.StreamWriter]::new($payloads1kbFile, $false, [System.Text.Encoding]::UTF8)
$sw.WriteLine("sku,name,price,stock,description")

$baseDescription = "High quality product with advanced features. " * 20

for ($i = 1; $i -le 500; $i++) {
    $sku = "SKU" + $i.ToString("D8")
    $randomItem = $itemNames | Get-Random
    $randomNumber = Get-Random -Minimum 100 -Maximum 999
    $name = "$randomItem $randomNumber"
    $price = [math]::Round((Get-Random -Minimum 10 -Maximum 5000) + (Get-Random) / 100, 2)
    $stock = Get-Random -Minimum 0 -Maximum 500
    
    $sw.WriteLine("`"$sku`",`"$name`",$price,$stock,`"$baseDescription`"")
}

$sw.Close()
Write-Host "✓ 500 payloads 1KB générés" -ForegroundColor Green
Write-Host ""

# 5. Générer payloads_5KB.csv (200 payloads ~5KB)
Write-Host "Génération de payloads_5KB.csv..." -ForegroundColor Yellow
$payloads5kbFile = "payloads_5KB.csv"
$premiumItems = @("Premium Laptop", "Pro Smartphone", "Advanced Tablet", 
                  "Professional Monitor", "Gaming Keyboard", "Wireless Mouse",
                  "Studio Headphones", "Smart Speaker", "DSLR Camera", "Laser Printer")

$sw = [System.IO.StreamWriter]::new($payloads5kbFile, $false, [System.Text.Encoding]::UTF8)
$sw.WriteLine("sku,name,price,stock,description,specifications")

$longDescription = ("This is a premium product designed for professionals and enthusiasts. " +
                    "It features cutting-edge technology, superior build quality, " +
                    "and exceptional performance in all conditions. ") * 30

$longSpecs = ("Weight: 2.5kg | Dimensions: 30x20x5cm | Color: Black | " +
              "Material: Aluminum | Warranty: 2 years | Battery: 10 hours | " +
              "Connectivity: WiFi, Bluetooth 5.0, USB-C | ") * 25

for ($i = 1; $i -le 200; $i++) {
    $sku = "SKU" + $i.ToString("D8")
    $randomItem = $premiumItems | Get-Random
    $randomNumber = Get-Random -Minimum 1000 -Maximum 9999
    $name = "$randomItem Model $randomNumber"
    $price = [math]::Round((Get-Random -Minimum 50 -Maximum 10000) + (Get-Random) / 100, 2)
    $stock = Get-Random -Minimum 0 -Maximum 200
    
    $sw.WriteLine("`"$sku`",`"$name`",$price,$stock,`"$longDescription`",`"$longSpecs`"")
}

$sw.Close()
Write-Host "✓ 200 payloads 5KB générés" -ForegroundColor Green
Write-Host ""

# 6. Générer categories_random.csv (1000 IDs aléatoires)
Write-Host "Génération de categories_random.csv (1000 IDs aléatoires)..." -ForegroundColor Yellow
$categoriesRandomFile = "categories_random.csv"
$randomCats = 1..$CATEGORIES_COUNT | Get-Random -Count 1000 | Sort-Object

$sw = [System.IO.StreamWriter]::new($categoriesRandomFile, $false, [System.Text.Encoding]::UTF8)
$sw.WriteLine("id")
foreach ($catId in $randomCats) {
    $sw.WriteLine($catId)
}
$sw.Close()
Write-Host "✓ Sélection aléatoire de 1000 categories générée" -ForegroundColor Green
Write-Host ""

# 7. Générer items_random.csv (10000 IDs aléatoires)
Write-Host "Génération de items_random.csv (10000 IDs aléatoires)..." -ForegroundColor Yellow
$itemsRandomFile = "items_random.csv"
$randomItems = 1..$ITEMS_COUNT | Get-Random -Count 10000 | Sort-Object

$sw = [System.IO.StreamWriter]::new($itemsRandomFile, $false, [System.Text.Encoding]::UTF8)
$sw.WriteLine("id")
foreach ($itemId in $randomItems) {
    $sw.WriteLine($itemId)
}
$sw.Close()
Write-Host "✓ Sélection aléatoire de 10000 items générée" -ForegroundColor Green
Write-Host ""

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "✓ Tous les datasets ont été générés avec succès!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Fichiers créés:" -ForegroundColor White
Write-Host "  - categories.csv           : $CATEGORIES_COUNT IDs" -ForegroundColor White
Write-Host "  - items.csv                : $ITEMS_COUNT IDs" -ForegroundColor White
Write-Host "  - categories_payloads.csv  : 500 payloads" -ForegroundColor White
Write-Host "  - payloads_1KB.csv         : 500 payloads ~1KB" -ForegroundColor White
Write-Host "  - payloads_5KB.csv         : 200 payloads ~5KB" -ForegroundColor White
Write-Host "  - categories_random.csv    : 1000 IDs aléatoires" -ForegroundColor White
Write-Host "  - items_random.csv         : 10000 IDs aléatoires" -ForegroundColor White
Write-Host ""
Write-Host "Ces fichiers peuvent être utilisés dans les plans JMeter avec CSV Data Set Config" -ForegroundColor Yellow
