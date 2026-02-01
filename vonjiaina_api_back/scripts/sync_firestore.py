"""Script d'outil: synchroniser des données sélectionnées vers Firestore.
Usage: python scripts/sync_firestore.py [pharmacies|users|all]
Requires env: FIREBASE_CREDENTIALS_PATH (or configured in app.settings)
"""
import sys
from app.database import SessionLocal
from utils.firebase_client import init_firebase, sync_pharmacies, sync_users
from repositories.pharmacie_repository import PharmacieRepository
from repositories.user_repository import UserRepository


from sqlalchemy import text

def fetch_pharmacies(db):
    # Basic query to fetch pharmacies; return as dicts
    q = db.execute(text("SELECT id, nom, adresse, telephone, latitude, longitude, statut, quartier, horaires, verified, actif, updated_at FROM pharmacies"))
    return [dict(r._mapping) for r in q]


def fetch_users(db):
    q = db.execute(text("SELECT id, email, nom, role, pharmacie_id, is_active, created_at FROM users"))
    return [dict(r._mapping) for r in q]


def main():
    if len(sys.argv) < 2:
        print("Usage: python scripts/sync_firestore.py [pharmacies|users|all]")
        sys.exit(1)

    what = sys.argv[1]

    init_firebase()

    db = SessionLocal()
    try:
        total = 0
        if what in ("pharmacies", "all"):
            phs = fetch_pharmacies(db)
            c = sync_pharmacies(phs)
            print(f"Synced {c} pharmacies to Firestore")
            total += c
        if what in ("users", "all"):
            us = fetch_users(db)
            c = sync_users(us)
            print(f"Synced {c} users to Firestore")
            total += c
        print(f"Done. Total documents synced: {total}")
    finally:
        db.close()

if __name__ == '__main__':
    main()
