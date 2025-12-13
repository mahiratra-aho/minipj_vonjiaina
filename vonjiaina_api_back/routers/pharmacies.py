from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from services.search_service import SearchService

router = APIRouter(prefix="/pharmacies", tags=["Pharmacies"])

@router.get("/search")
async def rechercher_pharmacies(
    medicament: str = Query(..., min_length=2, description="Nom du médicament recherché"),
    latitude: float = Query(..., ge=-90, le=90, description="Latitude de l'utilisateur"),
    longitude: float = Query(..., ge=-180, le=180, description="Longitude de l'utilisateur"),
    rayon_km: float = Query(5.0, ge=0.1, le=50, description="Rayon de recherche en km"),
    db: Session = Depends(get_db)
):
    """
    Rechercher les pharmacies ayant un médicament en stock
    
    Retourne les pharmacies triées par distance (la plus proche en premier)
    
    Paramètres:
    - medicament: Nom du médicament (ex: "Doliprane", "Paracétamol")
    - latitude: Position GPS de l'utilisateur (ex: -18.9137)
    - longitude: Position GPS de l'utilisateur (ex: 47.5236)
    - rayon_km: Distance maximale de recherche en kilomètres (défaut: 5km)
    
    Retourne:
    - Liste des pharmacies avec stock disponible, triées par distance
    """
    try:
        pharmacies = SearchService.rechercher_pharmacies(
            db=db,
            medicament=medicament,
            latitude=latitude,
            longitude=longitude,
            rayon_km=rayon_km
        )
        
        if not pharmacies:
            return {
                "message": f"Aucune pharmacie trouvée avec '{medicament}' dans un rayon de {rayon_km}km",
                "resultats": []
            }
        
        return {
            "message": f"{len(pharmacies)} pharmacie(s) trouvée(s)",
            "rayon_recherche_km": rayon_km,
            "medicament_recherche": medicament,
            "position_utilisateur": {
                "latitude": latitude,
                "longitude": longitude
            },
            "resultats": pharmacies
        }
        
    except Exception as e:
        print(f"Erreur de recherche: {e}")
        import traceback
        traceback.print_exc()
        raise HTTPException(
            status_code=500, 
            detail=f"Erreur lors de la recherche: {str(e)}"
        )