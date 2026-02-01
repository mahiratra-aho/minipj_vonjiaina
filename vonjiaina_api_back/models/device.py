from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey
from datetime import datetime, timezone
from app.database import Base

class Device(Base):
    __tablename__ = "devices"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    hardware_id = Column(String(255), nullable=False)
    name = Column(String(255), nullable=True)
    trusted = Column(Boolean, default=False)
    verification_code_hash = Column(String(255), nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    last_seen = Column(DateTime(timezone=True), nullable=True)
    verified_at = Column(DateTime(timezone=True), nullable=True)
