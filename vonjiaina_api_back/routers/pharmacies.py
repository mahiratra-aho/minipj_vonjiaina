from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import Optional
from app.database import get_db
from services.search_service import SearchService

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
    🔍 Rechercher les pharmacies avec calcul automatique du statut
    
    Paramètres:
    - statut: 
        * "garde" : uniquement les pharmacies de garde
        * "ouverte" : uniquement les pharmacies actuellement ouvertes
        * null : toutes les pharmacies (avec leur statut)
    
    Réponse inclut:
    - statut: "garde", "ouverte", ou "fermée"
    - prochaine_ouverture: si fermée, indique quand elle ouvre
    """
    try:
        pharmacies = SearchService.rechercher_pharmacies(
            db=db,
            medicament=medicament,
            latitude=latitude,
            longitude=longitude,
            rayon_km=rayon_km,
            filtre_statut=statut
        )
        
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
            "message": f"{len(pharmacies)} pharmacie(s) trouvée(s)",
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