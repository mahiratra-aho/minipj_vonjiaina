"""
Script pour tester la connexion à PostgreSQL
"""
from sqlalchemy import create_engine, text
from app.config import get_settings

def test_connection():
    print(" Test de connexion à PostgreSQL...\n")
    
    try:
        settings = get_settings()
        print(f" URL de connexion : {settings.DATABASE_URL.replace(settings.DATABASE_URL.split(':')[2].split('@')[0], '***')}")
        
        # Créer la connexion
        engine = create_engine(settings.DATABASE_URL)
        
        # Tester la connexion
        with engine.connect() as connection:
            result = connection.execute(text("SELECT version();"))
            version = result.fetchone()[0]
            print(f"\n Connexion réussie !")
            print(f" Version PostgreSQL : {version[:50]}...\n")
            
            # Tester PostGIS
            result = connection.execute(text("SELECT PostGIS_version();"))
            postgis = result.fetchone()[0]
            print(f" Version PostGIS : {postgis}\n")
            
            # Compter les tables
            result = connection.execute(text("""
                SELECT COUNT(*) 
                FROM information_schema.tables 
                WHERE table_schema = 'public';
            """))
            nb_tables = result.fetchone()[0]
            print(f" Nombre de tables : {nb_tables}")
            
            # Lister les tables
            result = connection.execute(text("""
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = 'public'
                ORDER BY table_name;
            """))
            tables = result.fetchall()
            print(" Tables disponibles :")
            for table in tables:
                print(f"   - {table[0]}")
            
            # Compter les données
            print("\n Données dans les tables :")
            for table in ['pharmacies', 'medicaments', 'stocks']:
                try:
                    result = connection.execute(text(f"SELECT COUNT(*) FROM {table};"))
                    count = result.fetchone()[0]
                    print(f"   - {table}: {count} enregistrements")
                except Exception as e:
                    print(f"   - {table}: Erreur - {e}")
        
        print("\n Tout fonctionne parfaitement !")
        return True
        
    except Exception as e:
        print(f"\n Erreur de connexion : {e}")
        print("\n Vérifiez :")
        print("   1. PostgreSQL est démarré")
        print("   2. Le mot de passe dans .env est correct")
        print("   3. Le nom de la base de données est correct")
        print("   4. L'utilisateur a les permissions nécessaires")
        return False

if __name__ == "__main__":
    test_connection()