-- Query 1: This query returns all of the champions with a Pokemon team that has mixed typings
SELECT name
FROM champions
WHERE type LIKE '%Mix%';


--Query 2: This query returns the people who are a rival and champion
SELECT rivals.name
FROM rivals, champions
WHERE rivals.person_id = champions.person_id;

--Query 3: This query returns the people who are an elite4 member and champion
SELECT elite4.name
FROM elite4, champions
WHERE elite4.person_id = champions.person_id;

--Query 4: This query returns the people who are a gym leader and elite4 member
SELECT gym_leaders.name
FROM gym_leaders, elite4
WHERE gym_leaders.person_id = elite4.person_id;

--Query 5: This query returns all the 3rd evolution, pseduo-legendary pokemon
SELECT name, evo_status, mon_status
FROM pokemon
WHERE evo_status = 3 AND mon_status = 'Pseudo-Legendary';

--Query 6: This query returns all the pokemon that cannot evolve but only the basic and fossil pokemon (not legendary, sub-legendary, or mythical)
SELECT name, evo_status, mon_status
FROM pokemon
WHERE evo_status = 0 AND (mon_status = 'Basic' OR mon_status = 'Fossil');

--Query 7: This query returns all the legendary and sub-legendary pokemon that only have one type
SELECT name, mon_status, type1
FROM pokemon
WHERE (mon_status = 'Legendary' OR mon_status = 'Sub-Legendary') AND type2 = 'n/a';

--Query 8: This query returns the average number of rivals battles between all rivals
SELECT AVG (num_battles)
FROM rivals

--Query 9: This query returns the average number of pokemon a gym leader has
SELECT AVG(num_pokemon)
FROM gym_leaders

--Query 10: This query returns the name of every gym leader, elite4, and champion that have an ace pokemon that is a psuedo legendary
(SELECT gym_leaders.name, ace_pokemon
FROM gym_leaders
WHERE ace_pokemon in ('Dragonite','Metagross','Salamence','Garchomp','Hydreigon'))
UNION
(SELECT elite4.name, ace_pokemon
FROM elite4
WHERE ace_pokemon in ('Dragonite','Metagross','Salamence','Garchomp','Hydreigon'))
UNION
(SELECT champions.name, ace_pokemon
FROM champions
WHERE ace_pokemon in ('Dragonite','Metagross','Salamence','Garchomp','Hydreigon'));

--Query 11: Using the type function I can find the number of water type pokemon in the Kanto region
SELECT *
FROM type_count('Water');

--Query 12: Using the starter typing function I created I can find the number of fire type pokemon with a second typing
SELECT *
FROM starter_type_count('Fire');
