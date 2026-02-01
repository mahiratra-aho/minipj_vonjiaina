from sqlalchemy.orm import Session
from models.journal_audit import JournalAudit
from datetime import datetime, timezone

class JournalAuditRepository:

    @staticmethod
    def create(db: Session, user_id: int = None, action_type: str = None, resource_id: str = None, adresse_ip: str = None, user_agent: str = None):
        ja = JournalAudit(
            user_id=user_id,
            action_type=action_type,
            resource_id=resource_id,
            adresse_ip=adresse_ip,
            user_agent=user_agent,
        )
        db.add(ja)
        db.commit()
        db.refresh(ja)
        return ja

    @staticmethod
    def find_by_user(db: Session, user_id: int):
        return db.query(JournalAudit).filter(JournalAudit.user_id == user_id).order_by(JournalAudit.horodatage_precis.desc()).all()

    @staticmethod
    def find_recent(db: Session, limit: int = 50):
        return db.query(JournalAudit).order_by(JournalAudit.horodatage_precis.desc()).limit(limit).all()
