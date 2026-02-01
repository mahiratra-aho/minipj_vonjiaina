# FIREBASE & Firestore — Configuration et bonnes pratiques

But : permettre la synchronisation des données (pharmacies, users, devices) vers Firestore pour faciliter l'accès des équipes en développement.

## Variables d'environnement attendues
- `FIREBASE_CREDENTIALS_PATH` : chemin vers le fichier JSON du service account (ne **pas** commit). Exemple : `/home/user/keys/firebase-sa.json`
- `FIREBASE_PROJECT_ID` : (optionnel) ID du projet Firebase (ex: `vonjiaina-geit`)

## Initialisation
1. Placer la clé JSON sur le serveur local (ne pas committer).
2. Exporter les variables d'environnement :

```bash
export FIREBASE_CREDENTIALS_PATH="/chemin/vers/firebase-credentials.json"
export FIREBASE_PROJECT_ID="vonjiaina-geit"
```

3. Tester l'initialisation depuis le backend :

```python
from utils.firebase_client import init_firebase, get_db
db = init_firebase()
print('Firestore client:', db)
```

## Synchronisation
Un script d'outil est disponible : `scripts/sync_firestore.py`.
- `python scripts/sync_firestore.py pharmacies`
- `python scripts/sync_firestore.py users`
- `python scripts/sync_firestore.py all`

Le script lit la base SQL et envoie des documents nettoyés vers Firestore (collections `pharmacies` et `users`).

## Règles Firestore recommandées (exemple minimal)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/devices/{deviceId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /pharmacies/{doc} {
      allow read: if true; // en dev seulement
      allow write: if false;
    }
  }
}
```
> IMPORTANT: Pour la production, **ne pas** autoriser des lectures/écritures publiques. Restreindre via `request.auth`.

## Sécurité & confidentialité
- Ne jamais stocker la clé JSON dans le repo.
- Eviter d'exposer des données médicales sensibles dans Firestore (ou chiffrer côté client avant stockage).
- Pour limiter l'accès des clients non autorisés, activer App Check et règles strictes.

## Flux recommandé pour dev vs prod
- Dev: sync complet possible (facilite collaboration) mais mettre un plan de purge et authentification (ex: whitelist IP, service account restreint).
- Prod: sync minimal, ou uniquement métadonnées, chiffrées et firewallées; privilégier sauvegardes chiffrées.

---
Si tu veux, je peux :
- exécuter une première synchronisation (si tu me confirmes le chemin de `firebase-credentials.json`),
- ajouter un job cron / simple webhook admin pour lancer la sync périodique,
- ou verrouiller la synchronisation pour n'envoyer que des champs non-sensibles.
