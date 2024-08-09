--see lines 34-36 before running

--This table creates the regions which is the base of all the other tables most of the other tables reference regions
CREATE TABLE regions(name 			varchar(7),
					 games			varchar(15),
					 year_made		char(4),
					 based_off		varchar(25),
					 CONSTRAINT regions_pkey PRIMARY KEY (name)
					);
ALTER TABLE regions ADD num_pokemon int;


--This table creates the pokemon which is the bulk of the data set and it references regions with a foreign key
CREATE TABLE pokemon(dexnum			int,
					 name 			varchar(30),
					 type1			varchar(15),
					 type2			varchar(15),
					 evo_status		integer,
					 mon_status		varchar(25),
					 region			varchar(7),
					 CONSTRAINT pokemon_pkey PRIMARY KEY (name),
					 CONSTRAINT pokemon_fkey FOREIGN KEY (region) REFERENCES regions (name)
					);
					

--This table creates the locations within the regions and it references the regions with a foreign key
CREATE TABLE locations(name			varchar(25),
					   gym_leader	varchar(18),
					   region		varchar(7),
					   CONSTRAINT locations_pkey PRIMARY KEY (name),
					   CONSTRAINT locations_fkey FOREIGN KEY (region) REFERENCES regions (name)
					  );
					  
ALTER TABLE locations ADD CONSTRAINT locations_fkey2 FOREIGN KEY (gym_leader) REFERENCES gym_leaders (name);
-- ^^ This was needed to make the locations table because I couldn't make it with this constraint without the gym leader table
-- and I couldn't make the gym leader table without locations. RUN THIS AFTER THE UPDATE STATEMENTS IN THE DML FILE

					  
--This table creates the people which all of the people types reference
CREATE TABLE people(person_id			char(4),
				    CONSTRAINT people_pkey PRIMARY KEY (person_id)
				   );
				
				
--This table creates the gym leadersm which references the location, region, pokemon, and people tables with a foreign key
CREATE TABLE gym_leaders(person_id 			char(4),
						 name 				varchar(18),
						 region				varchar(7),
						 type				varchar(10),
						 location			varchar(25),
						 badge				varchar(15),
						 num_pokemon		integer,
						 ace_pokemon		varchar(30),
						 CONSTRAINT gym_leaders_pkey PRIMARY KEY (name),
					     CONSTRAINT gym_leaders_fkey FOREIGN KEY (location) REFERENCES locations (name),
					     CONSTRAINT gym_leaders_fkey2 FOREIGN KEY (region) REFERENCES regions (name),
						 CONSTRAINT gym_leaders_fkey3 FOREIGN KEY (ace_pokemon) REFERENCES pokemon (name),
						 CONSTRAINT gym_leaders_fkey4 FOREIGN KEY (person_id) REFERENCES people (person_id)
						 );
			
			
			
--This table creates the elite 4 members references the region, pokemon,and people tables with a foreign key
CREATE TABLE elite4(person_id 			char(4),
					   name 				varchar(18),
					   region				varchar(7),
					   type					varchar(10),
					   num_pokemon			integer,
					   ace_pokemon			varchar(30),
					   CONSTRAINT elite4_pkey PRIMARY KEY (name),
					   CONSTRAINT elite4_fkey FOREIGN KEY (region) REFERENCES regions (name),
					   CONSTRAINT elite4_fkey2 FOREIGN KEY (ace_pokemon) REFERENCES pokemon (name),
					   CONSTRAINT elite4_fkey3 FOREIGN KEY (person_id) REFERENCES people (person_id)
					  );
					  
					  
--This table creates the champions references the region, pokemon,and people tables with a foreign key
CREATE TABLE champions(person_id 			char(4),
					   name 				varchar(18),
					   region				varchar(7),
					   type					varchar(10),
					   num_pokemon			integer,
					   ace_pokemon			varchar(30),
					   CONSTRAINT champions_pkey PRIMARY KEY (name),
					   CONSTRAINT champions_fkey FOREIGN KEY (region) REFERENCES regions (name),
					   CONSTRAINT champions_fkey2 FOREIGN KEY (ace_pokemon) REFERENCES pokemon (name),
					   CONSTRAINT champions_fkey3 FOREIGN KEY (person_id) REFERENCES people (person_id)
					  );
					  
					  
--This table creates the rivals references the region, people tables with a foreign key
CREATE TABLE rivals(person_id 			char(4),
					name 				varchar(18),
					region				varchar(7),
				   	num_battles			integer,
				   	gender				varchar(6),
				    CONSTRAINT rivals_pkey PRIMARY KEY (name),
				    CONSTRAINT rivals_fkey FOREIGN KEY (region) REFERENCES regions (name),
					CONSTRAINT rivals_fkey2 FOREIGN KEY (person_id) REFERENCES people (person_id)
				   );


--This table creates the professors references the region, people tables with a foreign key
CREATE TABLE professors(person_id 			char(4),
					name 				varchar(18),
					region				varchar(7),
				   	specialty			varchar(10),
				   	gender				varchar(6),
				    CONSTRAINT professors_pkey PRIMARY KEY (name),
				    CONSTRAINT professors_fkey FOREIGN KEY (region) REFERENCES regions (name),
					CONSTRAINT professors_fkey2 FOREIGN KEY (person_id) REFERENCES people (person_id)
				   );
				   

				   
--This view shows the grass type gyms that can be found throughout all 5 regions. It looks like there are 3 grass type gyms located only in Kanto, Sinnoh, and Unova.
CREATE VIEW grass_gyms AS
SELECT region, location, type
FROM gym_leaders
WHERE type = 'Grass';


				   
--This view shows the rock type gyms that can be found throughout all 5 regions. It looks like there are 3 rock type gyms located only in Kanto, Hoenn and Sinnoh.
CREATE VIEW rock_gyms AS
SELECT region, location, type
FROM gym_leaders
WHERE type = 'Rock';

				   
				   
				   
-- This function gives a count of all the pokemon in the Kanto region that have a certain typing in type1 or type2
CREATE OR REPLACE FUNCTION type_count(type_name varchar(15))
	RETURNS INTEGER
	LANGUAGE plpgsql
	AS 
	$$
		DECLARE 
			type_count INT;
		BEGIN
			SELECT COUNT(*) INTO type_count
			FROM pokemon
			WHERE region = 'Kanto' AND (type1 = type_name OR type2 = type_name);
			
			RETURN type_count;
		END;
	$$;



-- This function gives a count of any starter pokemon that has a water, grass, or fire(they have to have water, grass or fire by default but you can input whichever you like) typing as well as another typing.
CREATE OR REPLACE FUNCTION starter_type_count(type_name varchar(15))
	RETURNS INTEGER
	LANGUAGE plpgsql
	AS 
	$$
		DECLARE 
			s_t_count INT;
		BEGIN
			SELECT COUNT(*) INTO s_t_count
			FROM pokemon
			WHERE type1 = type_name AND type2 != 'n/a' AND mon_status = 'Starter';
			
			RETURN s_t_count;
		END;
	$$;
	
-- This trigger adds to the number of pokemon in a region when a pokemon is added to the pokemon table.

CREATE OR REPLACE FUNCTION add_pokemon_region() 
	RETURNS TRIGGER
	LANGUAGE plpgsql
	AS 
	$$
		BEGIN
			UPDATE regions
			SET num_pokemon = num_pokemon + 1
			WHERE name = NEW.region;

			RETURN NULL;
		END;
	$$;

CREATE TRIGGER pokemon_insert_trigger
	AFTER INSERT ON pokemon
	FOR EACH ROW
	EXECUTE FUNCTION add_pokemon_region();
	


--This procedure returns the number of pokemon of a certain mon_status as output and takes in a mon_status
CREATE OR REPLACE PROCEDURE status_count (IN mon_s VARCHAR(25), INOUT type_mon_count INTEGER DEFAULT 0) 
	LANGUAGE plpgsql
	AS 
	$$
		BEGIN
			SELECT count(*) INTO type_mon_count
			FROM pokemon
			WHERE mon_status = mon_s; 
		END;
	$$;

CALL status_count('Legendary');






