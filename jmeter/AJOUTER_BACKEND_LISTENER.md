# Guide : Ajouter Backend Listener InfluxDB v2 aux plans JMeter

## Méthode Recommandée : Via l'interface JMeter GUI

### Étape 1 : Ouvrir JMeter

```powershell
# Méthode 1 : Via script helper (recommandé)
cd jmeter
.\jmeter-gui.ps1

# Méthode 2 : Chemin complet
C:\tools\apache-jmeter-5.6.3\bin\jmeter.bat

# Méthode 3 : Ouvrir directement un plan
.\jmeter-gui.ps1 -PlanFile "plans\read_heavy.jmx"
```

### Étape 2 : Ouvrir un plan de test

1. File > Open
2. Sélectionner `plans\read_heavy.jmx` (ou un autre plan)

### Étape 3 : Ajouter un Backend Listener

1. **Clic droit** sur `Test Plan` (racine de l'arbre)
2. Add > Listener > **Backend Listener**

### Étape 4 : Configurer le Backend Listener

Dans la fenêtre du Backend Listener qui s'ouvre :

#### Backend Listener implementation
Sélectionner dans le menu déroulant :
```
org.apache.jmeter.visualizers.backend.influxdb.InfluxdbBackendListenerClient
```

#### Parameters (cliquer sur le bouton pour éditer)

| Nom | Valeur |
|-----|--------|
| `influxdbMetricsSender` | `org.apache.jmeter.visualizers.backend.influxdb.HttpMetricsSender` |
| `influxdbUrl` | `http://localhost:8086/api/v2/write?org=perf&bucket=jmeter&precision=ms` |
| `influxdbToken` | `my-super-secret-auth-token` |
| `application` | `benchmark-rest` |
| `measurement` | `jmeter` |
| `summaryOnly` | `false` |
| `samplersRegex` | `.*` |
| `percentiles` | `50;95;99` |
| `testTitle` | `READ_HEAVY` *(adapter selon le scénario)* |
| `eventTags` | `scenario=read_heavy` *(adapter selon le scénario)* |

### Étape 5 : Adapter les paramètres par scénario

#### Pour READ-heavy (read_heavy.jmx)
```
testTitle: READ_HEAVY
eventTags: scenario=read_heavy;variant=${__P(variant,UNKNOWN)}
```

#### Pour JOIN-filter (join_filter.jmx)
```
testTitle: JOIN_FILTER
eventTags: scenario=join_filter;variant=${__P(variant,UNKNOWN)}
```

#### Pour MIXED (mixed.jmx)
```
testTitle: MIXED
eventTags: scenario=mixed;variant=${__P(variant,UNKNOWN)}
```

#### Pour HEAVY-body (heavy_body.jmx)
```
testTitle: HEAVY_BODY
eventTags: scenario=heavy_body;variant=${__P(variant,UNKNOWN)}
```

### Étape 6 : Sauvegarder

1. File > Save
2. Répéter pour les 3 autres plans

---

## Configuration complète en détail

### Écran Backend Listener - Paramètres à remplir

```
┌─────────────────────────────────────────────────────────────────┐
│ Backend Listener                                                 │
├─────────────────────────────────────────────────────────────────┤
│ Name: Backend Listener                                           │
│ Comments:                                                         │
│                                                                   │
│ Backend Listener implementation:                                 │
│ [org.apache.jmeter.visualizers.backend.influxdb.InfluxdbBackend▼]│
│                                                                   │
│ [Parameters (10)]                                      [Add]     │
│ ┌───────────────────────────────────────────────────────────┐   │
│ │ Name                      │ Value                          │   │
│ ├───────────────────────────┼────────────────────────────────┤   │
│ │ influxdbMetricsSender     │ org.apache...HttpMetricsSender │   │
│ │ influxdbUrl               │ http://localhost:8086/api/v2..│   │
│ │ influxdbToken             │ my-super-secret-auth-token     │   │
│ │ application               │ benchmark-rest                 │   │
│ │ measurement               │ jmeter                         │   │
│ │ summaryOnly               │ false                          │   │
│ │ samplersRegex             │ .*                             │   │
│ │ percentiles               │ 50;95;99                       │   │
│ │ testTitle                 │ READ_HEAVY                     │   │
│ │ eventTags                 │ scenario=read_heavy;variant=...│   │
│ └───────────────────────────────────────────────────────────┘   │
│                                                                   │
│ Queue Size: [5000]                                                │
│                                                                   │
│ [☑] Async Listener                                               │
└─────────────────────────────────────────────────────────────────┘
```

---

## Test de la configuration

### 1. Démarrer l'infrastructure

```powershell
cd infra
.\start-infrastructure.ps1
```

Vérifier que InfluxDB est accessible :
```powershell
curl http://localhost:8086/health
```

### 2. Démarrer une variante REST

```powershell
cd services\variant-c-springmvc
.\mvnw.cmd spring-boot:run
```

Attendre que le service soit démarré (voir "Started VariantCSpringmvcApplication")

### 3. Exécuter un test court

En ligne de commande (non-GUI mode) :

```powershell
cd jmeter\plans
jmeter -n -t read_heavy.jmx -l test_results.jtl -Jvariant=C -JloopMinutesPerStage=1 -Jstage1Users=10
```

Paramètres :
- `-n` : mode non-GUI
- `-t` : fichier de test
- `-l` : fichier de log des résultats
- `-Jvariant=C` : définit la variante testée
- `-JloopMinutesPerStage=1` : réduit à 1 minute par palier (au lieu de 10)
- `-Jstage1Users=10` : réduit à 10 users (au lieu de 50)

### 4. Vérifier dans InfluxDB

Pendant ou après le test :

1. Ouvrir http://localhost:8086
2. Login : `admin` / `adminpassword`
3. Cliquer sur **Data Explorer** (icône graphique à gauche)
4. Sélectionner :
   - `_measurement` = `jmeter`
   - `_field` = `throughput` ou `pct95.0`
   - `scenario` = `read_heavy`
   - `variant` = `C`

5. Cliquer **Submit** → Vous devriez voir des données !

---

## Exemple de requête Flux pour vérifier

Dans InfluxDB Data Explorer, mode "Script Editor" :

```flux
from(bucket: "jmeter")
  |> range(start: -30m)
  |> filter(fn: (r) => r._measurement == "jmeter")
  |> filter(fn: (r) => r._field == "throughput" or r._field == "pct95.0")
  |> filter(fn: (r) => r.scenario == "read_heavy")
  |> filter(fn: (r) => r.variant == "C")
```

Si vous voyez des données → ✅ **Configuration réussie !**

---

## Captures d'écran des étapes clés

### 1. Ajouter Backend Listener
```
Test Plan
  └─ [Right-click] Add > Listener > Backend Listener
```

### 2. Sélectionner l'implementation
```
Backend Listener implementation:
[org.apache.jmeter.visualizers.backend.influxdb.InfluxdbBackendListenerClient ▼]
```

### 3. Cliquer "Add" pour ajouter chaque paramètre
```
[Parameters (0)]  [Add ⊕]

Après avoir cliqué Add 10 fois, vous aurez 10 lignes à remplir.
```

---

## Alternative : Copier depuis un plan template

Si vous voulez éviter de tout saisir manuellement, je peux créer un plan template avec le Backend Listener déjà configuré, que vous pourrez copier-coller dans vos autres plans.

Voulez-vous que je crée ce template ?
