# Base de données VonjiAIna

Base de données PostgreSQL contenant 120 pharmacies d'Antananarivo avec coordonnées GPS.

## Installation rapide

### Option 1: Installation locale PostgreSQL
```bash
# 1. Installer PostgreSQL
sudo apt install postgresql postgresql-contrib

# 2. Exécuter le script d'installation
cd database/scripts
chmod +x setup_database.sh
./setup_database.sh
```

### Option 2: Avec Docker (recommandé)
```bash
# 1. Démarrer la base de données
cd database
docker-compose up -d

# 2. Vérifier que tout fonctionne
docker-compose logs -f
```

## Structure des données

- **120 pharmacies** à Antananarivo
- Coordonnées GPS précises (latitude/longitude)
- Numéros de téléphone
- Horaires d'ouverture
- Statut (normal/garde/24h)

## Connexion
Host: localhost
Port: 5432
Database: vonjiaina_db
User: vonjiaina_user
Password: vonjiaina_2026

## Requêtes utiles
```sql
-- Toutes les pharmacies
SELECT * FROM pharmacies;

-- Pharmacies de garde
SELECT * FROM pharmacies WHERE statut = 'garde';

-- Pharmacies proches de votre position
SELECT *, 
  calculate_distance(-18.8792, 47.5079, latitude, longitude) as distance_km
FROM pharmacies
ORDER BY distance_km
LIMIT 10;
```

## Mise à jour des données

Les données sont mises à jour depuis:
- actu.orange.mg
- groupe-metropole.mg
- Vérification GPS manuelle

Dernière mise à jour: **Janvier 2026**