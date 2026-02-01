import sys
import os
# Ensure repo root in path for direct pytest invocation
sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from repositories.user_repository import UserRepository
from services.auth import AuthService
from app.database import Base
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# Ensure env defaults for tests
os.environ.setdefault('DATABASE_URL', 'sqlite:///:memory:')
os.environ.setdefault('SECRET_KEY', 'testsecret')

engine = create_engine('sqlite:///:memory:')
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def setup_function(function):
    Base.metadata.create_all(bind=engine)


def teardown_function(function):
    Base.metadata.drop_all(bind=engine)


def test_device_register_and_verify():
    db = TestingSessionLocal()
    # create user
    user = UserRepository.create(db=db, email='device@test', nom='Device', hashed_password='h', role='user')

    # register device
    from repositories.device_repository import DeviceRepository
    from services.auth import AuthService

    # simulate register flow
    from utils.security import generate_refresh_token_value, hash_refresh_token
    code = generate_refresh_token_value()[:8]
    code_hash = hash_refresh_token(code)

    device = DeviceRepository.create(db, user_id=user.id, hardware_id='hw-123', name='Phone', verification_code_hash=code_hash)
    assert device is not None
    assert not device.trusted

    # verify using correct code
    from utils.security import verify_refresh_token_hash
    assert verify_refresh_token_hash(code, device.verification_code_hash)

    DeviceRepository.mark_trusted(db, device)
    assert device.trusted

    db.close()
