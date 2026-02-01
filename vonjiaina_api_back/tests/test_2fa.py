import os
# Force an isolated SQLite test database for these tests to avoid schema mismatch
os.environ.setdefault('DATABASE_URL', 'sqlite:////tmp/test_2fa.db')

from fastapi.testclient import TestClient
from app.main import app
from repositories.user_repository import UserRepository
from utils.security import create_access_token, get_password_hash
import pyotp

client = TestClient(app)


def test_totp_setup_and_verify():
    # create a user directly
    from app.database import SessionLocal, Base, engine
    # Ensure tables exist in the test DB
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    import uuid
    email = f"alice+{uuid.uuid4().hex}@example.com"
    user = UserRepository.create(db, email=email, nom="Alice", hashed_password=get_password_hash("secret"), role="user")

    # create an access token for authentication
    token = create_access_token({"sub": user.email, "role": user.role})
    headers = {"Authorization": f"Bearer {token}"}

    # setup TOTP
    resp = client.post("/api/v1/auth/2fa/setup", headers=headers)
    assert resp.status_code == 200
    data = resp.json()
    assert "otpauth_url" in data and "secret" in data
    secret = data["secret"]

    # produce a valid code and verify
    code = pyotp.TOTP(secret).now()
    resp2 = client.post("/api/v1/auth/2fa/verify", json={"code": code}, headers=headers)
    assert resp2.status_code == 200
    body = resp2.json()
    assert "backup_codes" in body and len(body["backup_codes"]) >= 1

    # check user database updated
    db.refresh(user)
    assert user.totp_enabled is True

    db.close()
