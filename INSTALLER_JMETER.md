# Installation de JMeter sur Windows

## Méthode 1 : Installation rapide (Recommandée)

### Prérequis
- Java 17 installé (vous l'avez déjà pour les variantes Spring Boot)

### Étapes

1. **Télécharger JMeter**
   - Aller sur : https://jmeter.apache.org/download_jmeter.cgi
   - Télécharger : **apache-jmeter-5.6.3.zip** (ou version plus récente)
   - Ou lien direct : https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-5.6.3.zip

2. **Extraire le fichier ZIP**
   ```powershell
   # Exemple : extraire dans C:\
   Expand-Archive -Path "$env:USERPROFILE\Downloads\apache-jmeter-5.6.3.zip" -DestinationPath "C:\"
   ```

3. **Ajouter JMeter au PATH (optionnel mais recommandé)**
   ```powershell
   # Ouvrir les variables d'environnement
   # Windows > Rechercher "variables d'environnement"
   # Éditer la variable PATH utilisateur
   # Ajouter : C:\apache-jmeter-5.6.3\bin
   ```

4. **Lancer JMeter**
   ```powershell
   # Si dans le PATH
   jmeter
   
   # Sinon, chemin complet
   C:\apache-jmeter-5.6.3\bin\jmeter.bat
   ```

---

## Méthode 2 : Via Chocolatey (si installé)

```powershell
# Installer JMeter via Chocolatey
choco install jmeter -y

# Lancer JMeter
jmeter
```

---

## Méthode 3 : Utiliser JMeter sans installation GUI

Si vous voulez juste **exécuter les tests** sans interface graphique :

### Option A : Télécharger et utiliser directement

```powershell
# 1. Télécharger JMeter
$jmeterUrl = "https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-5.6.3.zip"
$downloadPath = "$env:USERPROFILE\Downloads\apache-jmeter-5.6.3.zip"

# Télécharger (peut prendre quelques minutes)
Invoke-WebRequest -Uri $jmeterUrl -OutFile $downloadPath

# 2. Extraire dans le répertoire du projet
Expand-Archive -Path $downloadPath -DestinationPath "C:\jmeter" -Force

# 3. Tester
C:\jmeter\apache-jmeter-5.6.3\bin\jmeter.bat --version
```

### Option B : Utiliser un script de téléchargement automatique

J'ai créé un script pour vous : `jmeter\download-jmeter.ps1`

```powershell
cd jmeter
.\download-jmeter.ps1
```

---

## Vérification de l'installation

```powershell
# Vérifier la version
jmeter --version

# Ou avec le chemin complet
C:\apache-jmeter-5.6.3\bin\jmeter.bat --version
```

Vous devriez voir :
```
    _    ____   _    ____ _   _ _____       _ __  __ _____ _____ _____ ____
   / \  |  _ \ / \  / ___| | | | ____|     | |  \/  | ____|_   _| ____|  _ \
  / _ \ | |_) / _ \| |   | |_| |  _|    _  | | |\/| |  _|   | | |  _| | |_) |
 / ___ \|  __/ ___ \ |___|  _  | |___  | |_| | |  | | |___  | | | |___|  _ <
/_/   \_\_| /_/   \_\____|_| |_|_____|  \___/|_|  |_|_____| |_| |_____|_| \_\ 5.6.3

Copyright (c) 1999-2024 The Apache Software Foundation
```

---

## Lancer l'interface graphique JMeter

### Depuis n'importe où (si dans PATH)
```powershell
jmeter
```

### Depuis le répertoire d'installation
```powershell
C:\apache-jmeter-5.6.3\bin\jmeter.bat
```

### Ouvrir directement un plan de test
```powershell
jmeter -t "C:\Users\Microsoft\Documents\GitHub\benchmark-rest\jmeter\plans\read_heavy.jmx"
```

---

## Exécuter les tests en mode non-GUI (recommandé pour benchmark)

```powershell
# Syntaxe générale
jmeter -n -t <fichier.jmx> -l <resultats.jtl> -e -o <dossier-rapport>

# Exemple concret
cd C:\Users\Microsoft\Documents\GitHub\benchmark-rest\jmeter\plans
jmeter -n -t read_heavy.jmx -l results.jtl -Jvariant=C -JloopMinutesPerStage=1
```

Paramètres :
- `-n` : mode non-GUI (plus performant)
- `-t` : fichier de test
- `-l` : fichier log des résultats
- `-J` : définir une variable
- `-e -o` : générer un rapport HTML (optionnel)

---

## Emplacement des fichiers importants

```
C:\apache-jmeter-5.6.3\
├── bin\
│   ├── jmeter.bat          ← Lancer l'interface graphique
│   ├── jmeter.properties   ← Configuration JMeter
│   └── user.properties     ← Configuration utilisateur
├── lib\
│   └── ext\                ← Plugins JMeter (si besoin)
└── docs\
```

---

## Troubleshooting

### Erreur : "JAVA_HOME is not set"

JMeter a besoin de Java. Vérifier :

```powershell
# Vérifier Java
java -version

# Si pas installé, installer Java 17
# Télécharger depuis : https://adoptium.net/
```

Définir JAVA_HOME :
```powershell
# Trouver le chemin Java
$javaPath = (Get-Command java).Path
$javaHome = Split-Path (Split-Path $javaPath)

# Définir JAVA_HOME pour la session
$env:JAVA_HOME = $javaHome

# Ou définir de façon permanente via l'interface Windows
# Rechercher "variables d'environnement" > Nouvelle variable système
# Nom: JAVA_HOME
# Valeur: C:\Program Files\Eclipse Adoptium\jdk-17.0.xx-hotspot\
```

### Erreur : "Cannot find class"

Les dépendances ne sont pas chargées. Vérifier que vous lancez bien `jmeter.bat` et non `jmeter.jar` directement.

### JMeter est très lent au démarrage

Normal la première fois. JMeter charge tous ses plugins.

---

## Alternative : Modifier les plans sans GUI

Si vous ne voulez vraiment pas installer JMeter GUI, vous pouvez :

1. **Éditer les fichiers .jmx manuellement** (XML)
2. **Utiliser un éditeur de texte** pour ajouter le Backend Listener

Je peux vous créer un script PowerShell qui ajoute automatiquement le Backend Listener à tous vos plans .jmx si vous préférez.

Voulez-vous que je crée ce script ?
