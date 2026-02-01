-- ============================================
-- SCRIPT COMPLET VONJIAINA - VERSION ORIGINALE
-- 120 pharmacies avec latitude/longitude/statut
-- ============================================

-- ÉTAPE 1 : ACTIVATION DE POSTGIS
CREATE EXTENSION IF NOT EXISTS postgis;

-- ÉTAPE 2 : SUPPRESSION DES ANCIENNES TABLES
DROP TABLE IF EXISTS stocks CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS medicaments CASCADE;
DROP TABLE IF EXISTS pharmacies CASCADE;

-- ÉTAPE 3 : CRÉATION DES TABLES (FORMAT ORIGINAL)
CREATE TABLE pharmacies (
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

CREATE TABLE medicaments (
    id SERIAL PRIMARY KEY,
    nom_commercial VARCHAR(255) NOT NULL,
    dci VARCHAR(255),
    laboratoire VARCHAR(255),
    forme VARCHAR(100),
    dosage VARCHAR(50),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE stocks (
    id SERIAL PRIMARY KEY,
    pharmacie_id INTEGER NOT NULL REFERENCES pharmacies(id) ON DELETE CASCADE,
    medicament_id INTEGER NOT NULL REFERENCES medicaments(id) ON DELETE CASCADE,
    quantite INTEGER NOT NULL DEFAULT 0,
    prix DECIMAL(10, 2),
    date_maj TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(pharmacie_id, medicament_id)
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    nom VARCHAR(255) NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'user',
    pharmacie_id INTEGER REFERENCES pharmacies(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index
CREATE INDEX idx_pharmacies_lat_lon ON pharmacies(latitude, longitude);
CREATE INDEX idx_medicaments_nom ON medicaments(nom_commercial);
CREATE INDEX idx_medicaments_dci ON medicaments(dci);
CREATE INDEX idx_stocks_pharmacie ON stocks(pharmacie_id);
CREATE INDEX idx_stocks_medicament ON stocks(medicament_id);
CREATE INDEX idx_stocks_quantite ON stocks(quantite) WHERE quantite > 0;
CREATE INDEX idx_users_email ON users(email);

-- ÉTAPE 4 : INSERTION DES 120 PHARMACIES
INSERT INTO pharmacies (nom, adresse, telephone, latitude, longitude, statut, quartier, horaires, verified) VALUES
('Pharmacie Andohatapenaka', 'Lot II J 25 Ter Andohatapenaka', '+261 34 00 000 01', -18.9388, 47.5214, 'normal', 'Andohatapenaka', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Ankorondrano', 'Angle Rue Andriantsitohaina et Ravelonarivo', '+261 34 00 000 02', -18.8898, 47.5079, 'garde', 'Ankorondrano', '24h/24', true),
('Pharmacie Antaninarenina', 'Rue Rainandriamampandry', '+261 34 00 000 03', -18.9195, 47.5346, 'normal', 'Antaninarenina', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Ampefiloha', 'Rue Ratsimilaho', '+261 34 00 000 04', -18.9156, 47.5287, 'normal', 'Ampefiloha', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Behoririka', 'Avenue Ravelonarivo', '+261 34 00 000 05', -18.9234, 47.5321, 'garde', 'Behoririka', '24h/24', true),
('Pharmacie Besarety', 'Rue Besarety', '+261 34 00 000 06', -18.9278, 47.5356, 'normal', 'Besarety', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Isoraka', 'Rue Andriamanalina', '+261 34 00 000 07', -18.9123, 47.5267, 'normal', 'Isoraka', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Itaosy', 'Route d''Itaosy', '+261 34 00 000 08', -18.9456, 47.5234, 'normal', 'Itaosy', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Mahamasina', 'Rue Mahamasina', '+261 34 00 000 09', -18.9089, 47.5245, 'garde', 'Mahamasina', '24h/24', true),
('Pharmacie Manjakamiadana', 'Avenue de l''Indépendance', '+261 34 00 000 10', -18.9178, 47.5312, 'normal', 'Manjakamiadana', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie 67 Ha', 'Rue 67 Ha', '+261 34 00 000 11', -18.9212, 47.5298, 'normal', '67 Ha', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Analakely', 'Rue Ranavalona III', '+261 34 00 000 12', -18.9189, 47.5301, 'garde', 'Analakely', '24h/24', true),
('Pharmacie Antsirabe', 'Rue Antsirabe', '+261 34 00 000 13', -18.9134, 47.5278, 'normal', 'Antsirabe', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Ambatobe', 'Route d''Ambatobe', '+261 34 00 000 14', -18.9345, 47.5221, 'normal', 'Ambatobe', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Ambohimirary', 'Rue Ambohimirary', '+261 34 00 000 15', -18.9167, 47.5289, 'normal', 'Ambohimirary', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Anosy', 'Route d''Anosy', '+261 34 00 000 16', -18.9412, 47.5256, 'normal', 'Anosy', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Atsimondrano', 'Rue Atsimondrano', '+261 34 00 000 17', -18.9234, 47.5312, 'garde', 'Atsimondrano', '24h/24', true),
('Pharmacie Befelatanana', 'Route de Befelatanana', '+261 34 00 000 18', -18.9289, 47.5345, 'normal', 'Befelatanana', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Faravohitra', 'Rue Faravohitra', '+261 34 00 000 19', -18.9156, 47.5267, 'normal', 'Faravohitra', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Fort-Dauphin', 'Rue Fort-Dauphin', '+261 34 00 000 20', -18.9198, 47.5291, 'normal', 'Fort-Dauphin', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Galien', 'Avenue Galien', '+261 34 00 000 21', -18.9123, 47.5256, 'garde', 'Galien', '24h/24', true),
('Pharmacie Ivandry', 'Rue Ivandry', '+261 34 00 000 22', -18.9378, 47.5209, 'normal', 'Ivandry', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Jovenna', 'Rue Jovenna', '+261 34 00 000 23', -18.9212, 47.5304, 'normal', 'Jovenna', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Lazaret', 'Rue Lazaret', '+261 34 00 000 24', -18.9345, 47.5234, 'normal', 'Lazaret', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Mandroseza', 'Route de Mandroseza', '+261 34 00 000 25', -18.9456, 47.5221, 'normal', 'Mandroseza', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Manjakaray', 'Rue Manjakaray', '+261 34 00 000 26', -18.9167, 47.5278, 'garde', 'Manjakaray', '24h/24', true),
('Pharmacie Nanisana', 'Route de Nanisana', '+261 34 00 000 27', -18.9289, 47.5334, 'normal', 'Nanisana', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Ohlin', 'Rue Ohlin', '+261 34 00 000 28', -18.9134, 47.5267, 'normal', 'Ohlin', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Pasteur', 'Rue Pasteur', '+261 34 00 000 29', -18.9198, 47.5298, 'normal', 'Pasteur', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Renivohitra', 'Rue Renivohitra', '+261 34 00 000 30', -18.9234, 47.5312, 'garde', 'Renivohitra', '24h/24', true),
('Pharmacie Sabotsy', 'Rue Sabotsy', '+261 34 00 000 31', -18.9289, 47.5345, 'normal', 'Sabotsy', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Soavita', 'Rue Soavita', '+261 34 00 000 32', -18.9156, 47.5278, 'normal', 'Soavita', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Tsimbazaza', 'Route de Tsimbazaza', '+261 34 00 000 33', -18.9345, 47.5234, 'normal', 'Tsimbazaza', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Tsaralalana', 'Rue Tsaralalana', '+261 34 00 000 34', -18.9212, 47.5301, 'garde', 'Tsaralalana', '24h/24', true),
('Pharmacie Vatomandry', 'Rue Vatomandry', '+261 34 00 000 35', -18.9378, 47.5221, 'normal', 'Vatomandry', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Vorontsoa', 'Rue Vorontsoa', '+261 34 00 000 36', -18.9198, 47.5291, 'normal', 'Vorontsoa', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Zafimahazo', 'Rue Zafimahazo', '+261 34 00 000 37', -18.9134, 47.5267, 'normal', 'Zafimahazo', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Ambohidratrimo', 'Route d''Ambohidratrimo', '+261 34 00 000 38', -18.9456, 47.5256, 'normal', 'Ambohidratrimo', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Anosizato', 'Rue Anosizato', '+261 34 00 000 39', -18.9289, 47.5334, 'garde', 'Anosizato', '24h/24', true),
('Pharmacie Antanetibe', 'Rue Antanetibe', '+261 34 00 000 40', -18.9167, 47.5289, 'normal', 'Antanetibe', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Antsahabe', 'Rue Antsahabe', '+261 34 00 000 41', -18.9234, 47.5312, 'normal', 'Antsahabe', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Amboditsiry', 'Rue Amboditsiry', '+261 34 00 000 42', -18.9345, 47.5221, 'normal', 'Amboditsiry', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Ambohijanaka', 'Rue Ambohijanaka', '+261 34 00 000 43', -18.9198, 47.5298, 'normal', 'Ambohijanaka', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Ambohidahy', 'Rue Ambohidahy', '+261 34 00 000 44', -18.9156, 47.5278, 'garde', 'Ambohidahy', '24h/24', true),
('Pharmacie Ambohipo', 'Rue Ambohipo', '+261 34 00 000 45', -18.9378, 47.5209, 'normal', 'Ambohipo', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Ambohimanarina', 'Rue Ambohimanarina', '+261 34 00 000 46', -18.9212, 47.5304, 'normal', 'Ambohimanarina', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Ambohijanahary', 'Rue Ambohijanahary', '+261 34 00 000 47', -18.9289, 47.5345, 'normal', 'Ambohijanahary', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Ambohitrarahaba', 'Rue Ambohitrarahaba', '+261 34 00 000 48', -18.9134, 47.5267, 'normal', 'Ambohitrarahaba', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Ambohimanoro', 'Rue Ambohimanoro', '+261 34 00 000 49', -18.9345, 47.5234, 'garde', 'Ambohimanoro', '24h/24', true),
('Pharmacie Ambohijanavo', 'Rue Ambohijanavo', '+261 34 00 000 50', -18.9198, 47.5291, 'normal', 'Ambohijanavo', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Ambohimanambola', 'Rue Ambohimanambola', '+261 34 00 000 51', -18.9289, 47.5345, 'normal', 'Ambohimanambola', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Ambohimanarina 2', 'Rue Ambohimanarina', '+261 34 00 000 52', -18.9156, 47.5278, 'garde', 'Ambohimanarina', '24h/24', true),
('Pharmacie Ambohijato', 'Rue Ambohijato', '+261 34 00 000 53', -18.9345, 47.5234, 'normal', 'Ambohijato', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Ambohitrinimbahoaka', 'Rue Ambohitrinimbahoaka', '+261 34 00 000 54', -18.9212, 47.5301, 'normal', 'Ambohitrinimbahoaka', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Ambohitrivoanjo', 'Rue Ambohitrivoanjo', '+261 34 00 000 55', -18.9378, 47.5221, 'normal', 'Ambohitrivoanjo', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Ambohidrapeto', 'Rue Ambohidrapeto', '+261 34 00 000 56', -18.9198, 47.5298, 'normal', 'Ambohidrapeto', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Ambohikely', 'Rue Ambohikely', '+261 34 00 000 57', -18.9134, 47.5267, 'garde', 'Ambohikely', '24h/24', true),
('Pharmacie Ambohitsimanova', 'Rue Ambohitsimanova', '+261 34 00 000 58', -18.9289, 47.5334, 'normal', 'Ambohitsimanova', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Ambohijanakandriana', 'Rue Ambohijanakandriana', '+261 34 00 000 59', -18.9167, 47.5289, 'normal', 'Ambohijanakandriana', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Ambohijanaka 2', 'Rue Ambohijanaka', '+261 34 00 000 60', -18.9234, 47.5312, 'normal', 'Ambohijanaka', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Ambohimanoro 2', 'Rue Ambohimanoro', '+261 34 00 000 61', -18.9345, 47.5221, 'normal', 'Ambohimanoro', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Ambohijanahary 2', 'Rue Ambohijanahary', '+261 34 00 000 62', -18.9198, 47.5291, 'garde', 'Ambohijanahary', '24h/24', true),
('Pharmacie Ambohitrarahaba 2', 'Rue Ambohitrarahaba', '+261 34 00 000 63', -18.9156, 47.5278, 'normal', 'Ambohitrarahaba', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Ambohimanarina 3', 'Rue Ambohimanarina', '+261 34 00 000 64', -18.9378, 47.5209, 'normal', 'Ambohimanarina', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Ambohijanavo 2', 'Rue Ambohijanavo', '+261 34 00 000 65', -18.9212, 47.5304, 'normal', 'Ambohijanavo', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Ambohidratrimo 2', 'Rue Ambohidratrimo', '+261 34 00 000 66', -18.9289, 47.5345, 'normal', 'Ambohidratrimo', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Anosizato 2', 'Rue Anosizato', '+261 34 00 000 67', -18.9134, 47.5267, 'garde', 'Anosizato', '24h/24', true),
('Pharmacie Antanetibe 2', 'Rue Antanetibe', '+261 34 00 000 68', -18.9345, 47.5234, 'normal', 'Antanetibe', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Antsahabe 2', 'Rue Antsahabe', '+261 34 00 000 69', -18.9198, 47.5298, 'normal', 'Antsahabe', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Amboditsiry 2', 'Rue Amboditsiry', '+261 34 00 000 70', -18.9289, 47.5334, 'normal', 'Amboditsiry', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Ambohijanaka 3', 'Rue Ambohijanaka', '+261 34 00 000 71', -18.9167, 47.5289, 'garde', 'Ambohijanaka', '24h/24', true),
('Pharmacie Ambohidahy 2', 'Rue Ambohidahy', '+261 34 00 000 72', -18.9234, 47.5312, 'normal', 'Ambohidahy', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Ambohipo 2', 'Rue Ambohipo', '+261 34 00 000 73', -18.9345, 47.5221, 'normal', 'Ambohipo', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Ambohimanarina 4', 'Rue Ambohimanarina', '+261 34 00 000 74', -18.9198, 47.5291, 'normal', 'Ambohimanarina', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Ambohijanahary 3', 'Rue Ambohijanahary', '+261 34 00 000 75', -18.9156, 47.5278, 'normal', 'Ambohijanahary', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Ambohitrarahaba 3', 'Rue Ambohitrarahaba', '+261 34 00 000 76', -18.9378, 47.5209, 'garde', 'Ambohitrarahaba', '24h/24', true),
('Pharmacie Ambohimanoro 3', 'Rue Ambohimanoro', '+261 34 00 000 77', -18.9212, 47.5304, 'normal', 'Ambohimanoro', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Ambohijanavo 3', 'Rue Ambohijanavo', '+261 34 00 000 78', -18.9289, 47.5345, 'normal', 'Ambohijanavo', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Ambohimanambola 2', 'Rue Ambohimanambola', '+261 34 00 000 79', -18.9134, 47.5267, 'normal', 'Ambohimanambola', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Ambohimanarina 5', 'Rue Ambohimanarina', '+261 34 00 000 80', -18.9345, 47.5234, 'normal', 'Ambohimanarina', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Ambohijato 2', 'Rue Ambohijato', '+261 34 00 000 81', -18.9198, 47.5298, 'garde', 'Ambohijato', '24h/24', true),
('Pharmacie Ambohitrinimbahoaka 2', 'Rue Ambohitrinimbahoaka', '+261 34 00 000 82', -18.9289, 47.5334, 'normal', 'Ambohitrinimbahoaka', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Ambohitrivoanjo 2', 'Rue Ambohitrivoanjo', '+261 34 00 000 83', -18.9167, 47.5289, 'normal', 'Ambohitrivoanjo', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Ambohidrapeto 2', 'Rue Ambohidrapeto', '+261 34 00 000 84', -18.9234, 47.5312, 'normal', 'Ambohidrapeto', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Ambohikely 2', 'Rue Ambohikely', '+261 34 00 000 85', -18.9345, 47.5221, 'normal', 'Ambohikely', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Ambohitsimanova 2', 'Rue Ambohitsimanova', '+261 34 00 000 86', -18.9198, 47.5291, 'garde', 'Ambohitsimanova', '24h/24', true),
('Pharmacie Ambohijanakandriana 2', 'Rue Ambohijanakandriana', '+261 34 00 000 87', -18.9156, 47.5278, 'normal', 'Ambohijanakandriana', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Ambohijanaka 4', 'Rue Ambohijanaka', '+261 34 00 000 88', -18.9378, 47.5209, 'normal', 'Ambohijanaka', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Ambohimanoro 4', 'Rue Ambohimanoro', '+261 34 00 000 89', -18.9212, 47.5304, 'normal', 'Ambohimanoro', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Ambohijanahary 4', 'Rue Ambohijanahary', '+261 34 00 000 90', -18.9289, 47.5345, 'normal', 'Ambohijanahary', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Ambohitrarahaba 4', 'Rue Ambohitrarahaba', '+261 34 00 000 91', -18.9134, 47.5267, 'garde', 'Ambohitrarahaba', '24h/24', true),
('Pharmacie Ambohimanarina 6', 'Rue Ambohimanarina', '+261 34 00 000 92', -18.9345, 47.5234, 'normal', 'Ambohimanarina', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Ambohijanavo 4', 'Rue Ambohijanavo', '+261 34 00 000 93', -18.9198, 47.5298, 'normal', 'Ambohijanavo', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Ambohimanambola 3', 'Rue Ambohimanambola', '+261 34 00 000 94', -18.9289, 47.5334, 'normal', 'Ambohimanambola', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Ambohimanarina 7', 'Rue Ambohimanarina', '+261 34 00 000 95', -18.9167, 47.5289, 'normal', 'Ambohimanarina', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Ambohijato 3', 'Rue Ambohijato', '+261 34 00 000 96', -18.9234, 47.5312, 'garde', 'Ambohijato', '24h/24', true),
('Pharmacie Ambohitrinimbahoaka 3', 'Rue Ambohitrinimbahoaka', '+261 34 00 000 97', -18.9345, 47.5221, 'normal', 'Ambohitrinimbahoaka', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Ambohitrivoanjo 3', 'Rue Ambohitrivoanjo', '+261 34 00 000 98', -18.9198, 47.5291, 'normal', 'Ambohitrivoanjo', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Ambohidrapeto 3', 'Rue Ambohidrapeto', '+261 34 00 000 99', -18.9156, 47.5278, 'normal', 'Ambohidrapeto', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Ambohikely 3', 'Rue Ambohikely', '+261 34 00 001 00', -18.9378, 47.5209, 'normal', 'Ambohikely', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Ambohitsimanova 3', 'Rue Ambohitsimanova', '+261 34 00 001 01', -18.9212, 47.5304, 'garde', 'Ambohitsimanova', '24h/24', true),
('Pharmacie Ambohijanakandriana 3', 'Rue Ambohijanakandriana', '+261 34 00 001 02', -18.9289, 47.5345, 'normal', 'Ambohijanakandriana', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Ambohijanaka 5', 'Rue Ambohijanaka', '+261 34 00 001 03', -18.9134, 47.5267, 'normal', 'Ambohijanaka', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Ambohimanoro 5', 'Rue Ambohimanoro', '+261 34 00 001 04', -18.9345, 47.5234, 'normal', 'Ambohimanoro', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Ambohijanahary 5', 'Rue Ambohijanahary', '+261 34 00 001 05', -18.9198, 47.5298, 'normal', 'Ambohijanahary', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Ambohitrarahaba 5', 'Rue Ambohitrarahaba', '+261 34 00 001 06', -18.9289, 47.5334, 'garde', 'Ambohitrarahaba', '24h/24', true),
('Pharmacie Ambohimanarina 8', 'Rue Ambohimanarina', '+261 34 00 001 07', -18.9167, 47.5289, 'normal', 'Ambohimanarina', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Ambohijanavo 5', 'Rue Ambohijanavo', '+261 34 00 001 08', -18.9234, 47.5312, 'normal', 'Ambohijanavo', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Ambohimanambola 4', 'Rue Ambohimanambola', '+261 34 00 001 09', -18.9345, 47.5221, 'normal', 'Ambohimanambola', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Ambohimanarina 9', 'Rue Ambohimanarina', '+261 34 00 001 10', -18.9198, 47.5291, 'normal', 'Ambohimanarina', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Ambohijato 4', 'Rue Ambohijato', '+261 34 00 001 11', -18.9156, 47.5278, 'garde', 'Ambohijato', '24h/24', true),
('Pharmacie Ambohitrinimbahoaka 4', 'Rue Ambohitrinimbahoaka', '+261 34 00 001 12', -18.9378, 47.5209, 'normal', 'Ambohitrinimbahoaka', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Ambohitrivoanjo 4', 'Rue Ambohitrivoanjo', '+261 34 00 001 13', -18.9212, 47.5304, 'normal', 'Ambohitrivoanjo', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Ambohidrapeto 4', 'Rue Ambohidrapeto', '+261 34 00 001 14', -18.9289, 47.5345, 'normal', 'Ambohidrapeto', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Ambohikely 4', 'Rue Ambohikely', '+261 34 00 001 15', -18.9134, 47.5267, 'normal', 'Ambohikely', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Ambohitsimanova 4', 'Rue Ambohitsimanova', '+261 34 00 001 16', -18.9345, 47.5234, 'garde', 'Ambohitsimanova', '24h/24', true),
('Pharmacie Ambohijanakandriana 4', 'Rue Ambohijanakandriana', '+261 34 00 001 17', -18.9198, 47.5298, 'normal', 'Ambohijanakandriana', 'Lun-Dim: 07h30-20h00', true),
('Pharmacie Ambohijanaka 6', 'Rue Ambohijanaka', '+261 34 00 001 18', -18.9289, 47.5334, 'normal', 'Ambohijanaka', 'Lun-Dim: 08h00-19h30', true),
('Pharmacie Ambohimanoro 6', 'Rue Ambohimanoro', '+261 34 00 001 19', -18.9167, 47.5289, 'normal', 'Ambohimanoro', 'Lun-Dim: 08h00-19h00', true),
('Pharmacie Ambohijanahary 6', 'Rue Ambohijanahary', '+261 34 00 001 20', -18.9234, 47.5312, 'garde', 'Ambohijanahary', '24h/24', true);

-- ÉTAPE 5 : INSERTION DES MÉDICAMENTS
INSERT INTO medicaments (nom_commercial, dci, laboratoire, forme, dosage, description) VALUES
('Doliprane', 'Paracétamol', 'Sanofi', 'Comprimé', '1000mg', 'Antalgique et antipyrétique'),
('Efferalgan', 'Paracétamol', 'UPSA', 'Comprimé effervescent', '500mg', 'Antalgique et antipyrétique effervescent'),
('Dafalgan', 'Paracétamol', 'UPSA', 'Comprimé', '500mg', 'Traitement de la douleur et de la fièvre'),
('Ibuprofène Mylan', 'Ibuprofène', 'Mylan', 'Comprimé', '400mg', 'Anti-inflammatoire non stéroïdien'),
('Advil', 'Ibuprofène', 'Pfizer', 'Comprimé pelliculé', '200mg', 'Anti-inflammatoire et antalgique'),
('Nurofen', 'Ibuprofène', 'Reckitt Benckiser', 'Comprimé', '400mg', 'Traitement de la douleur et inflammation'),
('Amoxicilline', 'Amoxicilline', 'Biogaran', 'Gélule', '500mg', 'Antibiotique de la famille des pénicillines'),
('Augmentin', 'Amoxicilline + Acide clavulanique', 'GSK', 'Comprimé', '500mg/125mg', 'Antibiotique à large spectre'),
('Azithromycine', 'Azithromycine', 'Sandoz', 'Comprimé', '250mg', 'Antibiotique macrolide'),
('Spasfon', 'Phloroglucinol', 'Sanofi', 'Comprimé', '80mg', 'Antispasmodique'),
('Débridat', 'Trimébutine', 'Pfizer', 'Comprimé', '200mg', 'Traitement des troubles du transit intestinal'),
('Ventoline', 'Salbutamol', 'GSK', 'Spray', '100µg/dose', 'Bronchodilatateur pour l''asthme'),
('Rhinadvil', 'Ibuprofène + Pseudoéphédrine', 'Pfizer', 'Comprimé', '200mg/30mg', 'Rhume et congestion nasale'),
('Humex', 'Paracétamol + Pseudoéphédrine', 'UPSA', 'Comprimé', '500mg/60mg', 'Traitement du rhume'),
('Smecta', 'Diosmectite', 'Ipsen', 'Poudre', '3g', 'Traitement symptomatique de la diarrhée'),
('Gaviscon', 'Alginate de sodium', 'Reckitt Benckiser', 'Suspension buvable', '500mg', 'Traitement du reflux gastro-œsophagien'),
('Maalox', 'Hydroxyde d''aluminium + Hydroxyde de magnésium', 'Sanofi', 'Comprimé', '400mg/400mg', 'Traitement des brûlures d''estomac'),
('Cétirizine', 'Cétirizine', 'Biogaran', 'Comprimé', '10mg', 'Antihistaminique'),
('Aerius', 'Desloratadine', 'MSD', 'Comprimé', '5mg', 'Traitement des allergies'),
('Bion 3', 'Multivitamines + Probiotiques', 'Merck', 'Comprimé', '-', 'Complément alimentaire immunité');

-- ÉTAPE 6 : INSERTION DES STOCKS (pour les 30 premières pharmacies)
INSERT INTO stocks (pharmacie_id, medicament_id, quantite, prix) VALUES
(1, 1, 150, 1200), (1, 2, 80, 950), (1, 4, 120, 800), (1, 7, 90, 2500), (1, 10, 60, 1500),
(2, 1, 200, 1150), (2, 3, 100, 900), (2, 5, 80, 700), (2, 8, 50, 3500), (2, 12, 70, 3200),
(3, 1, 180, 1180), (3, 4, 90, 850), (3, 6, 110, 900), (3, 9, 60, 1800), (3, 13, 50, 2500),
(4, 2, 120, 980), (4, 5, 70, 720), (4, 7, 100, 2400), (4, 11, 80, 3000), (4, 15, 40, 4500),
(5, 1, 160, 1190), (5, 3, 90, 920), (5, 8, 65, 3600), (5, 10, 75, 1550), (5, 14, 55, 2200),
(6, 1, 100, 1220), (6, 4, 60, 820), (6, 7, 70, 2550), (6, 12, 50, 3300), (6, 16, 45, 5500),
(7, 2, 110, 960), (7, 5, 80, 710), (7, 9, 55, 1850), (7, 13, 60, 2450), (7, 17, 40, 6200),
(8, 1, 130, 1210), (8, 6, 70, 880), (8, 10, 65, 1520), (8, 14, 50, 2180), (8, 18, 35, 3500),
(9, 3, 95, 930), (9, 7, 85, 2480), (9, 11, 70, 2950), (9, 15, 45, 4400), (9, 19, 50, 4800),
(10, 1, 140, 1190), (10, 4, 75, 830), (10, 8, 60, 3550), (10, 12, 55, 3250), (10, 20, 30, 12000),
(11, 2, 105, 970), (11, 5, 65, 730), (11, 9, 50, 1820), (11, 13, 55, 2480), (11, 16, 40, 5400),
(12, 1, 125, 1200), (12, 6, 80, 870), (12, 10, 70, 1530), (12, 14, 60, 2200), (12, 17, 45, 6100),
(13, 3, 100, 920), (13, 7, 90, 2500), (13, 11, 75, 2980), (13, 15, 50, 4450), (13, 18, 40, 3400),
(14, 1, 135, 1180), (14, 4, 70, 810), (14, 8, 55, 3580), (14, 12, 60, 3280), (14, 19, 55, 4750),
(15, 2, 115, 950), (15, 5, 75, 720), (15, 9, 60, 1830), (15, 13, 65, 2460), (15, 20, 35, 11800),
(16, 1, 120, 1210), (16, 6, 75, 860), (16, 10, 65, 1540), (16, 14, 55, 2190), (16, 16, 50, 5450),
(17, 3, 90, 940), (17, 7, 80, 2520), (17, 11, 70, 2970), (17, 15, 55, 4420), (17, 17, 50, 6150),
(18, 1, 145, 1195), (18, 4, 80, 820), (18, 8, 65, 3570), (18, 12, 65, 3270), (18, 18, 45, 3450),
(19, 2, 110, 965), (19, 5, 70, 725), (19, 9, 55, 1840), (19, 13, 60, 2470), (19, 19, 60, 4780),
(20, 1, 150, 1185), (20, 6, 85, 875), (20, 10, 75, 1535), (20, 14, 65, 2210), (20, 20, 40, 11900),
(21, 1, 125, 1195), (21, 3, 95, 915), (21, 7, 75, 2490), (21, 11, 65, 2965), (21, 15, 48, 4410),
(22, 2, 105, 975), (22, 5, 65, 715), (22, 10, 55, 1525), (22, 14, 52, 2195), (22, 18, 38, 3425),
(23, 1, 140, 1200), (23, 4, 70, 825), (23, 8, 60, 3540), (23, 12, 58, 3265), (23, 16, 47, 5440),
(24, 3, 100, 925), (24, 6, 80, 865), (24, 12, 65, 3260), (24, 17, 51, 6135), (24, 19, 57, 4770),
(25, 1, 130, 1190), (25, 5, 75, 720), (25, 9, 55, 1835), (25, 13, 61, 2468), (25, 20, 36, 11825),
(26, 2, 115, 960), (26, 7, 85, 2510), (26, 13, 60, 2465), (26, 16, 46, 5430), (26, 18, 39, 3415),
(27, 1, 145, 1185), (27, 4, 75, 815), (27, 11, 70, 2975), (27, 15, 51, 4425), (27, 19, 58, 4765),
(28, 3, 90, 930), (28, 8, 65, 3565), (28, 14, 55, 2195), (28, 17, 52, 6145), (28, 20, 37, 11850),
(29, 1, 120, 1205), (29, 6, 70, 870), (29, 15, 50, 4430), (29, 12, 63, 3275), (29, 10, 68, 1538),
(30, 2, 110, 970), (30, 10, 60, 1540), (30, 16, 45, 5425), (30, 13, 62, 2473), (30, 7, 88, 2495);

-- ÉTAPE 7 : VÉRIFICATION
SELECT 'Pharmacies' as table_name, COUNT(*) as total FROM pharmacies
UNION ALL
SELECT 'Médicaments', COUNT(*) FROM medicaments
UNION ALL
SELECT 'Stocks', COUNT(*) FROM stocks;

SELECT COUNT(*) as "Pharmacies de garde (statut='garde')" FROM pharmacies WHERE statut = 'garde';

SELECT 'BASE DE DONNÉES CONFIGURÉE AVEC SUCCÈS !' as message;
SELECT '120 pharmacies | 20 médicaments | Stocks pour 30 pharmacies' as resume;