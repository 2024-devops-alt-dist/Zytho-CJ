create table Users (
	id serial primary key,
	firstname VARCHAR(80) not null,
	email VARCHAR(200) not null,
	password VARCHAR(250) not null,
	
	constraint check_password_length check (LENGTH(password) >= 8)
);

create table Details_Beer (
	id serial primary key,
	description TEXT,
	color VARCHAR(150) not null,
	pays VARCHAR(150) not null,
	amertume INT check (amertume between 0 and 5),
    douceur INT check (douceur between 0 and 5),
    fruite INT check (fruite between 0 and 5),
    fermentation VARCHAR(150) not null,
    conditionnement VARCHAR(150) not null,
    contenance INT not null,
    IBU INT not null check (IBU between 0 and 120),
    EBC INT not null check (EBC between 0 and 100)
);

create table Brewery (
	id serial primary key,
	name VARCHAR(250) not null unique,
	address VARCHAR(250) not null,            
    country VARCHAR(150) not null,
    description TEXT,  
    schedules VARCHAR(250),  
    url_social_media VARCHAR(850)
    
    -- constraint check_schedules_format check (schedules ~ '^[A-Za-z]+, [0-9]{2}:[0-9]{2} - [0-9]{2}:[0-9]{2}$')  -- ex : "Monday, 08:00 - 18:00"
);

create table Beer (
	id serial primary key,
	name VARCHAR(250) not null,
	type VARCHAR(150) not null,
	alcool_pourcent FLOAT not null,
	
	details_beer_id INT not null,
	brewery_id INT not null,
	constraint fk_details_beer foreign key(details_beer_id) references Details_Beer(id) on delete cascade, 
	constraint fk_brewery foreign key(brewery_id) references Brewery(id) on delete cascade,
	
	constraint unique_beer_per_brewery unique (brewery_id, name),
    -- contrainte taux alcool 1
	constraint check_alcool_pourcent check (alcool_pourcent >= 0 and alcool_pourcent <= 20)
);

-- contrainte taux alcool 2 - Trigger
-- Création fonction
create or replace function check_alcool_pourcent()
returns trigger as $$
BEGIN
    IF NEW.alcool_pourcent < 0 OR NEW.alcool_pourcent > 20 THEN
        RAISE EXCEPTION 'Le taux d''alcool doit être compris entre 0 et 20. Valeur reçue: %', NEW.alcool_pourcent;
    END IF;
    RETURN NEW;
END;
$$ language plpgsql;

-- Création Trigger
create trigger trigger_check_alcool_pourcent 
before insert or update 
on Beer
for each row
execute function check_alcool_pourcent();

create table Category (
	id serial primary key,
	name VARCHAR(150) not null unique
);

create table Beer_Category (
    id serial primary key,
    beer_id INT not null,
    category_id INT not null,
    constraint fk_beer foreign key (beer_id) references Beer(id),
    constraint fk_category foreign key (category_id) references Category(id),
    constraint unique_beer_category unique (beer_id, category_id)
);

create table Review (
	id serial primary key,
	note INT not null check (note between 0 and 5),
	avis TEXT,  
	user_id INT not null,
	beer_id INT not null,
	constraint fk_user foreign key(user_id) references Users(id) on delete cascade, 
	constraint fk_beer foreign key(beer_id) references Beer(id) on delete cascade,
	constraint unique_user_beer UNIQUE (user_id, beer_id)
);

-- Procédure stockée
create or replace function add_or_update_review(
    p_user_id INT, 
    p_beer_id INT, 
    p_note INT, 
    p_avis TEXT
) returns VOID as $$
BEGIN
    -- Vérifier si l'utilisateur a déjà noté cette bière
    IF EXISTS (SELECT 1 FROM Review WHERE user_id = p_user_id AND beer_id = p_beer_id) THEN
        -- Si l'utilisateur a déjà noté la bière, mettre à jour la note et l'avis
        UPDATE Review
        SET note = p_note, avis = p_avis
        WHERE user_id = p_user_id AND beer_id = p_beer_id;
    ELSE
        -- Sinon, ajouter une nouvelle note
        INSERT INTO Review (user_id, beer_id, note, avis)
        VALUES (p_user_id, p_beer_id, p_note, p_avis);
    END IF;
END;
$$ language plpgsql;

create table Favorite (
	id serial primary key,
	user_id INT not null,
	beer_id INT not null,
	constraint fk_user foreign key(user_id) references Users(id) on delete cascade, 
	constraint fk_beer foreign key(beer_id) references Beer(id) on delete cascade,
	constraint unique_favorites unique (user_id, beer_id)
);

create table Picture (
	id serial primary key,
	url VARCHAR(850) not null,
	is_principale BOOLEAN not null default false    
);

create table Beer_Picture (
    id serial primary key,
    beer_id INT not null,
    picture_id INT not null,
    constraint fk_beer foreign key(beer_id) references Beer(id) on delete cascade,
    constraint fk_picture foreign key(picture_id) references Picture(id)
);

create table Brewery_Picture (
    id serial primary key,
    brewery_id INT not null,
    picture_id INT not null,
    constraint fk_brewery foreign key(brewery_id) references Brewery(id) on delete cascade,
    constraint fk_picture foreign key(picture_id) references Picture(id)
);

create table Ingredient (
	id serial primary key,
	name VARCHAR(250) not null    
);

create table Beer_Ingredient (
    id serial primary key,
    beer_id INT not null,
    ingredient_id INT not null,
    constraint fk_beer foreign key(beer_id) references Beer(id),
    constraint fk_ingredient foreign key(ingredient_id) references Ingredient(id)
);

insert into Users (firstname, email, password) values
	('Alice', 'alice@example.com', '123456789'),
	('Bob', 'bob@example.com', '123456789'),
	('Charlie', 'charlie@example.com', '123456789'),
	('David', 'david@example.com', '123456789'),
	('Eva', 'eva@example.com', '123456789'),
	('Adrien', 'adrien@example.com', '123456789'),
	('Grace', 'grace@example.com', '123456789'),
	('Hannah', 'hannah@example.com', '123456789'),
	('Igor', 'igor@example.com', '123456789'),
	('Jack', 'jack@example.com', '123456789'),
	('Kathy', 'kathy@example.com', '123456789'),
	('Liam', 'liam@example.com', '123456789'),
	('Mona', 'mona@example.com', '123456789'),
	('Nina', 'nina@example.com', '123456789'),
	('Oscar', 'oscar@example.com', '123456789');

insert into Brewery (name, address, country, description, schedules, url_social_media)
values
    ('Brasserie du Mont-Blanc', 
    'Lieu-dit Les Biollons, 73590 La Motte-Servolex', 
    'France', 
    'Brasserie artisanale des Alpes, célèbre pour sa bière au génépi et son eau de montagne.', 
    'Lundi-Vendredi, 09:00 - 17:30', 
    'https://www.facebook.com/brasseriedumontblanc'),

    ('Brasserie La Choulette', 
    '50 Rue de la Brasserie, 59283 Hordain', 
    'Belgique', 
    'Brasserie familiale et artisanale, spécialisée dans les bières de garde.', 
    'Lundi-Samedi, 09:00 - 18:00', 
    'https://www.facebook.com/brasserielachoulette'),

    ('Brasserie Demory Paris', 
    '36 Rue de Paradis, 75010 Paris', 
    'France', 
    'Brasserie urbaine produisant des bières contemporaines et des classiques revisités.', 
    'Mardi-Dimanche, 12:00 - 22:00', 
    'https://www.instagram.com/demoryparis'),

    ('Brasserie du Pays Flamand', 
    '22 Rue Jean Monnet, 59113 Blaringhem', 
    'Allemagne', 
    'Fabricant des célèbres bières Anosteké et Wilde Leeuw, dans le respect de la tradition flamande.', 
    'Lundi-Vendredi, 08:30 - 17:00', 
    'https://www.facebook.com/brasseriedupaysflamand'),

    ('Brasserie Castelain', 
    '13 Rue Pasteur, 62410 Bénifontaine', 
    'France', 
    'Réputée pour sa Ch’ti, une bière emblématique du Nord-Pas-de-Calais.', 
    'Lundi-Vendredi, 09:00 - 17:30', 
    'https://www.facebook.com/BrasserieCastelain'),

    ('Brasserie Saint-Germain', 
    '5 Rue Gabriel, 62119 Aix-Noulette', 
    'France', 
    'Fabricant des bières artisanales Jenlain, mélangeant tradition et modernité.', 
    'Lundi-Samedi, 10:00 - 18:00', 
    'https://www.facebook.com/BrasserieSaintGermain'),

    ('Brasserie Lancelot', 
    'Le Roc Saint-André, 56460 Val d’Oust', 
    'Royaume-Uni', 
    'Brasserie bretonne spécialisée dans les bières inspirées de la légende arthurienne.', 
    'Mardi-Dimanche, 10:00 - 19:00', 
    'https://www.instagram.com/brasserielancelot'),

    ('Brasserie de Vézelay', 
    '3 Rue de l''Europe, 89450 Saint-Père', 
    'France', 
    'Brasserie biologique produisant des bières non filtrées dans un cadre naturel.', 
    'Lundi-Vendredi, 09:00 - 18:00', 
    'https://www.facebook.com/BrasseriedeVezelay'),

    ('Brasserie Mira', 
    '33 Avenue de Bordeaux, 33740 Arès', 
    'France', 
    'Brasserie indépendante du Bassin d’Arcachon, connue pour ses bières originales.', 
    'Mardi-Dimanche, 10:00 - 20:00', 
    'https://www.instagram.com/brasseriemira'),

    ('Brasserie Dupont', 
    'Rue Basse, 59380 Tournai-sur-Dive', 
    'USA', 
    'Brasserie traditionnelle française produisant des bières de caractère.', 
    'Lundi-Vendredi, 08:00 - 17:00', 
    'https://www.facebook.com/BrasserieDupont');

insert into Details_Beer (description, color, pays, amertume, douceur, fruite, fermentation, conditionnement, contenance, IBU, EBC)
values
    -- Brasserie du Mont-Blanc
    ('Une bière blanche rafraîchissante au génépi, idéale pour les amateurs de saveurs alpines.', 'Blanche', 'France', 2, 4, 3, 'Haute', 'Bouteille', 33, 15, 10),
    ('Une bière ambrée équilibrée avec des notes maltées et caramélisées.', 'Ambrée', 'France', 3, 3, 2, 'Haute', 'Fût', 50, 25, 20),
    ('Une bière blanche légère aux notes florales.', 'Blanche', 'France', 2, 5, 3, 'Haute', 'Bouteille', 33, 12, 8),
    ('Une bière blonde subtilement épicée.', 'Blonde', 'France', 3, 4, 4, 'Haute', 'Bouteille', 33, 22, 12),
    ('Une bière brune riche aux saveurs de caramel et de fruits noirs.', 'Brune', 'France', 4, 3, 2, 'Haute', 'Fût', 50, 35, 40),
    ('Une bière ambrée aux notes maltées et épicées.', 'Ambrée', 'France', 3, 3, 3, 'Haute', 'Bouteille', 33, 25, 20),
    ('Une bière IPA audacieuse avec des arômes de fruits tropicaux.', 'IPA', 'France', 4, 2, 5, 'Haute', 'Canette', 33, 45, 25),


    -- Brasserie La Choulette
    ('Une bière de garde traditionnelle, ronde et savoureuse, parfaite pour accompagner les plats régionaux.', 'Blonde', 'France', 2, 4, 1, 'Basse', 'Bouteille', 33, 18, 8),
    ('Une bière brune riche, aux notes de chocolat et de café.', 'Brune', 'France', 4, 2, 1, 'Basse', 'Bouteille', 75, 30, 35),

    -- Brasserie Demory Paris
    ('Une bière moderne et légère, idéale pour l’apéritif.', 'Pale Ale', 'France', 2, 3, 4, 'Haute', 'Canette', 33, 20, 15),
    ('Une IPA aromatique avec des notes de fruits tropicaux.', 'IPA', 'France', 4, 2, 5, 'Haute', 'Fût', 50, 45, 25),

    -- Brasserie du Pays Flamand
    ('Une bière blonde sèche et houblonnée, avec une touche d’agrumes.', 'Blonde', 'France', 3, 3, 4, 'Haute', 'Bouteille', 33, 50, 12),
    ('Une bière triple aux notes complexes de fruits secs et d’épices.', 'Triple', 'France', 4, 2, 3, 'Haute', 'Bouteille', 75, 35, 18),

    -- Brasserie Castelain
    ('Une bière blonde douce et maltée, symbole de la région nordique.', 'Blonde', 'France', 2, 5, 2, 'Basse', 'Bouteille', 33, 18, 8),
    ('Une bière ambrée au caractère affirmé, idéale pour les amateurs de bières corsées.', 'Ambrée', 'France', 3, 3, 1, 'Basse', 'Fût', 50, 28, 22),
    ('Une blonde légère et désaltérante.', 'Blonde', 'France', 2, 4, 2, 'Basse', 'Bouteille', 33, 15, 8),
    ('Une bière rousse équilibrée aux arômes de noisette.', 'Rousse', 'France', 3, 3, 3, 'Basse', 'Bouteille', 33, 20, 15),
    ('Une bière triple puissante et complexe.', 'Triple', 'France', 4, 2, 3, 'Haute', 'Fût', 50, 35, 18),
    ('Une bière blanche rafraîchissante avec une touche citronnée.', 'Blanche', 'France', 2, 5, 4, 'Basse', 'Bouteille', 33, 10, 10),


    -- Brasserie Saint-Germain
    ('Une bière artisanale blonde aux arômes floraux et fruités.', 'Blonde', 'France', 3, 4, 5, 'Haute', 'Bouteille', 33, 22, 10),
    ('Une bière noire dense, aux saveurs de réglisse et de cacao.', 'Noire', 'France', 5, 1, 2, 'Haute', 'Bouteille', 75, 55, 40),

    -- Brasserie Lancelot
    ('Une bière blonde bretonne avec une touche de miel.', 'Blonde', 'France', 2, 4, 3, 'Haute', 'Bouteille', 33, 20, 10),
    ('Une bière rousse aux notes de caramel et de noisettes.', 'Rousse', 'France', 3, 3, 2, 'Haute', 'Fût', 50, 30, 25),

    -- Brasserie de Vézelay
    ('Une bière biologique blonde, pure et désaltérante.', 'Blonde', 'France', 2, 4, 3, 'Basse', 'Bouteille', 33, 15, 10),
    ('Une bière blanche légère et légèrement acidulée.', 'Blanche', 'France', 1, 5, 4, 'Basse', 'Bouteille', 33, 10, 8),

    -- Brasserie Mira
    ('Une bière blonde fraîche avec des notes de fruits tropicaux.', 'Blonde', 'France', 2, 4, 5, 'Haute', 'Bouteille', 33, 25, 12),
    ('Une bière IPA puissante et aromatique.', 'IPA', 'France', 4, 2, 5, 'Haute', 'Fût', 50, 50, 30),

    -- Brasserie Dupont
    ('Une bière blonde classique avec une belle amertume et des notes d’agrumes.', 'Blonde', 'France', 3, 3, 4, 'Haute', 'Bouteille', 33, 28, 15),
    ('Une bière brune riche et complexe avec des saveurs de cacao et de café.', 'Brune', 'France', 4, 2, 1, 'Haute', 'Bouteille', 75, 40, 35);

insert into Beer (name, type, alcool_pourcent, details_beer_id, brewery_id)
values
    -- Brasserie du Mont-Blanc
    ('Blanche au Génépi', 'Blanche', 5.9, 1, 1),
    ('Ambrée des Alpes', 'Ambrée', 6.5, 2, 1),
    ('Blanche Florale', 'Blanche', 4.5, 21, 1),
    ('Blonde Epicée', 'Blonde', 5.2, 22, 1),
    ('Brune Gourmande', 'Brune', 6.8, 23, 1),
    ('Ambrée Alpine', 'Ambrée', 6.0, 24, 1),
    ('IPA Tropicale', 'IPA', 7.0, 25, 1),

    -- Brasserie La Choulette
    ('Tradition Blonde', 'Blonde', 6.4, 3, 2),
    ('Brune Prestige', 'Brune', 7.5, 4, 2),

    -- Brasserie Demory Paris
    ('Paris Pale Ale', 'Pale Ale', 5.2, 5, 3),
    ('Tropical IPA', 'IPA', 6.8, 6, 3),

    -- Brasserie du Pays Flamand
    ('Anosteké Blonde', 'Blonde', 8.0, 7, 4),
    ('Anosteké Triple', 'Triple', 9.5, 8, 4),

    -- Brasserie Castelain
    ('Ch’ti Blonde', 'Blonde', 6.4, 9, 5),
    ('Ch’ti Ambrée', 'Ambrée', 6.8, 10, 5),
    ('Blonde Désaltérante', 'Blonde', 4.8, 26, 5),
    ('Rousse Castelain', 'Rousse', 5.5, 27, 5),
    ('Triple du Nord', 'Triple', 8.5, 28, 5),
    ('Blanche Citronnée', 'Blanche', 4.2, 29, 5),

    -- Brasserie Saint-Germain
    ('Jenlain Blonde', 'Blonde', 7.0, 11, 6),
    ('Jenlain Noire', 'Noire', 8.5, 12, 6),

    -- Brasserie Lancelot
    ('Lancelot Blonde', 'Blonde', 6.0, 13, 7),
    ('Lancelot Rousse', 'Rousse', 6.8, 14, 7),

    -- Brasserie de Vézelay
    ('Vézelay Blonde', 'Blonde', 5.2, 15, 8),
    ('Vézelay Blanche', 'Blanche', 4.8, 16, 8),

    -- Brasserie Mira
    ('Mira Blonde', 'Blonde', 5.5, 17, 9),
    ('Mira IPA', 'IPA', 6.9, 18, 9),

    -- Brasserie Dupont
    ('Dupont Blonde', 'Blonde', 6.5, 19, 10),
    ('Dupont Brune', 'Brune', 8.0, 20, 10);

insert into Review (note, avis, user_id, beer_id)
values
    -- Avis pour les bières de la Brasserie du Mont-Blanc
    (4, 'Une bière blanche très rafraîchissante, idéale pour l’été.', 1, 1),
    (5, 'J’adore le goût subtil du génépi, très original.', 2, 1),
    (3, 'Bonne bière, mais un peu trop amère à mon goût.', 3, 2),

    -- Avis pour les bières de la Brasserie La Choulette
    (5, 'La meilleure bière blonde que j’ai goûtée, parfaitement équilibrée.', 4, 3),
    (4, 'Un classique, idéale pour accompagner les repas.', 5, 3),
    (5, 'Une bière brune riche avec des saveurs profondes, un régal.', 6, 4),

    -- Avis pour les bières de la Brasserie Demory Paris
    (3, 'Un peu trop légère à mon goût, mais agréable en apéritif.', 7, 5),
    (4, 'Une Pale Ale sympa avec de beaux arômes.', 8, 5),
    (5, 'Une IPA au top ! Les notes de fruits tropicaux explosent en bouche.', 9, 6),

    -- Avis pour les bières de la Brasserie du Pays Flamand
    (5, 'Anosteké Blonde est une valeur sûre, j’en reprendrai.', 10, 7),
    (4, 'Une triple complexe, très intéressante mais un peu forte.', 11, 8),
    (5, 'Une excellente bière pour les amateurs de sensations fortes.', 12, 8),

    -- Avis pour les bières de la Brasserie Castelain
    (4, 'Une blonde douce et agréable, parfaite pour l’apéritif.', 13, 9),
    (3, 'Une ambrée correcte, mais il manque un peu de caractère.', 14, 10),

    -- Avis pour les bières de la Brasserie Saint-Germain
    (4, 'Une bière artisanale très bien réalisée, avec de beaux arômes.', 15, 11),
    (5, 'Une bière noire absolument sublime, avec des saveurs intenses.', 1, 12),

    -- Avis pour les bières de la Brasserie Lancelot
    (4, 'Lancelot Blonde est une belle découverte, légèrement sucrée.', 2, 13),
    (5, 'Une rousse avec des notes subtiles de caramel, parfaite.', 3, 14),

    -- Avis pour les bières de la Brasserie de Vézelay
    (5, 'Une blonde bio d’une grande pureté, très désaltérante.', 4, 15),
    (4, 'Une blanche légère, agréable en bouche.', 5, 16),

    -- Avis pour les bières de la Brasserie Mira
    (5, 'Une blonde tropicale incroyablement fraîche, un vrai coup de cœur.', 6, 17),
    (4, 'Une IPA bien houblonnée et équilibrée.', 7, 18),

    -- Avis pour les bières de la Brasserie Dupont
    (5, 'Dupont Blonde est un classique indémodable.', 8, 19),
    (4, 'Une brune riche et complexe, mais un peu forte pour moi.', 9, 20);

insert into Category (name)
values
    ('Blonde'),
    ('Brune'),
    ('Blanche'),
    ('Ambrée'),
    ('IPA'),
    ('Rousse'),
    ('Biologique'),
    ('Forte'),
    ('Fruitée'),
    ('Traditionnelle');

insert into Beer_Category (beer_id, category_id)
values
    -- Brasserie du Mont-Blanc
    (1, 3),
    (2, 4),

    -- Brasserie La Choulette
    (3, 1), 
    (3, 10), 
    (4, 2),

    -- Brasserie Demory Paris
    (5, 9), 
    (5, 1), 
    (6, 5), 

    -- Brasserie du Pays Flamand
    (7, 1),
    (7, 9), 
    (8, 8),
    (8, 10),

    -- Brasserie Castelain
    (9, 1),
    (10, 4),

    -- Brasserie Saint-Germain
    (11, 1),  
    (11, 9), 
    (12, 2), 

    -- Brasserie Lancelot
    (13, 1), 
    (14, 6), 

    -- Brasserie de Vézelay
    (15, 7), 
    (15, 1), 
    (16, 3), 

    -- Brasserie Mira
    (17, 1), 
    (17, 9), 
    (18, 5), 
    (18, 8), 

    -- Brasserie Dupont
    (19, 1), 
    (19, 10), 
    (20, 2); 

insert into Ingredient (name)
values
    ('Eau'),
    ('Malt d''orge'),
    ('Malt de blé'),
    ('Houblon'),
    ('Levure'),
    ('Épices'),
    ('Génépi'),
    ('Miel'),
    ('Caramel'),
    ('Fruits rouges'),
    ('Agrumes'),
    ('Coriandre'),
    ('Gingembre'),
    ('Cannelle');

insert into Beer_Ingredient (beer_id, ingredient_id)
values
    -- Brasserie du Mont-Blanc
    (1, 1),
    (1, 3),
    (1, 4),
    (1, 5),
    (2, 1),
    (2, 2),
    (2, 6),
    (2, 7),

    -- Brasserie La Choulette
    (3, 1),
    (3, 2),
    (3, 4),
    (3, 5),
    (4, 1),
    (4, 2),
    (4, 5),
    (4, 9),

    -- Brasserie Demory Paris
    (5, 1),
    (5, 3),
    (5, 4),
    (5, 5),
    (6, 1),
    (6, 2),
    (6, 4),
    (6, 5),
    (6, 11),

    -- Brasserie du Pays Flamand
    (7, 1),
    (7, 2),
    (7, 9),
    (7, 5),
    (8, 1),
    (8, 2),
    (8, 5),
    (8, 6),

    -- Brasserie Castelain
    (9, 1),
    (9, 2),
    (9, 4),
    (9, 5),
    (10, 1),
    (10, 2),
    (10, 5),
    (10, 9),

    -- Brasserie Saint-Germain
    (11, 1),
    (11, 2),
    (11, 4),
    (11, 5),
    (12, 1),
    (12, 2),
    (12, 5),
    (12, 8),

    -- Brasserie Lancelot
    (13, 1),
    (13, 2),
    (13, 4),
    (13, 5),
    (13, 9),
    (14, 1),
    (14, 2),
    (14, 5),
    (14, 10),

    -- Brasserie de Vézelay
    (15, 1),
    (15, 2),
    (15, 4),
    (15, 5),
    (15, 6),
    (16, 1),
    (16, 3),
    (16, 4),
    (16, 5),
    (16, 12),

    -- Brasserie Mira
    (17, 1),
    (17, 2),
    (17, 4),
    (17, 5),
    (17, 11),
    (18, 1),
    (18, 2),
    (18, 4),
    (18, 5),

    -- Brasserie Dupont
    (19, 1),
    (19, 2),
    (19, 4),
    (19, 5),
    (19, 9),
    (20, 1),
    (20, 2),
    (20, 4),
    (20, 5),
    (20, 6);

insert into Favorite (user_id, beer_id)
values
    (12, 13),
    (8, 9),
    (9, 17),
    (6, 5),
    (14, 6),
    (3, 9),
    (5, 6),
    (10, 5),
    (9, 13),
    (1, 20),
    (6, 4),
    (1, 17),
    (12, 17),
    (4, 13),
    (3, 20),
    (9, 15),
    (9, 18),
    (10, 19),
    (15, 9),
    (2, 15),
    (1, 19),
    (15, 18);

insert into Picture (url, is_principale) 
values
    ('image-principale-beer.jpg', true),
    ('image-secondaire-beer.jpeg', false),
    ('image-principale-brasserie.jpg', true),
    ('image-secondaire-brasserie.jpg', false),
    ('test-delete.jpg', false);

insert into Beer_Picture (beer_id, picture_id) 
values
    (1, 1),
    (1, 2),
    (1, 5),
    (2, 1),
    (2, 2),
    (2, 5),
    (3, 1),
    (3, 2),
    (4, 1),
    (4, 2),
    (5, 1),
    (5, 2),
    (6, 1),
    (6, 2),
    (7, 1),
    (7, 2),
    (8, 1),
    (8, 2),
    (9, 1),
    (9, 2),
    (10, 1),
    (10, 2),
    (11, 1),
    (11, 2),
    (12, 1),
    (12, 2),
    (13, 1),
    (13, 2),
    (14, 1),
    (14, 2),
    (15, 1),
    (15, 2),
    (16, 1),
    (16, 2),
    (17, 1),
    (17, 2),
    (18, 1),
    (18, 2),
    (19, 1),
    (19, 2),
    (20, 1),
    (20, 2);

insert into Brewery_Picture (brewery_id, picture_id) 
values
    (1, 3),
    (1, 4),
    (2, 3),
    (2, 4),
    (3, 3),
    (3, 4),
    (4, 3),
    (4, 4),
    (5, 3),
    (5, 4),
    (6, 3),
    (6, 4),
    (7, 3),
    (7, 4),
    (8, 3),
    (8, 4),
    (9, 3),
    (9, 4),
    (10, 3),
    (10, 4);