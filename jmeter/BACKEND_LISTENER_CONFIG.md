# Configuration Backend Listener InfluxDB v2 - JMeter

## Configuration pour les 4 scénarios

Les Backend Listeners ont été ajoutés aux 4 plans JMeter pour envoyer les métriques vers InfluxDB v2.

### Paramètres communs

| Paramètre | Valeur |
|-----------|--------|
| **influxdbMetricsSender** | `org.apache.jmeter.visualizers.backend.influxdb.HttpMetricsSender` |
| **influxdbUrl** | `http://localhost:8086/api/v2/write?org=perf&bucket=jmeter&precision=ms` |
| **influxdbToken** | `my-super-secret-auth-token` |
| **application** | `benchmark-rest` |
| **measurement** | `jmeter` |
| **summaryOnly** | `false` |
| **samplersRegex** | `.*` |
| **percentiles** | `50;95;99` |

### Paramètres spécifiques par scénario

#### 1. READ-heavy
```
testTitle: READ_HEAVY
eventTags: scenario=read_heavy
```

#### 2. JOIN-filter
```
testTitle: JOIN_FILTER
eventTags: scenario=join_filter
```

#### 3. MIXED
```
testTitle: MIXED
eventTags: scenario=mixed
```

#### 4. HEAVY-body
```
testTitle: HEAVY_BODY
eventTags: scenario=heavy_body
```

## Tags supplémentaires à ajouter lors de l'exécution

Lors de l'exécution des tests, vous devez spécifier la variante testée via les tags.

### Méthode 1 : Modifier le eventTags dans le plan JMeter avant d'exécuter

Pour tester la variante A :
```
eventTags: scenario=read_heavy;variant=A
```

Pour tester la variante C :
```
eventTags: scenario=read_heavy;variant=C
```

Pour tester la variante D :
```
eventTags: scenario=read_heavy;variant=D
```

### Méthode 2 : Utiliser des User Defined Variables

Ajouter une variable `variant` dans Test Plan > User Defined Variables :
```
variant = A
```

Puis utiliser dans eventTags :
```
eventTags: scenario=read_heavy;variant=${variant}
```

## Exécution en ligne de commande

Pour spécifier la variante depuis la ligne de commande :

```bash
jmeter -n -t read_heavy.jmx -l results.jtl -Jvariant=A
```

Et dans le plan, utiliser :
```
eventTags: scenario=read_heavy;variant=${__P(variant,UNKNOWN)}
```

## Métriques envoyées à InfluxDB

Le Backend Listener envoie automatiquement :

- **Response Times** : min, max, moyenne, p50, p95, p99
- **Throughput** : requests/sec, bytes/sec  
- **Error Rate** : pourcentage d'erreurs
- **Active Threads** : nombre de threads actifs
- **Hits per Second** : nombre de requêtes par seconde
- **Par sampler** : métriques individuelles pour chaque endpoint

## Vérification

### 1. Démarrer l'infrastructure
```powershell
cd infra
.\start-infrastructure.ps1
```

### 2. Lancer un test JMeter
```bash
jmeter -n -t read_heavy.jmx -l results.jtl
```

### 3. Vérifier dans InfluxDB

1. Ouvrir http://localhost:8086
2. Login : `admin` / `adminpassword`
3. Aller dans **Data Explorer**
4. Sélectionner bucket `jmeter`
5. Filtrer par `_measurement = "jmeter"`

### 4. Visualiser dans Grafana

1. Ouvrir http://localhost:3001
2. Login : `admin` / `admin`
3. Create > Dashboard
4. Add visualization
5. Sélectionner datasource `InfluxDB_JMeter`

## Requêtes Flux exemples

### RPS moyen par scénario
```flux
from(bucket: "jmeter")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "jmeter")
  |> filter(fn: (r) => r._field == "throughput")
  |> group(columns: ["scenario"])
  |> mean()
```

### Latence p95 par variante
```flux
from(bucket: "jmeter")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "jmeter")
  |> filter(fn: (r) => r._field == "pct95.0")
  |> group(columns: ["variant"])
```

### Taux d'erreur
```flux
from(bucket: "jmeter")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "jmeter")
  |> filter(fn: (r) => r._field == "errorRate")
```

## Troubleshooting

### Les métriques n'arrivent pas dans InfluxDB

1. Vérifier que InfluxDB est démarré :
```powershell
docker ps | findstr influxdb
```

2. Vérifier les logs JMeter (jmeter.log)

3. Tester l'URL manuellement :
```bash
curl -X POST "http://localhost:8086/api/v2/write?org=perf&bucket=jmeter" ^
  -H "Authorization: Token my-super-secret-auth-token" ^
  -d "jmeter,application=test value=1"
```

### Erreur "unauthorized"

Vérifier le token dans le Backend Listener configuration.
Token par défaut : `my-super-secret-auth-token`

### Erreur "bucket not found"

Vérifier que le bucket existe :
```bash
docker exec -it perf-influxdb influx bucket list --org perf
```

Si le bucket n'existe pas, le créer :
```bash
docker exec -it perf-influxdb influx bucket create -n jmeter -o perf
```
