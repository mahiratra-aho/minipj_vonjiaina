#!/bin/bash

echo " Installation de la base de données VonjiAIna..."

# Variables
DB_NAME="vonjiaina_db"
DB_USER="vonjiaina_user"
DB_PASSWORD="vonjiaina_2026"

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Vérifier si PostgreSQL est installé
if ! command -v psql &> /dev/null; then
    echo -e "${RED} PostgreSQL n'est pas installé${NC}"
    echo "Installez PostgreSQL avec: sudo apt install postgresql"
    exit 1
fi

# Créer la base de données
echo " Création de la base de données..."
sudo -u postgres psql -c "DROP DATABASE IF EXISTS $DB_NAME;"
sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;"
sudo -u postgres psql -c "DROP USER IF EXISTS $DB_USER;"
sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"

# Exécuter le schéma
echo " Création des tables..."
sudo -u postgres psql -d $DB_NAME -f ../schema/pharmacies_schema.sql

# Insérer les données
echo "Insertion des données..."
sudo -u postgres psql -d $DB_NAME -f ../seeds/pharmacies_antananarivo.sql

echo -e "${GREEN} Installation terminée !${NC}"
echo ""
echo " Informations de connexion:"
echo "  Base de données: $DB_NAME"
echo "  Utilisateur: $DB_USER"
echo "  Mot de passe: $DB_PASSWORD"
echo "  Host: localhost"
echo "  Port: 5432"