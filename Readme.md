Benchmark REST – Variantes A, C, D
==================================

Objectif
--------
Comparer l’impact des différentes stacks REST sur :
- Latence (p50 / p95 / p99)
- Débit (RPS)
- Taux d’erreurs
- Consommation CPU / RAM / GC
- Simplification ou surcharge due aux frameworks

Architecture générale
---------------------
<img width="177" height="273" alt="Capture d’écran 2025-11-12 184342" src="https://github.com/user-attachments/assets/36c5a7bd-f8c0-4d36-9457-31e49599d86b" />


Variantes testées :
- A : Jersey (JAX-RS) + JPA/Hibernate
- C : Spring Boot + @RestController + JPA/Hibernate
- D : Spring Boot + Spring Data REST

Base de données
---------------
<img width="960" height="540" alt="join-filter-1" src="https://github.com/user-attachments/assets/525b82cd-7f8f-4426-a91c-a745908a9450" />


Données utilisées :
- 2000 catégories
- 100 000 items
- Payloads JSON : 1 KB et 5 KB

Scénarios JMeter
----------------

1. READ-heavy

<img width="960" height="540" alt="join-filter-c1" src="https://github.com/user-attachments/assets/a92bf513-0ca4-470f-a346-a634efe0dba7" />

2. JOIN-filter

<img width="960" height="540" alt="mixed-1" src="https://github.com/user-attachments/assets/98ad4732-403a-4a09-ad7d-c91f4ae5004c" />

3. MIXED (lecture + écriture)

<img width="960" height="540" alt="mixed-2" src="https://github.com/user-attachments/assets/aefdfa77-5d34-4cf8-bd4e-a258c0a44465" />

4. HEAVY-body (payload 5 KB)

<img width="960" height="540" alt="heavy-body-c-1" src="https://github.com/user-attachments/assets/951449ae-070a-4a70-b729-4ea0fba13d8f" />

Observabilité
-------------
- JMeter -> Backend Listener InfluxDB v2
- Grafana dashboards (JMeter + JVM)

<img width="960" height="540" alt="heavy-body-c-2" src="https://github.com/user-attachments/assets/abc4f6ff-abce-4472-9e9c-6c6800e1c20c" />
<img width="169" height="288" alt="Capture d’écran 2025-11-12 184519" src="https://github.com/user-attachments/assets/2f1b5ea8-164d-484e-b385-87dd1c7eb7b3" />

T0 — Configuration matérielle et logicielle
-------------------------------------------
Machine : Intel Core i7 / 16 Go RAM
OS : Windows 10
Java : 17
JMeter : 5.6.3
PostgreSQL : 14
InfluxDB : v2
Grafana : v10
HikariCP : min=10, max=20

T1 — Définition des scénarios
-----------------------------


T2 — Résultats JMeter (approx.)
-------------------------------

| Mesure | A (Jersey) | C (MVC) | D (Data REST) |
| ------ | ---------- | ------- | ------------- |
| RPS    | 5200       | 6100    | 4300          |
| p50    | 18 ms      | 15 ms   | 22 ms         |
| p95    | 42 ms      | 35 ms   | 58 ms         |
| p99    | 77 ms      | 64 ms   | 110 ms        |
| Err %  | 0.30%      | 0.10%   | 0.80%         |


JOIN-filter :
| Mesure | A     | C     | D      |
| ------ | ----- | ----- | ------ |
| RPS    | 4700  | 5300  | 4100   |
| p95    | 48 ms | 39 ms | 70 ms  |
| p99    | 90 ms | 68 ms | 125 ms |
| Err %  | 0.4%  | 0.2%  | 1.1%   |


MIXED :
| Mesure | A      | C      | D      |
| ------ | ------ | ------ | ------ |
| RPS    | 1800   | 2100   | 1500   |
| p95    | 95 ms  | 78 ms  | 130 ms |
| p99    | 160 ms | 135 ms | 210 ms |
| Err %  | 1.5%   | 0.9%   | 3.5%   |


HEAVY-body (5 KB) :
| Mesure | A      | C      | D      |
| ------ | ------ | ------ | ------ |
| RPS    | 1200   | 1500   | 900    |
| p95    | 120 ms | 95 ms  | 170 ms |
| p99    | 200 ms | 160 ms | 260 ms |
| Err %  | 2.2%   | 1.3%   | 4.0%   |


T3 — Ressources JVM (Prometheus)
--------------------------------

| Variante | CPU (%) | Heap (Mo) | GC (ms/s) | Threads | Hikari (actifs/max) |
| -------- | ------- | --------- | --------- | ------- | ------------------- |
| A        | 55 / 78 | 450 / 750 | 6 / 20    | 120     | 18 / 20             |
| C        | 48 / 70 | 420 / 690 | 5 / 15    | 110     | 18 / 20             |
| D        | 62 / 89 | 510 / 820 | 7 / 25    | 140     | 18 / 20             |


T4 — Détails JOIN-filter par endpoint
-------------------------------------

| Endpoint                   | Variante | RPS  | p95 | Err % | Observations                  |
| -------------------------- | -------- | ---- | --- | ----- | ----------------------------- |
| GET /items?categoryId      | A        | 4900 | 45  | 0.4   | + Bon JOIN FETCH              |
|                            | C        | 5400 | 37  | 0.2   | 🌟 Meilleur équilibre         |
|                            | D        | 4200 | 75  | 1.2   | HAL + surcharge serialization |
| GET /categories/{id}/items | A        | 4600 | 52  | 0.5   | —                             |
|                            | C        | 5200 | 40  | 0.3   | 🌟 Plus rapide                |
|                            | D        | 3900 | 85  | 1.7   | HAL structure coûteuse        |


T5 — Détails MIXED par endpoint
-------------------------------

| Endpoint         | A    | C    | D    | Observations   |
| ---------------- | ---- | ---- | ---- | -------------- |
| GET /items       | 2100 | 2600 | 1800 | C meilleur     |
| POST /items      | 1300 | 1500 | 900  | HAL pénalise D |
| PUT /items       | 1200 | 1450 | 850  | —              |
| DELETE /items    | 1600 | 1800 | 1400 | —              |
| GET /categories  | 2200 | 2600 | 2000 | —              |
| POST /categories | 1400 | 1550 | 1000 | —              |


T6 — Incidents et erreurs
-------------------------
| Run        | Variante | Erreur  | %    | Cause probable     | Action          |
| ---------- | -------- | ------- | ---- | ------------------ | --------------- |
| READ-heavy | D        | 404     | 0.8% | HAL traversal      | réduire payload |
| MIXED      | A        | timeout | 1.5% | GC + DB contention | augmenter pool  |
| HEAVY      | D        | 500     | 4%   | surcharge JSON     | augmenter heap  |


T7 — Synthèse et conclusion
---------------------------
| Critère                   | Meilleure variante | Pourquoi                            |
| ------------------------- | ------------------ | ----------------------------------- |
| 🟦 Débit global           | **C**              | Spring MVC = meilleure optimisation |
| 🟩 Latence p95            | **C**              | pipeline le plus rapide             |
| 🟨 Stabilité              | **A**              | moins sensible à la surcharge       |
| 🟥 CPU/RAM                | **C**              | plus léger que Data REST            |
| 🟧 Facilité relationnelle | **D**              | endpoints auto, HAL                 |


Conclusion :
La variante C (Spring MVC) offre le meilleur équilibre entre performances, stabilité
et consommation de ressources. La variante A est robuste mais légèrement moins rapide.
La variante D est utile pour générer rapidement des endpoints mais montre une surcharge
importante (latence, RPS plus faible, erreurs plus élevées).

