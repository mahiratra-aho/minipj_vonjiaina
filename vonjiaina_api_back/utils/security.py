from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta, timezone
from app.config import get_settings

settings = get_settings()

# Configuration du hachage de mot de passe
# Use pbkdf2_sha256 by default (avoids bcrypt 72-byte limitation in tests)
pwd_context = CryptContext(schemes=["pbkdf2_sha256", "bcrypt"], deprecated="auto")

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Vérifier un mot de passe"""
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    """Hasher un mot de passe"""
    return pwd_context.hash(password)

def create_access_token(data: dict, expires_delta: timedelta = None, device_id: str = None) -> str:
    """Créer un token JWT avec claims standards"""
    to_encode = data.copy()

    now = datetime.now(timezone.utc)
    if expires_delta:
        expire = now + expires_delta
    else:
        expire = now + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)

    # Standard claims
    to_encode.update({
        "exp": expire,
        "iat": now,
        "iss": settings.PROJECT_NAME,
    })

    if device_id:
        to_encode["device_id"] = device_id

    encoded_jwt = jwt.encode(
        to_encode,
        settings.SECRET_KEY,
        algorithm=settings.ALGORITHM,
    )
    return encoded_jwt

from fastapi import HTTPException, status

def verify_token(token: str) -> dict:
    """Vérifier et décoder un token JWT, lève une exception HTTP si invalide"""
    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM]
        )
        return payload
    except JWTError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token invalide ou expiré",
            headers={"WWW-Authenticate": "Bearer"},
        ) from exc


# --- Refresh token helpers ---
import secrets
import hashlib
import hmac


def generate_refresh_token_value() -> str:
    """Générer un refresh token sécurisé côté serveur (valeur brute à transmettre au client)"""
    return secrets.token_urlsafe(64)


def hash_refresh_token(token_value: str) -> str:
    """Hash simple (SHA-256) pour stockage côté serveur"""
    return hashlib.sha256(token_value.encode()).hexdigest()


def verify_refresh_token_hash(token_value: str, token_hash: str) -> bool:
    """Comparer de manière constante la valeur et le hash"""
    computed = hashlib.sha256(token_value.encode()).hexdigest()
    return hmac.compare_digest(computed, token_hash)