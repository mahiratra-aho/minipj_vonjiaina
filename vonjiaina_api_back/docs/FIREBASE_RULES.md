# Firestore Rules & App Check (recommended)

## Overview ✅
Ces règles servent de base minimale pour limiter l'accès aux collections `pharmacies` et `users` en production.

- Lecture des pharmacies : uniquement pour les utilisateurs authentifiés et ayant un email vérifié.
- Écriture des pharmacies / accès aux utilisateurs : uniquement pour les comptes admin (claim `admin` dans le token).

## Déploiement
1. Installer l'outil Firebase CLI :
   - `npm install -g firebase-tools`
2. Initialiser le projet (si nécessaire) et copier `firebase.rules` dans le dossier de projet firebase.
3. Déployer les règles :
   - `firebase deploy --only firestore:rules --project vonjiaina-geit`

## App Check
- Active App Check dans la console Firebase et génère des clés pour chaque plateforme.
- En production, enforce App Check pour Firestore pour réduire les risques d'abus.

## Notes
- Pour les environnements de développement, crée un projet Firebase séparé (`-dev`) si l'équipe a besoin d'un accès plus large.
- Les scripts côté serveur (utilisant la clé de service) ne passent pas par App Check et c'est attendu : garde la clé de service sécurisée et n'expose pas le fichier JSON dans les dépôts.

## Déploiement CI (GitHub Actions) ✅
Tu peux automatiser le déploiement des règles en ajoutant une action GitHub qui les publie sur chaque push vers `main` ou via déclenchement manuel.

1) Ajoute un secret GitHub au dépôt : **Settings → Secrets → Actions → New repository secret**
   - **Name**: `FIREBASE_SERVICE_ACCOUNT`
   - **Value**: contenu JSON du compte de service (service account key) fourni par Firebase (ne pas committer dans le dépôt)

2) Le workflow est déjà ajouté dans `.github/workflows/deploy-firestore-rules.yml`. Il fait :
   - installer `firebase-tools` ;
   - écrire le JSON du secret dans `service-account.json`; 
   - exécuter `firebase deploy --only firestore:rules --project vonjiaina-geit`.

3) Commandes utiles pour gestion locale :
   - Tester la compilation des règles : `firebase emulators:exec --only firestore "firebase deploy --only firestore:rules --project vonjiaina-geit --dry-run"` (ou utiliser l'émulateur Firestore pour tests locaux).

> Sécurité : donne seulement un compte de service avec les rôles nécessaires (`roles/firebaserules.admin` `roles/datastore.owner` / `roles/firebasedatabase.admin` selon besoins) et limite l'accès au secret aux personnes de confiance.
