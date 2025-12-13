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
        rayon_metres: int = 5000
    ) -> List[dict]:
        """
        Rechercher les pharmacies ayant un médicament en stock
        dans un certain rayon, triées par distance
        """
        point = f'POINT({longitude} {latitude})'
        
        query = text(f"""
            SELECT 
                p.id,
                p.nom,
                p.adresse,
                p.telephone,
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
        
        return [dict(row._mapping) for row in result]