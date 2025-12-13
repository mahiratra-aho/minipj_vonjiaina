from sqlalchemy.orm import Session
from typing import List
from repositories.pharmacie_repository import PharmacieRepository

class SearchService:
    
    @staticmethod
    def rechercher_pharmacies(
        db: Session,
        medicament: str,
        latitude: float,
        longitude: float,
        rayon_km: float = 5.0
    ) -> List[dict]:
        """
        Service de recherche des pharmacies
        Convertit le rayon de km en mètres
        """
        rayon_metres = int(rayon_km * 1000)
        
        pharmacies = PharmacieRepository.search_with_medicament(
            db=db,
            medicament_nom=medicament,
            latitude=latitude,
            longitude=longitude,
            rayon_metres=rayon_metres
        )
        
        # Enrichir les données
        for pharmacie in pharmacies:
            # Convertir distance en km avec 2 décimales
            pharmacie['distance_km'] = round(pharmacie['distance'] / 1000, 2)
            
            # Arrondir le prix
            if pharmacie.get('prix'):
                pharmacie['prix'] = round(pharmacie['prix'], 0)
        
        return pharmacies