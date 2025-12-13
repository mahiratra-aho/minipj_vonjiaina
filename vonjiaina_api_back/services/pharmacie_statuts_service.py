from datetime import datetime
from typing import Dict, Optional
import pytz

class PharmacieStatusService:
    
    # Jours de la semaine en français
    JOURS = {
        0: "lundi",
        1: "mardi",
        2: "mercredi",
        3: "jeudi",
        4: "vendredi",
        5: "samedi",
        6: "dimanche"
    }
    
    @staticmethod
    def get_status(type_pharmacie: str, horaires: Optional[Dict]) -> str:
        """
        Détermine l'état actuel d'une pharmacie
        
        Args:
            type_pharmacie: "normale" ou "garde"
            horaires: Dictionnaire des horaires d'ouverture
        
        Returns:
            "garde", "ouverte", ou "fermée"
        """
        # Si c'est une pharmacie de garde, elle est toujours "garde"
        if type_pharmacie == "garde":
            return "garde"
        
        # Si pas d'horaires définis, considérer comme fermée
        if not horaires:
            return "fermée"
        
        # Obtenir l'heure actuelle à Madagascar (UTC+3)
        tz_madagascar = pytz.timezone('Indian/Antananarivo')
        maintenant = datetime.now(tz_madagascar)
        
        # Obtenir le jour de la semaine (0 = lundi, 6 = dimanche)
        jour_semaine = maintenant.weekday()
        nom_jour = PharmacieStatusService.JOURS.get(jour_semaine)
        
        # Vérifier si la pharmacie est ouverte aujourd'hui
        if nom_jour not in horaires:
            return "fermée"
        
        horaire_jour = horaires[nom_jour]
        
        # Gérer différents formats d'horaires
        # Format 1: "8h-18h"
        if isinstance(horaire_jour, str):
            return PharmacieStatusService._check_horaire_string(
                horaire_jour, 
                maintenant
            )
        
        # Format 2: {"ouverture": "08:00", "fermeture": "18:00"}
        elif isinstance(horaire_jour, dict):
            return PharmacieStatusService._check_horaire_dict(
                horaire_jour, 
                maintenant
            )
        
        return "fermée"
    
    @staticmethod
    def _check_horaire_string(horaire: str, maintenant: datetime) -> str:
        """
        Vérifier l'horaire au format "8h-18h"
        """
        try:
            # Parser "8h-18h" ou "8h30-18h30"
            parties = horaire.lower().replace(' ', '').split('-')
            if len(parties) != 2:
                return "fermée"
            
            ouverture_str, fermeture_str = parties
            
            # Convertir en heures
            ouverture = PharmacieStatusService._parse_heure(ouverture_str)
            fermeture = PharmacieStatusService._parse_heure(fermeture_str)
            
            heure_actuelle = maintenant.hour + maintenant.minute / 60.0
            
            # Vérifier si c'est dans la plage horaire
            if ouverture <= heure_actuelle < fermeture:
                return "ouverte"
            else:
                return "fermée"
                
        except Exception as e:
            print(f"Erreur parsing horaire: {e}")
            return "fermée"
    
    @staticmethod
    def _check_horaire_dict(horaire: Dict, maintenant: datetime) -> str:
        """
        Vérifier l'horaire au format {"ouverture": "08:00", "fermeture": "18:00"}
        """
        try:
            ouverture_str = horaire.get('ouverture', '')
            fermeture_str = horaire.get('fermeture', '')
            
            if not ouverture_str or not fermeture_str:
                return "fermée"
            
            # Convertir "08:00" en heures décimales
            ouverture = PharmacieStatusService._parse_heure_hhmm(ouverture_str)
            fermeture = PharmacieStatusService._parse_heure_hhmm(fermeture_str)
            
            heure_actuelle = maintenant.hour + maintenant.minute / 60.0
            
            if ouverture <= heure_actuelle < fermeture:
                return "ouverte"
            else:
                return "fermée"
                
        except Exception as e:
            print(f"Erreur parsing horaire dict: {e}")
            return "fermée"
    
    @staticmethod
    def _parse_heure(heure_str: str) -> float:
        """
        Convertir "8h" ou "8h30" en heures décimales
        Exemple: "8h30" -> 8.5
        """
        heure_str = heure_str.replace('h', ':')
        parties = heure_str.split(':')
        
        heures = int(parties[0])
        minutes = int(parties[1]) if len(parties) > 1 else 0
        
        return heures + minutes / 60.0
    
    @staticmethod
    def _parse_heure_hhmm(heure_str: str) -> float:
        """
        Convertir "08:00" en heures décimales
        Exemple: "08:30" -> 8.5
        """
        parties = heure_str.split(':')
        
        heures = int(parties[0])
        minutes = int(parties[1]) if len(parties) > 1 else 0
        
        return heures + minutes / 60.0
    
    @staticmethod
    def get_prochaine_ouverture(horaires: Optional[Dict]) -> Optional[str]:
        """
        Obtenir la prochaine heure d'ouverture
        """
        if not horaires:
            return None
        
        tz_madagascar = pytz.timezone('Indian/Antananarivo')
        maintenant = datetime.now(tz_madagascar)
        jour_semaine = maintenant.weekday()
        
        # Chercher dans les 7 prochains jours
        for i in range(7):
            jour_index = (jour_semaine + i) % 7
            nom_jour = PharmacieStatusService.JOURS.get(jour_index)
            
            if nom_jour in horaires:
                horaire = horaires[nom_jour]
                
                if isinstance(horaire, str):
                    ouverture = horaire.split('-')[0] if '-' in horaire else None
                elif isinstance(horaire, dict):
                    ouverture = horaire.get('ouverture')
                else:
                    continue
                
                if ouverture:
                    if i == 0:
                        return f"Aujourd'hui à {ouverture}"
                    elif i == 1:
                        return f"Demain à {ouverture}"
                    else:
                        return f"{nom_jour.capitalize()} à {ouverture}"
        
        return None