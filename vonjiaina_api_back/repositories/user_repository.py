from sqlalchemy.orm import Session
from typing import Optional
from models.user import User

class UserRepository:
    
    @staticmethod
    def create(db: Session, **kwargs) -> User:
        """Créer un utilisateur"""
        user = User(**kwargs)
        db.add(user)
        db.commit()
        db.refresh(user)
        return user
    
    @staticmethod
    def find_by_email(db: Session, email: str) -> Optional[User]:
        """Trouver un utilisateur par email"""
        return db.query(User).filter(User.email == email).first()
    
    @staticmethod
    def find_by_id(db: Session, user_id: int) -> Optional[User]:
        """Trouver un utilisateur par ID"""
        return db.query(User).filter(User.id == user_id).first()
# Helper to update TOTP fields (module-level for simplicity)
def update_totp(db, user_id: int, secret: str = None, enabled: bool = False):
    from models.user import User
    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        return None
    user.totp_secret = secret
    user.totp_enabled = enabled
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

# attach to class for backwards compatibility
UserRepository.update_totp = staticmethod(update_totp)
