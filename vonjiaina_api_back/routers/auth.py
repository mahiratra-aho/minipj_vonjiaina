from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from app.database import get_db
from services.auth import AuthService
from schemas.user import UserCreate, UserLogin, Token, UserResponse, TokenResponse, RefreshRequest
from schemas.auth_2fa import ChallengeRequest, ChallengeResponse, CompleteRequest, CompleteResponse

router = APIRouter(prefix="/auth", tags=["Authentification"])

@router.post("/register", response_model=UserResponse, status_code=201)
async def register(
    user_data: UserCreate,
    db: Session = Depends(get_db)
):
    """Enregistrer un nouvel utilisateur"""
    try:
        user = AuthService.register_user(db, user_data)
        return user
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/login", response_model=TokenResponse)
async def login(
    credentials: UserLogin,
    request: Request,
    db: Session = Depends(get_db)
):
    """Se connecter"""
    user = AuthService.authenticate_user(
        db, 
        credentials.email, 
        credentials.password
    )
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email ou mot de passe incorrect",
            headers={"WWW-Authenticate": "Bearer"},
        )

    ip = request.client.host if request.client else None
    ua = request.headers.get("user-agent")
    tokens = AuthService.create_token_for_user(db, user, adresse_ip=ip, user_agent=ua)
    
    return {
        "access_token": tokens["access_token"],
        "refresh_token": tokens["refresh_token"],
        "token_type": "bearer",
        "user": tokens["user"],
    }


# --- 2FA / TOTP endpoints ---
from utils.dependencies import get_current_user
from utils.two_factor import generate_totp_secret, get_otpauth_url, verify_totp_code, generate_backup_codes, encrypt_totp_secret, decrypt_totp_secret
from repositories.totp_backup_repository import TOTPBackupRepository
from repositories.user_repository import UserRepository
from schemas.user import UserResponse
from pydantic import BaseModel


class TOTPSetupResponse(BaseModel):
    otpauth_url: str
    secret: str


class TOTPVerifyRequest(BaseModel):
    code: str


@router.post('/2fa/setup', response_model=TOTPSetupResponse)
async def totp_setup(current_user = Depends(get_current_user), db: Session = Depends(get_db)):
    """Generate a TOTP secret and return an otpauth URL to scan. Secret is stored encrypted."""
    secret = generate_totp_secret()
    enc = encrypt_totp_secret(secret)
    # store the secret encrypted (unverified)
    UserRepository.update_totp(db, current_user.id, secret=enc, enabled=False)
    uri = get_otpauth_url(secret, current_user.email)
    return {"otpauth_url": uri, "secret": secret}


@router.post('/2fa/verify')
async def totp_verify(body: TOTPVerifyRequest, current_user = Depends(get_current_user), db: Session = Depends(get_db)):
    """Verify a TOTP code to enable 2FA and return backup codes."""
    if not current_user.totp_secret:
        raise HTTPException(status_code=400, detail="TOTP not initialized for user")
    try:
        secret = decrypt_totp_secret(current_user.totp_secret)
    except Exception:
        raise HTTPException(status_code=500, detail="Unable to decrypt TOTP secret")

    if not verify_totp_code(secret, body.code):
        raise HTTPException(status_code=400, detail="Invalid TOTP code")

    # enable TOTP (secret already stored encrypted) and create backup codes
    UserRepository.update_totp(db, current_user.id, secret=current_user.totp_secret, enabled=True)
    backup_codes = generate_backup_codes(8)
    TOTPBackupRepository.create_bulk(db, current_user.id, backup_codes)
    return {"backup_codes": backup_codes}


@router.post('/2fa/disable')
async def totp_disable(body: TOTPVerifyRequest, current_user = Depends(get_current_user), db: Session = Depends(get_db)):
    """Disable 2FA after verifying a TOTP code."""
    if not current_user.totp_secret or not current_user.totp_enabled:
        raise HTTPException(status_code=400, detail="TOTP not enabled for user")
    try:
        secret = decrypt_totp_secret(current_user.totp_secret)
    except Exception:
        raise HTTPException(status_code=500, detail="Unable to decrypt TOTP secret")
    if not verify_totp_code(secret, body.code):
        raise HTTPException(status_code=400, detail="Invalid TOTP code")
    UserRepository.update_totp(db, current_user.id, secret=None, enabled=False)
    return {"ok": True}


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(
    data: RefreshRequest,
    request: Request,
    db: Session = Depends(get_db)
):
    """Obtenir un nouvel access token à partir d'un refresh token"""
    try:
        tokens = AuthService.refresh_access_token(db, data.refresh_token)
        return {
            "access_token": tokens["access_token"],
            "refresh_token": tokens["refresh_token"],
            "token_type": "bearer",
            "user": tokens["user"],
        }
    except ValueError as e:
        raise HTTPException(status_code=401, detail=str(e))


@router.post('/2fa/challenge', response_model=ChallengeResponse)
async def totp_challenge(body: ChallengeRequest, db: Session = Depends(get_db)):
    """Authenticate credentials and return a short-lived pre_auth token when 2FA is required."""
    user = AuthService.authenticate_user(db, body.email, body.password)
    if not user:
        raise HTTPException(status_code=401, detail="Email ou mot de passe incorrect")

    if not user.totp_enabled:
        # Not 2FA enabled: return normal tokens
        tokens = AuthService.create_token_for_user(db, user)
        return {"pre_auth_token": tokens["access_token"], "two_factor_required": False}

    # Create a short lived pre-auth token
    from utils.security import create_access_token
    from datetime import timedelta
    pre = create_access_token({"sub": user.email, "pre_auth": True}, expires_delta=timedelta(minutes=5))
    return {"pre_auth_token": pre, "two_factor_required": True}


@router.post('/2fa/complete', response_model=CompleteResponse)
async def totp_complete(body: CompleteRequest, db: Session = Depends(get_db)):
    """Complete 2FA using a pre-auth token and either a TOTP code or a backup code."""
    from utils.security import verify_token
    try:
        payload = verify_token(body.pre_auth_token)
    except HTTPException:
        raise HTTPException(status_code=401, detail="Invalid or expired pre-auth token")
    if not payload.get("pre_auth"):
        raise HTTPException(status_code=400, detail="Not a pre-auth token")
    email = payload.get("sub")
    user = UserRepository.find_by_email(db, email)
    if not user:
        raise HTTPException(status_code=401, detail="Utilisateur introuvable")

    # verify either totp code or backup code
    ok = False
    if body.code:
        try:
            secret = decrypt_totp_secret(user.totp_secret)
            ok = verify_totp_code(secret, body.code)
        except Exception:
            ok = False
    elif body.backup_code:
        ok = TOTPBackupRepository.use_code(db, user.id, body.backup_code)

    if not ok:
        raise HTTPException(status_code=400, detail="Invalid 2FA credentials")

    # issue normal tokens
    tokens = AuthService.create_token_for_user(db, user)
    return {
        "access_token": tokens["access_token"],
        "refresh_token": tokens["refresh_token"],
        "token_type": "bearer",
        "user": tokens["user"],
    }

@router.post("/revoke")
async def revoke_token(
    data: RefreshRequest,
    request: Request,
    db: Session = Depends(get_db)
):
    """Révoquer un refresh token"""
    ip = request.client.host if request.client else None
    ua = request.headers.get("user-agent")
    result = AuthService.revoke_refresh_token(db, data.refresh_token, adresse_ip=ip, user_agent=ua)
    if not result:
        raise HTTPException(status_code=404, detail="Refresh token introuvable")
    return {"revoked": True}