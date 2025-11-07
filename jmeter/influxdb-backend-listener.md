# Configuration Backend Listener InfluxDB v2 pour JMeter

## Prérequis

Assurez-vous que l'infrastructure est démarrée :
```bash
cd infra
docker-compose up -d
```

InfluxDB doit être accessible sur `http://localhost:8086`

## Configuration dans JMeter

### 1. Ajouter un Backend Listener

Dans votre plan de test JMeter :
1. Clic droit sur Thread Group
2. Add > Listener > Backend Listener

### 2. Paramètres du Backend Listener

**Backend Listener implementation:**
```
org.apache.jmeter.visualizers.backend.influxdb.InfluxdbBackendListenerClient
```

**Parameters:**

| Paramètre | Valeur | Description |
|-----------|---------|-------------|
| `influxdbMetricsSender` | `org.apache.jmeter.visualizers.backend.influxdb.HttpMetricsSender` | Sender HTTP |
| `influxdbUrl` | `http://localhost:8086/api/v2/write?org=perf&bucket=jmeter&precision=ms` | URL InfluxDB v2 |
| `application` | `benchmark-rest` | Nom de l'application |
| `measurement` | `jmeter` | Nom de la mesure |
| `summaryOnly` | `false` | Envoyer tous les samples |
| `samplersRegex` | `.*` | Tous les samplers |
| `percentiles` | `50;95;99` | Percentiles p50, p95, p99 |
| `testTitle` | `READ_HEAVY_VARIANT_A` | Titre du test (adapter) |
| `eventTags` | `variant=A;scenario=read_heavy` | Tags personnalisés |
| `influxdbToken` | `my-super-secret-auth-token` | Token d'authentification |

### 3. Configuration par scénario

#### Scénario READ-heavy - Variante A
```
testTitle: READ_HEAVY_VARIANT_A
eventTags: variant=A;scenario=read_heavy
```

#### Scénario READ-heavy - Variante C
```
testTitle: READ_HEAVY_VARIANT_C
eventTags: variant=C;scenario=read_heavy
```

#### Scénario READ-heavy - Variante D
```
testTitle: READ_HEAVY_VARIANT_D
eventTags: variant=D;scenario=read_heavy
```

#### Scénario JOIN-filter - Variante A
```
testTitle: JOIN_FILTER_VARIANT_A
eventTags: variant=A;scenario=join_filter
```

#### Scénario MIXED - Variante A
```
testTitle: MIXED_VARIANT_A
eventTags: variant=A;scenario=mixed
```

#### Scénario HEAVY-body - Variante A
```
testTitle: HEAVY_BODY_VARIANT_A
eventTags: variant=A;scenario=heavy_body
```

**Important:** Adapter le variant (A/C/D) selon la variante testée.

## Vérification dans InfluxDB

### Via l'interface Web
1. Ouvrir http://localhost:8086
2. Login: `admin` / `adminpassword`
3. Aller dans Data Explorer
4. Sélectionner bucket `jmeter`
5. Filtrer par `_measurement = "jmeter"`

### Via Flux Query
```flux
from(bucket: "jmeter")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "jmeter")
  |> filter(fn: (r) => r.variant == "A")
  |> filter(fn: (r) => r.scenario == "read_heavy")
```

## Métriques collectées

Le Backend Listener envoie automatiquement :

- **Response Times** : min, max, moyenne, p50, p95, p99
- **Throughput** : requests/sec, bytes/sec
- **Error Rate** : pourcentage d'erreurs
- **Active Threads** : nombre de threads actifs
- **Hits per Second** : nombre de requêtes par seconde

## Troubleshooting

### JMeter n'envoie pas les données
1. Vérifier que InfluxDB est démarré : `docker ps | findstr influxdb`
2. Vérifier le token d'authentification
3. Consulter les logs JMeter (jmeter.log)
4. Tester l'URL manuellement :
```bash
curl -X POST "http://localhost:8086/api/v2/write?org=perf&bucket=jmeter" ^
  -H "Authorization: Token my-super-secret-auth-token" ^
  -d "jmeter,application=test value=1"
```

### Erreur "bucket not found"
Vérifier que le bucket existe :
```bash
docker exec -it perf-influxdb influx bucket list --org perf
```

### Erreur d'authentification
Vérifier le token dans les paramètres du Backend Listener.
Le token par défaut est : `my-super-secret-auth-token`

## Dashboards Grafana

Une fois les données dans InfluxDB, créer un dashboard Grafana :
1. Ouvrir http://localhost:3001
2. Login: `admin` / `admin`
3. Create > Dashboard > Add visualization
4. Sélectionner datasource "InfluxDB_JMeter"
5. Construire vos requêtes Flux pour visualiser les métriques
