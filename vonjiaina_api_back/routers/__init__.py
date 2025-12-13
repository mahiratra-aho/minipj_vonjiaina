"""
Routes API
"""

from .pharmacies import router as pharmacies_router
from .medicaments import router as medicaments_router
from .auth import router as auth_router

__all__ = [
    "pharmacies_router",
    "medicaments_router",
    "auth_router",
]
