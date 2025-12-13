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
                p.type,
                p.horaires,
                ST_Y(p.location::geometry) as latitude,
                ST_X(p.location::geometry) as longitude,
                ST_Distance(
                    p.location,
                    ST_GeogFromText('SRID=4326;{point}')
                ) as distance,
                s.prix,
                s.quantite,
                m.nom_commercial,
                m.forme,
                m.dosage
            FROM pharmacies p
            INNER JOIN stocks s ON p.id = s.pharmacie_id
            INNER JOIN medicaments m ON s.medicament_id = m.id
            WHERE 
                m.nom_commercial ILIKE :medicament
                AND s.quantite > 0
                AND p.actif = true
                AND ST_DWithin(
                    p.location,
                    ST_GeogFromText('SRID=4326;{point}'),
                    :rayon
                )
            ORDER BY distance ASC
        """)
        
        result = db.execute(
            query, 
            {
                "medicament": f"%{medicament_nom}%",
                "rayon": rayon_metres
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