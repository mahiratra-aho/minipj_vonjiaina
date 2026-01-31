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