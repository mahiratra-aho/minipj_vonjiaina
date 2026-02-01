import os
os.environ.setdefault('DATABASE_URL', 'sqlite:///:memory:')
os.environ.setdefault('SECRET_KEY', 'testsecret')

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.database import Base
from repositories.user_repository import UserRepository
from services.auth import AuthService
from utils.security import hash_refresh_token, verify_refresh_token_hash
from datetime import datetime, timedelta, timezone

# Setup in-memory SQLite for tests
TEST_SQLITE_URL = "sqlite:///:memory:"
engine = create_engine(TEST_SQLITE_URL)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@pytest.fixture(scope="function")
def db_session():
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


def test_refresh_token_hashing():
    raw = "mysecretrandomtoken"
    h = hash_refresh_token(raw)
    assert verify_refresh_token_hash(raw, h)
    assert not verify_refresh_token_hash(raw + "x", h)


def test_auth_create_and_refresh(db_session):
    # Create a user
    user = UserRepository.create(db=db_session, email="test@example.com", nom="Test", hashed_password="hash", role="user")

    # Create tokens
    tokens = AuthService.create_token_for_user(db_session, user)
    assert "access_token" in tokens
    assert "refresh_token" in tokens

    refresh_value = tokens["refresh_token"]

    # Ensure refresh token stored in DB
    from utils.security import hash_refresh_token
    from repositories.refresh_token_repository import RefreshTokenRepository
    from repositories.journal_audit_repository import JournalAuditRepository

    stored = RefreshTokenRepository.find_by_hash(db_session, hash_refresh_token(refresh_value))
    assert stored is not None
    assert not stored.revoked

    # After issuance there should be an audit log
    audits = JournalAuditRepository.find_by_user(db_session, user.id)
    assert any(a.action_type == "token_issued" for a in audits)

    # Use refresh to get new tokens
    new_tokens = AuthService.refresh_access_token(db_session, refresh_value)
    assert "access_token" in new_tokens
    assert "refresh_token" in new_tokens

    # Old token should be revoked
    stored_after = RefreshTokenRepository.find_by_hash(db_session, hash_refresh_token(refresh_value))
    assert stored_after.revoked

    # After refresh there should be an audit log
    audits_after = JournalAuditRepository.find_by_user(db_session, user.id)
    assert any(a.action_type == "token_refreshed" for a in audits_after)
