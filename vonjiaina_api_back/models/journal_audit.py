from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from datetime import datetime, timezone
from app.database import Base

class JournalAudit(Base):
    __tablename__ = "journal_audit"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True, index=True)
    action_type = Column(String(100), nullable=False)
    resource_id = Column(String(255), nullable=True)
    adresse_ip = Column(String(100), nullable=True)
    user_agent = Column(String(512), nullable=True)
    horodatage_precis = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
