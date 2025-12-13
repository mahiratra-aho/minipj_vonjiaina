# """
# Script pour initialiser la base de données avec des données de test
# """
# from sqlalchemy.orm import Session
# from app.database import engine, Base, SessionLocal
# from models.pharmacie import Pharmacie
# from models.medicament import Medicament
# from models.stock import Stock
# from geoalchemy2.elements import WKTElement

# def init_db():
#     """Initialiser la base de données"""
    
#     print("Initialisation de la base de données...")
    
#     # Créer toutes les tables
#     print("Création des tables...")
#     Base.metadata.create_all(bind=engine)
#     print("Tables créées")
    
#     # Créer une session
#     db = SessionLocal()
    
#     try:
#         # Vérifier si des données existent déjà
#         pharmacie_count = db.query(Pharmacie).count()
        
#         if pharmacie_count > 0:
#             print(f"  {pharmacie_count} pharmacies existent déjà dans la base")
#             response = input("Voulez-vous réinitialiser ? (oui/non): ")
#             if response.lower() != 'oui':
#                 print(" Initialisation annulée")
#                 return
            
#             # Supprimer toutes les données
#             print("  Suppression des anciennes données...")
#             db.query(Stock).delete()
#             db.query(Medicament).delete()
#             db.query(Pharmacie).delete()
#             db.commit()
#             print(" Données supprimées")
        
#         # Insérer les pharmacies
#         print("\n Insertion des pharmacies...")
#         pharmacies = [
#             Pharmacie(
#                 nom="Pharmacie Analakely",
#                 adresse="101 Avenue de l'Indépendance, Antananarivo",
#                 telephone="020 22 123 45",
#                 email="analakely@pharmacy.mg",
#                 location=WKTElement('POINT(47.5236 -18.9137)', srid=4326),
#                 horaires={
#                     "lundi": "8h-18h",
#                     "mardi": "8h-18h",
#                     "mercredi": "8h-18h",
#                     "jeudi": "8h-18h",
#                     "vendredi": "8h-18h",
#                     "samedi": "8h-12h"
#                 }
#             ),
#             Pharmacie(
#                 nom="Pharmacie Behoririka",
#                 adresse="Rue du Commerce, Antananarivo",
#                 telephone="020 22 678 90",
#                 email="behoririka@pharmacy.mg",
#                 location=WKTElement('POINT(47.5200 -18.9100)', srid=4326),
#                 horaires={
#                     "lundi": "8h-19h",
#                     "mardi": "8h-19h",
#                     "mercredi": "8h-19h",
#                     "jeudi": "8h-19h",
#                     "vendredi": "8h-19h",
#                     "samedi": "8h-13h"
#                 }
#             ),
#             Pharmacie(
#                 nom="Pharmacie 67 Ha",
#                 adresse="Route de l'Université, Antananarivo",
#                 telephone="020 22 456 78",
#                 email="67ha@pharmacy.mg",
#                 location=WKTElement('POINT(47.5280 -18.9050)', srid=4326),
#                 horaires={
#                     "lundi": "7h-20h",
#                     "mardi": "7h-20h",
#                     "mercredi": "7h-20h",
#                     "jeudi": "7h-20h",
#                     "vendredi": "7h-20h",
#                     "samedi": "7h-17h",
#                     "dimanche": "9h-12h"
#                 }
#             ),
#         ]
        
#         for p in pharmacies:
#             db.add(p)
        
#         db.commit()
#         print(f" {len(pharmacies)} pharmacies insérées")
        
#         # Rafraîchir pour obtenir les IDs
#         for p in pharmacies:
#             db.refresh(p)
        
#         # Insérer les médicaments
#         print("\n Insertion des médicaments...")
#         medicaments = [
#             Medicament(
#                 nom_commercial="Doliprane",
#                 dci="Paracétamol",
#                 laboratoire="Sanofi",
#                 forme="Comprimé",
#                 dosage="1000mg",
#                 description="Antalgique et antipyrétique"
#             ),
#             Medicament(
#                 nom_commercial="Efferalgan",
#                 dci="Paracétamol",
#                 laboratoire="UPSA",
#                 forme="Comprimé effervescent",
#                 dosage="500mg",
#                 description="Antalgique et antipyrétique effervescent"
#             ),
#             Medicament(
#                 nom_commercial="Ibuprofène Mylan",
#                 dci="Ibuprofène",
#                 laboratoire="Mylan",
#                 forme="Comprimé",
#                 dosage="400mg",
#                 description="Anti-inflammatoire non stéroïdien"
#             ),
#             Medicament(
#                 nom_commercial="Amoxicilline",
#                 dci="Amoxicilline",
#                 laboratoire="Biogaran",
#                 forme="Gélule",
#                 dosage="500mg",
#                 description="Antibiotique de la famille des pénicillines"
#             ),
#             Medicament(
#                 nom_commercial="Spasfon",
#                 dci="Phloroglucinol",
#                 laboratoire="Sanofi",
#                 forme="Comprimé",
#                 dosage="80mg",
#                 description="Antispasmodique"
#             ),
#             Medicament(
#                 nom_commercial="Ventoline",
#                 dci="Salbutamol",
#                 laboratoire="GSK",
#                 forme="Spray",
#                 dosage="100µg/dose",
#                 description="Bronchodilatateur pour l'asthme"
#             ),
#         ]
        
#         for m in medicaments:
#             db.add(m)
        
#         db.commit()
#         print(f" {len(medicaments)} médicaments insérés")
        
#         # Rafraîchir pour obtenir les IDs
#         for m in medicaments:
#             db.refresh(m)
        
#         # Insérer les stocks
#         print("\n Insertion des stocks...")
#         stocks = [
#             # Pharmacie Analakely
#             Stock(pharmacie_id=pharmacies[0].id, medicament_id=medicaments[0].id, quantite=50, prix=1200),
#             Stock(pharmacie_id=pharmacies[0].id, medicament_id=medicaments[2].id, quantite=30, prix=800),
#             Stock(pharmacie_id=pharmacies[0].id, medicament_id=medicaments[4].id, quantite=25, prix=1500),
            
#             # Pharmacie Behoririka
#             Stock(pharmacie_id=pharmacies[1].id, medicament_id=medicaments[0].id, quantite=20, prix=1150),
#             Stock(pharmacie_id=pharmacies[1].id, medicament_id=medicaments[1].id, quantite=40, prix=950),
#             Stock(pharmacie_id=pharmacies[1].id, medicament_id=medicaments[3].id, quantite=15, prix=2000),
            
#             # Pharmacie 67 Ha
#             Stock(pharmacie_id=pharmacies[2].id, medicament_id=medicaments[3].id, quantite=60, prix=2500),
#             Stock(pharmacie_id=pharmacies[2].id, medicament_id=medicaments[5].id, quantite=10, prix=3500),
#             Stock(pharmacie_id=pharmacies[2].id, medicament_id=medicaments[0].id, quantite=35, prix=1100),
#         ]
        
#         for s in stocks:
#             db.add(s)
        
#         db.commit()
#         print(f" {len(stocks)} stocks insérés")
        
#         print("\n" + "="*50)
#         print("✨ Base de données initialisée avec succès !")
#         print("="*50)
#         print("\n Résumé des données :")
#         print(f"   Pharmacies : {db.query(Pharmacie).count()}")
#         print(f"    Médicaments : {db.query(Medicament).count()}")
#         print(f"    Stocks : {db.query(Stock).count()}")
        
#         # Afficher un exemple de données
#         print("\n Exemple de stock :")
#         first_stock = db.query(Stock).first()
#         if first_stock:
#             print(f"   - Pharmacie: {first_stock.pharmacie.nom}")
#             print(f"   - Médicament: {first_stock.medicament.nom_commercial}")
#             print(f"   - Quantité: {first_stock.quantite}")
#             print(f"   - Prix: {first_stock.prix} Ar")
        
#     except Exception as e:
#         print(f"\n Erreur : {e}")
#         import traceback
#         traceback.print_exc()
#         db.rollback()
#     finally:
#         db.close()

# if __name__ == "__main__":
#     init_db()