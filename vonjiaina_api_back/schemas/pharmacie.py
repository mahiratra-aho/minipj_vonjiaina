from pydantic import BaseModel, EmailStr, field_validator
from typing import Optional, Dict
from datetime import datetime

# Schéma de base
class PharmacieBase(BaseModel):
    nom: str
    adresse: Optional[str] = None
    telephone: Optional[str] = None
    email: Optional[EmailStr] = None
    latitude: float
    longitude: float
    horaires: Optional[Dict] = None

# Pour la création
class PharmacieCreate(PharmacieBase):
    pass

# Pour la mise à jour
class PharmacieUpdate(BaseModel):
    nom: Optional[str] = None
    adresse: Optional[str] = None
    telephone: Optional[str] = None
    email: Optional[EmailStr] = None
    horaires: Optional[Dict] = None

# Pour la réponse simple (dans la recherche)
class PharmacieResponse(BaseModel):
    id: int
    nom: str
    adresse: Optional[str]
    telephone: Optional[str]
    latitude: float
    longitude: float
    distance: Optional[float] = None  # en mètres
    
    class Config:
        from_attributes = True

# Pour la réponse détaillée (endpoint individuel)
class PharmacieDetailResponse(BaseModel):
    id: int
    nom: str
    adresse: Optional[str]
    telephone: Optional[str]
    email: Optional[EmailStr]
    latitude: float
    longitude: float
    horaires: Optional[Dict]
    actif: bool
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True