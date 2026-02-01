# Base de Données VonjiAIna

Installation automatique de la base de données PostgreSQL avec PostGIS pour l'application VonjiAIna (recherche de pharmacies à Madagascar).

## Contenu de la base

- **120 pharmacies** d'Antananarivo avec coordonnées GPS
- **40+ médicaments** courants
- **Stocks** automatiquement générés pour toutes les pharmacies
- **Extension PostGIS** pour les recherches géographiques

## Installation Automatique (Recommandé)

### Option 1 : Avec Docker (Le plus simple)

```bash
# 1. Démarrer les conteneurs
docker-compose up -d

# C'est tout ! La base est automatiquement initialisée avec toutes les données
```

La base de données sera accessible sur :
- **Host:** localhost
- **Port:** 5432
- **Database:** vonjiaina_db
- **User:** postgres
- **Password:** (défini dans .env)

### Option 2 : Installation Manuelle

Si vous avez déjà PostgreSQL installé localement :

```bash
# 1. Se placer dans le dossier scripts
cd database/scripts

# 2. Rendre le script exécutable
chmod +x setup_database.sh

# 3. Configurer les variables d'environnement
export POSTGRES_DB=vonjiaina_db
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=votre_mot_de_passe
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432

# 4. Exécuter le script
./setup_database.sh
```

## Structure des fichiers

```
database/
├── schema/                    # Structure de la base
│   └── pharmacies_schema.sql  # Tables + Index
├── seeds/                     # Données initiales
│   ├── pharmacies_antananarivo.sql  # 120 pharmacies
│   ├── medicaments.sql        # 40+ médicaments
│   └── stocks.sql             # Génération automatique des stocks
├── scripts/                   # Scripts d'automatisation
│   ├── setup_database.sh      # Installation complète
│   └── reset_database.sh      # Réinitialisation
├── migrations/                # Évolutions du schéma
│   └── 001_initial_schema.sql
└── backup/                    # Sauvegardes
```

## Commandes utiles

### Réinitialiser la base

```bash
cd database/scripts
./reset_database.sh
```

### Créer une sauvegarde

```bash
pg_dump -h localhost -U postgres vonjiaina_db > backup/backup_$(date +%Y%m%d).sql
```

### Restaurer une sauvegarde

```bash
psql -h localhost -U postgres vonjiaina_db < backup/backup_20260201.sql
```

## Schéma de la base

### Table: `pharmacies`
- **id** : Identifiant unique
- **nom** : Nom de la pharmacie
- **adresse** : Adresse complète
- **telephone** : Numéro de téléphone
- **latitude, longitude** : Coordonnées GPS
- **statut** : 'normal' ou 'garde' (24h/24)
- **quartier** : Quartier d'Antananarivo
- **horaires** : Horaires d'ouverture
- **verified** : Vérifié ou non

### Table: `medicaments`
- **id** : Identifiant unique
- **nom_commercial** : Nom commercial
- **dci** : Dénomination Commune Internationale
- **laboratoire** : Fabricant
- **forme** : Comprimé, Gélule, Sirop, etc.
- **dosage** : Dosage du médicament
- **description** : Description

### Table: `stocks`
- **id** : Identifiant unique
- **pharmacie_id** : Référence à la pharmacie
- **medicament_id** : Référence au médicament
- **quantite** : Quantité en stock
- **prix** : Prix en Ariary
- **date_maj** : Date de mise à jour

## Exemples de requêtes

### Trouver les pharmacies de garde

```sql
SELECT nom, adresse, telephone 
FROM pharmacies 
WHERE statut = 'garde'
ORDER BY nom;
```

### Rechercher un médicament

```sql
SELECT 
    p.nom as pharmacie,
    p.telephone,
    p.adresse,
    s.quantite,
    s.prix
FROM stocks s
JOIN pharmacies p ON s.pharmacie_id = p.id
JOIN medicaments m ON s.medicament_id = m.id
WHERE m.nom_commercial ILIKE '%doliprane%'
  AND s.quantite > 0
ORDER BY s.prix;
```

### Pharmacies dans un rayon de 2km (Analakely)

```sql
SELECT 
    nom,
    adresse,
    (6371 * acos(
        cos(radians(-18.9178)) * cos(radians(latitude)) * 
        cos(radians(longitude) - radians(47.5234)) + 
        sin(radians(-18.9178)) * sin(radians(latitude))
    )) as distance_km
FROM pharmacies
WHERE (6371 * acos(
    cos(radians(-18.9178)) * cos(radians(latitude)) * 
    cos(radians(longitude) - radians(47.5234)) + 
    sin(radians(-18.9178)) * sin(radians(latitude))
)) <= 2.0
ORDER BY distance_km;
```

## 🛠️ Dépannage

### PostgreSQL ne démarre pas

```bash
# Vérifier les logs
docker-compose logs db

# Redémarrer le conteneur
docker-compose restart db
```

### Erreur de connexion

Vérifiez que :
1. PostgreSQL est bien démarré
2. Les variables d'environnement sont correctes
3. Le port 5432 n'est pas déjà utilisé

### Réinstaller complètement

```bash
# Supprimer les conteneurs et volumes
docker-compose down -v

# Redémarrer
docker-compose up -d
```

## 👥 Support

Pour toute question, contactez l'équipe de développement VonjiAIna.

---

**Version:** 1.0.0  
**Dernière mise à jour:** Février 2026