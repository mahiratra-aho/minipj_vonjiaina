from fastapi import Request, HTTPException, status
from utils.security import verify_token
from app.database import SessionLocal
from repositories.user_repository import UserRepository


def get_current_admin_user(request: Request) -> dict:
    """Dependency that validates Authorization header and requires role==admin."""
    auth = request.headers.get("authorization")
    if not auth or not auth.lower().startswith("bearer "):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Missing or invalid Authorization header")
    token = auth.split(" ", 1)[1]
    payload = verify_token(token)
    role = payload.get("role")
    if role != "admin":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin privileges required")
    return payload


def get_current_user(request: Request):
    """Return the current authenticated user (models.User) or raise 401."""
    auth = request.headers.get("authorization")
    if not auth or not auth.lower().startswith("bearer "):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Missing or invalid Authorization header")
    token = auth.split(" ", 1)[1]
    payload = verify_token(token)
    email = payload.get("sub")
    if not email:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token payload")
    db = SessionLocal()
    try:
        user = UserRepository.find_by_email(db, email)
        if not user:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")
        return user
    finally:
        db.close()
