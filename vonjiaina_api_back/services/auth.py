from sqlalchemy.orm import Session
from typing import Optional
from repositories.user_repository import UserRepository
from repositories.refresh_token_repository import RefreshTokenRepository
from repositories.journal_audit_repository import JournalAuditRepository
from utils.security import (
    verify_password,
    get_password_hash,
    create_access_token,
    generate_refresh_token_value,
    hash_refresh_token,
)
from models.user import User
from schemas.user import UserCreate
from datetime import datetime, timedelta, timezone

REFRESH_TOKEN_DAYS = 7

class AuthService:
    
    @staticmethod
    def authenticate_user(db: Session, email: str, password: str) -> Optional[User]:
        """Authentifier un utilisateur"""
        user = UserRepository.find_by_email(db, email)
        if not user:
            return None
        if not verify_password(password, user.hashed_password):
            return None
        return user
    
    @staticmethod
    def register_user(db: Session, user_data: UserCreate) -> User:
        """Enregistrer un nouvel utilisateur"""
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
    def create_token_for_user(db: Session, user: User, device_id: str = None, adresse_ip: str = None, user_agent: str = None) -> dict:
        """Créer access token et refresh token (stocke le hash du refresh token)"""
        access = create_access_token(data={"sub": user.email, "role": user.role}, device_id=device_id)

        # Générer et stocker refresh token
        refresh_value = generate_refresh_token_value()
        refresh_hash = hash_refresh_token(refresh_value)
        expires_at = datetime.now(timezone.utc) + timedelta(days=REFRESH_TOKEN_DAYS)

        RefreshTokenRepository.create(db, token_hash=refresh_hash, user_id=user.id, expires_at=expires_at, device_id=device_id)

        # Journaliser l'emission du token
        from repositories.journal_audit_repository import JournalAuditRepository
        JournalAuditRepository.create(db, user_id=user.id, action_type="token_issued", resource_id=None, adresse_ip=adresse_ip, user_agent=user_agent)

        return {
            "access_token": access,
            "refresh_token": refresh_value,
            "user": user,
        }

    @staticmethod
    def refresh_access_token(db: Session, refresh_token_value: str, device_id: str = None) -> dict:
        """Valider un refresh token, le révoquer (rotation) et renvoyer nouveaux tokens"""
        refresh_hash = hash_refresh_token(refresh_token_value)
        token = RefreshTokenRepository.find_by_hash(db, refresh_hash)

        if not token or token.revoked:
            raise ValueError("Refresh token invalide ou révoqué")

        # Vérifier expiration
        if token.expires_at:
            exp = token.expires_at
            # Certains SGBD (ex: SQLite tests) peuvent renvoyer des datetimes sans tzinfo
            if exp.tzinfo is None:
                exp = exp.replace(tzinfo=timezone.utc)
            if exp <= datetime.now(timezone.utc):
                raise ValueError("Refresh token expiré")

        # Rotation: révoquer l'ancien et en créer un nouveau
        RefreshTokenRepository.revoke(db, token)

        user = UserRepository.find_by_id(db, token.user_id)
        if not user:
            raise ValueError("Utilisateur introuvable pour le refresh token")

        # Journaliser le refresh
        from repositories.journal_audit_repository import JournalAuditRepository
        JournalAuditRepository.create(db, user_id=user.id, action_type="token_refreshed", resource_id=None)

        return AuthService.create_token_for_user(db, user, device_id=device_id)

    @staticmethod
    def revoke_refresh_token(db: Session, refresh_token_value: str, adresse_ip: str = None, user_agent: str = None):
        refresh_hash = hash_refresh_token(refresh_token_value)
        token = RefreshTokenRepository.find_by_hash(db, refresh_hash)
        if token:
            res = RefreshTokenRepository.revoke(db, token)
            from repositories.journal_audit_repository import JournalAuditRepository
            JournalAuditRepository.create(db, user_id=token.user_id, action_type="token_revoked", resource_id=str(token.id), adresse_ip=adresse_ip, user_agent=user_agent)
            return res
        return None