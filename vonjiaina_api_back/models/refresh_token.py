from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey
from datetime import datetime, timezone
from app.database import Base

class RefreshToken(Base):
    __tablename__ = "refresh_tokens"

    id = Column(Integer, primary_key=True, index=True)
    token_hash = Column(String(255), nullable=False, unique=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    device_id = Column(String(255), nullable=True)
    revoked = Column(Boolean, default=False)
    created_at = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc)
    )
    expires_at = Column(DateTime(timezone=True), nullable=True)
