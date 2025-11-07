# Infrastructure de Monitoring - Benchmark REST

## Services disponibles

### Base de données
- **PostgreSQL** : Port `5432`
  - User: `postgres`
  - Password: `ilham123`
  - Database: `perfdb`

- **PgAdmin** : http://localhost:5050
  - Email: `admin@local`
  - Password: `admin`

### Monitoring & Métriques

- **Prometheus** : http://localhost:9090
  - Collecte des métriques JVM via Actuator et JMX Exporter
  - Scraping toutes les 5 secondes

- **InfluxDB v2** : http://localhost:8086
  - Organisation: `perf`
  - Bucket: `jmeter`
  - Token: `my-super-secret-auth-token`
  - Stocke les métriques JMeter via Backend Listener

- **Grafana** : http://localhost:3001
  - User: `admin`
  - Password: `admin`
  - Datasources configurées automatiquement :
    - Prometheus (métriques JVM)
    - InfluxDB (métriques JMeter)

## Démarrage

### Démarrer tous les services
```bash
cd infra
docker-compose up -d
```

### Vérifier l'état des services
```bash
docker-compose ps
```

### Voir les logs
```bash
# Tous les services
docker-compose logs -f

# Un service spécifique
docker-compose logs -f grafana
docker-compose logs -f prometheus
docker-compose logs -f influxdb
```

### Arrêter les services
```bash
docker-compose down
```

### Arrêter et supprimer les volumes (reset complet)
```bash
docker-compose down -v
```

## Configuration des variantes REST

Les variantes Java doivent exposer les métriques sur :

### Variante A (Jersey)
- Application: `http://localhost:8082`
- Actuator: `http://localhost:8082/actuator/prometheus`
- JMX Exporter: `http://localhost:9402/metrics`

### Variante C (Spring MVC)
- Application: `http://localhost:8083`
- Actuator: `http://localhost:8083/actuator/prometheus`
- JMX Exporter: `http://localhost:9403/metrics`

### Variante D (Spring Data REST)
- Application: `http://localhost:8084`
- Actuator: `http://localhost:8084/actuator/prometheus`
- JMX Exporter: `http://localhost:9404/metrics`

## Configuration JMeter Backend Listener

Pour envoyer les métriques JMeter vers InfluxDB v2 :

**Backend Listener Config:**
- Implementation: `org.apache.jmeter.visualizers.backend.influxdb.InfluxdbBackendListenerClient`
- influxdbUrl: `http://localhost:8086/api/v2/write?org=perf&bucket=jmeter`
- application: `benchmark-rest`
- measurement: `jmeter`
- summaryOnly: `false`
- samplersRegex: `.*`
- percentiles: `50;95;99`
- testTitle: `[Nom du test]`
- eventTags: `variant=[A/C/D]`

**Headers HTTP à ajouter:**
```
Authorization: Token my-super-secret-auth-token
```

## Dashboards Grafana

Après le démarrage, importer les dashboards depuis `grafana/dashboards/`:
1. JVM Metrics Dashboard (Prometheus)
2. JMeter Performance Dashboard (InfluxDB)

Ou créer vos propres dashboards via l'interface Grafana.

## Troubleshooting

### Prometheus ne collecte pas les métriques
- Vérifier que les variantes Java sont démarrées
- Vérifier l'URL dans `prometheus.yml`
- Consulter Prometheus > Targets : http://localhost:9090/targets

### InfluxDB n'accepte pas les données JMeter
- Vérifier le token dans JMeter Backend Listener
- Vérifier que l'organisation et le bucket existent
- Consulter les logs : `docker-compose logs influxdb`

### Grafana ne trouve pas les datasources
- Vérifier que Prometheus et InfluxDB sont démarrés
- Redémarrer Grafana : `docker-compose restart grafana`
- Vérifier Configuration > Data Sources dans Grafana
