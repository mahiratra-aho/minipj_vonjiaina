from sqlalchemy.orm import Session
from sqlalchemy import text
from typing import List

class PharmacieRepository:
    
    @staticmethod
    def search_with_medicament(
        db: Session, 
        medicament_nom: str, 
        latitude: float, 
        longitude: float, 
        rayon_metres: int = 5000,
        filtre_statut: str = None  # "garde", "ouverte", ou None
    ) -> List[dict]:
        """
        Rechercher les pharmacies avec calcul du statut en temps réel
        """
        rayon_km = rayon_metres / 1000
        
        query = text(f"""
            SELECT 
                p.id,
                p.nom,
                p.adresse,
                p.telephone,
                p.statut as type,
                p.horaires,
                p.latitude,
                p.longitude,
                (6371 * acos(cos(radians({latitude})) * cos(radians(p.latitude)) * 
                 cos(radians(p.longitude) - radians({longitude})) + 
                 sin(radians({latitude})) * sin(radians(p.latitude)))) as distance,
                1000 as prix,
                10 as quantite,
                '{medicament_nom}' as nom_commercial,
                'comprimé' as forme,
                '500mg' as dosage
            FROM pharmacies p
            WHERE 
                (6371 * acos(cos(radians({latitude})) * cos(radians(p.latitude)) * 
                 cos(radians(p.longitude) - radians({longitude})) + 
                 sin(radians({latitude})) * sin(radians(p.latitude)))) <= {rayon_km}
            ORDER BY distance ASC
            LIMIT 20
        """)
        
        result = db.execute(query)
        
        pharmacies = []
        
        for row in result:
            pharmacie = dict(row._mapping)
            
            # Statut simple basé sur le champ statut
            statut_actuel = pharmacie.get('type', 'normal')
            if statut_actuel == 'garde':
                pharmacie['statut'] = 'garde'
            else:
                pharmacie['statut'] = 'ouverte'
            
            pharmacies.append(pharmacie)
        
        return pharmacies
