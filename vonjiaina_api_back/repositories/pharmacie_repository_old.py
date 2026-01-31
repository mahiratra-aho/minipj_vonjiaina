from sqlalchemy.orm import Session
from sqlalchemy import text
from typing import List
from services.pharmacie_statuts_service import PharmacieStatusService

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
        point = f'POINT({longitude} {latitude})'
        
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
                (6371 * acos(cos(radians(:latitude)) * cos(radians(p.latitude)) * 
                 cos(radians(p.longitude) - radians(:longitude)) + 
                 sin(radians(:latitude)) * sin(radians(p.latitude)))) as distance,
                1000 as prix,  -- Prix fictif
                10 as quantite,  -- Quantité fictite
                :medicament_nom as nom_commercial,  -- Médicament recherché
                'comprimé' as forme,  -- Forme fictive
                '500mg' as dosage  -- Dosage fictif
            FROM pharmacies p
            WHERE 
                (6371 * acos(cos(radians(:latitude)) * cos(radians(p.latitude)) * 
                 cos(radians(p.longitude) - radians(:longitude)) + 
                 sin(radians(:latitude)) * sin(radians(p.latitude)))) <= :rayon_km
            ORDER BY distance ASC
            LIMIT 20
        """)
        
        result = db.execute(
            query, 
            {
                "medicament_nom": medicament_nom,
                "latitude": latitude,
                "longitude": longitude,
                "rayon_km": rayon_metres / 1000  # Convertir mètres en km
            }
        )
        
        pharmacies = []
        
        for row in result:
            pharmacie = dict(row._mapping)
            
            # CALCUL DU STATUT EN TEMPS RÉEL
            statut = PharmacieStatusService.get_status(
                type_pharmacie=pharmacie['type'],
                horaires=pharmacie['horaires']
            )
            
            pharmacie['statut'] = statut
            
            # Si prochaine ouverture demandée et pharmacie fermée
            if statut == "fermée":
                pharmacie['prochaine_ouverture'] = PharmacieStatusService.get_prochaine_ouverture(
                    pharmacie['horaires']
                )
            
            # Filtrer selon le statut demandé
            if filtre_statut:
                if filtre_statut == "garde" and statut == "garde":
                    pharmacies.append(pharmacie)
                elif filtre_statut == "ouverte" and statut in ["ouverte", "garde"]:
                    pharmacies.append(pharmacie)
            else:
                # Pas de filtre, tout afficher
                pharmacies.append(pharmacie)
        
        return pharmacies