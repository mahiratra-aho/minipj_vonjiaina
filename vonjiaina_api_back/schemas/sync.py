from pydantic import BaseModel
from typing import Literal, Optional
from datetime import datetime


class SyncRequest(BaseModel):
    what: Literal["pharmacies", "users", "all"] = "all"
    since: Optional[datetime] = None
