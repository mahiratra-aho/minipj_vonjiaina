-- DONNÉES INITIALES: MÉDICAMENTS

INSERT INTO medicaments (nom_commercial, dci, laboratoire, forme, dosage, description) VALUES
-- Antalgiques / Antipyrétiques
('Doliprane', 'Paracétamol', 'Sanofi', 'Comprimé', '1000mg', 'Antalgique et antipyrétique'),
('Efferalgan', 'Paracétamol', 'UPSA', 'Comprimé effervescent', '500mg', 'Antalgique et antipyrétique effervescent'),
('Dafalgan', 'Paracétamol', 'UPSA', 'Comprimé', '500mg', 'Traitement de la douleur et de la fièvre'),

-- Anti-inflammatoires
('Ibuprofène Mylan', 'Ibuprofène', 'Mylan', 'Comprimé', '400mg', 'Anti-inflammatoire non stéroïdien'),
('Advil', 'Ibuprofène', 'Pfizer', 'Comprimé pelliculé', '200mg', 'Anti-inflammatoire et antalgique'),
('Nurofen', 'Ibuprofène', 'Reckitt Benckiser', 'Comprimé', '400mg', 'Traitement de la douleur et inflammation'),

-- Antibiotiques
('Amoxicilline', 'Amoxicilline', 'Biogaran', 'Gélule', '500mg', 'Antibiotique de la famille des pénicillines'),
('Augmentin', 'Amoxicilline + Acide clavulanique', 'GSK', 'Comprimé', '500mg/125mg', 'Antibiotique à large spectre'),
('Azithromycine', 'Azithromycine', 'Sandoz', 'Comprimé', '250mg', 'Antibiotique macrolide'),
('Ciprofloxacine', 'Ciprofloxacine', 'Biogaran', 'Comprimé', '500mg', 'Antibiotique fluoroquinolone'),

-- Antispasmodiques / Digestifs
('Spasfon', 'Phloroglucinol', 'Sanofi', 'Comprimé', '80mg', 'Antispasmodique'),
('Débridat', 'Trimébutine', 'Pfizer', 'Comprimé', '200mg', 'Traitement des troubles du transit intestinal'),
('Smecta', 'Diosmectite', 'Ipsen', 'Poudre', '3g', 'Traitement symptomatique de la diarrhée'),

-- Respiratoires
('Ventoline', 'Salbutamol', 'GSK', 'Spray', '100µg/dose', 'Bronchodilatateur pour l''asthme'),
('Rhinadvil', 'Ibuprofène + Pseudoéphédrine', 'Pfizer', 'Comprimé', '200mg/30mg', 'Rhume et congestion nasale'),
('Humex', 'Paracétamol + Pseudoéphédrine', 'UPSA', 'Comprimé', '500mg/60mg', 'Traitement du rhume'),

-- Gastro-intestinaux
('Gaviscon', 'Alginate de sodium', 'Reckitt Benckiser', 'Suspension buvable', '500mg', 'Traitement du reflux gastro-œsophagien'),
('Maalox', 'Hydroxyde d''aluminium + Hydroxyde de magnésium', 'Sanofi', 'Comprimé', '400mg/400mg', 'Traitement des brûlures d''estomac'),
('Rennie', 'Carbonate de calcium + Carbonate de magnésium', 'Bayer', 'Comprimé à croquer', '680mg/80mg', 'Traitement des brûlures d''estomac'),

-- Antihistaminiques
('Cétirizine', 'Cétirizine', 'Biogaran', 'Comprimé', '10mg', 'Antihistaminique'),
('Aerius', 'Desloratadine', 'MSD', 'Comprimé', '5mg', 'Traitement des allergies'),
('Loratadine', 'Loratadine', 'Mylan', 'Comprimé', '10mg', 'Antihistaminique'),

-- Vitamines / Compléments
('Bion 3', 'Multivitamines + Probiotiques', 'Merck', 'Comprimé', '-', 'Complément alimentaire immunité'),
('Vitamine C', 'Acide ascorbique', 'UPSA', 'Comprimé effervescent', '1000mg', 'Complément vitaminique'),
('Magnésium', 'Magnésium', 'Biogaran', 'Comprimé', '300mg', 'Complément en magnésium'),

-- Antidiabétiques
('Metformine', 'Metformine', 'Biogaran', 'Comprimé', '850mg', 'Traitement du diabète de type 2'),
('Glucophage', 'Metformine', 'Merck', 'Comprimé', '500mg', 'Antidiabétique oral'),

-- Anticoagulants
('Kardegic', 'Aspirine', 'Sanofi', 'Sachet', '75mg', 'Antiagrégant plaquettaire'),
('Aspegic', 'Aspirine', 'Sanofi', 'Sachet', '100mg', 'Antalgique et antiagrégant'),

-- Dermatologie
('Biafine', 'Emulsion', 'Bayer', 'Crème', '-', 'Traitement des brûlures superficielles'),
('Homéoplasmine', 'Homéopathique', 'Boiron', 'Pommade', '-', 'Irritations cutanées'),

-- Anti-hypertenseurs
('Amlodipine', 'Amlodipine', 'Biogaran', 'Comprimé', '5mg', 'Traitement de l''hypertension'),
('Enalapril', 'Enalapril', 'Mylan', 'Comprimé', '10mg', 'Inhibiteur de l''enzyme de conversion'),

-- Antifongiques
('Daktarin', 'Miconazole', 'Janssen', 'Gel buccal', '2%', 'Traitement des mycoses buccales'),
('Pevaryl', 'Econazole', 'Janssen', 'Crème', '1%', 'Traitement des mycoses cutanées'),

-- Antiparasitaires
('Vermox', 'Mébendazole', 'Janssen', 'Comprimé', '100mg', 'Traitement des vers intestinaux'),
('Fluvermal', 'Flubendazole', 'Janssen', 'Comprimé', '100mg', 'Antiparasitaire intestinal'),

-- Anti-inflammatoires stéroïdiens
('Cortancyl', 'Prednisone', 'Sanofi', 'Comprimé', '20mg', 'Corticoïde anti-inflammatoire'),
('Solupred', 'Prednisolone', 'Sanofi', 'Comprimé effervescent', '20mg', 'Corticoïde'),

-- Anxiolytiques (sur ordonnance)
('Lexomil', 'Bromazépam', 'Roche', 'Comprimé', '6mg', 'Anxiolytique benzodiazépine'),
('Xanax', 'Alprazolam', 'Pfizer', 'Comprimé', '0.25mg', 'Traitement de l''anxiété'),

-- Contraceptifs
('Optimizette', 'Desogestrel', 'MSD', 'Comprimé', '75µg', 'Contraceptif oral'),
('Microval', 'Lévonorgestrel', 'Bayer', 'Comprimé', '30µg', 'Pilule contraceptive')

ON CONFLICT DO NOTHING;

-- Message de confirmation
SELECT COUNT(*) as "Nombre de médicaments insérés" FROM medicaments;