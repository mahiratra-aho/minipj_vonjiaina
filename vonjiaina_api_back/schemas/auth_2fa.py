from pydantic import BaseModel
from typing import Optional
from schemas.user import UserResponse

class ChallengeRequest(BaseModel):
    email: str
    password: str

class ChallengeResponse(BaseModel):
    pre_auth_token: str
    two_factor_required: bool

class CompleteRequest(BaseModel):
    pre_auth_token: str
    code: Optional[str] = None
    backup_code: Optional[str] = None

class CompleteResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user: UserResponse
