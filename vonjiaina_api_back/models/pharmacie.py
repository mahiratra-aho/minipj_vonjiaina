from sqlalchemy import Column, Integer, String, Boolean, JSON, DateTime
from geoalchemy2 import Geography
from datetime import datetime, timezone
from app.database import Base

class Pharmacie(Base):
    __tablename__ = "pharmacies"
    
    id = Column(Integer, primary_key=True, index=True)
    nom = Column(String(255), nullable=False)
    adresse = Column(String(500))
    telephone = Column(String(20))
    email = Column(String(255))
    
    location = Column(
        Geography(geometry_type='POINT', srid=4326),
        nullable=False
    )
    
    horaires = Column(JSON)
    actif = Column(Boolean, default=True)
    
    created_at = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc)
    )
    updated_at = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc)
    )