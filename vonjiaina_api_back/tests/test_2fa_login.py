import os
# Force an isolated SQLite test database for these tests to avoid schema mismatch
os.environ.setdefault('DATABASE_URL', 'sqlite:////tmp/test_2fa.db')

from fastapi.testclient import TestClient
from app.main import app
from repositories.user_repository import UserRepository
from utils.security import create_access_token, get_password_hash
import pyotp

client = TestClient(app)


def test_2fa_challenge_and_complete():
    from app.database import SessionLocal, Base, engine
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    # create user with 2FA enabled (unique email)
    import uuid
    email = f"bob+{uuid.uuid4().hex}@example.com"
    secret = pyotp.random_base32()
    from utils.encryption import encrypt_value
    enc = encrypt_value(secret)
    user = UserRepository.create(db, email=email, nom="Bob", hashed_password=get_password_hash("secret"), role="user")
    UserRepository.update_totp(db, user.id, secret=enc, enabled=True)

    # challenge
    resp = client.post('/api/v1/auth/2fa/challenge', json={"email": email, "password": "secret"})
    assert resp.status_code == 200
    data = resp.json()
    assert data["two_factor_required"] is True
    pre = data["pre_auth_token"]

    # complete with valid totp code
    code = pyotp.TOTP(secret).now()
    resp2 = client.post('/api/v1/auth/2fa/complete', json={"pre_auth_token": pre, "code": code})
    assert resp2.status_code == 200
    body = resp2.json()
    assert "access_token" in body and "refresh_token" in body

    # Now test backup code flow
    # generate backup codes
    from utils.two_factor import generate_backup_codes
    codes = generate_backup_codes(4)
    from repositories.totp_backup_repository import TOTPBackupRepository
    TOTPBackupRepository.create_bulk(db, user.id, codes)

    resp3 = client.post('/api/v1/auth/2fa/challenge', json={"email": email, "password": "secret"})
    assert resp3.status_code == 200
    pre2 = resp3.json()["pre_auth_token"]
    # use backup code
    resp4 = client.post('/api/v1/auth/2fa/complete', json={"pre_auth_token": pre2, "backup_code": codes[0]})
    assert resp4.status_code == 200
    # reusing same backup code should fail
    resp5 = client.post('/api/v1/auth/2fa/complete', json={"pre_auth_token": pre2, "backup_code": codes[0]})
    assert resp5.status_code == 400

    db.close()
