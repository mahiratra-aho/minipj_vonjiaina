from sqlalchemy.orm import Session
from sqlalchemy import text
from typing import List, Dict, Optional
from math import radians, cos, sin, asin, sqrt
import datetime

class SearchService:
    
    @staticmethod
    def calculate_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """
        Calcule la distance en km entre deux points GPS
        """
        # Convertir en radians
        lat1, lon1, lat2, lon2 = map(radians, [lat1, lon1, lat2, lon2])
        
        # Formule Haversine
        dlat = lat2 - lat1
        dlon = lon2 - lon1
        a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
        c = 2 * asin(sqrt(a))
        km = 6371 * c
        
        return round(km, 2)
    
    @staticmethod
    def est_pharmacie_ouverte(horaires: str, statut: str) -> bool:
        """
        Vérifie si une pharmacie est actuellement ouverte
        """
        if statut == "24h":
            return True
        elif statut == "garde":
            return True
        
        if not horaires:
            return False
            
        # Logique simple pour l'ouverture (peut être améliorée)
        maintenant = datetime.datetime.now()
        heure_actuelle = maintenant.hour
        
        # Si les horaires contiennent "24h" ou "24h/24"
        if "24h" in horaires.lower():
            return True
            
        # Logique basique: 8h-20h pour la plupart des pharmacies
        if "08h00" in horaires or "8h" in horaires:
            return 8 <= heure_actuelle <= 20
            
        return False
    
    @staticmethod
    def rechercher_pharmacies(
        db: Session,
        medicament: str,
        latitude: float,
        longitude: float,
        rayon_km: float = 5.0,
        filtre_statut: Optional[str] = None
    ) -> List[Dict]:
        """
        Recherche les pharmacies dans un rayon donné
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
                HAVING distance_km <= :rayon
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
                    "distance_km": round(float(row.distance_km), 2)
                }
                
                # Déterminer le statut actuel
                est_ouverte = SearchService.est_pharmacie_ouverte(row.horaires, row.statut)
                
                if row.statut == "garde":
                    statut_actuel = "garde"
                elif est_ouverte:
                    statut_actuel = "ouverte"
                else:
                    statut_actuel = "fermée"
                
                pharmacy_data["statut_actuel"] = statut_actuel
                
                # Filtrer selon le statut demandé
                if filtre_statut:
                    if filtre_statut == "garde" and statut_actuel != "garde":
                        continue
                    elif filtre_statut == "ouverte" and statut_actuel != "ouverte":
                        continue
                
                pharmacies.append(pharmacy_data)
            
            return pharmacies
            
        except Exception as e:
            print(f"Erreur dans la recherche: {e}")
            raise e
