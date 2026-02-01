from fastapi.testclient import TestClient
from app.main import app
from utils.security import create_access_token
import json

client = TestClient(app)


def test_admin_sync_requires_admin():
    # token with non-admin role
    token = create_access_token({"sub": "user@example.com", "role": "user"})
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    resp = client.post("/api/v1/admin/sync", data=json.dumps({"what": "pharmacies"}), headers=headers)
    assert resp.status_code == 403


def test_admin_sync_success(monkeypatch):
    # patch firebase sync functions to avoid external calls
    monkeypatch.setattr("utils.firebase_client.sync_pharmacies", lambda phs: len(phs))
    monkeypatch.setattr("utils.firebase_client.sync_users", lambda us: len(us))

    token = create_access_token({"sub": "admin@example.com", "role": "admin"})
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

    # run sync for pharmacies (no since param)
    resp = client.post("/api/v1/admin/sync", data=json.dumps({"what": "pharmacies"}), headers=headers)
    assert resp.status_code == 200
    data = resp.json()
    assert "synced" in data
    assert "pharmacies" in data["synced"]
