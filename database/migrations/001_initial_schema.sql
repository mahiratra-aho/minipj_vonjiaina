-- Migration initiale pour la base de données VonjiAIna
-- Création: 2026-01-18
-- Description: Création de la table pharmacies avec tous les champs nécessaires

-- Extension pour les calculs de distance géographique
CREATE EXTENSION IF NOT EXISTS postgis;

-- Table principale des pharmacies
CREATE TABLE IF NOT EXISTS pharmacies (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    adresse TEXT NOT NULL,
    telephone VARCHAR(100),
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    statut VARCHAR(50) DEFAULT 'normal' CHECK (statut IN ('normal', 'garde', '24h')),
    quartier VARCHAR(100),
    horaires TEXT,
    email VARCHAR(255),
    site_web VARCHAR(255),
    verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index pour optimiser les requêtes
CREATE INDEX IF NOT EXISTS idx_pharmacies_location ON pharmacies (latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_pharmacies_statut ON pharmacies (statut);
CREATE INDEX IF NOT EXISTS idx_pharmacies_quartier ON pharmacies (quartier);
CREATE INDEX IF NOT EXISTS idx_pharmacies_nom ON pharmacies (nom);

-- Trigger pour mettre à jour updated_at automatiquement
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_pharmacies_updated_at 
    BEFORE UPDATE ON pharmacies 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Fonction pour calculer la distance entre deux points GPS
CREATE OR REPLACE FUNCTION calculate_distance(
    lat1 DECIMAL, 
    lon1 DECIMAL, 
    lat2 DECIMAL, 
    lon2 DECIMAL
)
RETURNS DECIMAL AS $$
BEGIN
    RETURN 6371 * acos(
        cos(radians(lat1)) * cos(radians(lat2)) * 
        cos(radians(lon2) - radians(lon1)) + 
        sin(radians(lat1)) * sin(radians(lat2))
    );
END;
$$ LANGUAGE plpgsql;

COMMENT ON TABLE pharmacies IS 'Table contenant les informations des pharmacies d''Antananarivo';
COMMENT ON COLUMN pharmacies.statut IS 'Statut de la pharmacie: normal, garde, ou 24h';
COMMENT ON COLUMN pharmacies.verified IS 'Indique si les informations ont été vérifiées manuellement';