from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from repositories.medicament_repository import MedicamentRepository
from schemas.medicament import MedicamentCreate, MedicamentResponse

router = APIRouter(prefix="/medicaments", tags=["Médicaments"])

@router.get("/", response_model=List[MedicamentResponse])
async def get_medicaments(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db)
):
    """Obtenir la liste des médicaments"""
    medicaments = MedicamentRepository.get_all(db, skip=skip, limit=limit)
    return medicaments

@router.get("/search")
async def search_medicaments(
    nom: str = Query(..., min_length=2),
    db: Session = Depends(get_db)
):
    """Rechercher des médicaments par nom"""
    medicaments = MedicamentRepository.find_by_name(db, nom)
    return medicaments

@router.get("/{medicament_id}", response_model=MedicamentResponse)
async def get_medicament(
    medicament_id: int,
    db: Session = Depends(get_db)
):
    """Obtenir un médicament par ID"""
    medicament = MedicamentRepository.find_by_id(db, medicament_id)
    if not medicament:
        raise HTTPException(status_code=404, detail="Médicament non trouvé")
    return medicament

@router.post("/", response_model=MedicamentResponse, status_code=201)
async def create_medicament(
    medicament: MedicamentCreate,
    db: Session = Depends(get_db)
):
    """Créer un nouveau médicament"""
    return MedicamentRepository.create(db, **medicament.model_dump())