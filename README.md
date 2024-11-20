# Zythologue - Base De Données pour Amateurs de Bière

## Contexte du projet
"Tu as une passion dévorante pour la bière artisanale et souhaites découvrir et partager ce monde au-delà de la dégustation : explorer l'histoire derrière chaque brasserie, les ingrédients spécifiques, et les techniques de brassage."

=> Créer une application web/mobile pour organiser et partager cette passion.

## Prérequis
- Docker
- Docker Compose
- DBeaver (ou tout autre client SQL pour interagir avec PostgreSQL)

## Installation
### 1. Clonez le dépôt
`git clone https://github.com/2024-devops-alt-dist/Zytho-CJ.git`

### 2. Lancer/Arrêter container
```
docker-compose up -d
docker-compose down
```
### 3. Configuration PostgreSQL
Utilisez les informations de connexion ci-dessous :
- Nom BDD : zytho_postgres_db
- Utilisateur : admin
- Mot de passe : admin
- Port : 5432 

## Base de données
Vous retrouverez : 
- Un dictionnaire de données définissant les attributs de chaque entité.
- Des règles de gestion décrivant les contraintes et processus métiers.
- Un MCD (Modèle Conceptuel de Données) pour formaliser les entités et leurs relations.
- Un MLD (Modèle Logique de Données) pour préparer le passage au SGBD relationnel.
- Un MPD (Modèle Physique de Données) pour traduire le modèle en tables SQL.

## Requêtes SQL
1) Lister les bières par taux d'alcool, de la plus légère à la plus forte :
```
SELECT id, name AS beer_name, alcool_pourcent
FROM Beer
ORDER BY alcool_pourcent ASC;
```

2) Afficher le nombre de bières par catégorie :
```
SELECT c.id, c.name AS category_name, COUNT(bc.beer_id) AS beer_count
FROM Category c
JOIN Beer_Category bc ON c.id = bc.category_id
GROUP BY c.id
ORDER BY c.id;
```

3) Trouver toutes les bières d'une brasserie donnée :
```
SELECT 
	br.id AS brewery_id,
	br.name AS brewery_name,
	b.id AS beer_id,
    b.name AS beer_name
FROM 
    Beer b
JOIN 
    Brewery br ON b.brewery_id = br.id
WHERE 
    br.name = 'Brasserie La Choulette';
```

4) Lister les utilisateurs et le nombre de bières qu'ils ont ajoutées à leurs favoris :
```
SELECT 
    u.id, 
    u.firstname, 
    COUNT(f.beer_id) AS nombre_favoris
FROM 
    Users u
LEFT JOIN 
    Favorite f ON u.id = f.user_id
GROUP BY 
    u.id
ORDER BY 
    u.id;
```

5) Ajouter une nouvelle bière à la base de données :
```
WITH details_inserted AS (
    INSERT INTO Details_Beer (
        description, color, pays, amertume, douceur, fruite, fermentation,
        conditionnement, contenance, IBU, EBC
    ) 
    VALUES (
        'TEST ADD - Une bière légère avec des notes de miel',
        'Blonde',
        'France',
        2,
        3,
        4,
        'Haute',
        'Bouteille',
        33,
        30,
        15
    )
    RETURNING id
),
beer_inserted AS (
    INSERT INTO Beer (
        name, type, alcool_pourcent, details_beer_id, brewery_id
    ) 
    VALUES (
        'TEST ADD - Blanche au Génépi',
        'Blanche',
        5.5,
        (SELECT id FROM details_inserted),
        1
    )
    RETURNING id
)
INSERT INTO Beer_Category (beer_id, category_id)
VALUES
    ((SELECT id FROM beer_inserted), 1),
    ((SELECT id FROM beer_inserted), 2);
```

6) Afficher les bières et leurs brasseries, ordonnées par pays de la brasserie :
```
SELECT 
    b.name AS beer_name, 
    br.name AS brewery_name, 
    br.country AS brewery_country
FROM 
    Beer b
JOIN 
    Brewery br ON b.brewery_id = br.id
ORDER BY 
    br.country;
```

7) Lister les bières avec leurs ingrédients :
```
SELECT 
	b.id,
    b.name AS beer_name,
    STRING_AGG(i.name, ', ') AS ingredients
FROM 
    Beer b
JOIN 
   Beer_Ingredient bi ON b.id = bi.beer_id
JOIN 
   Ingredient i ON bi.ingredient_id = i.id
GROUP BY 
    b.id
ORDER BY 
    b.id;
```

8) Afficher les brasseries et le nombre de bières qu'elles produisent, pour celles ayant plus de 5 bières :
```
SELECT br.id, br.name AS brewery_name, COUNT(b.id) AS beer_count
FROM Brewery br
JOIN Beer b ON br.id = b.brewery_id
GROUP BY br.id, br.name
HAVING COUNT(b.id) > 5;
```

9) Lister les bières qui n'ont pas encore été ajoutées aux favoris par aucun utilisateur :
```
SELECT b.id, b.name AS beer_name
FROM Beer b
LEFT JOIN Favorite f ON b.id = f.beer_id
WHERE f.beer_id IS NULL
ORDER BY b.id;
```

10) Trouver les bières favorites communes entre deux utilisateurs :
```
SELECT b.id, b.name AS beer_name, COUNT(f.user_id) AS number_of_users
FROM Favorite f
JOIN Beer b ON f.beer_id = b.id
GROUP BY b.name, b.id
HAVING COUNT(f.user_id) > 1
ORDER BY b.id;
```

11) Afficher les brasseries dont les bières ont une moyenne de notes supérieure à une certaine valeur :
```
SELECT br.id, br.name AS brewery_name, AVG(r.note) AS moyenne_note
FROM Brewery br
JOIN Beer b ON br.id = b.brewery_id
JOIN Review r ON b.id = r.beer_id
GROUP BY br.id, br.name
HAVING AVG(r.note) > 4.5
ORDER BY br.id;
```

12) Mettre à jour les informations d'une brasserie :
```
UPDATE Brewery
SET address = '325 boulevard du test', description = 'nouvelle description test - lorem ipsum', schedules = 'Lundi-Samedi, 08:00 - 20:30' 
WHERE name = 'Brasserie du Mont-Blanc';
```

13) Supprimer les photos d'une bière en particulier :
```
DELETE FROM Beer_Picture
WHERE picture_id = 5 AND beer_id = 1;
```
## Manipulations Avancées
### 1. Procédure stockée 
Écrire une procédure stockée permettant à un utilisateur de noter une bière. Si l'utilisateur a déjà noté cette bière, la note est mise à jour ; sinon, une nouvelle note est ajoutée.

Appeller la fonction : 
```
SELECT add_or_update_review(5, 10, 4, 'Je valide');
```

### 1. Trigger 
Valide : 
```
INSERT INTO Beer (name, type, alcool_pourcent, details_beer_id, brewery_id)
VALUES ('Test Beer', 'Blonde', 5, 1, 1);
```
Non-valide : 
```
INSERT INTO Beer (name, type, alcool_pourcent, details_beer_id, brewery_id)
VALUES ('Invalid Beer', 'IPA', 35, 1, 1);
``` 