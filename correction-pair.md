Correction du projet de Arnaud MAINDRE :

Règles de gestion : OK 
Dictionnaire : OK
MCD-MLD-MPD : OK

Les requêtes SQL : 

- Lister les bières par taux d'alcool, de la plus légère à la plus forte. => OK

- Lister les utilisateurs et le nombre de bières qu'ils ont ajoutées à leurs favoris. => OK

- Afficher les bières et leurs brasseries, ordonnées par pays de la brasserie. => OK

- Lister les bières avec leurs ingrédients. => OK 
Avis perso : 
    "SELECT b."name" AS beer_name,
    i."name" AS ingredient,
    i.type as ingredient"

    => i."name" & i.type, je ne les aurais pas appelés de la même façon car ça porte à confusion. Dans ta table "Ingredient" tu as mis "name" et "type", garde peut être les mêmes intitulés.

- Trouver les bières favorites communes entre deux utilisateurs. => la requête est OK, j'aurais juste inséré plus de fausses données afin de pouvoir vraiment la tester. Ici aucun user n'a en commun des bières favorites avec un autre user

- Afficher les brasseries dont les bières ont une moyenne de notes supérieure à une certaine valeur. => OK 

- Supprimer les photos d'une bière en particulier. => OK