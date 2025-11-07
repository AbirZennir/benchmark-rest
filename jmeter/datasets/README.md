# JMeter Datasets - Benchmark REST

## Fichiers générés

### Datasets principaux

| Fichier | Lignes | Description | Utilisation |
|---------|--------|-------------|-------------|
| `categories.csv` | 2,001 | Tous les IDs de categories (1-2000) | GET /categories/{id}, DELETE, filtres |
| `items.csv` | 100,001 | Tous les IDs d'items (1-100000) + categoryId | GET /items/{id}, DELETE, filtres |
| `categories_random.csv` | 1,001 | 1000 IDs de categories aléatoires | Tests avec distribution aléatoire |
| `items_random.csv` | 10,001 | 10000 IDs d'items aléatoires | Tests avec distribution aléatoire |

### Payloads pour POST/PUT

| Fichier | Lignes | Taille | Description |
|---------|--------|--------|-------------|
| `categories_payloads.csv` | 500 | ~0.5-1 KB | Payloads JSON pour POST/PUT categories |
| `payloads_1KB.csv` | 500 | ~1 KB | Payloads JSON pour POST/PUT items (léger) |
| `payloads_5KB.csv` | 200 | ~5 KB | Payloads JSON pour POST/PUT items (lourd) |

## Structure des fichiers

### categories.csv
```csv
id
1
2
3
...
2000
```

### items.csv
```csv
id,categoryId
1,1
2,2
3,3
...
100000,2000
```

Distribution: ~50 items par catégorie (distribution cyclique)

### categories_payloads.csv
```csv
code,name
"CAT0001","Electronics 123"
"CAT0002","Clothing 456"
...
```

### payloads_1KB.csv
```csv
sku,name,price,stock,description
"SKU00000001","Laptop 456",1299.99,100,"High quality product..."
...
```

### payloads_5KB.csv
```csv
sku,name,price,stock,description,specifications
"SKU00000001","Premium Laptop Model 5678",2499.99,50,"Long description...","Long specs..."
...
```

## Utilisation dans JMeter

### Configuration CSV Data Set Config

#### Pour GET par ID (categories)

```
Filename: categories.csv
Variable Names: categoryId
Delimiter: ,
Recycle on EOF: True
Stop thread on EOF: False
Sharing mode: All threads
```

Utilisation: `${categoryId}` dans le path `/categories/${categoryId}`

#### Pour GET par ID (items)

```
Filename: items.csv
Variable Names: itemId,categoryId
Delimiter: ,
Recycle on EOF: True
Stop thread on EOF: False
Sharing mode: All threads
```

Utilisation:
- Item par ID: `/items/${itemId}`
- Items par category: `/items?categoryId=${categoryId}`
- Category items: `/categories/${categoryId}/items`

#### Pour POST/PUT categories

```
Filename: categories_payloads.csv
Variable Names: code,name
Delimiter: ,
Recycle on EOF: True
Stop thread on EOF: False
Sharing mode: All threads
```

Body JSON:
```json
{
  "code": "${code}",
  "name": "${name}"
}
```

#### Pour POST/PUT items (1KB)

```
Filename: payloads_1KB.csv
Variable Names: sku,name,price,stock,description
Delimiter: ,
Recycle on EOF: True
Stop thread on EOF: False
Sharing mode: All threads
```

Body JSON:
```json
{
  "sku": "${sku}",
  "name": "${name}",
  "price": ${price},
  "stock": ${stock},
  "description": "${description}",
  "categoryId": ${categoryId}
}
```

#### Pour POST/PUT items (5KB)

```
Filename: payloads_5KB.csv
Variable Names: sku,name,price,stock,description,specifications
Delimiter: ,
Recycle on EOF: True
Stop thread on EOF: False
Sharing mode: All threads
```

Body JSON:
```json
{
  "sku": "${sku}",
  "name": "${name}",
  "price": ${price},
  "stock": ${stock},
  "description": "${description}",
  "specifications": "${specifications}",
  "categoryId": ${categoryId}
}
```

## Régénération des datasets

Si vous devez régénérer les datasets (par exemple après avoir modifié les données en base) :

```powershell
cd jmeter\datasets
.\Generate-Datasets.ps1
```

Ou si Python est installé :
```bash
python generate_datasets.py
```

## Exemples de scénarios

### Scénario READ-heavy
- Utiliser `items.csv` et `categories.csv` pour les requêtes GET
- Combiner avec `categories_random.csv` pour une distribution plus réaliste
- Mode Recycle activé pour boucler sur les IDs

### Scénario JOIN-filter
- Utiliser `items.csv` pour obtenir les categoryId
- Filtrer items par category: `/items?categoryId=${categoryId}`
- Relation category→items: `/categories/${categoryId}/items`

### Scénario MIXED
- GET: utiliser `items.csv` et `categories.csv`
- POST/PUT: utiliser `payloads_1KB.csv` et `categories_payloads.csv`
- DELETE: utiliser `items_random.csv` et `categories_random.csv`

### Scénario HEAVY-body
- POST/PUT uniquement avec `payloads_5KB.csv`
- Permet de tester l'impact des gros payloads
- Threads réduits (30-60) car plus lourd

## Notes importantes

1. **Recycle on EOF**: Toujours à `True` pour les tests de charge longs
2. **Stop thread on EOF**: À `False` pour ne pas arrêter les threads
3. **Sharing mode**: `All threads` pour partager entre tous les threads
4. **Distribution**: items.csv a une distribution cyclique (item 1→cat 1, item 2→cat 2, ...)
5. **Payloads**: Les descriptions sont répétées pour atteindre la taille cible

## Correspondance avec la base de données

Les IDs dans les CSV correspondent aux IDs auto-générés dans PostgreSQL :
- Categories: 1-2000 (codes CAT0001-CAT2000)
- Items: 1-100000 (SKUs générés automatiquement)

Distribution: ~50 items par catégorie en moyenne
