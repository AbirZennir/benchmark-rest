# JMeter - Tests de performance REST

Ce répertoire contient les plans de test JMeter pour benchmarker les 3 variantes REST.

## 📁 Structure

```
jmeter/
├── plans/                          # Plans de test JMeter (.jmx)
│   ├── read_heavy.jmx             # 80% READ operations
│   ├── join_filter.jmx            # Requêtes avec JOINs et filtres
│   ├── mixed.jmx                  # Mix READ/WRITE 50/50
│   └── heavy_body.jmx             # POST/PUT avec payloads 1KB-5KB
├── datasets/                       # Données CSV pour les tests
│   ├── categories.csv             # 2000 category IDs
│   ├── items.csv                  # 100,000 item IDs
│   ├── categories_random.csv      # Sous-ensemble aléatoire
│   ├── items_random.csv           # Sous-ensemble aléatoire
│   ├── categories_payloads.csv    # Payloads pour POST categories
│   ├── payloads_1KB.csv           # Payloads ~1KB
│   └── payloads_5KB.csv           # Payloads ~5KB
├── results/                        # Résultats des tests (.jtl)
├── jmeter-gui.ps1                 # Script pour lancer JMeter GUI
├── jmeter-run.ps1                 # Script pour exécuter les tests
└── README.md                       # Ce fichier
```

## 🚀 Démarrage rapide

### 1. Lancer JMeter GUI

```powershell
# Ouvrir JMeter vide
.\jmeter-gui.ps1

# Ouvrir avec un plan spécifique
.\jmeter-gui.ps1 -PlanFile "plans\read_heavy.jmx"

# Ou avec le chemin complet
C:\tools\apache-jmeter-5.6.3\bin\jmeter.bat
```

### 2. Exécuter un test (mode non-GUI)

```powershell
# Syntaxe
.\jmeter-run.ps1 -Scenario <scenario> -Variant <A|C|D> [options]

# Exemple : Test READ-heavy sur variante C
.\jmeter-run.ps1 -Scenario read_heavy -Variant C

# Test court (1 minute par palier au lieu de 10)
.\jmeter-run.ps1 -Scenario read_heavy -Variant C -LoopMinutes 1 -Stage1Users 10

# Test complet MIXED sur variante D
.\jmeter-run.ps1 -Scenario mixed -Variant D -LoopMinutes 10
```

## 📊 Scénarios disponibles

### 1. READ-heavy (`read_heavy.jmx`)

Distribution des requêtes :
- **50%** : GET /items?page=&size=50 (pagination)
- **20%** : GET /items?categoryId=... (filtrage)
- **20%** : GET /categories/{id}/items (JOIN)
- **10%** : GET /categories?page=&size= (catégories)

**Objectif** : Mesurer les performances en lecture pure

---

### 2. JOIN-filter (`join_filter.jmx`)

Distribution des requêtes :
- **40%** : GET /categories/{id}/items (JOIN category → items)
- **30%** : GET /items?categoryId=... (filtrage sur FK)
- **20%** : GET /items?page=&size= (pagination simple)
- **10%** : GET /categories/{id} (lecture simple)

**Objectif** : Mesurer l'impact des JOINs et filtres

---

### 3. MIXED (`mixed.jmx`)

Distribution des requêtes :
- **30%** : GET /items?page=&size=
- **20%** : GET /categories/{id}/items
- **20%** : POST /items (création)
- **15%** : PUT /items/{id} (modification)
- **10%** : GET /categories?page=
- **5%** : DELETE /items/{id} (suppression)

**Objectif** : Charger réaliste READ + WRITE

---

### 4. HEAVY-body (`heavy_body.jmx`)

Distribution des requêtes :
- **40%** : POST /items avec payload ~1KB
- **30%** : PUT /items/{id} avec payload ~1KB
- **20%** : POST /items avec payload ~5KB
- **10%** : PUT /items/{id} avec payload ~5KB

**Objectif** : Mesurer l'impact de gros payloads JSON

---

## ⚙️ Configuration des tests

### Paliers de charge (staging)

Chaque test a 3 paliers progressifs :

| Palier | Utilisateurs | Durée | Ramp-up |
|--------|--------------|-------|---------|
| Stage 1 | 50 users | 10 min | 60 sec |
| Stage 2 | 100 users | 10 min | 60 sec |
| Stage 3 | 200 users | 10 min | 60 sec |

**Durée totale** : ~31 minutes par test

### Paramètres personnalisables

Via ligne de commande :

```powershell
.\jmeter-run.ps1 -Scenario read_heavy -Variant C `
    -LoopMinutes 5 `
    -Stage1Users 25 `
    -Stage2Users 50 `
    -Stage3Users 100
```

Ou dans JMeter GUI : Test Plan > User Defined Variables

---

## 📈 Backend Listener InfluxDB

### Configuration requise

Les plans JMeter doivent avoir un **Backend Listener** configuré pour envoyer les métriques vers InfluxDB.

### Ajouter le Backend Listener

**Voir le guide** : `AJOUTER_BACKEND_LISTENER.md`

1. Ouvrir le plan dans JMeter GUI
2. Clic droit sur Test Plan > Add > Listener > Backend Listener
3. Sélectionner : `org.apache.jmeter.visualizers.backend.influxdb.InfluxdbBackendListenerClient`
4. Configurer les paramètres :

| Paramètre | Valeur |
|-----------|--------|
| `influxdbUrl` | `http://localhost:8086/api/v2/write?org=perf&bucket=jmeter&precision=ms` |
| `influxdbToken` | `my-super-secret-auth-token` |
| `application` | `benchmark-rest` |
| `testTitle` | `READ_HEAVY` (adapter selon scénario) |
| `eventTags` | `scenario=read_heavy;variant=${__P(variant,UNKNOWN)}` |

---

## 🎯 Exécution complète d'un benchmark

### Procédure recommandée

Pour chaque **variante** (A, C, D) :

1. **Démarrer UNIQUEMENT cette variante**
   ```powershell
   cd ..\services
   .\start-variant.ps1 -Variant C
   ```

2. **Attendre le démarrage complet** (~30 secondes)
   - Voir "Started VariantXApplication" dans les logs

3. **Exécuter les 4 scénarios**
   ```powershell
   cd ..\jmeter
   
   # Scénario 1 : READ-heavy
   .\jmeter-run.ps1 -Scenario read_heavy -Variant C
   
   # Scénario 2 : JOIN-filter
   .\jmeter-run.ps1 -Scenario join_filter -Variant C
   
   # Scénario 3 : MIXED
   .\jmeter-run.ps1 -Scenario mixed -Variant C
   
   # Scénario 4 : HEAVY-body
   .\jmeter-run.ps1 -Scenario heavy_body -Variant C
   ```

4. **Arrêter la variante** (Ctrl+C dans le terminal)

5. **Répéter pour les variantes A et D**

### Durée totale estimée

- 4 scénarios × 31 minutes × 3 variantes = **~6h12min**

### Tests courts (pour validation)

```powershell
# Test de 3 minutes au lieu de 31 minutes
.\jmeter-run.ps1 -Scenario read_heavy -Variant C -LoopMinutes 1 -Stage1Users 10
```

---

## 📊 Visualisation des résultats

### Option 1 : Grafana (temps réel)

1. Ouvrir http://localhost:3001
2. Login : `admin` / `admin`
3. Créer un dashboard avec les métriques InfluxDB

### Option 2 : JMeter GUI (post-mortem)

1. Lancer JMeter GUI
2. Ajouter un Listener : Add > Listener > Summary Report
3. Charger le fichier .jtl : results/xxx.jtl

### Option 3 : Rapport HTML JMeter

```powershell
C:\tools\apache-jmeter-5.6.3\bin\jmeter.bat -g results/read_heavy_variantC_20251106_120000.jtl -o reports/read_heavy_C
```

Puis ouvrir : `reports/read_heavy_C/index.html`

---

## 🔧 Troubleshooting

### Erreur : "Cannot find CSV file"

Les plans JMeter cherchent les CSV dans `../datasets/`. Vérifiez :
- Vous êtes dans le dossier `jmeter/plans/`
- Les fichiers CSV existent dans `jmeter/datasets/`

Solution :
```powershell
cd jmeter\datasets
.\Generate-Datasets.ps1  # Regénérer les CSV si besoin
```

### Erreur : "Connection refused" vers l'API

La variante REST n'est pas démarrée.

```powershell
cd services
.\start-variant.ps1 -Variant C
```

### Erreur : "Cannot write to InfluxDB"

InfluxDB n'est pas démarré ou le token est incorrect.

```powershell
cd infra
.\start-infrastructure.ps1
```

Vérifier : http://localhost:8086

### JMeter très lent

En mode non-GUI, désactivez les Listeners inutiles :
- Clic droit > Disable sur les Listeners graphiques
- Garder seulement le Backend Listener

---

## 📝 Bonnes pratiques

### Tests de performance

1. **Toujours en mode non-GUI** pour les vrais tests
   - JMeter GUI consomme beaucoup de CPU
   - Utiliser `jmeter-run.ps1` ou `jmeter -n`

2. **Une seule variante à la fois**
   - Ne jamais démarrer plusieurs variantes simultanément
   - Fausse les résultats (contention CPU/RAM/DB)

3. **Nettoyer la base entre les tests**
   - Redémarrer PostgreSQL
   - Ou vider les connexions : `SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'perfdb';`

4. **Monitoring système**
   - Surveiller CPU/RAM/Disk pendant les tests
   - Vérifier que le système n'est pas saturé

5. **Répétabilité**
   - Même machine, même heure
   - Pas d'autres processus lourds en arrière-plan
   - Réseau stable

### Fichiers .jtl

- **Ne pas commiter** les .jtl (volumineux)
- Ajouter `results/*.jtl` dans `.gitignore`
- Archiver les .jtl importants séparément

---

## 🧪 Tests de validation

Avant de lancer le benchmark complet, testez avec des paramètres réduits :

```powershell
# Test court (3 minutes au lieu de 31)
.\jmeter-run.ps1 -Scenario read_heavy -Variant C `
    -LoopMinutes 1 `
    -Stage1Users 10 `
    -Stage2Users 20 `
    -Stage3Users 30
```

Vérifiez :
- ✅ Aucune erreur HTTP
- ✅ Les métriques arrivent dans InfluxDB
- ✅ Prometheus collecte les métriques JVM
- ✅ Les temps de réponse sont cohérents

---

## 📚 Documentation complète

- **Backend Listener** : `BACKEND_LISTENER_CONFIG.md`
- **Ajouter Backend Listener** : `AJOUTER_BACKEND_LISTENER.md`
- **Datasets** : `datasets/README.md`
- **Installation JMeter** : `../INSTALLER_JMETER.md`

---

## 🎯 Checklist avant benchmark

- [ ] Infrastructure démarrée (PostgreSQL, Prometheus, InfluxDB, Grafana)
- [ ] Base de données initialisée (2000 categories, 100k items)
- [ ] Datasets CSV générés (2000 + 100k IDs)
- [ ] Backend Listeners configurés dans les 4 plans .jmx
- [ ] UNE SEULE variante démarrée
- [ ] Système non surchargé (CPU < 20% au repos)
- [ ] Espace disque suffisant pour les logs

---

## ❓ Support

En cas de problème :
1. Vérifier les logs JMeter : `jmeter.log`
2. Vérifier les logs de la variante testée
3. Vérifier InfluxDB : http://localhost:8086
4. Vérifier Prometheus : http://localhost:9090

Commandes utiles :
```powershell
# Voir les processus Java
Get-Process java

# Tester un endpoint manuellement
curl http://localhost:8083/categories?page=0&size=10

# Vérifier PostgreSQL
docker ps | findstr postgres
```
