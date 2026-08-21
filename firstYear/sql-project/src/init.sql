-- ============================================================
-- 0. SUPPRESSION DES TABLES (si elles existent déjà)
-- ============================================================
DROP TABLE IF EXISTS VALEUR_MARCHANDE CASCADE;
DROP TABLE IF EXISTS CLASSEMENT CASCADE;
DROP TABLE IF EXISTS STATS_MATCH_EQUIPE CASCADE;
DROP TABLE IF EXISTS MATCH_FOOTBALL CASCADE;
DROP TABLE IF EXISTS JOUEUR CASCADE;
DROP TABLE IF EXISTS CLUB CASCADE;
DROP TABLE IF EXISTS SAISON CASCADE;
DROP TABLE IF EXISTS CHAMPIONNAT CASCADE;

-- ============================================================
--  BASE DE DONNÉES FOOTBALL
--  Création des tables + Peuplement (enrichi)
-- ============================================================

-- ============================================================
-- 1. CRÉATION DES TABLES
-- ============================================================

CREATE TABLE CHAMPIONNAT (
    id          SERIAL PRIMARY KEY,
    nom         VARCHAR(100) NOT NULL,
    pays        VARCHAR(100) NOT NULL,
    logo_url    VARCHAR(255),
    nb_clubs    INT NOT NULL DEFAULT 20
);

CREATE TABLE SAISON (
    id              SERIAL PRIMARY KEY,
    championnat_id  INT NOT NULL,
    annee_debut     INT NOT NULL,
    annee_fin       INT NOT NULL,
    statut          VARCHAR(20) DEFAULT 'en_cours',  -- 'en_cours', 'termine', 'a_venir'
    CONSTRAINT fk_saison_championnat FOREIGN KEY (championnat_id) REFERENCES CHAMPIONNAT(id)
);

CREATE TABLE CLUB (
    id              SERIAL PRIMARY KEY,
    championnat_id  INT NOT NULL,
    nom             VARCHAR(100) NOT NULL,
    ville           VARCHAR(100),
    stade           VARCHAR(100),
    capacite_stade  INT,
    logo_url        VARCHAR(255),
    annee_fondation INT,
    CONSTRAINT fk_club_championnat FOREIGN KEY (championnat_id) REFERENCES CHAMPIONNAT(id)
);

CREATE TABLE JOUEUR (
    id              SERIAL PRIMARY KEY,
    club_id         INT NOT NULL,
    nom             VARCHAR(100) NOT NULL,
    prenom          VARCHAR(100) NOT NULL,
    date_naissance  DATE,
    nationalite     VARCHAR(100),
    poste           VARCHAR(50),
    numero_maillot  INT,
    pied_fort       VARCHAR(10),  -- 'droit', 'gauche', 'ambidextre'
    taille_cm       FLOAT,
    poids_kg        FLOAT,
    CONSTRAINT fk_joueur_club FOREIGN KEY (club_id) REFERENCES CLUB(id)
);

CREATE TABLE MATCH_FOOTBALL (
    id                  SERIAL PRIMARY KEY,
    saison_id           INT NOT NULL,
    club_domicile_id    INT NOT NULL,
    club_exterieur_id   INT NOT NULL,
    date_match          DATE,
    journee             INT,
    score_domicile      INT DEFAULT 0,
    score_exterieur     INT DEFAULT 0,
    statut              VARCHAR(20) DEFAULT 'programme',  -- 'programme', 'en_cours', 'termine'
    stade               VARCHAR(100),
    CONSTRAINT fk_match_saison    FOREIGN KEY (saison_id)         REFERENCES SAISON(id),
    CONSTRAINT fk_match_domicile  FOREIGN KEY (club_domicile_id)  REFERENCES CLUB(id),
    CONSTRAINT fk_match_exterieur FOREIGN KEY (club_exterieur_id) REFERENCES CLUB(id)
);

CREATE TABLE CLASSEMENT (
    id          SERIAL PRIMARY KEY,
    saison_id   INT NOT NULL,
    club_id     INT NOT NULL,
    journee     INT NOT NULL,
    position    INT,
    points      INT DEFAULT 0,
    victoires   INT DEFAULT 0,
    nuls        INT DEFAULT 0,
    defaites    INT DEFAULT 0,
    buts_pour   INT DEFAULT 0,
    buts_contre INT DEFAULT 0,
    diff_buts   INT,
    CONSTRAINT fk_classement_saison FOREIGN KEY (saison_id) REFERENCES SAISON(id),
    CONSTRAINT fk_classement_club   FOREIGN KEY (club_id)   REFERENCES CLUB(id)
);

CREATE TABLE STATS_MATCH_EQUIPE (
    id                  SERIAL PRIMARY KEY,
    match_id            INT NOT NULL,
    club_id             INT NOT NULL,
    possession_pct      INT,
    tirs                INT DEFAULT 0,
    tirs_cadres         INT DEFAULT 0,
    corners             INT DEFAULT 0,
    fautes              INT DEFAULT 0,
    cartons_jaunes      INT DEFAULT 0,
    cartons_rouges      INT DEFAULT 0,
    hors_jeux           INT DEFAULT 0,
    CONSTRAINT fk_stats_match FOREIGN KEY (match_id) REFERENCES MATCH_FOOTBALL(id),
    CONSTRAINT fk_stats_club  FOREIGN KEY (club_id)  REFERENCES CLUB(id)
);

CREATE TABLE VALEUR_MARCHANDE (
    id              SERIAL PRIMARY KEY,
    joueur_id       INT NOT NULL,
    valeur_eur      DECIMAL(15, 2) NOT NULL,
    date_evaluation DATE NOT NULL,
    source          VARCHAR(100),
    CONSTRAINT fk_valeur_joueur FOREIGN KEY (joueur_id) REFERENCES JOUEUR(id)
);


-- ============================================================
-- 2. PEUPLEMENT DES TABLES
-- ============================================================

-- ------------------------------------------------------------
-- CHAMPIONNATS
-- ------------------------------------------------------------
INSERT INTO CHAMPIONNAT (nom, pays, logo_url, nb_clubs) VALUES
('Ligue 1',          'France',    'https://logos.example.com/ligue1.png',    18),
('Premier League',   'Angleterre','https://logos.example.com/epl.png',       20),
('La Liga',          'Espagne',   'https://logos.example.com/laliga.png',    20),
('Bundesliga',       'Allemagne', 'https://logos.example.com/bundesliga.png',18),
('Serie A',          'Italie',    'https://logos.example.com/seriea.png',    20);

-- ------------------------------------------------------------
-- SAISONS
-- ------------------------------------------------------------
INSERT INTO SAISON (championnat_id, annee_debut, annee_fin, statut) VALUES
(1, 2024, 2025, 'en_cours'),   -- id=1
(1, 2023, 2024, 'termine'),    -- id=2
(2, 2024, 2025, 'en_cours'),   -- id=3
(3, 2024, 2025, 'en_cours'),   -- id=4
(4, 2024, 2025, 'en_cours'),   -- id=5
(5, 2024, 2025, 'en_cours');   -- id=6

-- ------------------------------------------------------------
-- CLUBS — Ligue 1 (championnat_id = 1)  → id 1–10
-- ------------------------------------------------------------
INSERT INTO CLUB (championnat_id, nom, ville, stade, capacite_stade, logo_url, annee_fondation) VALUES
(1, 'Paris Saint-Germain',    'Paris',       'Parc des Princes',        47929, 'https://logos.example.com/psg.png',     1970),
(1, 'Olympique de Marseille', 'Marseille',   'Stade Vélodrome',         67394, 'https://logos.example.com/om.png',      1899),
(1, 'Olympique Lyonnais',     'Lyon',        'Groupama Stadium',        59186, 'https://logos.example.com/ol.png',      1950),
(1, 'AS Monaco',              'Monaco',      'Stade Louis-II',          18523, 'https://logos.example.com/asm.png',     1924),
(1, 'LOSC Lille',             'Lille',       'Stade Pierre-Mauroy',     49712, 'https://logos.example.com/losc.png',    1944),
(1, 'Stade Rennais',          'Rennes',      'Roazhon Park',            29778, 'https://logos.example.com/srfc.png',    1901),
(1, 'RC Lens',                'Lens',        'Stade Bollaert-Delelis',  38223, 'https://logos.example.com/rcl.png',     1906),
(1, 'OGC Nice',               'Nice',        'Allianz Riviera',         35624, 'https://logos.example.com/ogcn.png',    1904),
(1, 'Stade de Reims',         'Reims',       'Stade Auguste-Delaune',   21684, 'https://logos.example.com/sdr.png',     1931),
(1, 'Montpellier HSC',        'Montpellier', 'Stade de la Mosson',      32900, 'https://logos.example.com/mhsc.png',    1974);

-- ╔══════════════════════════════════════════════════════════════╗
-- ║                                                              ║
-- ║   ✦  ENRICHISSEMENT GÉNÉRÉ PAR IA  ✦                        ║
-- ║   Tout ce qui suit a été ajouté automatiquement.            ║
-- ║   Le contenu ci-dessus (Ligue 1) est d'origine humaine.     ║
-- ║                                                              ║
-- ╚══════════════════════════════════════════════════════════════╝

-- ------------------------------------------------------------
-- CLUBS — Premier League (championnat_id = 2)  → id 11–20
-- ------------------------------------------------------------
INSERT INTO CLUB (championnat_id, nom, ville, stade, capacite_stade, logo_url, annee_fondation) VALUES
(2, 'Manchester City',    'Manchester',  'Etihad Stadium',        53400, 'https://logos.example.com/mancity.png',  1880),
(2, 'Arsenal',            'Londres',     'Emirates Stadium',      60704, 'https://logos.example.com/arsenal.png',  1886),
(2, 'Liverpool',          'Liverpool',   'Anfield',               53394, 'https://logos.example.com/liverpool.png',1892),
(2, 'Chelsea',            'Londres',     'Stamford Bridge',       40341, 'https://logos.example.com/chelsea.png',  1905),
(2, 'Manchester United',  'Manchester',  'Old Trafford',          74140, 'https://logos.example.com/manutd.png',   1878),
(2, 'Tottenham Hotspur',  'Londres',     'Tottenham Hotspur Stadium',62850,'https://logos.example.com/spurs.png',  1882),
(2, 'Newcastle United',   'Newcastle',   'St. James Park',        52305, 'https://logos.example.com/newcastle.png',1892),
(2, 'Aston Villa',        'Birmingham',  'Villa Park',            42682, 'https://logos.example.com/avilla.png',   1874),
(2, 'Brighton',           'Brighton',    'Amex Stadium',          31876, 'https://logos.example.com/brighton.png', 1901),
(2, 'West Ham United',    'Londres',     'London Stadium',        60000, 'https://logos.example.com/westham.png',  1895);

-- ------------------------------------------------------------
-- CLUBS — La Liga (championnat_id = 3)  → id 21–30
-- ------------------------------------------------------------
INSERT INTO CLUB (championnat_id, nom, ville, stade, capacite_stade, logo_url, annee_fondation) VALUES
(3, 'Real Madrid',        'Madrid',      'Santiago Bernabéu',     81044, 'https://logos.example.com/realmadrid.png',1902),
(3, 'FC Barcelone',       'Barcelone',   'Estadi Olímpic',        54367, 'https://logos.example.com/barca.png',    1899),
(3, 'Atlético de Madrid', 'Madrid',      'Civitas Metropolitano', 68456, 'https://logos.example.com/atletico.png', 1903),
(3, 'Real Sociedad',      'San Sebastián','Reale Arena',          39500, 'https://logos.example.com/rsociedad.png',1909),
(3, 'Athletic Bilbao',    'Bilbao',      'San Mamés',             53289, 'https://logos.example.com/athletic.png', 1898),
(3, 'Villarreal CF',      'Villarreal',  'Estadio de la Cerámica',23500, 'https://logos.example.com/villarreal.png',1923),
(3, 'Séville FC',         'Séville',     'Estadio Ramón Sánchez-Pizjuán',43883,'https://logos.example.com/sevilla.png',1890),
(3, 'Real Betis',         'Séville',     'Estadio Benito Villamarín',60721,'https://logos.example.com/betis.png', 1907),
(3, 'Girona FC',          'Gérone',      'Estadi Montilivi',      13450, 'https://logos.example.com/girona.png',   1930),
(3, 'Valencia CF',        'Valence',     'Estadio de Mestalla',   49430, 'https://logos.example.com/valencia.png', 1919);

-- ------------------------------------------------------------
-- CLUBS — Bundesliga (championnat_id = 4)  → id 31–40
-- ------------------------------------------------------------
INSERT INTO CLUB (championnat_id, nom, ville, stade, capacite_stade, logo_url, annee_fondation) VALUES
(4, 'Bayern Munich',      'Munich',      'Allianz Arena',         75024, 'https://logos.example.com/bayern.png',   1900),
(4, 'Borussia Dortmund',  'Dortmund',    'Signal Iduna Park',     81365, 'https://logos.example.com/bvb.png',      1909),
(4, 'Bayer Leverkusen',   'Leverkusen',  'BayArena',              30210, 'https://logos.example.com/leverkusen.png',1904),
(4, 'RB Leipzig',         'Leipzig',     'Red Bull Arena',        47069, 'https://logos.example.com/leipzig.png',  2009),
(4, 'Borussia M''Gladbach','Mönchengladbach','Borussia-Park',     54042, 'https://logos.example.com/gladbach.png', 1900),
(4, 'Eintracht Francfort','Francfort',   'Deutsche Bank Park',    51500, 'https://logos.example.com/eintracht.png',1899),
(4, 'VfB Stuttgart',      'Stuttgart',   'MHPArena',              60449, 'https://logos.example.com/stuttgart.png',1893),
(4, 'SC Freiburg',        'Fribourg',    'Europa-Park Stadion',   34700, 'https://logos.example.com/freiburg.png', 1904),
(4, 'Union Berlin',       'Berlin',      'Stadion An der Alten Försterei',22012,'https://logos.example.com/unionberlin.png',1906),
(4, 'Werder Brême',       'Brême',       'Weserstadion',          42358, 'https://logos.example.com/werder.png',   1899);

-- ------------------------------------------------------------
-- CLUBS — Serie A (championnat_id = 5)  → id 41–50
-- ------------------------------------------------------------
INSERT INTO CLUB (championnat_id, nom, ville, stade, capacite_stade, logo_url, annee_fondation) VALUES
(5, 'Inter Milan',        'Milan',       'San Siro',              80018, 'https://logos.example.com/inter.png',    1908),
(5, 'AC Milan',           'Milan',       'San Siro',              80018, 'https://logos.example.com/acmilan.png',  1899),
(5, 'Juventus',           'Turin',       'Juventus Stadium',      41507, 'https://logos.example.com/juventus.png', 1897),
(5, 'Napoli',             'Naples',      'Stadio Diego Armando Maradona',54726,'https://logos.example.com/napoli.png',1926),
(5, 'AS Roma',            'Rome',        'Stadio Olimpico',       70634, 'https://logos.example.com/roma.png',     1927),
(5, 'Lazio',              'Rome',        'Stadio Olimpico',       70634, 'https://logos.example.com/lazio.png',    1900),
(5, 'Atalanta',           'Bergame',     'Gewiss Stadium',        24747, 'https://logos.example.com/atalanta.png', 1907),
(5, 'Fiorentina',         'Florence',    'Stadio Artemio Franchi',43147, 'https://logos.example.com/fiorentina.png',1926),
(5, 'Bologne FC',         'Bologne',     'Stadio Renato Dall''Ara',38279,'https://logos.example.com/bologna.png', 1909),
(5, 'Torino FC',          'Turin',       'Stadio Olimpico Grande Torino',28177,'https://logos.example.com/torino.png',1906);


-- ============================================================
-- JOUEURS
-- ============================================================

-- ------------------------------------------------------------
-- JOUEURS — Ligue 1
-- ------------------------------------------------------------
INSERT INTO JOUEUR (club_id, nom, prenom, date_naissance, nationalite, poste, numero_maillot, pied_fort, taille_cm, poids_kg) VALUES
-- PSG (club_id=1)
(1, 'Donnarumma', 'Gianluigi',  '1999-02-25', 'Italienne',   'Gardien',    99, 'droit',   196, 90),
(1, 'Hakimi',     'Achraf',     '1998-11-04', 'Marocaine',   'Défenseur',   2, 'droit',   181, 73),
(1, 'Marquinhos', '',           '1994-05-14', 'Brésilienne', 'Défenseur',   5, 'droit',   183, 75),
(1, 'Vitinha',    '',           '2000-02-13', 'Portugaise',  'Milieu',      17,'droit',   170, 63),
(1, 'Dembélé',   'Ousmane',    '1997-05-15', 'Française',   'Attaquant',  10, 'droit',   178, 67),
-- OM (club_id=2)
(2, 'Pau López',  '',           '1992-12-13', 'Espagnole',   'Gardien',     1, 'droit',   189, 82),
(2, 'Gigot',      'Samuel',     '1993-08-09', 'Française',   'Défenseur',   5, 'droit',   192, 85),
(2, 'Koné',       'Ismaïla',    '2002-09-01', 'Française',   'Milieu',      8, 'droit',   183, 77),
(2, 'Greenwood',  'Mason',      '2001-10-01', 'Anglaise',    'Attaquant',  11, 'droit',   181, 76),
(2, 'Rabiot',     'Adrien',     '1995-04-03', 'Française',   'Milieu',      6, 'gauche',  188, 78),
-- OL (club_id=3)
(3, 'Lopes',      'Anthony',    '1990-10-01', 'Française',   'Gardien',     1, 'droit',   185, 80),
(3, 'Tagliafico', 'Nicolás',    '1992-08-31', 'Argentine',   'Défenseur',   3, 'gauche',  172, 69),
(3, 'Tolisso',    'Corentin',   '1994-08-03', 'Française',   'Milieu',      11,'droit',   181, 76),
(3, 'Lacazette',  'Alexandre',  '1991-05-28', 'Française',   'Attaquant',   9, 'droit',   175, 74),
(3, 'Reine-Adélaïde','Jeff',    '1998-01-17', 'Française',   'Milieu',      8, 'droit',   179, 71),
-- Monaco (club_id=4)
(4, 'Majecki',    'Radoslaw',   '1999-03-01', 'Polonaise',   'Gardien',     1, 'droit',   196, 84),
(4, 'Vanderson',  '',           '2001-07-21', 'Brésilienne', 'Défenseur',   2, 'droit',   172, 68),
(4, 'Camara',     'Youssouf',   '2002-01-29', 'Française',   'Milieu',      8, 'droit',   176, 70),
(4, 'Ben Seghir', 'Eliesse',    '2005-04-09', 'Française',   'Milieu',      10,'gauche',  177, 67),
(4, 'Embolo',     'Breel',      '1997-02-14', 'Suisse',      'Attaquant',   9, 'droit',   187, 83),
-- Lille (club_id=5)
(5, 'Chevalier',  'Lucas',      '1996-06-14', 'Française',   'Gardien',     1, 'droit',   193, 88),
(5, 'Meunier',    'Thomas',     '1991-09-12', 'Belge',       'Défenseur',   24,'droit',   187, 79),
(5, 'André',      'Manuel',     '2001-08-05', 'Portugaise',  'Milieu',      8, 'droit',   174, 66),
(5, 'David',      'Jonathan',   '2000-01-14', 'Canadienne',  'Attaquant',   9, 'droit',   177, 72),
(5, 'Zhegrova',   'Edon',       '1999-03-17', 'Kosovare',    'Attaquant',   11,'droit',   178, 70);

-- ------------------------------------------------------------
-- JOUEURS — Premier League
-- ------------------------------------------------------------
INSERT INTO JOUEUR (club_id, nom, prenom, date_naissance, nationalite, poste, numero_maillot, pied_fort, taille_cm, poids_kg) VALUES
-- Manchester City (club_id=11)
(11, 'Ederson',      '',          '1993-08-17', 'Brésilienne', 'Gardien',     31, 'gauche',  188, 88),
(11, 'Walker',       'Kyle',      '1990-05-28', 'Anglaise',    'Défenseur',    2, 'droit',   178, 70),
(11, 'Rúben Dias',   '',          '1997-05-14', 'Portugaise',  'Défenseur',    3, 'droit',   187, 76),
(11, 'Rodri',        '',          '1996-06-22', 'Espagnole',   'Milieu',       16,'droit',   191, 82),
(11, 'De Bruyne',    'Kevin',     '1991-06-28', 'Belge',       'Milieu',       17,'droit',   181, 68),
(11, 'Haaland',      'Erling',    '2000-07-21', 'Norvégienne', 'Attaquant',    9, 'droit',   194, 88),
-- Arsenal (club_id=12)
(12, 'Raya',         'David',     '1995-09-15', 'Espagnole',   'Gardien',      22,'droit',   183, 78),
(12, 'White',        'Ben',       '1997-10-08', 'Anglaise',    'Défenseur',     4,'droit',   186, 75),
(12, 'Saliba',       'William',   '2001-03-24', 'Française',   'Défenseur',    12,'droit',   192, 82),
(12, 'Odegaard',     'Martin',    '1998-12-17', 'Norvégienne', 'Milieu',        8,'droit',   178, 68),
(12, 'Saka',         'Bukayo',    '2001-09-05', 'Anglaise',    'Attaquant',     7,'gauche',  178, 72),
(12, 'Havertz',      'Kai',       '1999-06-11', 'Allemande',   'Attaquant',    29,'gauche',  189, 75),
-- Liverpool (club_id=13)
(13, 'Alisson',      'Becker',    '1992-10-02', 'Brésilienne', 'Gardien',       1,'droit',   193, 91),
(13, 'Alexander-Arnold','Trent', '1998-10-07', 'Anglaise',    'Défenseur',     66,'droit',   175, 69),
(13, 'Van Dijk',     'Virgil',    '1991-07-08', 'Néerlandaise','Défenseur',     4, 'droit',   193, 92),
(13, 'Mac Allister', 'Alexis',    '1998-12-24', 'Argentine',   'Milieu',        10,'droit',   180, 75),
(13, 'Salah',        'Mohamed',   '1992-06-15', 'Égyptienne',  'Attaquant',     11,'gauche',  175, 71),
(13, 'Núñez',        'Darwin',    '1999-06-24', 'Uruguayenne', 'Attaquant',     9, 'droit',   187, 81),
-- Chelsea (club_id=14)
(14, 'Sánchez',      'Robert',    '1997-11-08', 'Colombienne', 'Gardien',       1,'droit',   197, 94),
(14, 'Reece James',  '',          '1999-12-08', 'Anglaise',    'Défenseur',     24,'droit',   180, 76),
(14, 'Silva',        'Thiago',    '1984-09-22', 'Brésilienne', 'Défenseur',     6, 'droit',   183, 79),
(14, 'Enzo Fernández','',         '2001-01-17', 'Argentine',   'Milieu',        8, 'droit',   178, 73),
(14, 'Palmer',       'Cole',      '2002-05-06', 'Anglaise',    'Milieu',        20,'droit',   183, 72),
(14, 'Jackson',      'Nicolas',   '2001-06-20', 'Sénégalaise', 'Attaquant',     15,'droit',   185, 78),
-- Manchester United (club_id=15)
(15, 'Onana',        'André',     '1996-04-02', 'Camerounaise','Gardien',       24,'droit',   190, 89),
(15, 'Dalot',        'Diogo',     '1999-03-18', 'Portugaise',  'Défenseur',     20,'droit',   183, 72),
(15, 'Lisandro Martínez','',      '1998-01-18', 'Argentine',   'Défenseur',     6, 'droit',   178, 77),
(15, 'Mainoo',       'Kobbie',    '2005-04-19', 'Anglaise',    'Milieu',        37,'droit',   178, 71),
(15, 'Rashford',     'Marcus',    '1997-10-31', 'Anglaise',    'Attaquant',     10,'droit',   185, 80),
(15, 'Højlund',      'Rasmus',    '2003-02-04', 'Danoise',     'Attaquant',     11,'droit',   191, 83);

-- ------------------------------------------------------------
-- JOUEURS — La Liga
-- ------------------------------------------------------------
INSERT INTO JOUEUR (club_id, nom, prenom, date_naissance, nationalite, poste, numero_maillot, pied_fort, taille_cm, poids_kg) VALUES
-- Real Madrid (club_id=21)
(21, 'Courtois',     'Thibaut',   '1992-05-11', 'Belge',       'Gardien',      1, 'droit',   199, 96),
(21, 'Carvajal',     'Dani',      '1992-01-11', 'Espagnole',   'Défenseur',    2, 'droit',   173, 73),
(21, 'Militão',      'Éder',      '1998-01-18', 'Brésilienne', 'Défenseur',    3, 'droit',   186, 78),
(21, 'Modrić',       'Luka',      '1985-09-09', 'Croate',      'Milieu',       10,'droit',   172, 66),
(21, 'Bellingham',   'Jude',      '2003-06-29', 'Anglaise',    'Milieu',        5,'droit',   186, 83),
(21, 'Vinicius Junior','',        '2000-07-12', 'Brésilienne', 'Attaquant',     7,'droit',   176, 73),
(21, 'Mbappé',       'Kylian',    '1998-12-20', 'Française',   'Attaquant',     9,'droit',   182, 78),
-- FC Barcelone (club_id=22)
(22, 'Ter Stegen',   'Marc-André','1992-04-30', 'Allemande',   'Gardien',      1, 'droit',   187, 85),
(22, 'Koundé',       'Jules',     '1998-11-12', 'Française',   'Défenseur',    23,'droit',   178, 73),
(22, 'Christensen',  'Andreas',   '1996-04-10', 'Danoise',     'Défenseur',    15,'droit',   185, 78),
(22, 'Pedri',        '',          '2002-11-25', 'Espagnole',   'Milieu',        8,'droit',   174, 60),
(22, 'Gavi',         '',          '2004-08-05', 'Espagnole',   'Milieu',        6,'gauche',  173, 60),
(22, 'Lewandowski',  'Robert',    '1988-08-21', 'Polonaise',   'Attaquant',     9,'droit',   185, 81),
(22, 'Yamal',        'Lamine',    '2007-07-13', 'Espagnole',   'Attaquant',    19,'droit',   180, 69),
-- Atlético Madrid (club_id=23)
(23, 'Oblak',        'Jan',       '1993-01-07', 'Slovène',     'Gardien',      13,'droit',   188, 87),
(23, 'Nahuel Molina','',          '1998-04-06', 'Argentine',   'Défenseur',    16,'droit',   176, 72),
(23, 'Hermoso',      'Mario',     '1995-06-18', 'Espagnole',   'Défenseur',    22,'gauche',  186, 82),
(23, 'Koke',         '',          '1992-01-08', 'Espagnole',   'Milieu',        6,'droit',   176, 76),
(23, 'De Paul',      'Rodrigo',   '1994-05-24', 'Argentine',   'Milieu',        5,'droit',   185, 79),
(23, 'Álvarez',      'Julián',    '2000-01-31', 'Argentine',   'Attaquant',    19,'droit',   170, 70);

-- ------------------------------------------------------------
-- JOUEURS — Bundesliga
-- ------------------------------------------------------------
INSERT INTO JOUEUR (club_id, nom, prenom, date_naissance, nationalite, poste, numero_maillot, pied_fort, taille_cm, poids_kg) VALUES
-- Bayern Munich (club_id=31)
(31, 'Neuer',        'Manuel',    '1986-03-27', 'Allemande',   'Gardien',      1, 'droit',   193, 93),
(31, 'Kimmich',      'Joshua',    '1995-02-08', 'Allemande',   'Défenseur',    6, 'droit',   177, 73),
(31, 'Upamecano',    'Dayot',     '1998-10-27', 'Française',   'Défenseur',    2, 'droit',   186, 82),
(31, 'Müller',       'Thomas',    '1989-09-13', 'Allemande',   'Milieu',       25,'droit',   186, 75),
(31, 'Musiala',      'Jamal',     '2003-02-26', 'Allemande',   'Milieu',       42,'droit',   183, 71),
(31, 'Kane',         'Harry',     '1993-07-28', 'Anglaise',    'Attaquant',     9,'droit',   188, 86),
-- Borussia Dortmund (club_id=32)
(32, 'Kobel',        'Gregor',    '1997-12-06', 'Suisse',      'Gardien',       1,'droit',   194, 88),
(32, 'Ryerson',      'Julian',    '1997-11-17', 'Américaine',  'Défenseur',     2,'droit',   177, 70),
(32, 'Schlotterbeck','Nico',      '2000-01-01', 'Allemande',   'Défenseur',     4,'gauche',  189, 83),
(32, 'Brandt',       'Julian',    '1996-05-02', 'Allemande',   'Milieu',       19,'gauche',  185, 77),
(32, 'Sancho',       'Jadon',     '2000-03-25', 'Anglaise',    'Attaquant',     10,'droit',  180, 76),
(32, 'Guirassy',     'Serhou',    '1996-03-12', 'Guinéenne',   'Attaquant',      9,'droit',  187, 83),
-- Bayer Leverkusen (club_id=33)
(33, 'Hradecky',     'Lukáš',     '1989-11-24', 'Finlandaise', 'Gardien',       1,'droit',  193, 88),
(33, 'Tapsoba',      'Edmond',    '1999-02-02', 'Burkinabaise','Défenseur',     5,'droit',  189, 84),
(33, 'Hincapié',     'Piero',     '2002-01-09', 'Équatorienne','Défenseur',     3,'gauche', 184, 78),
(33, 'Xhaka',        'Granit',    '1992-09-27', 'Suisse',      'Milieu',        34,'gauche', 186, 82),
(33, 'Wirtz',        'Florian',   '2003-05-03', 'Allemande',   'Milieu',        10,'droit',  180, 74),
(33, 'Boniface',     'Victor',    '2000-12-23', 'Nigériane',   'Attaquant',      9,'droit',  188, 83);

-- ------------------------------------------------------------
-- JOUEURS — Serie A
-- ------------------------------------------------------------
INSERT INTO JOUEUR (club_id, nom, prenom, date_naissance, nationalite, poste, numero_maillot, pied_fort, taille_cm, poids_kg) VALUES
-- Inter Milan (club_id=41)
(41, 'Sommer',       'Yann',      '1988-12-17', 'Suisse',      'Gardien',       1,'droit',   183, 83),
(41, 'Dumfries',     'Denzel',    '1996-04-18', 'Néerlandaise','Défenseur',    2, 'droit',   187, 84),
(41, 'Acerbi',       'Francesco', '1988-02-10', 'Italienne',   'Défenseur',    15,'droit',   192, 90),
(41, 'Barella',      'Nicolò',    '1997-02-07', 'Italienne',   'Milieu',       23,'droit',   172, 68),
(41, 'Çalhanoğlu',   'Hakan',     '1994-02-08', 'Turque',      'Milieu',       20,'gauche',  183, 77),
(41, 'Lautaro Martínez','',       '1997-08-22', 'Argentine',   'Attaquant',    10,'droit',   174, 72),
(41, 'Thuram',       'Marcus',    '1997-08-06', 'Française',   'Attaquant',     9,'droit',   187, 82),
-- AC Milan (club_id=42)
(42, 'Maignan',      'Mike',      '1995-07-03', 'Française',   'Gardien',       1,'droit',   191, 84),
(42, 'Calabria',     'Davide',    '1996-12-06', 'Italienne',   'Défenseur',     2,'droit',   175, 68),
(42, 'Tomori',       'Fikayo',    '1997-12-19', 'Anglaise',    'Défenseur',     23,'droit',  187, 80),
(42, 'Reijnders',    'Tijjani',   '1998-07-29', 'Néerlandaise','Milieu',        14,'droit',  183, 73),
(42, 'Pulisic',      'Christian', '1998-09-18', 'Américaine',  'Milieu',        11,'droit',  177, 70),
(42, 'Morata',       'Álvaro',    '1992-10-23', 'Espagnole',   'Attaquant',     7, 'droit',  187, 81),
-- Juventus (club_id=43)
(43, 'Di Gregorio',  'Michele',   '1997-12-11', 'Italienne',   'Gardien',       1,'droit',  190, 85),
(43, 'Cambiaso',     'Andrea',    '2000-02-22', 'Italienne',   'Défenseur',     27,'gauche', 176, 72),
(43, 'Gatti',        'Federico',  '1998-06-06', 'Italienne',   'Défenseur',      4,'droit',  191, 86),
(43, 'Locatelli',    'Manuel',    '1998-01-08', 'Italienne',   'Milieu',          5,'droit', 185, 77),
(43, 'Yıldız',       'Kenan',     '2005-05-04', 'Turque',      'Milieu',          10,'gauche',184,72),
(43, 'Vlahović',     'Dušan',     '2000-01-28', 'Serbe',       'Attaquant',       9,'droit', 190, 86),
-- Napoli (club_id=44)
(44, 'Meret',        'Alex',      '1997-03-22', 'Italienne',   'Gardien',         1,'droit', 190, 83),
(44, 'Di Lorenzo',   'Giovanni',  '1993-08-04', 'Italienne',   'Défenseur',      22,'droit', 183, 78),
(44, 'Rrahmani',     'Amir',      '1994-02-24', 'Kosovar',     'Défenseur',      13,'droit', 187, 83),
(44, 'Lobotka',      'Stanislav', '1994-11-25', 'Slovaque',    'Milieu',          68,'droit',170, 64),
(44, 'Kvaratskhelia','Khvicha',   '2001-02-12', 'Géorgienne',  'Attaquant',       77,'droit',183, 75),
(44, 'Osimhen',      'Victor',    '1998-12-29', 'Nigériane',   'Attaquant',        9,'droit',185, 78);


-- ============================================================
-- MATCHS
-- ============================================================

-- ------------------------------------------------------------
-- Matchs — Ligue 1, Saison 2024-2025 (saison_id=1)
-- ------------------------------------------------------------
INSERT INTO MATCH_FOOTBALL (saison_id, club_domicile_id, club_exterieur_id, date_match, journee, score_domicile, score_exterieur, statut, stade) VALUES
(1, 1, 2, '2024-08-17', 1, 3, 1, 'termine', 'Parc des Princes'),
(1, 3, 4, '2024-08-17', 1, 2, 2, 'termine', 'Groupama Stadium'),
(1, 5, 6, '2024-08-18', 1, 1, 0, 'termine', 'Stade Pierre-Mauroy'),
(1, 7, 8, '2024-08-18', 1, 0, 1, 'termine', 'Stade Bollaert-Delelis'),
(1, 2, 3, '2024-08-25', 2, 1, 1, 'termine', 'Stade Vélodrome'),
(1, 4, 1, '2024-08-25', 2, 0, 2, 'termine', 'Stade Louis-II'),
(1, 6, 5, '2024-08-25', 2, 2, 0, 'termine', 'Roazhon Park'),
(1, 8, 7, '2024-08-25', 2, 3, 1, 'termine', 'Allianz Riviera'),
(1, 1, 3, '2024-09-01', 3, 2, 1, 'termine', 'Parc des Princes'),
(1, 2, 4, '2024-09-01', 3, 0, 0, 'termine', 'Stade Vélodrome'),
(1, 5, 8, '2024-09-14', 4, 2, 2, 'termine', 'Stade Pierre-Mauroy'),
(1, 7, 6, '2024-09-14', 4, 1, 3, 'termine', 'Stade Bollaert-Delelis'),
(1, 3, 1, '2024-09-22', 5, 1, 4, 'termine', 'Groupama Stadium'),
(1, 4, 5, '2024-09-22', 5, 1, 1, 'termine', 'Stade Louis-II'),
(1, 1, 5, '2024-10-05', 6, 2, 0, 'termine', 'Parc des Princes');

-- ------------------------------------------------------------
-- Matchs — Premier League, Saison 2024-2025 (saison_id=3)
-- ------------------------------------------------------------
INSERT INTO MATCH_FOOTBALL (saison_id, club_domicile_id, club_exterieur_id, date_match, journee, score_domicile, score_exterieur, statut, stade) VALUES
(3, 11, 12, '2024-08-18', 1, 2, 2, 'termine', 'Etihad Stadium'),
(3, 13, 14, '2024-08-18', 1, 3, 1, 'termine', 'Anfield'),
(3, 15, 16, '2024-08-18', 1, 0, 2, 'termine', 'Old Trafford'),
(3, 17, 18, '2024-08-18', 1, 3, 0, 'termine', 'St. James Park'),
(3, 12, 13, '2024-08-25', 2, 1, 2, 'termine', 'Emirates Stadium'),
(3, 14, 11, '2024-08-25', 2, 0, 3, 'termine', 'Stamford Bridge'),
(3, 16, 17, '2024-08-25', 2, 1, 1, 'termine', 'Tottenham Hotspur Stadium'),
(3, 18, 15, '2024-08-25', 2, 2, 1, 'termine', 'Villa Park'),
(3, 11, 13, '2024-09-22', 3, 2, 2, 'termine', 'Etihad Stadium'),
(3, 12, 14, '2024-09-22', 3, 3, 0, 'termine', 'Emirates Stadium');

-- ------------------------------------------------------------
-- Matchs — La Liga, Saison 2024-2025 (saison_id=4)
-- ------------------------------------------------------------
INSERT INTO MATCH_FOOTBALL (saison_id, club_domicile_id, club_exterieur_id, date_match, journee, score_domicile, score_exterieur, statut, stade) VALUES
(4, 21, 22, '2024-08-24', 1, 2, 1, 'termine', 'Santiago Bernabéu'),
(4, 23, 24, '2024-08-24', 1, 3, 0, 'termine', 'Civitas Metropolitano'),
(4, 25, 26, '2024-08-25', 1, 1, 1, 'termine', 'San Mamés'),
(4, 22, 23, '2024-08-31', 2, 1, 2, 'termine', 'Estadi Olímpic'),
(4, 21, 23, '2024-09-21', 3, 3, 1, 'termine', 'Santiago Bernabéu'),
(4, 24, 25, '2024-09-21', 3, 2, 0, 'termine', 'Reale Arena'),
(4, 22, 21, '2024-10-26', 4, 0, 4, 'termine', 'Estadi Olímpic');

-- ------------------------------------------------------------
-- Matchs — Bundesliga, Saison 2024-2025 (saison_id=5)
-- ------------------------------------------------------------
INSERT INTO MATCH_FOOTBALL (saison_id, club_domicile_id, club_exterieur_id, date_match, journee, score_domicile, score_exterieur, statut, stade) VALUES
(5, 31, 32, '2024-08-30', 1, 3, 2, 'termine', 'Allianz Arena'),
(5, 33, 34, '2024-08-31', 1, 3, 2, 'termine', 'BayArena'),
(5, 35, 36, '2024-09-01', 1, 1, 2, 'termine', 'Borussia-Park'),
(5, 32, 33, '2024-09-21', 2, 1, 4, 'termine', 'Signal Iduna Park'),
(5, 31, 33, '2024-11-09', 3, 1, 0, 'termine', 'Allianz Arena');

-- ------------------------------------------------------------
-- Matchs — Serie A, Saison 2024-2025 (saison_id=6)
-- ------------------------------------------------------------
INSERT INTO MATCH_FOOTBALL (saison_id, club_domicile_id, club_exterieur_id, date_match, journee, score_domicile, score_exterieur, statut, stade) VALUES
(6, 41, 42, '2024-09-22', 1, 2, 1, 'termine', 'San Siro'),
(6, 43, 44, '2024-09-21', 1, 0, 0, 'termine', 'Juventus Stadium'),
(6, 47, 48, '2024-09-22', 1, 2, 3, 'termine', 'Gewiss Stadium'),
(6, 42, 43, '2024-10-19', 2, 1, 0, 'termine', 'San Siro'),
(6, 44, 41, '2024-10-19', 2, 0, 1, 'termine', 'Stadio Diego Armando Maradona');


-- ============================================================
-- STATS_MATCH_EQUIPE (Ligue 1 – données d'origine)
-- ============================================================
INSERT INTO STATS_MATCH_EQUIPE (match_id, club_id, possession_pct, tirs, tirs_cadres, corners, fautes, cartons_jaunes, cartons_rouges, hors_jeux) VALUES
-- Match 1 : PSG 3-1 OM
(1, 1, 62, 18, 10, 8, 11, 2, 0, 4),
(1, 2, 38,  9,  4, 3, 13, 3, 0, 2),
-- Match 2 : OL 2-2 Monaco
(2, 3, 54, 14,  6, 5,  9, 1, 0, 3),
(2, 4, 46, 12,  5, 4, 10, 2, 0, 1),
-- Match 3 : Lille 1-0 Rennes
(3, 5, 51, 11,  5, 6,  8, 1, 0, 2),
(3, 6, 49, 10,  3, 4,  9, 2, 1, 1),
-- Match 4 : Lens 0-1 Nice
(4, 7, 48, 10,  3, 5, 12, 2, 0, 3),
(4, 8, 52, 13,  6, 7,  8, 1, 0, 1),
-- Match 5 : OM 1-1 OL
(5, 2, 44, 11,  4, 4, 14, 3, 0, 2),
(5, 3, 56, 15,  7, 6, 10, 1, 0, 3),
-- Match 6 : Monaco 0-2 PSG
(6, 4, 40,  8,  2, 3, 15, 4, 1, 1),
(6, 1, 60, 16,  9, 7,  7, 0, 0, 2),
-- Match 9 : PSG 2-1 OL
(9, 1, 58, 17,  9, 7, 10, 1, 0, 3),
(9, 3, 42,  9,  4, 3, 12, 2, 0, 1),
-- Match 13 : OL 1-4 PSG
(13, 3, 41, 10, 5, 4, 13, 2, 0, 2),
(13, 1, 59, 19,11, 9,  8, 1, 0, 4);

-- Premier League – quelques stats
INSERT INTO STATS_MATCH_EQUIPE (match_id, club_id, possession_pct, tirs, tirs_cadres, corners, fautes, cartons_jaunes, cartons_rouges, hors_jeux) VALUES
-- Match 16 : Man City 2-2 Arsenal
(16, 11, 58, 16,  7, 7,  9, 1, 0, 3),
(16, 12, 42, 12,  6, 4, 11, 2, 0, 2),
-- Match 17 : Liverpool 3-1 Chelsea
(17, 13, 55, 18,  9, 8,  8, 1, 0, 4),
(17, 14, 45, 10,  4, 3, 12, 3, 0, 1),
-- Match 25 : Man City 2-2 Liverpool
(25, 11, 53, 15,  7, 6, 10, 2, 0, 3),
(25, 13, 47, 14,  7, 5,  9, 1, 0, 2);

-- La Liga – quelques stats
INSERT INTO STATS_MATCH_EQUIPE (match_id, club_id, possession_pct, tirs, tirs_cadres, corners, fautes, cartons_jaunes, cartons_rouges, hors_jeux) VALUES
-- Match 26 : Real Madrid 2-1 Barcelone
(26, 21, 52, 14,  7, 6, 10, 2, 0, 3),
(26, 22, 48, 12,  5, 5, 11, 2, 1, 2),
-- Match 32 : Barcelone 0-4 Real Madrid
(32, 22, 49, 11,  3, 4, 14, 3, 1, 1),
(32, 21, 51, 20, 12, 9,  8, 1, 0, 5);

-- Bundesliga – quelques stats
INSERT INTO STATS_MATCH_EQUIPE (match_id, club_id, possession_pct, tirs, tirs_cadres, corners, fautes, cartons_jaunes, cartons_rouges, hors_jeux) VALUES
-- Match 33 : Bayern 3-2 BVB
(33, 31, 57, 17,  9, 8,  9, 1, 0, 4),
(33, 32, 43, 13,  6, 4, 12, 3, 0, 2);


-- ============================================================
-- CLASSEMENT
-- ============================================================

-- Ligue 1 (saison_id=1) – après journée 6
INSERT INTO CLASSEMENT (saison_id, club_id, journee, position, points, victoires, nuls, defaites, buts_pour, buts_contre) VALUES
(1,  1, 6,  1, 16, 5, 1, 0, 15,  5),
(1,  8, 6,  2, 13, 4, 1, 1, 11,  6),
(1,  6, 6,  3, 12, 4, 0, 2,  9,  7),
(1,  5, 6,  4, 11, 3, 2, 1, 10,  8),
(1,  2, 6,  5, 10, 3, 1, 2,  8,  8),
(1,  4, 6,  6,  8, 2, 2, 2,  6,  9),
(1,  3, 6,  7,  7, 2, 1, 3,  9, 11),
(1,  7, 6,  8,  4, 1, 1, 4,  5, 12),
(1,  9, 6,  9,  3, 1, 0, 5,  4, 13),
(1, 10, 6, 10,  2, 0, 2, 4,  3, 11);

-- Premier League (saison_id=3) – après journée 3
INSERT INTO CLASSEMENT (saison_id, club_id, journee, position, points, victoires, nuls, defaites, buts_pour, buts_contre) VALUES
(3, 13, 3,  1,  7, 2, 1, 0,  8,  3),
(3, 12, 3,  2,  7, 2, 1, 0,  6,  2),
(3, 11, 3,  3,  5, 1, 2, 0,  7,  4),
(3, 17, 3,  4,  6, 2, 0, 1,  6,  3),
(3, 18, 3,  5,  6, 2, 0, 1,  5,  4),
(3, 16, 3,  6,  4, 1, 1, 1,  3,  3),
(3, 14, 3,  7,  3, 1, 0, 2,  3,  7),
(3, 15, 3,  8,  0, 0, 0, 3,  2,  8),
(3, 19, 3,  9,  1, 0, 1, 2,  2,  6),
(3, 20, 3, 10,  1, 0, 1, 2,  3,  7);

-- La Liga (saison_id=4) – après journée 4
INSERT INTO CLASSEMENT (saison_id, club_id, journee, position, points, victoires, nuls, defaites, buts_pour, buts_contre) VALUES
(4, 21, 4,  1, 10, 3, 1, 0, 12,  3),
(4, 23, 4,  2,  9, 3, 0, 1,  9,  4),
(4, 24, 4,  3,  6, 2, 0, 2,  5,  6),
(4, 22, 4,  4,  3, 1, 0, 3,  5, 10),
(4, 25, 4,  5,  4, 1, 1, 2,  4,  7),
(4, 26, 4,  6,  4, 1, 1, 2,  3,  5),
(4, 27, 4,  7,  3, 1, 0, 3,  4,  8),
(4, 28, 4,  8,  3, 1, 0, 3,  3,  7),
(4, 29, 4,  9,  2, 0, 2, 2,  3,  6),
(4, 30, 4, 10,  1, 0, 1, 3,  2,  9);

-- Bundesliga (saison_id=5) – après journée 3
INSERT INTO CLASSEMENT (saison_id, club_id, journee, position, points, victoires, nuls, defaites, buts_pour, buts_contre) VALUES
(5, 33, 3,  1,  9, 3, 0, 0, 10,  3),
(5, 31, 3,  2,  6, 2, 0, 1,  7,  4),
(5, 36, 3,  3,  6, 2, 0, 1,  6,  4),
(5, 32, 3,  4,  3, 1, 0, 2,  5,  8),
(5, 34, 3,  5,  3, 1, 0, 2,  4,  7),
(5, 35, 3,  6,  3, 1, 0, 2,  3,  6),
(5, 37, 3,  7,  3, 1, 0, 2,  3,  5),
(5, 38, 3,  8,  3, 1, 0, 2,  3,  6),
(5, 39, 3,  9,  0, 0, 0, 3,  2,  8),
(5, 40, 3, 10,  0, 0, 0, 3,  1,  9);

-- Serie A (saison_id=6) – après journée 2
INSERT INTO CLASSEMENT (saison_id, club_id, journee, position, points, victoires, nuls, defaites, buts_pour, buts_contre) VALUES
(6, 41, 2,  1,  6, 2, 0, 0,  4,  1),
(6, 47, 2,  2,  3, 1, 0, 1,  5,  4),
(6, 42, 2,  3,  3, 1, 0, 1,  2,  2),
(6, 43, 2,  4,  1, 0, 1, 1,  1,  2),
(6, 44, 2,  5,  1, 0, 1, 1,  0,  1),
(6, 45, 2,  6,  0, 0, 0, 2,  1,  4),
(6, 46, 2,  7,  0, 0, 0, 2,  1,  4),
(6, 48, 2,  8,  3, 1, 0, 1,  3,  2),
(6, 49, 2,  9,  0, 0, 0, 2,  0,  3),
(6, 50, 2, 10,  0, 0, 0, 2,  0,  3);


-- ============================================================
-- VALEURS MARCHANDES
-- ============================================================

-- Ligue 1 (joueurs 1–25 — données d'origine)
INSERT INTO VALEUR_MARCHANDE (joueur_id, valeur_eur, date_evaluation, source) VALUES
( 1,  55000000.00, '2025-01-01', 'Transfermarkt'),
( 2,  70000000.00, '2025-01-01', 'Transfermarkt'),
( 3,  40000000.00, '2025-01-01', 'Transfermarkt'),
( 4,  65000000.00, '2025-01-01', 'Transfermarkt'),
( 5,  80000000.00, '2025-01-01', 'Transfermarkt'),
( 6,  12000000.00, '2025-01-01', 'Transfermarkt'),
( 7,  18000000.00, '2025-01-01', 'Transfermarkt'),
( 8,  22000000.00, '2025-01-01', 'Transfermarkt'),
( 9,  55000000.00, '2025-01-01', 'Transfermarkt'),
(10,  20000000.00, '2025-01-01', 'Transfermarkt'),
(11,  10000000.00, '2025-01-01', 'Transfermarkt'),
(12,  15000000.00, '2025-01-01', 'Transfermarkt'),
(13,  18000000.00, '2025-01-01', 'Transfermarkt'),
(14,  22000000.00, '2025-01-01', 'Transfermarkt'),
(15,  25000000.00, '2025-01-01', 'Transfermarkt'),
(16,   8000000.00, '2025-01-01', 'Transfermarkt'),
(17,  20000000.00, '2025-01-01', 'Transfermarkt'),
(18,  30000000.00, '2025-01-01', 'Transfermarkt'),
(19,  45000000.00, '2025-01-01', 'Transfermarkt'),
(20,  30000000.00, '2025-01-01', 'Transfermarkt'),
(21,  12000000.00, '2025-01-01', 'Transfermarkt'),
(22,  10000000.00, '2025-01-01', 'Transfermarkt'),
(23,  35000000.00, '2025-01-01', 'Transfermarkt'),
(24,  60000000.00, '2025-01-01', 'Transfermarkt'),
(25,  30000000.00, '2025-01-01', 'Transfermarkt');

-- Premier League (joueurs 26–55)
INSERT INTO VALEUR_MARCHANDE (joueur_id, valeur_eur, date_evaluation, source) VALUES
(26,  25000000.00, '2025-01-01', 'Transfermarkt'),  -- Ederson
(27,  35000000.00, '2025-01-01', 'Transfermarkt'),  -- Walker
(28,  70000000.00, '2025-01-01', 'Transfermarkt'),  -- Rúben Dias
(29, 120000000.00, '2025-01-01', 'Transfermarkt'),  -- Rodri
(30, 150000000.00, '2025-01-01', 'Transfermarkt'),  -- De Bruyne
(31, 200000000.00, '2025-01-01', 'Transfermarkt'),  -- Haaland
(32,  28000000.00, '2025-01-01', 'Transfermarkt'),  -- Raya
(33,  55000000.00, '2025-01-01', 'Transfermarkt'),  -- Ben White
(34,  80000000.00, '2025-01-01', 'Transfermarkt'),  -- Saliba
(35, 130000000.00, '2025-01-01', 'Transfermarkt'),  -- Odegaard
(36, 150000000.00, '2025-01-01', 'Transfermarkt'),  -- Saka
(37,  80000000.00, '2025-01-01', 'Transfermarkt'),  -- Havertz
(38,  30000000.00, '2025-01-01', 'Transfermarkt'),  -- Alisson
(39,  80000000.00, '2025-01-01', 'Transfermarkt'),  -- Trent Alexander-Arnold
(40,  50000000.00, '2025-01-01', 'Transfermarkt'),  -- Van Dijk
(41,  80000000.00, '2025-01-01', 'Transfermarkt'),  -- Mac Allister
(42, 100000000.00, '2025-01-01', 'Transfermarkt'),  -- Salah
(43,  80000000.00, '2025-01-01', 'Transfermarkt'),  -- Núñez
(44,  20000000.00, '2025-01-01', 'Transfermarkt'),  -- Sánchez
(45,  55000000.00, '2025-01-01', 'Transfermarkt'),  -- Reece James
(46,   5000000.00, '2025-01-01', 'Transfermarkt'),  -- Thiago Silva
(47, 120000000.00, '2025-01-01', 'Transfermarkt'),  -- Enzo Fernández
(48, 110000000.00, '2025-01-01', 'Transfermarkt'),  -- Cole Palmer
(49,  60000000.00, '2025-01-01', 'Transfermarkt'),  -- Jackson
(50,  18000000.00, '2025-01-01', 'Transfermarkt'),  -- Onana
(51,  30000000.00, '2025-01-01', 'Transfermarkt'),  -- Dalot
(52,  55000000.00, '2025-01-01', 'Transfermarkt'),  -- Lisandro Martínez
(53,  60000000.00, '2025-01-01', 'Transfermarkt'),  -- Mainoo
(54,  60000000.00, '2025-01-01', 'Transfermarkt'),  -- Rashford
(55,  80000000.00, '2025-01-01', 'Transfermarkt');  -- Højlund

-- La Liga (joueurs 56–75)
INSERT INTO VALEUR_MARCHANDE (joueur_id, valeur_eur, date_evaluation, source) VALUES
(56,  20000000.00, '2025-01-01', 'Transfermarkt'),  -- Courtois
(57,  25000000.00, '2025-01-01', 'Transfermarkt'),  -- Carvajal
(58,  70000000.00, '2025-01-01', 'Transfermarkt'),  -- Militão
(59,  25000000.00, '2025-01-01', 'Transfermarkt'),  -- Modrić
(60, 180000000.00, '2025-01-01', 'Transfermarkt'),  -- Bellingham
(61, 180000000.00, '2025-01-01', 'Transfermarkt'),  -- Vinicius Jr
(62, 200000000.00, '2025-01-01', 'Transfermarkt'),  -- Mbappé
(63,  20000000.00, '2025-01-01', 'Transfermarkt'),  -- Ter Stegen
(64,  60000000.00, '2025-01-01', 'Transfermarkt'),  -- Koundé
(65,  35000000.00, '2025-01-01', 'Transfermarkt'),  -- Christensen
(66, 120000000.00, '2025-01-01', 'Transfermarkt'),  -- Pedri
(67, 100000000.00, '2025-01-01', 'Transfermarkt'),  -- Gavi
(68,  25000000.00, '2025-01-01', 'Transfermarkt'),  -- Lewandowski
(69, 250000000.00, '2025-01-01', 'Transfermarkt'),  -- Lamine Yamal
(70,  30000000.00, '2025-01-01', 'Transfermarkt'),  -- Oblak
(71,  35000000.00, '2025-01-01', 'Transfermarkt'),  -- Nahuel Molina
(72,  18000000.00, '2025-01-01', 'Transfermarkt'),  -- Hermoso
(73,  20000000.00, '2025-01-01', 'Transfermarkt'),  -- Koke
(74,  60000000.00, '2025-01-01', 'Transfermarkt'),  -- De Paul
(75,  80000000.00, '2025-01-01', 'Transfermarkt');  -- Julián Álvarez

-- Bundesliga (joueurs 76–93)
INSERT INTO VALEUR_MARCHANDE (joueur_id, valeur_eur, date_evaluation, source) VALUES
(76,  10000000.00, '2025-01-01', 'Transfermarkt'),  -- Neuer
(77,  70000000.00, '2025-01-01', 'Transfermarkt'),  -- Kimmich
(78,  70000000.00, '2025-01-01', 'Transfermarkt'),  -- Upamecano
(79,  12000000.00, '2025-01-01', 'Transfermarkt'),  -- Müller
(80, 150000000.00, '2025-01-01', 'Transfermarkt'),  -- Musiala
(81, 100000000.00, '2025-01-01', 'Transfermarkt'),  -- Kane
(82,  35000000.00, '2025-01-01', 'Transfermarkt'),  -- Kobel
(83,  20000000.00, '2025-01-01', 'Transfermarkt'),  -- Ryerson
(84,  40000000.00, '2025-01-01', 'Transfermarkt'),  -- Schlotterbeck
(85,  50000000.00, '2025-01-01', 'Transfermarkt'),  -- Brandt
(86,  50000000.00, '2025-01-01', 'Transfermarkt'),  -- Sancho
(87,  60000000.00, '2025-01-01', 'Transfermarkt'),  -- Guirassy
(88,  20000000.00, '2025-01-01', 'Transfermarkt'),  -- Hradecky
(89,  50000000.00, '2025-01-01', 'Transfermarkt'),  -- Tapsoba
(90,  40000000.00, '2025-01-01', 'Transfermarkt'),  -- Hincapié
(91,  55000000.00, '2025-01-01', 'Transfermarkt'),  -- Xhaka
(92, 150000000.00, '2025-01-01', 'Transfermarkt'),  -- Wirtz
(93,  70000000.00, '2025-01-01', 'Transfermarkt');  -- Boniface

-- Serie A (joueurs 94–118)
INSERT INTO VALEUR_MARCHANDE (joueur_id, valeur_eur, date_evaluation, source) VALUES
( 94,  18000000.00, '2025-01-01', 'Transfermarkt'),  -- Sommer
( 95,  40000000.00, '2025-01-01', 'Transfermarkt'),  -- Dumfries
( 96,  10000000.00, '2025-01-01', 'Transfermarkt'),  -- Acerbi
( 97,  80000000.00, '2025-01-01', 'Transfermarkt'),  -- Barella
( 98,  60000000.00, '2025-01-01', 'Transfermarkt'),  -- Çalhanoğlu
( 99, 100000000.00, '2025-01-01', 'Transfermarkt'),  -- Lautaro Martínez
(100,  60000000.00, '2025-01-01', 'Transfermarkt'),  -- Marcus Thuram
(101,  30000000.00, '2025-01-01', 'Transfermarkt'),  -- Maignan
(102,  15000000.00, '2025-01-01', 'Transfermarkt'),  -- Calabria
(103,  45000000.00, '2025-01-01', 'Transfermarkt'),  -- Tomori
(104,  60000000.00, '2025-01-01', 'Transfermarkt'),  -- Reijnders
(105,  50000000.00, '2025-01-01', 'Transfermarkt'),  -- Pulisic
(106,  25000000.00, '2025-01-01', 'Transfermarkt'),  -- Morata
(107,  20000000.00, '2025-01-01', 'Transfermarkt'),  -- Di Gregorio
(108,  40000000.00, '2025-01-01', 'Transfermarkt'),  -- Cambiaso
(109,  30000000.00, '2025-01-01', 'Transfermarkt'),  -- Gatti
(110,  35000000.00, '2025-01-01', 'Transfermarkt'),  -- Locatelli
(111, 100000000.00, '2025-01-01', 'Transfermarkt'),  -- Kenan Yıldız
(112,  80000000.00, '2025-01-01', 'Transfermarkt'),  -- Vlahović
(113,  12000000.00, '2025-01-01', 'Transfermarkt'),  -- Meret
(114,  20000000.00, '2025-01-01', 'Transfermarkt'),  -- Di Lorenzo
(115,  25000000.00, '2025-01-01', 'Transfermarkt'),  -- Rrahmani
(116,  45000000.00, '2025-01-01', 'Transfermarkt'),  -- Lobotka
(117, 100000000.00, '2025-01-01', 'Transfermarkt'),  -- Kvaratskhelia
(118,  70000000.00, '2025-01-01', 'Transfermarkt');  -- Osimhen

-- Historique de valeurs — quelques stars
INSERT INTO VALEUR_MARCHANDE (joueur_id, valeur_eur, date_evaluation, source) VALUES
-- Dembélé (id=5)
( 5,  90000000.00, '2024-06-01', 'Transfermarkt'),
-- Jonathan David (id=24)
(24,  55000000.00, '2024-06-01', 'Transfermarkt'),
-- Ben Seghir (id=19)
(19,  40000000.00, '2024-06-01', 'Transfermarkt'),
-- Haaland (id=31)
(31, 180000000.00, '2024-06-01', 'Transfermarkt'),
-- Vinicius Jr (id=61)
(61, 150000000.00, '2024-06-01', 'Transfermarkt'),
-- Mbappé (id=62)
(62, 180000000.00, '2024-06-01', 'Transfermarkt'),
-- Lamine Yamal (id=69)
(69, 150000000.00, '2024-06-01', 'Transfermarkt'),
-- Wirtz (id=92)
(92, 120000000.00, '2024-06-01', 'Transfermarkt'),
-- Bellingham (id=60)
(60, 150000000.00, '2024-06-01', 'Transfermarkt');



-- Requêtes football — paramètres remplacés par leurs valeurs par défaut


-- ============================================================
-- SIMPLES
-- ============================================================

\echo '--- Clubs en Ligue 1 ---'
-- Clubs d'un championnat (défaut : Ligue 1)
SELECT c.nom, c.ville, c.stade, c.capacite_stade, c.annee_fondation
FROM   CLUB c
JOIN   CHAMPIONNAT ch ON c.championnat_id = ch.id
WHERE  ch.nom = 'Ligue 1'
ORDER  BY c.nom;

\echo '--- Joueurs français en Ligue 1 ---'
-- Joueurs d'une nationalité dans un championnat (défaut : Française / Ligue 1)
SELECT j.nom, j.prenom, j.nationalite, j.poste, c.nom AS club
FROM   JOUEUR j
JOIN   CLUB c         ON j.club_id         = c.id
JOIN   CHAMPIONNAT ch ON c.championnat_id  = ch.id
WHERE  j.nationalite = 'Française'
AND    ch.nom        = 'Ligue 1';

\echo '--- Matchs nuls de la saison 1 ---'
-- Matchs nuls d'une saison (défaut : saison 1)
SELECT cd.nom AS domicile, ce.nom AS exterieur,
       m.score_domicile, m.score_exterieur, m.date_match
FROM   MATCH_FOOTBALL m
JOIN   CLUB cd ON m.club_domicile_id  = cd.id
JOIN   CLUB ce ON m.club_exterieur_id = ce.id
WHERE  m.saison_id      = 1
AND    m.score_domicile = m.score_exterieur;

\echo '--- Attaquants de plus de 180 cm ---'
-- Attaquants au-dessus d'une taille (défaut : 180 cm)
SELECT j.nom, j.prenom, j.taille_cm, c.nom AS club
FROM   JOUEUR j
JOIN   CLUB c ON j.club_id = c.id
WHERE  j.poste     = 'Attaquant'
AND    j.taille_cm > 180;


-- ============================================================
-- INTERMÉDIAIRES
-- ============================================================

\echo '--- Classement à la journée 6 ---'
-- Classement à une journée (défaut : journée 6)
SELECT cl.position, c.nom, cl.points,
       cl.victoires, cl.nuls, cl.defaites
FROM   CLASSEMENT cl
JOIN   CLUB c ON cl.club_id = c.id
WHERE  cl.journee = 6
ORDER  BY cl.position;

\echo '--- Clubs ayant marqué plus de 5 buts ---'
-- Clubs ayant dépassé un seuil de buts (défaut : 5)
SELECT c.nom, cl.buts_pour
FROM   CLASSEMENT cl
JOIN   CLUB c ON c.id = cl.club_id
WHERE  cl.buts_pour > 5
ORDER  BY cl.buts_pour DESC;

\echo '--- Matchs joués dans des stades de plus de 35 000 places ---'
-- Matchs dans des stades dépassant une capacité (défaut : 35 000)
SELECT cd.nom AS domicile, ce.nom AS exterieur,
       m.score_domicile, m.score_exterieur, cd.capacite_stade
FROM   MATCH_FOOTBALL m
JOIN   CLUB cd ON cd.id = m.club_domicile_id
JOIN   CLUB ce ON ce.id = m.club_exterieur_id
WHERE  cd.capacite_stade > 35000
ORDER  BY cd.capacite_stade DESC;


-- ============================================================
-- COMPLEXES
-- ============================================================

\echo '--- Moyenne de buts par match par championnat ---'
-- Moyenne buts/match par championnat
SELECT ch.nom,
       ROUND(AVG(m.score_domicile + m.score_exterieur), 2) AS moyenne_buts
FROM   MATCH_FOOTBALL m
JOIN   SAISON      s  ON s.id   = m.saison_id
JOIN   CHAMPIONNAT ch ON ch.id  = s.championnat_id
GROUP  BY ch.nom
ORDER  BY moyenne_buts DESC;

\echo '--- Clubs dont la valeur marchande moyenne dépasse 20 M€ ---'
-- Clubs valeur marchande moyenne > seuil (défaut : 20 000 000 €)
SELECT c.nom,
       ROUND(AVG(vm.valeur_eur), 2) AS valeur_moyenne
FROM   JOUEUR j
JOIN   CLUB c              ON c.id         = j.club_id
JOIN   VALEUR_MARCHANDE vm ON vm.joueur_id = j.id
GROUP  BY c.nom
HAVING AVG(vm.valeur_eur) > 20000000
ORDER  BY valeur_moyenne DESC;

\echo '--- Top 5 des progressions de valeur marchande ---'
-- Joueurs avec la plus forte progression de valeur (défaut : top 5)
SELECT j.nom, j.prenom,
       (MAX(vm.valeur_eur) - MIN(vm.valeur_eur)) AS progression
FROM   JOUEUR j
JOIN   VALEUR_MARCHANDE vm ON vm.joueur_id = j.id
GROUP  BY j.id, j.nom, j.prenom
ORDER  BY progression DESC
LIMIT  5;

\echo '--- Taux de victoires à domicile par club ---'
-- Pourcentage de victoires à domicile par club
SELECT c.nom,
       ROUND(
           SUM(CASE WHEN m.score_domicile > m.score_exterieur THEN 1 ELSE 0 END)::numeric
           / COUNT(*) * 100
       , 2) AS taux_victoires_domicile
FROM   MATCH_FOOTBALL m
JOIN   CLUB c ON c.id = m.club_domicile_id
GROUP  BY c.nom
ORDER  BY taux_victoires_domicile DESC;

\echo '--- Clubs ayant terminé 1er au classement ---'
-- Clubs champions (position 1 toutes saisons confondues)
SELECT c.nom, COUNT(*) AS titres
FROM   CLASSEMENT cl
JOIN   CLUB c ON c.id = cl.club_id
WHERE  cl.position = 1
GROUP  BY c.nom
ORDER  BY titres DESC;

\echo '--- Top 5 des équipes par possession moyenne ---'
-- Meilleure possession moyenne en match (défaut : top 5)
SELECT c.nom,
       ROUND(AVG(sme.possession_pct), 2) AS possession_moyenne
FROM   STATS_MATCH_EQUIPE sme
JOIN   CLUB c ON c.id = sme.club_id
GROUP  BY c.nom
ORDER  BY possession_moyenne DESC
LIMIT  5;
