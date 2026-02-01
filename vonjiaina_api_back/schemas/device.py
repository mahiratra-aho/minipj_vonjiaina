from pydantic import BaseModel
from typing import Optional

class DeviceRegisterRequest(BaseModel):
    hardware_id: str
    name: Optional[str]

class DeviceVerifyRequest(BaseModel):
    hardware_id: str
    verification_code: str

class DeviceResponse(BaseModel):
    id: int
    hardware_id: str
    name: Optional[str]
    trusted: bool

    class Config:
        from_attributes = True
