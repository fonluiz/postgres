----------------------------------------------------------------
----------------------- Helper Functions -----------------------
----------------------------------------------------------------
-- Function to generate random integers between low and high
CREATE OR REPLACE FUNCTION random_int(low INT ,high INT) 
   RETURNS INT AS
$$
BEGIN
   RETURN floor(random() * (high - low + 1) + low);
END;
$$ language 'plpgsql' STRICT;

-- Function to generate random floats between low and high
CREATE OR REPLACE FUNCTION random_float(low INT ,high INT) 
   RETURNS FLOAT AS
$$
BEGIN
   RETURN random() * (( high - low + 1) + low);
END;
$$ language 'plpgsql' STRICT;

----------------------------------------------------------------
-------------- Helper Range Generating Functions ---------------
----------------------------------------------------------------

-- Function to generate random int8range between two values
CREATE OR REPLACE FUNCTION random_intrange(low INT, high INT) 
   RETURNS int8range AS
$$
DECLARE
   b1 int := random_int(low, high);
   b2 int := random_int(low, high);
BEGIN
   if (b1 > b2) then 
      return int8range(b2, b1);
   elsif (b1 = b2) then
   	  return int8range(b1, b1+1);
   else
      return int8range(b1, b2); 
   end if;
END;
$$ language 'plpgsql' STRICT;

-- Function to generate random numeric_range
CREATE OR REPLACE FUNCTION random_numrange(low INT, high INT) 
   RETURNS numrange AS
$$
DECLARE
   b1 int := random_float(low, high);
   b2 int := random_float(low, high);
BEGIN
   if (b1 > b2) then 
      return numrange(b2, b1); 
   else 
      return numrange(b1, b2); 
   end if;
END;
$$ language 'plpgsql' STRICT;

-- Function to generate random tsrange (timestamp range) b/w low and high timestamp
CREATE OR REPLACE FUNCTION random_timestamp(i INT) 
   RETURNS tsrange AS
$$
DECLARE
   low timestamp := (now()::timestamp + (random() * ((TIMESTAMP 'epoch' + (tres_random_interval(i, 4, 5, 6))) - (TIMESTAMP 'epoch' + (tres_random_interval(i, 1, 2, 3))) )));
   high timestamp := (now()::timestamp + (random() * ((TIMESTAMP 'epoch' + (tres_random_interval(i, 4, 5, 6))) - (TIMESTAMP 'epoch' + (tres_random_interval(i, 1, 2, 3))) )));
BEGIN
   if (low > high) then 
      return tsrange(high, low); 
   else 
      return tsrange(low, high); 
   end if;
END;
$$ language 'plpgsql' STRICT;

-- Function to generate random date range b/w low and high date
CREATE OR REPLACE FUNCTION random_date(i INT) 
   RETURNS daterange AS
$$
DECLARE
   low date := (now()::timestamp + (random_int( random_int(0, i), random_int(i + 1, i*2) )::text || ' days')::interval)::date;
   high date := (now()::timestamp + (random_int( random_int(i*3, i*4), random_int((i*4) + 1, i*8) )::text || ' days')::interval)::date;
BEGIN
   if (low > high) then 
      return daterange(high, low); 
   else 
      return daterange(low, high); 
   end if;
END;
$$ language 'plpgsql' STRICT;


--------------------------------------------------------------
------------------------ CREATE TABLES -----------------------
--------------------------------------------------------------

-- CREATE TABLES USING ALL POSSIBLE COMBINATIONS OF THE FOLLOWING VARIABLES:
-- size: 1k or 10k
-- data distribution: normal, left-aligned, right-aligned, in U shape
-- two different tables for each: A or B

DROP TABLE IF EXISTS normal_dist_1000_a;
DROP TABLE IF EXISTS normal_dist_1000_b;
DROP TABLE IF EXISTS left_dist_1000_a;
DROP TABLE IF EXISTS left_dist_1000_b;
DROP TABLE IF EXISTS right_dist_1000_a;
DROP TABLE IF EXISTS right_dist_1000_b;

DROP TABLE IF EXISTS normal_dist_10k_a;
DROP TABLE IF EXISTS normal_dist_10k_b;
DROP TABLE IF EXISTS left_dist_10k_a;
DROP TABLE IF EXISTS left_dist_10k_b;
DROP TABLE IF EXISTS right_dist_10k_a;
DROP TABLE IF EXISTS right_dist_10k_b;

CREATE TABLE normal_dist_1000_a (
	id int,
	integer_range int8range,
	float_range numrange
--	timestamp_range tsrange,
--	date_range daterange
);

CREATE TABLE normal_dist_1000_b (
	id int,
	integer_range int8range,
	float_range numrange
--	timestamp_range tsrange,
--	date_range daterange
);

CREATE TABLE left_dist_1000_a (
	id int,
	integer_range int8range,
	float_range numrange
--	timestamp_range tsrange,
--	date_range daterange
);

CREATE TABLE left_dist_1000_b (
	id int,
	integer_range int8range,
	float_range numrange
--	timestamp_range tsrange,
--	date_range daterange
);

CREATE TABLE right_dist_1000_a (
	id int,
	integer_range int8range,
	float_range numrange
--	timestamp_range tsrange,
--	date_range daterange
);

CREATE TABLE right_dist_1000_b (
	id int,
	integer_range int8range,
	float_range numrange
--	timestamp_range tsrange,
--	date_range daterange
);

CREATE TABLE normal_dist_10k_a (
	id int,
	integer_range int8range,
	float_range numrange
--	timestamp_range tsrange,
--	date_range daterange
);

CREATE TABLE normal_dist_10k_b (
	id int,
	integer_range int8range,
	float_range numrange
--	timestamp_range tsrange,
--	date_range daterange
);

CREATE TABLE left_dist_10k_a (
	id int,
	integer_range int8range,
	float_range numrange
--	timestamp_range tsrange,
--	date_range daterange
);

CREATE TABLE left_dist_10k_b (
	id int,
	integer_range int8range,
	float_range numrange
--	timestamp_range tsrange,
--	date_range daterange
);

CREATE TABLE right_dist_10k_a (
	id int,
	integer_range int8range,
	float_range numrange
--	timestamp_range tsrange,
--	date_range daterange
);

CREATE TABLE right_dist_10k_b (
	id int,
	integer_range int8range,
	float_range numrange
--	timestamp_range tsrange,
--	date_range daterange
);



---------------------------------------------------------------
-------------------- POPULATE THE TABLES ----------------------
---------------------------------------------------------------
-- For 1000 rows tables first
-- normal distribution
insert into normal_dist_1000_a select i, random_intrange(1, 500), random_numrange(1, 100) from generate_series(1, 1000) as i;
insert into normal_dist_1000_b select i, random_intrange(1, 500), random_numrange(1, 100) from generate_series(1, 1000) as i;

-- left-aligned distribution
insert into left_dist_1000_a  select i, random_intrange(1, 100), random_numrange(1, 100) from generate_series(1, 400) as i;
insert into left_dist_1000_a  select i, random_intrange(51, 200), random_numrange(51, 200) from generate_series(401, 700) as i;
insert into left_dist_1000_a  select i, random_intrange(151, 350), random_numrange(151, 350) from generate_series(701, 900) as i;
insert into left_dist_1000_a  select i, random_intrange(251, 500), random_numrange(251, 500) from generate_series(901, 1000) as i;

insert into left_dist_1000_b  select i, random_intrange(1, 100), random_numrange(1, 100) from generate_series(1, 400) as i;
insert into left_dist_1000_b  select i, random_intrange(51, 200), random_numrange(51, 200) from generate_series(401, 700) as i;
insert into left_dist_1000_b  select i, random_intrange(151, 350), random_numrange(151, 350) from generate_series(701, 900) as i;
insert into left_dist_1000_b  select i, random_intrange(251, 500), random_numrange(251, 500) from generate_series(901, 1000) as i;

-- right-aligned distribution
insert into right_dist_1000_a  select i, random_intrange(1, 250), random_numrange(1, 250) from generate_series(1, 100) as i;
insert into right_dist_1000_a  select i, random_intrange(151, 350), random_numrange(151, 350) from generate_series(101, 300) as i;
insert into right_dist_1000_a  select i, random_intrange(301, 450), random_numrange(301, 450) from generate_series(301, 600) as i;
insert into right_dist_1000_a  select i, random_intrange(401, 500), random_numrange(401, 500) from generate_series(601, 1000) as i;

insert into right_dist_1000_b  select i, random_intrange(1, 250), random_numrange(1, 250) from generate_series(1, 100) as i;
insert into right_dist_1000_b  select i, random_intrange(151, 350), random_numrange(151, 350) from generate_series(101, 300) as i;
insert into right_dist_1000_b  select i, random_intrange(301, 450), random_numrange(301, 450) from generate_series(301, 600) as i;
insert into right_dist_1000_b  select i, random_intrange(401, 500), random_numrange(401, 500) from generate_series(601, 1000) as i;

-- For 10k rows tables
-- normal distribution
insert into normal_dist_10k_a select i, random_intrange(1, 500), random_numrange(1, 100) from generate_series(1, 10000) as i;
insert into normal_dist_10k_b select i, random_intrange(1, 500), random_numrange(1, 100) from generate_series(1, 10000) as i;
 
-- left-aligned distribution
insert into left_dist_10k_a  select i, random_intrange(1, 100), random_numrange(1, 100) from generate_series(1, 4000) as i;
insert into left_dist_10k_a  select i, random_intrange(51, 200), random_numrange(51, 200) from generate_series(4001, 7000) as i;
insert into left_dist_10k_a  select i, random_intrange(151, 350), random_numrange(151, 350) from generate_series(7001, 9000) as i;
insert into left_dist_10k_a  select i, random_intrange(251, 500), random_numrange(251, 500) from generate_series(9001, 10000) as i;
 
insert into left_dist_10k_b  select i, random_intrange(1, 100), random_numrange(1, 100) from generate_series(1, 4000) as i;
insert into left_dist_10k_b  select i, random_intrange(51, 200), random_numrange(51, 200) from generate_series(4001, 7000) as i;
insert into left_dist_10k_b  select i, random_intrange(151, 350), random_numrange(151, 350) from generate_series(7001, 9000) as i;
insert into left_dist_10k_b  select i, random_intrange(251, 500), random_numrange(251, 500) from generate_series(9001, 10000) as i;

-- right-aligned distribution
insert into right_dist_10k_a  select i, random_intrange(1, 250), random_numrange(1, 250) from generate_series(1, 1000) as i;
insert into right_dist_10k_a  select i, random_intrange(151, 350), random_numrange(151, 350) from generate_series(1001, 3000) as i;
insert into right_dist_10k_a  select i, random_intrange(301, 450), random_numrange(301, 450) from generate_series(3001, 6000) as i;
insert into right_dist_10k_a  select i, random_intrange(401, 500), random_numrange(401, 500) from generate_series(6001, 10000) as i;

insert into right_dist_10k_b  select i, random_intrange(1, 250), random_numrange(1, 250) from generate_series(1, 1000) as i;
insert into right_dist_10k_b  select i, random_intrange(151, 350), random_numrange(151, 350) from generate_series(1001, 3000) as i;
insert into right_dist_10k_b  select i, random_intrange(301, 450), random_numrange(301, 450) from generate_series(3001, 6000) as i;
insert into right_dist_10k_b  select i, random_intrange(401, 500), random_numrange(401, 500) from generate_series(6001, 10000) as i;

