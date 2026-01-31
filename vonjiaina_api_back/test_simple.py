#!/usr/bin/env python3

import sys
sys.path.append('.')

from sqlalchemy.orm import Session
from sqlalchemy import text
from app.database import SessionLocal

def test_simple_query():
    db = SessionLocal()
    try:
        query = text("""
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
                1000 as prix,
                10 as quantite,
                :medicament_nom as nom_commercial,
                'comprimé' as forme,
                '500mg' as dosage
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
                "medicament_nom": "doliprane",
                "latitude": -18.9363201,
                "longitude": 47.4829453,
                "rayon_km": 10
            }
        )
        
        pharmacies = []
        for row in result:
            pharmacie = dict(row._mapping)
            pharmacies.append(pharmacie)
        
        print(f"Trouvé {len(pharmacies)} pharmacies")
        for p in pharmacies[:3]:
            print(f"- {p['nom']} à {p['distance']:.2f} km")
        
        return pharmacies
        
    except Exception as e:
        print(f"Erreur: {e}")
        import traceback
        traceback.print_exc()
        return []
    finally:
        db.close()

if __name__ == "__main__":
    test_simple_query()
