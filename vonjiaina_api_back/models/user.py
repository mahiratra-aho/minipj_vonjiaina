from sqlalchemy import Column, Integer, String, Boolean, DateTime
from datetime import datetime, timezone
from app.database import Base

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, nullable=False, index=True)
    nom = Column(String(255), nullable=False)
    hashed_password = Column(String(255), nullable=False)
    
    # Type d'utilisateur : "admin", "pharmacie", "user"
    role = Column(String(50), default="user")
    
    # Pour lier un utilisateur à une pharmacie
    pharmacie_id = Column(Integer, nullable=True)
    
    is_active = Column(Boolean, default=True)
    
    created_at = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc)
    )