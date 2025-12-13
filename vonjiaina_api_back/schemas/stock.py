from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class StockBase(BaseModel):
    pharmacie_id: int
    medicament_id: int
    quantite: int = Field(ge=0, description="Quantité en stock")
    prix: Optional[float] = Field(None, ge=0, description="Prix en Ariary")

class StockCreate(StockBase):
    pass

class StockUpdate(BaseModel):
    quantite: Optional[int] = Field(None, ge=0)
    prix: Optional[float] = Field(None, ge=0)

class StockResponse(StockBase):
    id: int
    date_maj: datetime
    
    class Config:
        from_attributes = True