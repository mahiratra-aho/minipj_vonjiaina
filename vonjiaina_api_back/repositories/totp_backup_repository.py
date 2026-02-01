from sqlalchemy.orm import Session
from models.totp_backup_code import TOTPBackupCode
from typing import List
import hashlib
import hmac

class TOTPBackupRepository:
    @staticmethod
    def create_bulk(db: Session, user_id: int, codes: List[str]):
        objs = []
        for c in codes:
            h = hashlib.sha256(c.encode()).hexdigest()
            obj = TOTPBackupCode(user_id=user_id, code_hash=h)
            db.add(obj)
            objs.append(obj)
        db.commit()
        return objs

    @staticmethod
    def use_code(db: Session, user_id: int, code: str) -> bool:
        h = hashlib.sha256(code.encode()).hexdigest()
        # Find an unused matching code
        obj = db.query(TOTPBackupCode).filter(TOTPBackupCode.user_id == user_id, TOTPBackupCode.used == False).all()
        for o in obj:
            if hmac.compare_digest(o.code_hash, h):
                o.used = True
                db.add(o)
                db.commit()
                return True
        return False

    @staticmethod
    def list_valid(db: Session, user_id: int):
        return db.query(TOTPBackupCode).filter(TOTPBackupCode.user_id == user_id, TOTPBackupCode.used == False).all()
