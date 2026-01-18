from sqlalchemy import Column, Integer, String, Text, DECIMAL, Boolean, TIMESTAMP
from sqlalchemy.sql import func
from app.database import Base

class Pharmacy(Base):
    __tablename__ = "pharmacies"
    
    id = Column(Integer, primary_key=True, index=True)
    nom = Column(String(255), nullable=False, index=True)
    adresse = Column(Text, nullable=False)
    telephone = Column(String(100))
    latitude = Column(DECIMAL(10, 8), nullable=False)
    longitude = Column(DECIMAL(11, 8), nullable=False)
    statut = Column(String(50), default='normal', index=True)
    quartier = Column(String(100), index=True)
    horaires = Column(Text)
    email = Column(String(255))
    site_web = Column(String(255))
    verified = Column(Boolean, default=False)
    created_at = Column(TIMESTAMP, server_default=func.now())
    updated_at = Column(TIMESTAMP, server_default=func.now(), onupdate=func.now())
    
    def __repr__(self):
        return f"<Pharmacy(id={self.id}, nom='{self.nom}', quartier='{self.quartier}')>"
    
    def to_dict(self):
        return {
            "id": self.id,
            "nom": self.nom,
            "adresse": self.adresse,
            "telephone": self.telephone,
            "latitude": float(self.latitude),
            "longitude": float(self.longitude),
            "statut": self.statut,
            "quartier": self.quartier,
            "horaires": self.horaires,
            "email": self.email,
            "site_web": self.site_web,
            "verified": self.verified,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None
        }
