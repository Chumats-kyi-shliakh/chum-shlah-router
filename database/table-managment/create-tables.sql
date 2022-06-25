CREATE TABLE ways_configuration (
      tag_id integer PRIMARY KEY
    , tag_key text DEFAULT 'highway'
    , tag_value text
    , priority real
    , maxspeed integer
    , CONSTRAINT configuration_tag_id_key UNIQUE (tag_id)
    );
CREATE INDEX IF NOT EXISTS  ways_configuration_tag_id_idx
    ON ways_configuration USING btree
    (tag_id ASC NULLS LAST);
    


INSERT INTO ways_configuration (
      tag_id
    , tag_value
    , priority
    , maxspeed
) VALUES
     (100,     'road',                 3,       50)
    ,(101,     'motorway',             1,       130)
    ,(102,     'motorway_link',        1,       130)
    ,(103,     'motorway_junction',    1,       130)
    ,(104,     'trunk',                1.05,    110)
    ,(105,     'trunk_link',           1.05,    110)
    ,(106,     'primary',              1.15,    90)
    ,(107,     'primary_link',         1.15,    90)
    ,(108,     'secondary',            1.5,     90)
    ,(109,     'secondary_link',       1.5,     90)
    ,(110,     'tertiary',             1.75,    90)
    ,(111,     'tertiary_link',        1.75,    90)
    ,(112,     'residential',          2.5,     50)
    ,(113,     'living_street',        3,       20)
    ,(114,     'service',              2.5,     50)
    ,(115,     'unclassified',         3,       90)
    ,(116,     'track',                3,       20)
    ,(117,     'proposed',             -1,      0)
    ,(118,     'destroyed',            -1,      0);
    
    
CREATE TABLE IF NOT EXISTS ways
(
      id serial PRIMARY KEY
    , way_id bigint
    , tag_id bigint REFERENCES ways_configuration
    , osm_source bigint
    , osm_target bigint
    , source bigint
    , target bigint
    , name text
    , destroyed text
    , proposed text
    , length_m real
    , cost_s double precision
    , reverse_cost_s double precision
    , dir text
    , the_geom geometry(Linestring, 4326)
);
CREATE INDEX IF NOT EXISTS ways_geom_idx
    ON ways USING gist
    (the_geom);
-- CREATE INDEX IF NOT EXISTS ways_geog_idx
--     ON ways USING gist
--     (GEOGRAPHY(the_geom));
CREATE INDEX IF NOT EXISTS ways_geom_ua_idx
    ON ways USING gist
    (ST_Transform(the_geom, 5558));
CREATE INDEX IF NOT EXISTS ways_id_idx
    ON ways USING btree
    (way_id ASC NULLS LAST);
CREATE INDEX IF NOT EXISTS ways_tag_id_idx
    ON ways USING btree
    (tag_id ASC NULLS LAST);
CREATE INDEX IF NOT EXISTS ways_source_idx
    ON ways USING btree
    (source ASC NULLS LAST);
CREATE INDEX IF NOT EXISTS ways_target_idx
    ON ways USING btree
    (target ASC NULLS LAST);
    