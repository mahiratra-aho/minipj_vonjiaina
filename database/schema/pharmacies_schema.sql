-- Création de la table sans données
CREATE TABLE IF NOT EXISTS pharmacies (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    adresse TEXT NOT NULL,
    telephone VARCHAR(100),
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    statut VARCHAR(50) DEFAULT 'normal',
    quartier VARCHAR(100),
    horaires TEXT,
    email VARCHAR(255),
    site_web VARCHAR(255),
    verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index
CREATE INDEX idx_pharmacies_location ON pharmacies (latitude, longitude);
CREATE INDEX idx_pharmacies_statut ON pharmacies (statut);