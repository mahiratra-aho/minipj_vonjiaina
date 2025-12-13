from pydantic import BaseModel
from typing import Optional

class MedicamentBase(BaseModel):
    nom_commercial: str
    dci: Optional[str] = None
    laboratoire: Optional[str] = None
    forme: Optional[str] = None
    dosage: Optional[str] = None
    description: Optional[str] = None

class MedicamentCreate(MedicamentBase):
    pass

class MedicamentUpdate(BaseModel):
    nom_commercial: Optional[str] = None
    dci: Optional[str] = None
    laboratoire: Optional[str] = None
    forme: Optional[str] = None
    dosage: Optional[str] = None
    description: Optional[str] = None

class MedicamentResponse(MedicamentBase):
    id: int
    
    class Config:
        from_attributes = True