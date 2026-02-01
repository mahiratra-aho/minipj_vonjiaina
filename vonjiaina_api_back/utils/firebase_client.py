import os
from typing import Iterable, Dict, Any, Optional

try:
    import firebase_admin
    from firebase_admin import credentials, firestore
    FIREBASE_AVAILABLE = True
except Exception:
    FIREBASE_AVAILABLE = False

from app.config import get_settings
settings = get_settings()

_db = None


def init_firebase():
    """Initialize Firebase Admin SDK using service account path or ADC.
    Returns Firestore client or None."""
    global _db
    if not FIREBASE_AVAILABLE:
        return None

    cred_path = os.environ.get("FIREBASE_CREDENTIALS_PATH") or settings.FIREBASE_CREDENTIALS_PATH
    project_id = os.environ.get("FIREBASE_PROJECT_ID") or settings.FIREBASE_PROJECT_ID

    try:
        if cred_path and os.path.exists(cred_path):
            cred = credentials.Certificate(cred_path)
            if not firebase_admin._apps:
                firebase_admin.initialize_app(cred, {'projectId': project_id} if project_id else None)
        else:
            # Will attempt application default credentials
            if not firebase_admin._apps:
                firebase_admin.initialize_app()

        _db = firestore.client()
        return _db
    except Exception as e:
        # Best-effort: log and continue without Firestore
        print(f"[firebase] init error: {e}")
        return None


def get_db():
    global _db
    if _db is None and FIREBASE_AVAILABLE:
        init_firebase()
    return _db


def upsert_device(user_id: int, device_doc: dict) -> bool:
    """Store or update a device doc in Firestore under users/{user_id}/devices/{hardware_id}"""
    db = get_db()
    if not db:
        return False
    path = f"users/{user_id}/devices/{device_doc.get('hardware_id')}"
    ref = db.document(path)
    ref.set(device_doc, merge=True)
    return True


def delete_device(user_id: int, hardware_id: str) -> bool:
    db = get_db()
    if not db:
        return False
    ref = db.document(f"users/{user_id}/devices/{hardware_id}")
    ref.delete()
    return True


# --- Sync helpers ---

def batch_upsert(collection: str, docs: Iterable[Dict[str, Any]], id_field: str = 'id') -> int:
    """Upsert multiple documents into a top-level collection, returning number written."""
    db = get_db()
    if not db:
        return 0

    batch = db.batch()
    count = 0
    for d in docs:
        doc_id = str(d.get(id_field))
        ref = db.collection(collection).document(doc_id)
        batch.set(ref, d, merge=True)
        count += 1

        # commit in groups of 500
        if count % 500 == 0:
            batch.commit()
            batch = db.batch()

    if count % 500 != 0:
        batch.commit()

    return count


def sync_pharmacies(pharmacies: Iterable[Dict[str, Any]]) -> int:
    """Sync pharmacies list to Firestore (collection: pharmacies).
    Each pharmacy dict should be sanitized (no sensitive fields) and contain 'id' or a provided id field.
    Returns number of documents written."""
    # Map/normalize fields if needed
    clean_docs = []
    for p in pharmacies:
        doc = {
            'id': p.get('id'),
            'nom': p.get('nom'),
            'adresse': p.get('adresse'),
            'telephone': p.get('telephone'),
            'latitude': float(p.get('latitude')) if p.get('latitude') is not None else None,
            'longitude': float(p.get('longitude')) if p.get('longitude') is not None else None,
            'statut': p.get('statut') or p.get('type') or 'normal',
            'quartier': p.get('quartier'),
            'horaires': p.get('horaires'),
            'verified': bool(p.get('verified')),
            'actif': bool(p.get('actif')),
            'updated_at': str(p.get('updated_at')) if p.get('updated_at') else None,
        }
        clean_docs.append(doc)

    return batch_upsert('pharmacies', clean_docs, id_field='id')


def sync_users(users: Iterable[Dict[str, Any]]) -> int:
    """Sync users to Firestore (collection: users). Does NOT write sensitive fields like hashed_password."""
    clean_docs = []
    for u in users:
        doc = {
            'id': u.get('id'),
            'email': u.get('email'),
            'nom': u.get('nom'),
            'role': u.get('role'),
            'pharmacie_id': u.get('pharmacie_id'),
            'is_active': bool(u.get('is_active')),
            'created_at': str(u.get('created_at')) if u.get('created_at') else None,
        }
        clean_docs.append(doc)

    return batch_upsert('users', clean_docs, id_field='id')


def delete_collection_items(collection: str, ids: Iterable[str]) -> int:
    db = get_db()
    if not db:
        return 0
    count = 0
    for i in ids:
        db.collection(collection).document(str(i)).delete()
        count += 1
    return count
