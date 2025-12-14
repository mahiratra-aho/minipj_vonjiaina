# VONJIAINA

## DESCRIPTION
* VonjiAIna est une application mobile Flutter qui résout le problème de perte de temps pour trouver un médicament en pharmacie.
* Elle permet à un utilisateur (malade ou proche) de rechercher un médicament par nom, d'utiliser sa géolocalisation pour identifier les pharmacies proches ayant le produit en stock (simulé).

## LISTE DES PAGES/SCREENS ET INTERACTIONS UTILISATEUR 

## Version MVP 12/2025

### Écran d'accueil

* Ce que l'utilisateur VOIT :
        - Barre de recherche texte pour le nom du médicament (avec placeholder "Entrez le nom du médicament...").
        - Bouton ou indicateur de géolocalisation (icône localisation + texte "Utiliser ma position actuelle" ou champ pour saisie manuelle d'adresse).
        - Message d'accueil simple : "Trouvez votre médicament en quelques secondes !"// optionnel 

* Ce que l'utilisateur PEUT FAIRE :
        - Saisir un médicament via la barre de recherche.
        - Autoriser la géolocalisation ou entrer une adresse manuellement.
        - Cliquer sur "Rechercher" pour passer à l'écran de résultats.

* Données impliquées : 
        - Suggestions mockées (liste statique en JSON local) ; géoloc via package location.

### Écran de résultats

* Ce que l'utilisateur VOIT :

        - Liste scrollable des pharmacies proches (5-10 items mockés, triés par distance). Chaque item montre : nom de la pharmacie, adresse abrégée, distance/temps estimé ("2 km - 5 min à pied"), indicateur de stock ("Disponible" en vert).
        - Option vue carte : Une map intégrée (google_maps_flutter) avec markers pour chaque pharmacie (zoom sur position utilisateur).
        - Filtre basique en haut (toggle liste/carte, ou tri par distance/horaires).
        - Message si rien trouvé : "Aucun résultat près de vous. Essayez une autre adresse."

* Ce que l'utilisateur PEUT FAIRE :
        - Scroller la liste ou zoomer/panner la carte.
        - Cliquer sur une pharmacie (liste ou marker) pour ouvrir l'écran de détails.
        - Changer de vue (liste et carte) via un bouton.
        - Retourner à la recherche via back button ou barre de navigation.

* Données impliquées : 
        - Pharmacies et stocks mockés (API locale ou Firebase mock ; calcul distance via lat/long fictifs).


## Produit final 2026 (réalisable jusqu'en juillet 2026 voir moins)

### Fonctionnalités patients/acheteurs/corps médicals
• Recherche + liste/carte + itinéraire
• Historique des recherches et ordonnances
• Scan d’ordonnance (photo → OCR + IA extrait les médicaments)
• Réservation / pré-commande du médicament (la pharmacie met de côté 1h ou 2h)
• Comparateur de prix réel entre pharmacies
• Notifications push “Votre médicament vient d’arriver dans telle pharmacie”
• Mode “urgence” (filtre uniquement les pharmacies de garde 24/7)

### Fonctionnalités pharmacies (juste données mockées)
• Dashboard complet :
• Mise à jour stock manuelle ou automatique
• Statistiques des médicaments les plus recherchés dans leur zone
• Chat direct avec le patient
• Gestion des réservations
• Option livraison via partenaires (ex : integration Gozem, Yango, ou livreurs locaux)

### Carte & géolocalisation 
• Google Maps basique
• Carte OpenStreetMap (moins cher à l’échelle) + couche personnalisée des pharmacies de Madagascar
• Calcul itinéraire multimodal (voiture, taxi-brousse, marche, moto)

