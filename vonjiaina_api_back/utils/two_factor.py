import pyotp
import secrets
from typing import List


from utils.encryption import encrypt_value, decrypt_value


def generate_totp_secret() -> str:
    return pyotp.random_base32()


def get_otpauth_url(secret: str, user_email: str, issuer: str = "Vonjiaina") -> str:
    return pyotp.totp.TOTP(secret).provisioning_uri(name=user_email, issuer_name=issuer)


def verify_totp_code(secret: str, code: str) -> bool:
    try:
        t = pyotp.TOTP(secret)
        return t.verify(code, valid_window=1)
    except Exception:
        return False


def generate_backup_codes(count: int = 8) -> List[str]:
    codes = []
    for _ in range(count):
        codes.append(secrets.token_urlsafe(8))
    return codes


# helpers to encrypt/decrypt stored secrets

def encrypt_totp_secret(secret: str) -> str:
    return encrypt_value(secret)


def decrypt_totp_secret(encrypted: str) -> str:
    return decrypt_value(encrypted)
