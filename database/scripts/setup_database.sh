#!/bin/bash

# SCRIPT DE SETUP AUTOMATIQUE DE LA BASE


set -e  # Arrêter en cas d'erreur

echo "Démarrage du setup de la base de données VonjiAIna..."
echo ""

# Couleurs pour les messages
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Variables de configuration (à adapter selon votre environnement)
DB_NAME="${POSTGRES_DB:-vonjiaina_db}"
DB_USER="${POSTGRES_USER:-postgres}"
DB_HOST="${POSTGRES_HOST:-localhost}"
DB_PORT="${POSTGRES_PORT:-5432}"

echo -e "${BLUE}Configuration:${NC}"
echo "  Database: $DB_NAME"
echo "  User: $DB_USER"
echo "  Host: $DB_HOST"
echo "  Port: $DB_PORT"
echo ""

# Fonction pour exécuter un fichier SQL
execute_sql() {
    local file=$1
    local description=$2
    
    echo -e "${BLUE}⏳ $description...${NC}"
    
    if [ -f "$file" ]; then
        PGPASSWORD=$POSTGRES_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$file" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ $description - Terminé${NC}"
        else
            echo -e "${RED}Erreur lors de: $description${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Fichier non trouvé: $file${NC}"
        exit 1
    fi
}

# Attendre que PostgreSQL soit prêt
echo -e "${BLUE}Attente de PostgreSQL...${NC}"
until PGPASSWORD=$POSTGRES_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c '\q' 2>/dev/null; do
  echo "  PostgreSQL n'est pas encore prêt - attente..."
  sleep 2
done
echo -e "${GREEN}PostgreSQL est prêt${NC}"
echo ""

# Étape 1: Créer le schéma
execute_sql "../schema/pharmacies_schema.sql" "Création du schéma (tables + index)"

# Étape 2: Insérer les pharmacies
execute_sql "../seeds/pharmacies_antananarivo.sql" "Insertion des 120 pharmacies d'Antananarivo"

# Étape 3: Insérer les médicaments
execute_sql "../seeds/medicaments.sql" "Insertion des 40 médicaments"

# Étape 4: Générer les stocks
execute_sql "../seeds/stocks.sql" "Génération des stocks pour toutes les pharmacies"

echo ""
echo -e "${GREEN}Setup terminé avec succès !${NC}"
echo ""
echo -e "${BLUE}Statistiques:${NC}"

# Afficher les statistiques
PGPASSWORD=$POSTGRES_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
SELECT 
    'Pharmacies' as table_name, COUNT(*) as total FROM pharmacies
UNION ALL
SELECT 'Médicaments', COUNT(*) FROM medicaments
UNION ALL
SELECT 'Stocks', COUNT(*) FROM stocks;
"

echo ""
echo -e "${GREEN}La base de données est prête à l'emploi !${NC}"