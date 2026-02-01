import os
import base64
import hashlib
from cryptography.fernet import Fernet
from app.config import get_settings

settings = get_settings()


def _derive_key_from_secret(secret: str) -> bytes:
    # Derive a 32-byte key from SECRET_KEY using SHA-256 and base64-url-safe encode
    h = hashlib.sha256(secret.encode()).digest()
    return base64.urlsafe_b64encode(h)


def get_fernet() -> Fernet:
    key = os.environ.get("TOTP_ENCRYPTION_KEY") or getattr(settings, "TOTP_ENCRYPTION_KEY", None)
    if key:
        # accept raw base64 key or pass-through
        try:
            # if key is 44-char urlsafe base64 return as is
            k = key.encode()
            return Fernet(k)
        except Exception:
            pass
    # fallback derive from SECRET_KEY (development only)
    k = _derive_key_from_secret(settings.SECRET_KEY)
    return Fernet(k)


def encrypt_value(value: str) -> str:
    f = get_fernet()
    token = f.encrypt(value.encode())
    return token.decode()


def decrypt_value(token: str) -> str:
    f = get_fernet()
    p = f.decrypt(token.encode())
    return p.decode()
