from sqlalchemy.orm import Session
from typing import Optional
from repositories.user_repository import UserRepository
from utils.security import verify_password, get_password_hash, create_access_token
from models.user import User
from schemas.user import UserCreate

class AuthService:
    
    @staticmethod
    def authenticate_user(db: Session, email: str, password: str) -> Optional[User]:
        "Authentifier un utilisateur"
        user = UserRepository.find_by_email(db, email)
        if not user:
            return None
        if not verify_password(password, user.hashed_password):
            return None
        return user
    
    @staticmethod
    def register_user(db: Session, user_data: UserCreate) -> User:
        "Enregistrer un nouvel utilisateur"
        # Vérifier si l'email existe déjà
        existing_user = UserRepository.find_by_email(db, user_data.email)
        if existing_user:
            raise ValueError("Cet email est déjà utilisé")
        
        # Hasher le mot de passe
        hashed_password = get_password_hash(user_data.password)
        
        # Créer l'utilisateur
        user = UserRepository.create(
            db=db,
            email=user_data.email,
            nom=user_data.nom,
            hashed_password=hashed_password,
            role=user_data.role,
            pharmacie_id=user_data.pharmacie_id
        )
        
        return user
    
    @staticmethod
    def create_token_for_user(user: User) -> str:
        "Créer un token JWT pour un utilisateur"
        return create_access_token(data={"sub": user.email, "role": user.role})