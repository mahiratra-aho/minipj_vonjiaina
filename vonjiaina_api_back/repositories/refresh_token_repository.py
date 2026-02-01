from sqlalchemy.orm import Session
from datetime import datetime, timezone
from models.refresh_token import RefreshToken

class RefreshTokenRepository:

    @staticmethod
    def create(db: Session, token_hash: str, user_id: int, expires_at: datetime = None, device_id: str = None) -> RefreshToken:
        rt = RefreshToken(
            token_hash=token_hash,
            user_id=user_id,
            device_id=device_id,
            expires_at=expires_at
        )
        db.add(rt)
        db.commit()
        db.refresh(rt)
        return rt

    @staticmethod
    def find_by_hash(db: Session, token_hash: str) -> RefreshToken:
        return db.query(RefreshToken).filter(RefreshToken.token_hash == token_hash).first()

    @staticmethod
    def revoke(db: Session, refresh_token: RefreshToken):
        refresh_token.revoked = True
        db.add(refresh_token)
        db.commit()
        db.refresh(refresh_token)
        return refresh_token

    @staticmethod
    def revoke_all_for_user_device(db: Session, user_id: int, device_id: str):
        tokens = db.query(RefreshToken).filter(RefreshToken.user_id == user_id, RefreshToken.device_id == device_id, RefreshToken.revoked == False).all()
        for t in tokens:
            t.revoked = True
            db.add(t)
        db.commit()
        return tokens

    @staticmethod
    def delete_expired(db: Session):
        now = datetime.now(timezone.utc)
        expired = db.query(RefreshToken).filter(RefreshToken.expires_at != None, RefreshToken.expires_at <= now).all()
        for t in expired:
            db.delete(t)
        db.commit()
        return len(expired)
