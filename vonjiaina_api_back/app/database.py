from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from app.config import get_settings

settings = get_settings()

# Créer le moteur de base de données
engine = create_engine(
    settings.DATABASE_URL,
    pool_pre_ping=True,
    echo=False  # Changé en False pour réduire les logs
)

# Session locale
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base pour les modèles
Base = declarative_base()

# Importer les modèles pour s'assurer qu'ils sont enregistrés dans Base.metadata
# (important pour create_all dans des environnements de test qui utilisent un engine séparé)
import models  # noqa: F401

# Dépendance pour obtenir la session DB
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()