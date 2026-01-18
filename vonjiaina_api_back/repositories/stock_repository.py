from sqlalchemy.orm import Session
from typing import List, Optional
from models.stock import Stock
from datetime import datetime, timezone

class StockRepository:
    
    @staticmethod
    def create(db: Session, **kwargs) -> Stock:
        """Créer un nouveau stock"""
        stock = Stock(**kwargs)
        db.add(stock)
        db.commit()
        db.refresh(stock)
        return stock
    
    @staticmethod
    def find_by_id(db: Session, stock_id: int) -> Optional[Stock]:
        """Trouver un stock par ID"""
        return db.query(Stock).filter(Stock.id == stock_id).first()
    
    @staticmethod
    def find_by_pharmacie_medicament(
        db: Session, 
        pharmacie_id: int, 
        medicament_id: int
    ) -> Optional[Stock]:
        """Trouver un stock par pharmacie et médicament"""
        return db.query(Stock).filter(
            Stock.pharmacie_id == pharmacie_id,
            Stock.medicament_id == medicament_id
        ).first()
    
    @staticmethod
    def get_by_pharmacie(db: Session, pharmacie_id: int) -> List[Stock]:
        """Obtenir tous les stocks d'une pharmacie"""
        return db.query(Stock).filter(
            Stock.pharmacie_id == pharmacie_id
        ).all()
    
    @staticmethod
    def update_quantite(
        db: Session, 
        stock_id: int, 
        nouvelle_quantite: int
    ) -> Optional[Stock]:
        """Mettre à jour la quantité d'un stock"""
        stock = StockRepository.find_by_id(db, stock_id)
        if not stock:
            return None
        
        stock.quantite = nouvelle_quantite
        stock.date_maj = datetime.now(timezone.utc)
        db.commit()
        db.refresh(stock)
        return stock
    
    @staticmethod
    def upsert(
        db: Session,
        pharmacie_id: int,
        medicament_id: int,
        quantite: int,
        prix: Optional[float] = None
    ) -> Stock:
        """Créer ou mettre à jour un stock"""
        stock = StockRepository.find_by_pharmacie_medicament(
            db, pharmacie_id, medicament_id
        )
        
        if stock:
            stock.quantite = quantite
            if prix is not None:
                stock.prix = prix
            stock.date_maj = datetime.now(timezone.utc)
        else:
            stock = Stock(
                pharmacie_id=pharmacie_id,
                medicament_id=medicament_id,
                quantite=quantite,
                prix=prix
            )
            db.add(stock)
        
        db.commit()
        db.refresh(stock)
        return stock