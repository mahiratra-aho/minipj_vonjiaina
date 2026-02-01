from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import text
from app.database import get_db
from utils.dependencies import get_current_admin_user
from schemas.sync import SyncRequest
from utils.firebase_client import sync_pharmacies, sync_users

router = APIRouter(prefix="/admin", tags=["Admin"])


@router.post("/sync")
async def admin_sync(payload: SyncRequest, db: Session = Depends(get_db), admin=Depends(get_current_admin_user)):
    """Trigger an on-demand sync to Firestore (admin only).
    Payload:
      - what: 'pharmacies' | 'users' | 'all'
      - since: optional ISO datetime to do incremental sync
    """
    what = payload.what
    since = payload.since
    total = 0
    result = {"pharmacies": 0, "users": 0}

    if what in ("pharmacies", "all"):
        if since:
            q = db.execute(text("SELECT id, nom, adresse, telephone, latitude, longitude, statut, quartier, horaires, verified, actif, updated_at FROM pharmacies WHERE updated_at > :since"), {"since": since})
        else:
            q = db.execute(text("SELECT id, nom, adresse, telephone, latitude, longitude, statut, quartier, horaires, verified, actif, updated_at FROM pharmacies"))
        phs = [dict(r._mapping) for r in q]
        c = sync_pharmacies(phs)
        result["pharmacies"] = c
        total += c

    if what in ("users", "all"):
        if since:
            q = db.execute(text("SELECT id, email, nom, role, pharmacie_id, is_active, created_at FROM users WHERE created_at > :since"), {"since": since})
        else:
            q = db.execute(text("SELECT id, email, nom, role, pharmacie_id, is_active, created_at FROM users"))
        us = [dict(r._mapping) for r in q]
        c = sync_users(us)
        result["users"] = c
        total += c

    return {"synced": result, "total": total}
