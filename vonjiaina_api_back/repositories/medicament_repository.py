from sqlalchemy.orm import Session
from typing import List, Optional
from models.medicament import Medicament

class MedicamentRepository:
    
    @staticmethod
    def create(db: Session, **kwargs) -> Medicament:
        """Créer un nouveau médicament"""
        medicament = Medicament(**kwargs)
        db.add(medicament)
        db.commit()
        db.refresh(medicament)
        return medicament
    
    @staticmethod
    def find_by_id(db: Session, medicament_id: int) -> Optional[Medicament]:
        """Trouver un médicament par ID"""
        return db.query(Medicament).filter(Medicament.id == medicament_id).first()
    
    @staticmethod
    def find_by_name(db: Session, nom: str) -> List[Medicament]:
        """Rechercher par nom commercial"""
        return db.query(Medicament).filter(
            Medicament.nom_commercial.ilike(f"%{nom}%")
        ).all()
    
    @staticmethod
    def get_all(db: Session, skip: int = 0, limit: int = 100) -> List[Medicament]:
        """Obtenir tous les médicaments"""
        return db.query(Medicament).offset(skip).limit(limit).all()
    
    @staticmethod
    def update(db: Session, medicament_id: int, **kwargs) -> Optional[Medicament]:
        """Mettre à jour un médicament"""
        medicament = MedicamentRepository.find_by_id(db, medicament_id)
        if not medicament:
            return None
        
        for key, value in kwargs.items():
            if value is not None:
                setattr(medicament, key, value)
        
        db.commit()
        db.refresh(medicament)
        return medicament
    
    @staticmethod
    def delete(db: Session, medicament_id: int) -> bool:
        """Supprimer un médicament"""
        medicament = MedicamentRepository.find_by_id(db, medicament_id)
        if not medicament:
            return False
        
        db.delete(medicament)
        db.commit()
        return True