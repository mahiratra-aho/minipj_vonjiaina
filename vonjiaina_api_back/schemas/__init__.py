"""
Schémas Pydantic pour validation des données
"""

from .pharmacie import (
    PharmacieBase,
    PharmacieCreate,
    PharmacieUpdate,
    PharmacieResponse
)
from .medicament import (
    MedicamentBase,
    MedicamentCreate,
    MedicamentResponse
)
from .stock import (
    StockBase,
    StockCreate,
    StockUpdate,
    StockResponse
)
from .user import (
    UserCreate,
    UserLogin,
    UserResponse,
    Token
)

__all__ = [
    "PharmacieBase",
    "PharmacieCreate",
    "PharmacieUpdate",
    "PharmacieResponse",
    "MedicamentBase",
    "MedicamentCreate",
    "MedicamentResponse",
    "StockBase",
    "StockCreate",
    "StockUpdate",
    "StockResponse",
    "UserCreate",
    "UserLogin",
    "UserResponse",
    "Token",
]