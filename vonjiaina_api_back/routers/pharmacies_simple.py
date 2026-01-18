from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import Optional
from app.database import get_db
from app.models import Pharmacy
from sqlalchemy import text

router = APIRouter(prefix="/pharmacies", tags=["Pharmacies"])

@router.get("/search")
async def rechercher_pharmacies(
    medicament: str = Query(..., min_length=2, description="Nom du médicament"),
    latitude: float = Query(..., ge=-90, le=90, description="Latitude"),
    longitude: float = Query(..., ge=-180, le=180, description="Longitude"),
    rayon_km: float = Query(5.0, ge=0.1, le=50, description="Rayon en km"),
    statut: Optional[str] = Query(
        None, 
        description="Filtre: 'garde' (pharmacies de garde) ou 'ouverte' (actuellement ouvertes)"
    ),
    db: Session = Depends(get_db)
):
    """
    Rechercher les pharmacies avec calcul automatique du statut
    """
    try:
        # Requête SQL pour trouver les pharmacies dans le rayon
        query = text("""
            SELECT *, 
                   (6371 * acos(
                       cos(radians(:lat)) * cos(radians(latitude)) * 
                       cos(radians(longitude) - radians(:lon)) + 
                       sin(radians(:lat)) * sin(radians(latitude))
                   )) as distance_km
            FROM pharmacies 
            WHERE (6371 * acos(
                       cos(radians(:lat)) * cos(radians(latitude)) * 
                       cos(radians(longitude) - radians(:lon)) + 
                       sin(radians(:lat)) * sin(radians(latitude))
                   )) <= :rayon
            ORDER BY distance_km
        """)
        
        result = db.execute(query, {
            'lat': latitude,
            'lon': longitude,
            'rayon': rayon_km
        })
        
        pharmacies = []
        for row in result:
            pharmacy_data = {
                "id": row.id,
                "nom": row.nom,
                "adresse": row.adresse,
                "telephone": row.telephone,
                "latitude": float(row.latitude),
                "longitude": float(row.longitude),
                "statut": row.statut,
                "quartier": row.quartier,
                "horaires": row.horaires,
                "email": row.email,
                "site_web": row.site_web,
                "verified": row.verified,
                "distance_km": round(float(row.distance_km), 2),
                "medicament_disponible": True  # Simulation pour l'exemple
            }
            
            # Déterminer le statut actuel
            if row.statut == "garde":
                statut_actuel = "garde"
            elif row.horaires and "24h" in row.horaires.lower():
                statut_actuel = "ouverte"
            else:
                # Logique simple: 8h-20h
                import datetime
                heure_actuelle = datetime.datetime.now().hour
                statut_actuel = "ouverte" if 8 <= heure_actuelle <= 20 else "fermée"
            
            pharmacy_data["statut_actuel"] = statut_actuel
            
            # Filtrer selon le statut demandé
            if statut:
                if statut == "garde" and statut_actuel != "garde":
                    continue
                elif statut == "ouverte" and statut_actuel != "ouverte":
                    continue
            
            pharmacies.append(pharmacy_data)
        
        if not pharmacies:
            message = "Aucune pharmacie trouvée"
            if statut == "garde":
                message = "Aucune pharmacie de garde trouvée"
            elif statut == "ouverte":
                message = "Aucune pharmacie ouverte actuellement"
            
            return {
                "message": message,
                "resultats": []
            }
        
        return {
            "message": f"{len(pharmacies)} pharmacie(s) trouvée(s) pour '{medicament}'",
            "rayon_recherche_km": rayon_km,
            "medicament_recherche": medicament,
            "filtre_statut": statut,
            "position_utilisateur": {
                "latitude": latitude,
                "longitude": longitude
            },
            "resultats": pharmacies
        }
        
    except Exception as e:
        print(f"Erreur: {e}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/proximity")
async def pharmacies_proches(
    latitude: float = Query(..., ge=-90, le=90, description="Latitude"),
    longitude: float = Query(..., ge=-180, le=180, description="Longitude"),
    rayon_km: float = Query(5.0, ge=0.1, le=50, description="Rayon en km"),
    db: Session = Depends(get_db)
):
    """
    Obtenir les pharmacies les plus proches (sans recherche de médicament)
    """
    try:
        query = text("""
            SELECT *, 
                   (6371 * acos(
                       cos(radians(:lat)) * cos(radians(latitude)) * 
                       cos(radians(longitude) - radians(:lon)) + 
                       sin(radians(:lat)) * sin(radians(latitude))
                   )) as distance_km
            FROM pharmacies 
            WHERE (6371 * acos(
                       cos(radians(:lat)) * cos(radians(latitude)) * 
                       cos(radians(longitude) - radians(:lon)) + 
                       sin(radians(:lat)) * sin(radians(latitude))
                   )) <= :rayon
            ORDER BY distance_km
            LIMIT 20
        """)
        
        result = db.execute(query, {
            'lat': latitude,
            'lon': longitude,
            'rayon': rayon_km
        })
        
        pharmacies = []
        for row in result:
            pharmacy_data = {
                "id": row.id,
                "nom": row.nom,
                "adresse": row.adresse,
                "telephone": row.telephone,
                "latitude": float(row.latitude),
                "longitude": float(row.longitude),
                "statut": row.statut,
                "quartier": row.quartier,
                "horaires": row.horaires,
                "email": row.email,
                "site_web": row.site_web,
                "verified": row.verified,
                "distance_km": round(float(row.distance_km), 2)
            }
            pharmacies.append(pharmacy_data)
        
        return {
            "message": f"{len(pharmacies)} pharmacie(s) trouvée(s)",
            "rayon_recherche_km": rayon_km,
            "position_utilisateur": {
                "latitude": latitude,
                "longitude": longitude
            },
            "resultats": pharmacies
        }
        
    except Exception as e:
        print(f"Erreur: {e}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))
