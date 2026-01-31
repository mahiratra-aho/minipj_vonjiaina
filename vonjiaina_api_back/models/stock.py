from sqlalchemy import Column, Integer, Float, ForeignKey, DateTime
from datetime import datetime, timezone
from app.database import Base

class Stock(Base):
    __tablename__ = "stocks"
    
    id = Column(Integer, primary_key=True, index=True)
    pharmacie_id = Column(Integer, ForeignKey("pharmacies.id"), nullable=False)
    medicament_id = Column(Integer, ForeignKey("medicaments.id"), nullable=False)
    quantite = Column(Integer, nullable=False, default=0)
    prix = Column(Float)
    
    date_maj = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc)
    )