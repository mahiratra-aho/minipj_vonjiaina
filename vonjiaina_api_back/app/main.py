from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import get_settings
from app.database import engine, Base
from routers import pharmacies, auth, medicaments, devices
from utils.firebase_client import init_firebase

settings = get_settings()

# Initialize Firebase if configured
init_firebase()

settings = get_settings()

# Créer les tables
Base.metadata.create_all(bind=engine)

# Application FastAPI
app = FastAPI(
    title=settings.PROJECT_NAME,
    description="API pour trouver des médicaments dans les pharmacies proches",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost",
        "http://localhost:*",
        "http://127.0.0.1",
        "http://127.0.0.1:*",
        "*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)

# Route principale
app.include_router(pharmacies.router, prefix=settings.API_V1_PREFIX)
app.include_router(auth.router, prefix=settings.API_V1_PREFIX)
app.include_router(medicaments.router, prefix=settings.API_V1_PREFIX)
app.include_router(devices.router, prefix=settings.API_V1_PREFIX)
# Admin routes (protected)
from routers import admin as admin_router
app.include_router(admin_router.router, prefix=settings.API_V1_PREFIX)

@app.get("/")
async def root():
    return {
        "message": "API VonjiAIna - Trouvez vos médicaments dans les pharmacies les plus proches",
        "version": "1.0.0",
        "documentation": "/docs",
        "endpoint_principal": "/api/v1/pharmacies/search"
    }

@app.get("/health")
async def health_check():
    return {"status": " API opérationnelle"}