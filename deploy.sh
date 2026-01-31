#!/bin/bash

# Script de déploiement pour VonjiAIna
echo "Déploiement de VonjiAIna..."

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Vérifier si Docker est installé
if ! command -v docker &> /dev/null; then
    log_error "Docker n'est pas installé. Veuillez installer Docker d'abord."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    log_error "Docker Compose n'est pas installé. Veuillez installer Docker Compose d'abord."
    exit 1
fi

# Arrêter les conteneurs existants
log_info "Arrêt des conteneurs existants..."
docker-compose down

# Nettoyer les images et volumes (optionnel)
read -p "Voulez-vous nettoyer les volumes Docker ? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "Nettoyage des volumes..."
    docker system prune -f
fi

# Lancer les services
log_info "Démarrage des services Docker..."

# Démarrer uniquement la base de données et l'API
log_info "Démarrage de la base de données et de l'API..."
docker-compose up -d postgres backend

# Attendre que l'API soit prête
log_info "Attente du démarrage de l'API..."
sleep 10

# Vérifier que l'API répond
if curl -s http://localhost:8001/health > /dev/null; then
    log_info "API Backend opérationnelle !"
else
    log_error "API Backend n'a pas démarré correctement"
    docker-compose logs backend
    exit 1
fi

# Demander si on veut lancer le frontend
read -p "Voulez-vous lancer le frontend Flutter ? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "Démarrage du frontend Flutter..."
    docker-compose --profile frontend up -d frontend
    
    log_info "Frontend Flutter en cours de démarrage..."
    log_info "Accès à l'application: http://localhost:8080"
    log_info "Documentation API: http://localhost:8001/docs"
else
    log_info "Déploiement terminé !"
    log_info "API: http://localhost:8001"
    log_info "Documentation: http://localhost:8001/docs"
    log_info "Pour lancer le frontend manuellement: flutter run -d <device_id>"
fi

log_info "VonjiAIna est maintenant déployée !"

# Afficher les commandes utiles
echo ""
echo "Commandes utiles:"
echo "Voir les logs: docker-compose logs [service]"
echo "Arrêter tout: docker-compose down"
echo "Redémarrer: docker-compose restart [service]"
echo "Lancer frontend: docker-compose --profile frontend up -d frontend"
