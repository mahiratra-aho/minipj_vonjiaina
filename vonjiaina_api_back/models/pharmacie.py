from sqlalchemy import Column, Integer, String, Boolean, DateTime, DECIMAL
from datetime import datetime, timezone
from app.database import Base

class Pharmacie(Base):
    __tablename__ = "pharmacies"
    
    id = Column(Integer, primary_key=True, index=True)
    nom = Column(String(255), nullable=False)
    adresse = Column(String(500))
    telephone = Column(String(20))
    email = Column(String(255))
    
    # Coordonnées GPS séparées
    latitude = Column(DECIMAL(10, 8), nullable=False)
    longitude = Column(DECIMAL(11, 8), nullable=False)
    
    # Statut: "normal" ou "garde"
    statut = Column(String(50), default="normal")
    
    # Quartier
    quartier = Column(String(100))
    
    # Horaires (texte simple)
    horaires = Column(String(200))
    
    # Vérification
    verified = Column(Boolean, default=True)
    
    # Actif
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




# from sqlalchemy import Column, Integer, String, Boolean, JSON, DateTime
# from geoalchemy2 import Geography
# from datetime import datetime, timezone
# from app.database import Base

# class Pharmacie(Base):
#     __tablename__ = "pharmacies"
    
#     id = Column(Integer, primary_key=True, index=True)
#     nom = Column(String(255), nullable=False)
#     adresse = Column(String(500))
#     telephone = Column(String(20))
#     email = Column(String(255))
    
#     location = Column(
#         Geography(geometry_type='POINT', srid=4326),
#         nullable=False
#     )
    
#     # Horaires d'ouverture par jour
#     # Format JSON: {"lundi": {"ouverture": "08:00", "fermeture": "18:00"}, ...}
#     horaires = Column(JSON)
    
#     actif = Column(Boolean, default=True)
    
#     # Type: "normale" ou "garde"
#     type = Column(String(50), default="normale")
    
#     created_at = Column(
#         DateTime(timezone=True),
#         default=lambda: datetime.now(timezone.utc)
#     )
#     updated_at = Column(
#         DateTime(timezone=True),
#         default=lambda: datetime.now(timezone.utc),
#         onupdate=lambda: datetime.now(timezone.utc)
#     )