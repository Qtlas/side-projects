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


-- ============================================================
-- TABLES
-- ============================================================

\echo '--- Table CLUB ---'
SELECT * FROM CLUB;

\echo '--- Table JOUEUR ---'
SELECT * FROM JOUEUR;

\echo '--- Table MATCH_FOOTBALL ---'
SELECT * FROM MATCH_FOOTBALL;

\echo '--- Table CHAMPIONNAT ---'
SELECT * FROM CHAMPIONNAT;

\echo '--- Table SAISON ---'
SELECT * FROM SAISON;

\echo '--- Table VALEUR_MARCHANDE ---'
SELECT * FROM VALEUR_MARCHANDE;