# PowerShell Script to generate CSV datasets for JMeter
# - 2000 categories (IDs 1-2000)
# - 100000 items (IDs 1-100000)

$CATEGORIES_COUNT = 2000
$ITEMS_COUNT = 100000

# Navigate to script directory
Set-Location $PSScriptRoot

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Generating JMeter Datasets for REST Benchmark" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Generate categories.csv
Write-Host "Generating categories.csv..." -ForegroundColor Yellow
$categoriesFile = "categories.csv"
$content = "id`n"
for ($i = 1; $i -le $CATEGORIES_COUNT; $i++) {
    $content += "$i`n"
}
[System.IO.File]::WriteAllText((Join-Path $PSScriptRoot $categoriesFile), $content, [System.Text.Encoding]::UTF8)
Write-Host "[OK] $CATEGORIES_COUNT categories generated" -ForegroundColor Green
Write-Host ""

# 2. Generate items.csv
Write-Host "Generating items.csv (this may take a minute)..." -ForegroundColor Yellow
$itemsFile = "items.csv"
$sw = [System.IO.StreamWriter]::new($itemsFile, $false, [System.Text.Encoding]::UTF8)
$sw.WriteLine("id,categoryId")

for ($i = 1; $i -le $ITEMS_COUNT; $i++) {
    $categoryId = (($i - 1) % $CATEGORIES_COUNT) + 1
    $sw.WriteLine("$i,$categoryId")
    
    if ($i % 10000 -eq 0) {
        Write-Host "  -> $i items generated..." -ForegroundColor Gray
    }
}

$sw.Close()
Write-Host "[OK] $ITEMS_COUNT items generated" -ForegroundColor Green
Write-Host ""

# 3. Generate categories_payloads.csv (500 payloads)
Write-Host "Generating categories_payloads.csv..." -ForegroundColor Yellow
$categoriesPayloadsFile = "categories_payloads.csv"
$categoryNames = @("Electronics", "Clothing", "Books", "Home", "Sports", 
                   "Toys", "Food", "Beauty", "Automotive", "Garden",
                   "Office", "Pet", "Health", "Music", "VideoGames")

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
Write-Host "[OK] 500 category payloads generated" -ForegroundColor Green
Write-Host ""

# 4. Generate payloads_1KB.csv (500 payloads)
Write-Host "Generating payloads_1KB.csv..." -ForegroundColor Yellow
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
    $price = [math]::Round((Get-Random -Minimum 1000 -Maximum 500000) / 100.0, 2)
    $stock = Get-Random -Minimum 0 -Maximum 500
    
    $sw.WriteLine("`"$sku`",`"$name`",$price,$stock,`"$baseDescription`"")
}

$sw.Close()
Write-Host "[OK] 500 payloads 1KB generated" -ForegroundColor Green
Write-Host ""

# 5. Generate payloads_5KB.csv (200 payloads)
Write-Host "Generating payloads_5KB.csv..." -ForegroundColor Yellow
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
    $price = [math]::Round((Get-Random -Minimum 5000 -Maximum 1000000) / 100.0, 2)
    $stock = Get-Random -Minimum 0 -Maximum 200
    
    $sw.WriteLine("`"$sku`",`"$name`",$price,$stock,`"$longDescription`",`"$longSpecs`"")
}

$sw.Close()
Write-Host "[OK] 200 payloads 5KB generated" -ForegroundColor Green
Write-Host ""

# 6. Generate categories_random.csv (1000 random IDs)
Write-Host "Generating categories_random.csv (1000 random IDs)..." -ForegroundColor Yellow
$categoriesRandomFile = "categories_random.csv"
$randomCats = 1..$CATEGORIES_COUNT | Get-Random -Count 1000 | Sort-Object

$sw = [System.IO.StreamWriter]::new($categoriesRandomFile, $false, [System.Text.Encoding]::UTF8)
$sw.WriteLine("id")
foreach ($catId in $randomCats) {
    $sw.WriteLine($catId)
}
$sw.Close()
Write-Host "[OK] Random selection of 1000 categories generated" -ForegroundColor Green
Write-Host ""

# 7. Generate items_random.csv (10000 random IDs)
Write-Host "Generating items_random.csv (10000 random IDs)..." -ForegroundColor Yellow
$itemsRandomFile = "items_random.csv"
$randomItems = 1..$ITEMS_COUNT | Get-Random -Count 10000 | Sort-Object

$sw = [System.IO.StreamWriter]::new($itemsRandomFile, $false, [System.Text.Encoding]::UTF8)
$sw.WriteLine("id")
foreach ($itemId in $randomItems) {
    $sw.WriteLine($itemId)
}
$sw.Close()
Write-Host "[OK] Random selection of 10000 items generated" -ForegroundColor Green
Write-Host ""

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  All datasets generated successfully!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Files created:" -ForegroundColor White
Write-Host "  - categories.csv           : $CATEGORIES_COUNT IDs" -ForegroundColor White
Write-Host "  - items.csv                : $ITEMS_COUNT IDs" -ForegroundColor White
Write-Host "  - categories_payloads.csv  : 500 payloads" -ForegroundColor White
Write-Host "  - payloads_1KB.csv         : 500 payloads ~1KB" -ForegroundColor White
Write-Host "  - payloads_5KB.csv         : 200 payloads ~5KB" -ForegroundColor White
Write-Host "  - categories_random.csv    : 1000 random IDs" -ForegroundColor White
Write-Host "  - items_random.csv         : 10000 random IDs" -ForegroundColor White
Write-Host ""
Write-Host "These files can be used in JMeter plans with CSV Data Set Config" -ForegroundColor Yellow
