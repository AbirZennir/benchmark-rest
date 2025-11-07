# Services REST - Variantes du Benchmark

Ce répertoire contient les 3 variantes REST à benchmarker.

## Variantes disponibles

| Variante | Technologie | Port | Base Path |
|----------|-------------|------|-----------|
| **A** | JAX-RS (Jersey) + JPA/Hibernate | 8082 | `/api` |
| **C** | Spring Boot @RestController + JPA | 8083 | - |
| **D** | Spring Boot + Spring Data REST | 8084 | `/api` |

## Prérequis

1. **Java 17** installé
2. **PostgreSQL** avec la base `perfdb` accessible sur `localhost:5432`
3. **Maven** (inclus via wrapper `mvnw`)

## Démarrage rapide

### Méthode 1 : Script PowerShell (Recommandé)

```powershell
# Démarrer la variante A
.\start-variant.ps1 -Variant A

# Démarrer la variante C
.\start-variant.ps1 -Variant C

# Démarrer la variante D
.\start-variant.ps1 -Variant D
```

### Méthode 2 : Manuellement

```powershell
# Variante A
cd variant-a-jersey
.\mvnw.cmd spring-boot:run

# Variante C
cd variant-c-springmvc
.\mvnw.cmd spring-boot:run

# Variante D
cd variant-d-springdata-rest
.\mvnw.cmd spring-boot:run
```

## Endpoints disponibles

### Variante A (Jersey) - Port 8082

- Base URL : `http://localhost:8082/api`
- Categories : `http://localhost:8082/api/categories`
- Items : `http://localhost:8082/api/items`
- Actuator Prometheus : `http://localhost:8082/actuator/prometheus`

### Variante C (Spring MVC) - Port 8083

- Base URL : `http://localhost:8083`
- Categories : `http://localhost:8083/categories`
- Items : `http://localhost:8083/items`
- Actuator Prometheus : `http://localhost:8083/actuator/prometheus`

### Variante D (Spring Data REST) - Port 8084

- Base URL : `http://localhost:8084/api`
- Categories : `http://localhost:8084/api/categories`
- Items : `http://localhost:8084/api/items`
- Actuator Prometheus : `http://localhost:8084/actuator/prometheus`

## Vérification

Tester qu'une variante fonctionne :

```powershell
# Variante A
curl http://localhost:8082/api/categories?page=0&size=5

# Variante C
curl http://localhost:8083/categories?page=0&size=5

# Variante D
curl http://localhost:8084/api/categories?page=0&size=5
```

Vérifier les métriques Prometheus :

```powershell
# Variante A
curl http://localhost:8082/actuator/prometheus

# Variante C
curl http://localhost:8083/actuator/prometheus

# Variante D
curl http://localhost:8084/actuator/prometheus
```

## Configuration commune

Toutes les variantes partagent :

- **Base de données** : PostgreSQL `perfdb` sur `localhost:5432`
- **Credentials** : `postgres` / `ilham123`
- **HikariCP** : 
  - `maximum-pool-size`: 20
  - `minimum-idle`: 10
- **JPA** : Hibernate avec validation `ddl-auto=validate`
- **Cache** : Désactivé (Hibernate L2 cache et HTTP cache)
- **Monitoring** : Actuator + Micrometer Prometheus

## Arrêt d'une variante

Dans le terminal où la variante tourne :
```
Ctrl + C
```

Ou forcer l'arrêt :
```powershell
# Trouver le processus Java
Get-Process java

# Arrêter le processus (remplacer PID)
Stop-Process -Id <PID>
```

## Compilation sans exécution

```powershell
# Compiler seulement
cd variant-c-springmvc
.\mvnw.cmd clean package -DskipTests

# Le JAR sera dans target/
```

## Logs

Les logs apparaissent dans le terminal. Pour les sauvegarder :

```powershell
.\mvnw.cmd spring-boot:run > logs.txt 2>&1
```

## Dépendances Maven

Télécharger toutes les dépendances :

```powershell
cd variant-c-springmvc
.\mvnw.cmd dependency:resolve
```

## Troubleshooting

### Erreur : "Port already in use"

Le port est déjà utilisé. Arrêter l'autre instance ou changer le port dans `application.properties`.

### Erreur : "Connection refused" PostgreSQL

PostgreSQL n'est pas démarré. Lancez l'infrastructure :
```powershell
cd ..\infra
.\start-infrastructure.ps1
```

### Erreur : "Table doesn't exist"

La base n'est pas initialisée. Vérifiez que les scripts SQL dans `db/` ont été exécutés.

### Maven lent au premier démarrage

Normal. Maven télécharge les dépendances. Les démarrages suivants seront plus rapides.

### Erreur : "mvnw : command not found"

Sur Windows, utilisez `.\mvnw.cmd` au lieu de `mvnw`.

## Architecture des variantes

### Variante A : Jersey

```
Controllers (JAX-RS @Path)
    ↓
Services
    ↓
Repositories (JPA)
    ↓
PostgreSQL
```

### Variante C : Spring MVC

```
Controllers (@RestController)
    ↓
Services
    ↓
Repositories (JPA)
    ↓
PostgreSQL
```

### Variante D : Spring Data REST

```
Repositories (@RepositoryRestResource)
    ↓
PostgreSQL
```

(Pas de controllers/services, exposition automatique)

## Métriques JVM collectées

Via Actuator/Prometheus :

- **CPU** : `process_cpu_usage`, `system_cpu_usage`
- **Memory** : `jvm_memory_used_bytes`, `jvm_memory_max_bytes`
- **GC** : `jvm_gc_pause_seconds`, `jvm_gc_memory_allocated_bytes`
- **Threads** : `jvm_threads_live`, `jvm_threads_peak`
- **HikariCP** : `hikaricp_connections_active`, `hikaricp_connections_max`
- **HTTP** : `http_server_requests_seconds`

## Benchmarking

Pour exécuter les benchmarks JMeter :

1. Démarrer UNE SEULE variante à la fois
2. Attendre qu'elle soit complètement démarrée
3. Lancer les tests JMeter depuis `../jmeter/plans/`
4. Arrêter la variante avant de tester la suivante

**Important** : Ne jamais démarrer plusieurs variantes en même temps pendant un benchmark !
