# VonjiAIna API

API REST pour l'application VonjiAIna - Recherche de médicaments dans les pharmacies à Madagascar.

## Stack technique

-voir requierments.txt

## Installation

### Prérequis

- Python 3.10+
- PostgreSQL 14+ avec PostGIS
- pip

### Étapes

1. Cloner le projet
```bash
git clone <url>
cd vonjiaaina-api
```

2. Créer un environnement virtuel
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows
```

3. Installer les dépendances
```bash
pip install -r requirements.txt
```

4. Configurer les variables d'environnement

Créer un fichier `.env` à la racine :
```env
DATABASE_URL=postgresql://user:password@localhost:5432/vonjiaaina
SECRET_KEY=votre-cle-secrete-
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
```
Pour la SECRET_key faire :
python -c "import secrets; print(secrets.token_urlsafe(32))"
Puis mettre dans .env

5. Créer la base de données
```bash
# Se connecter à PostgreSQL
psql -U postgres

# Exécuter le script SQL
\i scripts/init_db.sql
```

6. Lancer le serveur
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

L'API sera accessible sur `http://localhost:8000`

Documentation interactive : `http://localhost:8000/docs`


## Endpoints principaux

Pour le moment on reste sur juste la recherche de pharmacies ayant le médicament
### Pharmacies

- `GET /api/v1/pharmacies/search` - Rechercher pharmacies avec médicament

Pour plus tard faire plus