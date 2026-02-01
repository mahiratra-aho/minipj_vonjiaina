-- SCHÉMA COMPLET DE LA BASE DE DONNÉES

-- Extension PostGIS pour les données géographiques
CREATE EXTENSION IF NOT EXISTS postgis;

-- TABLE: pharmacies
CREATE TABLE IF NOT EXISTS pharmacies (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    adresse VARCHAR(500),
    telephone VARCHAR(20),
    email VARCHAR(255),
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    statut VARCHAR(50) DEFAULT 'normal',
    quartier VARCHAR(100),
    horaires VARCHAR(200),
    verified BOOLEAN DEFAULT true,
    actif BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- TABLE: medicaments
CREATE TABLE IF NOT EXISTS medicaments (
    id SERIAL PRIMARY KEY,
    nom_commercial VARCHAR(255) NOT NULL,
    dci VARCHAR(255),
    laboratoire VARCHAR(255),
    forme VARCHAR(100),
    dosage VARCHAR(50),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- TABLE: stocks
CREATE TABLE IF NOT EXISTS stocks (
    id SERIAL PRIMARY KEY,
    pharmacie_id INTEGER NOT NULL REFERENCES pharmacies(id) ON DELETE CASCADE,
    medicament_id INTEGER NOT NULL REFERENCES medicaments(id) ON DELETE CASCADE,
    quantite INTEGER NOT NULL DEFAULT 0,
    prix DECIMAL(10, 2),
    date_maj TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(pharmacie_id, medicament_id)
);

-- TABLE: users
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    nom VARCHAR(255) NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'user',
    pharmacie_id INTEGER REFERENCES pharmacies(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- TABLE: refresh_tokens
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id SERIAL PRIMARY KEY,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_id VARCHAR(255),
    revoked BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE
);

-- TABLE: journal_audit
CREATE TABLE IF NOT EXISTS journal_audit (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    action_type VARCHAR(100) NOT NULL,
    resource_id VARCHAR(255),
    adresse_ip VARCHAR(100),
    user_agent VARCHAR(512),
    horodatage_precis TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- INDEX
CREATE INDEX IF NOT EXISTS idx_pharmacies_lat_lon ON pharmacies(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_pharmacies_statut ON pharmacies(statut);
CREATE INDEX IF NOT EXISTS idx_pharmacies_quartier ON pharmacies(quartier);

CREATE INDEX IF NOT EXISTS idx_medicaments_nom ON medicaments(nom_commercial);
CREATE INDEX IF NOT EXISTS idx_medicaments_dci ON medicaments(dci);

CREATE INDEX IF NOT EXISTS idx_stocks_pharmacie ON stocks(pharmacie_id);
CREATE INDEX IF NOT EXISTS idx_stocks_medicament ON stocks(medicament_id);
CREATE INDEX IF NOT EXISTS idx_stocks_quantite ON stocks(quantite) WHERE quantite > 0;

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- Message de confirmation
SELECT 'Schéma de base de données créé avec succès!' as message;