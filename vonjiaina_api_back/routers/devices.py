from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from app.database import get_db
from services.auth import AuthService
from repositories.device_repository import DeviceRepository
from schemas.device import DeviceRegisterRequest, DeviceVerifyRequest, DeviceResponse
from utils.security import hash_refresh_token
from utils.notifications import send_verification_code_email
from utils.firebase_client import upsert_device, delete_device
from repositories.user_repository import UserRepository
from utils.security import generate_refresh_token_value

router = APIRouter(prefix="/devices", tags=["Devices"])

# NOTE: For MVP we return the verification code in response (dev only). In prod, send by email/SMS.

@router.post("/register", response_model=DeviceResponse)
async def register_device(
    data: DeviceRegisterRequest,
    request: Request,
    db: Session = Depends(get_db)
):
    # User must be authenticated - for MVP we assume a header X-User-Email for tests (replace with real auth dep)
    user_email = request.headers.get("X-User-Email")
    if not user_email:
        raise HTTPException(status_code=401, detail="En-tête X-User-Email requis pour ce endpoint (MVP)")

    user = UserRepository.find_by_email(db, user_email)
    if not user:
        raise HTTPException(status_code=404, detail="Utilisateur introuvable")

    # Check if hardware already registered
    existing = DeviceRepository.find_by_hardware(db, user.id, data.hardware_id)
    if existing:
        return existing

    # Generate verification code
    verification_code = generate_refresh_token_value()[:8]
    # Hash and store
    from utils.security import hash_refresh_token as hash_val
    code_hash = hash_val(verification_code)

    device = DeviceRepository.create(db, user_id=user.id, hardware_id=data.hardware_id, name=data.name, verification_code_hash=code_hash)

    # Optionally push to Firestore (best-effort)
    upsert_device(user.id, {"hardware_id": data.hardware_id, "name": data.name, "trusted": False})

    # Send code (stub) and for dev return code in body
    # (In prod, do not return the code in response)
    _ = send_verification_code_email(user.email, verification_code)

    return {"id": device.id, "hardware_id": device.hardware_id, "name": device.name, "trusted": device.trusted}

@router.post("/verify", response_model=DeviceResponse)
async def verify_device(
    data: DeviceVerifyRequest,
    request: Request,
    db: Session = Depends(get_db)
):
    user_email = request.headers.get("X-User-Email")
    if not user_email:
        raise HTTPException(status_code=401, detail="En-tête X-User-Email requis pour ce endpoint (MVP)")

    user = UserRepository.find_by_email(db, user_email)
    if not user:
        raise HTTPException(status_code=404, detail="Utilisateur introuvable")

    device = DeviceRepository.find_by_hardware(db, user.id, data.hardware_id)
    if not device:
        raise HTTPException(status_code=404, detail="Device introuvable")

    from utils.security import hash_refresh_token as hash_val, verify_refresh_token_hash

    if not device.verification_code_hash:
        raise HTTPException(status_code=400, detail="Aucun code de verification trouvé pour cet appareil")

    if not verify_refresh_token_hash(data.verification_code, device.verification_code_hash):
        raise HTTPException(status_code=401, detail="Code de verification invalide")

    DeviceRepository.mark_trusted(db, device)

    # Update Firestore
    upsert_device(user.id, {"hardware_id": device.hardware_id, "name": device.name, "trusted": True, "verified_at": str(device.verified_at)})

    # Journalize
    from repositories.journal_audit_repository import JournalAuditRepository
    JournalAuditRepository.create(db, user_id=user.id, action_type="device_verified", resource_id=str(device.id))

    return {"id": device.id, "hardware_id": device.hardware_id, "name": device.name, "trusted": device.trusted}

@router.get("/", response_model=list[DeviceResponse])
async def list_devices(request: Request, db: Session = Depends(get_db)):
    user_email = request.headers.get("X-User-Email")
    if not user_email:
        raise HTTPException(status_code=401, detail="En-tête X-User-Email requis pour ce endpoint (MVP)")

    user = UserRepository.find_by_email(db, user_email)
    if not user:
        raise HTTPException(status_code=404, detail="Utilisateur introuvable")

    devices = DeviceRepository.find_by_user(db, user.id)
    return devices

@router.delete("/{device_id}")
async def revoke_device(device_id: int, request: Request, db: Session = Depends(get_db)):
    user_email = request.headers.get("X-User-Email")
    if not user_email:
        raise HTTPException(status_code=401, detail="En-tête X-User-Email requis pour ce endpoint (MVP)")

    user = UserRepository.find_by_email(db, user_email)
    if not user:
        raise HTTPException(status_code=404, detail="Utilisateur introuvable")

    device = DeviceRepository.find_by_id(db, device_id)
    if not device or device.user_id != user.id:
        raise HTTPException(status_code=404, detail="Device introuvable")

    # Remove from firestore (best-effort)
    delete_device(user.id, device.hardware_id)

    DeviceRepository.revoke(db, device)

    from repositories.journal_audit_repository import JournalAuditRepository
    JournalAuditRepository.create(db, user_id=user.id, action_type="device_revoked", resource_id=str(device.id))

    return {"revoked": True}
