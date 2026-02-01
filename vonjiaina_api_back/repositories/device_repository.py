from sqlalchemy.orm import Session
from models.device import Device
from datetime import datetime, timezone

class DeviceRepository:

    @staticmethod
    def create(db: Session, user_id: int, hardware_id: str, name: str = None, verification_code_hash: str = None) -> Device:
        d = Device(
            user_id=user_id,
            hardware_id=hardware_id,
            name=name,
            verification_code_hash=verification_code_hash
        )
        db.add(d)
        db.commit()
        db.refresh(d)
        return d

    @staticmethod
    def find_by_user(db: Session, user_id: int):
        return db.query(Device).filter(Device.user_id == user_id).all()

    @staticmethod
    def find_by_id(db: Session, device_id: int):
        return db.query(Device).filter(Device.id == device_id).first()

    @staticmethod
    def find_by_hardware(db: Session, user_id: int, hardware_id: str):
        return db.query(Device).filter(Device.user_id == user_id, Device.hardware_id == hardware_id).first()

    @staticmethod
    def mark_trusted(db: Session, device: Device):
        device.trusted = True
        device.verified_at = datetime.now(timezone.utc)
        db.add(device)
        db.commit()
        db.refresh(device)
        return device

    @staticmethod
    def revoke(db: Session, device: Device):
        db.delete(device)
        db.commit()
        return True

    @staticmethod
    def set_last_seen(db: Session, device: Device):
        device.last_seen = datetime.now(timezone.utc)
        db.add(device)
        db.commit()
        db.refresh(device)
        return device
