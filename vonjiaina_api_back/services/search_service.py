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
        rayon_km: float = 5.0,
        filtre_statut: str = None  # "garde", "ouverte", ou None
    ) -> List[dict]:
        """
        Service de recherche avec filtre de statut
        """
        rayon_metres = int(rayon_km * 1000)
        
        pharmacies = PharmacieRepository.search_with_medicament(
            db=db,
            medicament_nom=medicament,
            latitude=latitude,
            longitude=longitude,
            rayon_metres=rayon_metres,
            filtre_statut=filtre_statut
        )
        
        # Enrichir les données
        for pharmacie in pharmacies:
            pharmacie['distance_km'] = round(pharmacie['distance'] / 1000, 2)
            if pharmacie.get('prix'):
                pharmacie['prix'] = round(pharmacie['prix'], 0)
        
        return pharmacies