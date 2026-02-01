-- Génération de stocks pour les 120 pharmacies


-- Stocks variés pour chaque pharmacie
-- Chaque pharmacie a entre 10 et 30 médicaments en stock avec des quantités variables

DO $$
DECLARE
    pharma_id INT;
    med_id INT;
    nb_meds INT;
    quantite_stock INT;
    prix_vente DECIMAL(10,2);
BEGIN
    -- Pour chaque pharmacie
    FOR pharma_id IN 1..120 LOOP
        -- Nombre aléatoire de médicaments en stock (entre 15 et 35)
        nb_meds := 15 + floor(random() * 20)::INT;
        
        -- Sélectionner aléatoirement des médicaments
        FOR med_id IN (
            SELECT id FROM medicaments 
            ORDER BY random() 
            LIMIT nb_meds
        ) LOOP
            -- Quantité aléatoire (entre 10 et 200)
            quantite_stock := 10 + floor(random() * 190)::INT;
            
            -- Prix aléatoire basé sur le type de médicament
            prix_vente := (800 + floor(random() * 5000))::DECIMAL(10,2);
            
            -- Insérer le stock
            INSERT INTO stocks (pharmacie_id, medicament_id, quantite, prix)
            VALUES (pharma_id, med_id, quantite_stock, prix_vente)
            ON CONFLICT (pharmacie_id, medicament_id) DO NOTHING;
        END LOOP;
    END LOOP;
END $$;

-- Message de confirmation
SELECT COUNT(*) as "Lignes de stock créées" FROM stocks;
SELECT COUNT(DISTINCT pharmacie_id) as "Pharmacies avec stock" FROM stocks;
SELECT COUNT(DISTINCT medicament_id) as "Médicaments en stock" FROM stocks;