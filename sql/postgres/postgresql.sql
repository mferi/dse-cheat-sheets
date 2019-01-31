
--TABLESAMPLE to explore a sample
SELECT avg(cost)
FROM bigtable TABLESAMPLE system(1) --1% sample of table blocks - fast, approximate

SELECT avg(cost)
FROM bigtable TABLESAMPLE system_time(1) -- 1 second sample - fast, approximate, time-bounded


---Full foreign data schema wraps
IMPORT FOREIGN SCHEMA yacht
FROM SERVER oracle
INTO reduce_license_cost;



---Upsert
INSERT INTO user_credit (username, credit)
VALUES ('simon', 10)
ON CONFLICT (username) --column primary key or unique key
DO UPDATE
SET credit = user_credit.credit + EXCLUDED.credit

---JSON features


--- Modified timestamp ON UPDATE

-- Setting a function to update the timestamp
CREATE OR REPLACE FUNCTION my_extensions.update_modified_time()
  RETURNS trigger AS
$BODY$
BEGIN
   IF row(NEW.*) IS DISTINCT FROM row(OLD.*) THEN
      NEW.modified_time = now();
      RETURN NEW;
   ELSE
      RETURN OLD;
   END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- Setting a trigger ON UPDATE to run the function to update the timestamp
CREATE TRIGGER update_apm_modifiedtime BEFORE UPDATE ON apm.apm FOR EACH ROW EXECUTE PROCEDURE my_extensions.update_modified_time();



---- Query Planner
-- http://www.postgresql.org/docs/current/static/runtime-config-query.html
-- eneble_nestloop, eneble_seqscan --> potentially to be diasble, slow strategies used as last resort



---- Connections

-- Connection settings
	$ psql -h awsrc01prod.c5rzwpu89mon.eu-west-1.redshift.amazonaws.com -d eu -p 5439 -U mariaferia

-- Recent connections listing
SELECT * FROM pg_stat_activity;

-- Cancel all active queries in a connection
SELECT pg_cancel_backend(procid);

--Kill a connection
SELECT pg_terminate_backend(procid);
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE username = 'some_user' --killing all connections belonging to a role

-- Reload the service
SELECT pg_reload_config();
	$ pg_ctl reload -D your_data_directory_here



---- Roles, group roles, privileges
SELECT user;

-- Creating roles:
CREATE ROLE superuser LOGIN PASSWORD 'superuser1' SUPERUSER VALID UNTIL 'infinity';
CREATE ROLE createdb LOGIN PASSWORD 'createdb1' CREATEDB VALID UNTIL '2020-1-1 00:00';

-- Creating a group role:
CREATE ROLE analytics INHERIT; -- members of a group inherit the rights of the group
CREATE ROLE analytics NOINHERIT; -- members of a group no inherit the rights of the group

-- Add roles to a group:
GRANT analytics TO createdb;

-- Privileges: SELECT, INSERT, UPDATE, ALTER, EXECUTE, TRUNCATE, qualifier WITH GRANT
-- http://www.postgresql.org/docs/current/interactive/ddl-priv.html
-- http://www.postgresql.org/docs/current/interactive/sql-grant.html
-- http://www.postgresql.org/docs/current/interactive/sql-alterdefaultprivileges.html
GRANT ALL ON ALL TABLES IN SCHEMA public TO user_name WITH GRANT OPTION;
GRANT SELECT, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA my_schema TO public; -- "public" grants privileges to all roles;
GRANT USAGE ON SCHEMA my_schema TO public; -- no forget to set GRANT USAGE ON SCHEMA or GRANT ALL ON SCHEMA in order to tables and functions rights being accesible to a role
GRANT USAGE ON TYPES TO public;
GRANT ALL ON FUNCTIONS;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO user;

-- Alter default privileges:
ALTER DEFAULT PRIVILEGES IN SCHEMA my_schema
GRANT SELECT, UPDATE ON SEQUENCES TO public;



---- Schema, database creation and templates
CREATE pg_database SET datistemplate = TRUE WHERE datname = 'mydb'; -- make a db a template. Set datistemplate to FALSE to edit or drop a template
CREATE DATABASE mydb TEMPLATE my_template_db WITH owner = 'role_name';
CREATE SCHEMA my_extensions;
ALTER DATABASE mydb SET search_path = 'my_schema, public, my_extensions';  -- having login role names same as schema names would allow to use "$user" to prioritase search_path


---- Extensions
-- List of extensions installed on server
SELECT name, default_version, installed_version, left(comment, 30) AS comment
FROM pg_available_extensions
WHERE installed_version IS NOT NULL
ORDER BY name;
-- Details about a particular extensions:
/dx+ fuzzystrmatch
-- or:
SELECT pg_catalog.pg_describe_object(d.classid, d.objid, 0) AS description
FROM pg_catalog.pg_depend AS D
INNER JOIN pg_catalog.pg_extension AS E
ON D.refclassid = 'pg_catalog.pg_extension' :: pg_catalog.regclass AND deptype = 'e' AND E.extname = 'fuzzystrmatch';
-- See available extension binaries on server:
SELECT * FROM pg_available_extensions;
-- Installing extensions:
CREATE EXTENSION fuzzystrmatch SCHEMA my_extensions;
-- Maintaining extensions when upgrade to a newer PostgreSQL version
CREATE EXTENSION fuzzystrmatch SCHEMA my_extensions FROM unpackaged;
-- psql
psql -p 5432 -d mydb -c "CREATE EXTENSION fuzzystrmatch;"



---- Tablespaces
CREATE TABLESPACE my_gis LOCATION 'C:/_GIS';
-- Moving all database objects to a different location
ALTER DATABASE mydb SET TABLESPACE my_gis;
ALTER TABLE mytable SET TABLESPACE my_gis;
-- Moving all objects from a tablespace to another:
ALTER TABLESPACE pg_default MOVE ALL TO secondary;



---- Verboten parctices:
-- If server fails to restart, from the OS command line:
path/to.your/bin/pg_ctl -D your_postgresql_data_folder
-- Don't give full OS admin rights to the postgres system account
-- Don't set shared_buffers as high as your physical RAM
-- Don't start postgresql on a port already in use



---- Foreign Data Wrappers
-- Flat file wrappers:

CREATE EXTENSION file_fdw SCHEMA my_extensions;

CREATE FOREIGN TABLE foreign_data.product_metrics3 (w_product_d_id integer,
  product_code varchar(100),
  product_code_type varchar(100),
  units_disp integer,
  units_auth integer,
  unit_undone integer,
  first_scan_date date,
  last_scan_date date,
  pharmacy_num integer,
  days integer,
  units_disp_week integer)
SERVER my_server
OPTIONS (format 'csv', header 'true', filename 'C:/wrappers/product_metrics_be.txt', delimiter ',', null '');

SELECT * FROM foreign_data.product_metrics3;


CREATE EXTENSION postgres_fdw SCHEMA my_extensions;

CREATE SERVER my_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'localhost', port '5432', dbname 'my_db');


----- Configuration files location: postgresql.cong (general settings), pg_hba.conf (security) and pg_indent.conf (OS login to PG user mapping)
SELECT name, setting
FROM pg_settings
WHERE category = 'File Locations';

-- postgresql.conf main settings
-- https://wiki.postgresql.org/wiki/Tuning_Your_PostgreSQL_Server

SELECT name, context, unit, setting, boot_val, reset_val
FROM pg_settings
WHERE name IN ('listen_addresses', 'port', 'max_connections', 'shared_buffers', 'effective_cache_size', 'work_mem','maintenance_work_mem')
ORDER BY context, name;

SELECT *
FROM pg_settings VIEW;

SHOW shared_buffers; -- memory amoong connections to store recent accessed pages. Around 25% of onborad memory, more than 8GB may disminish returns

SHOW effective_cache_size; -- stimation of memory availible availible in the OS and PG buffer cache (query planner decisions are affected)

SHOW work_mem; -- memory for operations as sorting, hash joins, table scans http://www.depesz.com/2011/07/03/understanding-postgresql-conf-work_mem/

SHOW maintenance_work_mem; -- memory for vacuuming, not higher than 1GB

ALTER SYSTEM SET work_mem = 8192;

-- pg_hba.conf Connection to PostgreSQL
-- Authentification methods http://www.postgresql.org/docs/current/interactive/client-authentication.html
-- trust: less secure, no password required
-- md5: require amd5 encripted password to connections, very common
-- password: clear-text password
-- ident: uses pg_indent.conf to see if the OS account matchs to a PG account, no password required
-- peer: uses the the client's OS name from the kernel, for local connections, only for linux, BSD, Mac OS X and Solaris





---- pgAgent
-- pgAgent tables description
SELECT c.relname AS table_name, d.description
FROM pg_class AS c
INNER JOIN pg_namespace n ON n.oid =c.relnamespace
INNER JOIN pg_description AS d ON d.objoid = c.oid AND d.objsubid = 0
WHERE n.nspname = 'pgagent';

-- To see the list log step results from today
SELECT j.jobname, s.jstname, l.jslstart, l.jslduration, l.jsloutput
FROM pgagent.pga_jobsteplog AS l
INNER JOIN pgagent.pga_jobstep AS s ON s.jstid = l.jsljstid
INNER JOIN pgagent.pga_job AS j ON j.jobid = s.jstjobid
WHERE jslstart > CURRENT_DATE
ORDER BY j.jobname, s.jstname, l.jslstart DESC;



---- Information_schema

SELECT table_schema, table_name, table_type
FROM information_schema.tables
WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY table_schema, table_name;

SELECT c.table_name, c.column_name, c.data_type, c.udt_name, c.character_maximum_length, c.ordinal_position, c.column_default
FROM information_schema.columns AS c
ORDER BY c.table_name, c.ordinal_position;

SELECT table_schema, table_name, view_definition
FROM information_schema.views
WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY table_schema, table_name;

---- Useful statements:
trim(regexp_replace(mystring, '\s+', ' ', 'g')) -- removing double whitespaces and tabs
WHERE dtd.reporting_date >= to_date('01/01/2015','DD/MM/YYYY')




-- integer types

CREATE TABLE t ( a INTEGER, b INTEGER );
CREATE TABLE t ( a SMALLINT, b SMALLINT );
CREATE TABLE t ( a BIGINT, b BIGINT );

SELECT * FROM t;

-- NUMERIC types

CREATE TABLE t ( a NUMERIC, b NUMERIC );
CREATE TABLE t ( a NUMERIC(12,2), b NUMERIC(64,5) );

DROP TABLE t;

-- real types

CREATE TABLE t ( a REAL, b DOUBLE PRECISION );

CREATE TABLE t ( da NUMERIC(10,2), db NUMERIC(10,2), fa REAL, fb REAL );
INSERT INTO t VALUES ( .1, .2, .1, .2 );
SELECT * FROM t;

SELECT da, db, da + db = .3 FROM t;
SELECT fa, fb, fa + fb = .3 FROM t;
SELECT fa, fb, to_char(fa + fb, '9D99999999999999999999EEEE') FROM t;

DROP TABLE t;

-- text types

CREATE TABLE t ( a TEXT, b TEXT, c TEXT );
CREATE TABLE t ( a TEXT, b VARCHAR(16), c CHAR(16) );

-- 36 char string
INSERT INTO t VALUES (
    'Now is the time for all good men ...',
    'Now is the time for all good men ...',
    'Now is the time for all good men ...'
);

-- 12 char string
INSERT INTO t VALUES ( 'Bill Weinman', 'Bill Weinman', 'Bill Weinman' );

-- boolean types

CREATE TABLE t ( a BOOLEAN, b BOOL );

INSERT INTO t VALUES ( TRUE, FALSE );
INSERT INTO t VALUES ( '1', '0' );
INSERT INTO t VALUES ( 'true', 't' );
INSERT INTO t VALUES ( 'false', 'f' );
INSERT INTO t VALUES ( 'yes', 'y' );
INSERT INTO t VALUES ( 'no', 'n' );

-- date/time types

CREATE TABLE t ( a TIMESTAMP, b TIMESTAMP WITH TIME ZONE );
CREATE TABLE t ( a TIME, b TIME WITH TIME ZONE );
CREATE TABLE t ( a DATE, b DATE );
CREATE TABLE t ( a INTERVAL, b INTERVAL );

INSERT INTO t VALUES ( '2011-10-07 15:25:00 EDT', '2011-10-07 3:25 PM EDT' );
INSERT INTO t VALUES ( '2011-10-07 15:25:00 UTC', '2011-10-07 3:25 PM UTC' );

INSERT INTO t VALUES ( '1 day', '1 week' );
INSERT INTO t VALUES ( '1 month', '1 year' );

INSERT INTO t VALUES ( AGE( DATE '2011-10-07', DATE '2011-10-06'), '2 days' );

-- reusable inserts

INSERT INTO t VALUES ( 1, 2 );
INSERT INTO t VALUES ( -32768, 32767 );
INSERT INTO t VALUES ( -2147483648, 2147483647 );
INSERT INTO t VALUES ( -9223372036854775808, 9223372036854775807 );

-- INSERT
CREATE TABLE a (a TEXT, b TEXT, c TEXT);
INSERT INTO a VALUES ('a', 'b', 'c');
INSERT INTO a VALUES ('a', 'b', 'c');
INSERT INTO a VALUES ('a', 'b', 'c');
INSERT INTO a VALUES ('a', 'b', 'c');
INSERT INTO a VALUES ('a', 'b', 'c');
SELECT * FROM a;

CREATE TABLE b (d TEXT, e TEXT, f TEXT);
INSERT INTO b SELECT * FROM a;
INSERT INTO b (f, e, d) SELECT * FROM a;
INSERT INTO b (f, e, d) SELECT c, a, b FROM a;
SELECT * FROM b;
DROP TABLE IF EXISTS a;
DROP TABLE IF EXISTS b;

-- UPDATE
CREATE TABLE t ( id SERIAL PRIMARY KEY, quote TEXT, byline TEXT );
INSERT INTO t ( quote, byline ) VALUES ( 'Aye Carumba!', 'Bart Simpson' );
INSERT INTO t ( quote, byline ) VALUES ( 'But Bullwinkle, that trick never works!', 'Rocket J. Squirrel' );
INSERT INTO t ( quote, byline ) VALUES ( 'I know.', 'Han Solo' );
INSERT INTO t ( quote, bygraline ) VALUES ( 'Ahhl be baahk.', 'The Terminator' );
SELECT * FROM t;
UPDATE t SET quote = 'Hasta la vista, baby.' WHERE id = 4;
SELECT * FROM t WHERE id = 4;
UPDATE t SET quote = 'Rosebud.', byline = 'Charles Foster Kane' WHERE id = 4;
SELECT * FROM t WHERE id = 4;
DROP TABLE IF EXISTS t;

-- DELETE

-- album database
SELECT * FROM track WHERE title = 'Fake Track'
DELETE FROM track WHERE title = 'Fake Track'

-- SELECT
-- album database
SELECT * FROM album;
SELECT title, artist, label FROM album;
SELECT artist AS "Artist", title AS "Album", released AS "Release Date" FROM album;
    -- will use a lot with JOINs, VIEWs, sub-selects, etc.

SELECT * FROM track
WHERE album_id IN (
  SELECT id FROM album WHERE artist = 'Jimi Hendrix' OR artist = 'Johnny Winter'
);

SELECT a.title AS album, t.title AS track, t.track_number
    FROM album AS a, track AS t
    WHERE a.id = t.album_id
    ORDER BY a.title, t.track_number;

-- JOIN

-- world database
SELECT c.name, l.language
    FROM countryLanguage AS l
    JOIN country AS c
        ON l.countryCode = c.code
    ORDER BY c.name, l.language

SELECT c.name, l.language
    FROM countryLanguage AS l
    JOIN country AS c
        ON l.countryCode = c.Code
    WHERE c.name = 'United States'
    ORDER BY l.language

-- album database
SELECT a.artist, a.title AS album, t.title AS track, t.track_number
  FROM track as t
  JOIN album AS a
    ON t.album_id = a.id
  ORDER BY a.artist, album, t.track_number

  -- LIKE

-- world database
SELECT * FROM City WHERE Name LIKE 'Z%' ORDER BY Name;
SELECT * FROM City WHERE Name ILIKE 'z%' ORDER BY Name;
SELECT * FROM City WHERE Name ILIKE '_w%' ORDER BY Name;
SELECT * FROM City WHERE Name SIMILAR TO '[ZK]w_+' ORDER BY Name;

-- CASE

-- test database
CREATE TABLE booltest (a BOOL, b BOOL);
INSERT INTO booltest VALUES ('1', '0');
SELECT * FROM booltest;
SELECT
    CASE WHEN a THEN 'TRUE' ELSE 'FALSE' END as boolA,
    CASE WHEN b THEN 'TRUE' ELSE 'FALSE' END as boolB
    FROM booltest;
DROP TABLE IF EXISTS booltest;

-- CAST

CREATE TABLE t ( a INTEGER, b REAL );
INSERT INTO t VALUES (123456789, 123456789);
SELECT a, b FROM t;
SELECT CAST(a AS REAL), b FROM t;
SELECT CAST(a AS NUMERIC(15,2)), CAST(b AS NUMERIC(15,2)) FROM t;
DROP TABLE IF EXISTS t;

-- PostgreSQL Documentation
-- http://www.postgresql.org/docs/9.1/static/functions-math.html

-- Arithmetic operators

SELECT 5 * 30;
SELECT 7 / 3;
SELECT 7.0 / 3;
SELECT 7 % 3;

-- world database
SELECT name, population / 1000000 AS "pop (MM)" FROM Country
    WHERE population > 100000000
    ORDER by population DESC;

-- test database
SELECT item_id, price FROM sale;
SELECT item_id, price / 100 AS  Price FROM sale;
SELECT item_id, CAST(price AS NUMERIC) / 100 AS price FROM sale;
SELECT item_id, TO_CHAR(CAST(price AS NUMERIC) / 100, '999,999.09') AS price FROM sale;

-- math functions

-- ABS
CREATE TABLE t ( a INTEGER, b INTEGER );
INSERT INTO t VALUES ( 1, 2 );
INSERT INTO t VALUES ( 3, 4 );
INSERT INTO t VALUES ( -1, -2 );
INSERT INTO t VALUES ( -3, -4 );
SELECT a, b FROM t;
SELECT ABS(a), b FROM t;
DROP TABLE IF EXISTS t;

-- ROUND
CREATE TABLE t ( a NUMERIC(10,3), b NUMERIC(10,3) );
INSERT INTO t VALUES ( 123.456, 456.789 );
INSERT INTO t VALUES ( -123.456, -456.789 );
SELECT ROUND(a), b FROM t;
SELECT ROUND(a, 2), b FROM t;
DROP TABLE IF EXISTS t;

-- Documentation
-- http://www.postgresql.org/docs/9.1/static/functions-string.html

-- Finding the length of a string
SELECT LENGTH('This string has 30 characters.');
SELECT CHAR_LENGTH('This string has 30 characters.');
SELECT OCTET_LENGTH('This string has 30 characters.');

-- Concatenating strings
SELECT 'This is a string.' || 'This is another string.';
SELECT CONCAT('This is a string', 'This is another string');
SELECT CONCAT_WS(':', 'This is a string', 'This is another string', 'One more string here');

-- Substrings
SELECT POSITION('string' IN 'This is a string');
SELECT SUBSTRING('This is a string' FROM 11);
SELECT SUBSTRING('This is a string' FROM 11 FOR 3);

-- Replacing strings
SELECT REPLACE('This is a string', 'is a', 'is not a');
SELECT OVERLAY('This is a xxxxxx' PLACING 'string' FROM 11);

-- Trimming strings
SELECT TRIM('  This is a string   ');  -- defaults to BTRIM
SELECT LTRIM('  This is a string   ');
SELECT RTRIM('  This is a string   ');

-- Converting strings
-- http://www.postgresql.org/docs/9.0/static/functions-formatting.html
SELECT TO_CHAR(1234567890.1234, '999,999,999,999.99');
SELECT TO_HEX(5555);
SELECT UPPER(TO_HEX(5555));

-- Documentation
-- http://www.postgresql.org/docs/9.1/static/functions-datetime.html

-- current time/date
SELECT CURRENT_TIMESTAMP;
SELECT CURRENT_DATE;
SELECT CURRENT_TIME;
SELECT LOCALTIMESTAMP;
SELECT LOCALTIME;

CREATE TABLE t (
    a TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    b TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    c INTEGER
);
INSERT INTO t (c) VALUES (1);
INSERT INTO t (c) VALUES (2);
INSERT INTO t (c) VALUES (3);
SELECT * FROM t;
DROP TABLE IF EXISTS t;

-- AT TIME ZONE
CREATE TABLE t (
    a TIMESTAMP WITH TIME ZONE,
    b TIMESTAMP
);
INSERT INTO t VALUES ( CURRENT_TIMESTAMP, LOCALTIMESTAMP );
SELECT * FROM t;
SELECT a AT TIME ZONE 'EDT' AS a, b AT TIME ZONE 'EDT' AS b FROM t;
SELECT a AT TIME ZONE 'UTC' AS a, b AT TIME ZONE 'UTC' AS b FROM t;
SELECT a AT TIME ZONE INTERVAL '+01:00' AS a, b AT TIME ZONE INTERVAL '+01:00' AS b FROM t;
DROP TABLE IF EXISTS t;

-- date and time arithmetic

SELECT DATE '2011-10-13' - DATE '2011-10-07';
SELECT DATE '2011-10-13' - INTERVAL '6 days';
SELECT TIMESTAMP '2011-10-13 15:35:00' - INTERVAL '6 days 3 hours 15 minutes';

-- EXTRACT
SELECT EXTRACT(HOUR FROM TIMESTAMP '2011-10-13 15:01:25');
SELECT EXTRACT(MONTH FROM INTERVAL '3 years 2 months 1 hour 15 minutes');
