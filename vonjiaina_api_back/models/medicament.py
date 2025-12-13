from sqlalchemy import Column, Integer, String, Text, DateTime
from datetime import datetime, timezone
from app.database import Base

class Medicament(Base):
    __tablename__ = "medicaments"
    
    id = Column(Integer, primary_key=True, index=True)
    nom_commercial = Column(String(255), nullable=False, index=True)
    dci = Column(String(255), index=True)
    laboratoire = Column(String(255))
    forme = Column(String(100))
    dosage = Column(String(50))
    description = Column(Text)
    created_at = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc)
    )