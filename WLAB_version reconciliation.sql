-- alternatively identify differences based on one of x fields differing using a concat predicate
-- v2 entries which have changed based on any of an id or name difference in v4
DROP VIEW IF EXISTS wlab_v4_rows_differing_from_v2;
CREATE VIEW wlab_v4_rows_differing_from_v2 AS
SELECT
  wlab.is_ultrataxon AS v4_is_ultrataxon,
  wlab.taxon_level AS v4_taxon_level,
  wlab.sp_id AS v4_sp_id,
  wlab.taxon_id AS v4_taxon_id,
  wlab.taxon_name AS v4_taxon_name,
  wlab.taxon_scientific_name AS v4_taxon_scientific_name
FROM wlab
FULL OUTER JOIN wlab_v2
ON CONCAT(wlab.sp_id, wlab.taxon_id, wlab.taxon_name, wlab.taxon_scientific_name) = CONCAT(wlab_v2.sp_id, wlab_v2.taxon_id, wlab_v2.taxon_name, wlab_v2.taxon_scientific_name)
WHERE
  CONCAT(wlab_v2.sp_id, wlab_v2.taxon_id, wlab_v2.taxon_name, wlab_v2.taxon_scientific_name) = ''
;
comment on view wlab_v4_rows_differing_from_v2 is 'v2 entries which have changed based on any of an id or name difference in v4';

-- v4 entries which were different in v2 based on any of an id or name difference in v2
DROP VIEW IF EXISTS wlab_v2_rows_differing_from_v4;
CREATE VIEW wlab_v2_rows_differing_from_v4 AS
SELECT
  wlab_v2.is_ultrataxon AS v2_is_ultrataxon,
  wlab_v2.taxon_level AS v2_taxon_level,
  wlab_v2.sp_id AS v2_sp_id,
  wlab_v2.taxon_id AS v2_taxon_id,
  wlab_v2.taxon_name AS v2_taxon_name,
  wlab_v2.taxon_scientific_name AS v2_taxon_scientific_name
FROM wlab
FULL OUTER JOIN wlab_v2
ON CONCAT(wlab.sp_id, wlab.taxon_id, wlab.taxon_name, wlab.taxon_scientific_name) = CONCAT(wlab_v2.sp_id, wlab_v2.taxon_id, wlab_v2.taxon_name, wlab_v2.taxon_scientific_name)
WHERE
  CONCAT(wlab.sp_id, wlab.taxon_id, wlab.taxon_name, wlab.taxon_scientific_name) = ''
;
comment on view wlab_v4_rows_differing_from_v2 is 'v4 entries which were different in v2 based on any of an id or name difference in v2';


-- identify WLAB_v4 entries that differ from v2
alter table wlab
  drop column v2_taxon_id_diff_sci;
alter table wlab
  drop column v2_taxon_id_diff_common;
alter table wlab
  drop column v2_taxon_name_diff_id;
alter table wlab
  drop column v2_taxon_name_diff_sci;
alter table wlab
  drop column v2_taxon_sci_name_diff_id;
alter table wlab
  drop column v2_taxon_sci_name_diff_name;
alter table wlab
  add v2_taxon_id_diff_sci integer,
  add v2_taxon_id_diff_common integer,
  add v2_taxon_name_diff_id integer,
  add v2_taxon_name_diff_sci integer,
  add v2_taxon_sci_name_diff_id integer,
  add v2_taxon_sci_name_diff_name integer
;

comment on column wlab.v2_taxon_id_diff_sci is 'taxon_id differs based on taxon_scientific_name';
comment on column wlab.v2_taxon_id_diff_common is 'taxon_id differs based on taxon_name';
comment on column wlab.v2_taxon_name_diff_id is 'taxon_name differs based on taxon_id';
comment on column wlab.v2_taxon_name_diff_sci is 'taxon_name differs based on taxon_scientific_name';
comment on column wlab.v2_taxon_sci_name_diff_id is 'taxon_scientific_name differs based on taxon_id';
comment on column wlab.v2_taxon_sci_name_diff_name is 'taxon_scientific_name differs based on taxon_name';

UPDATE wlab
SET v2_taxon_id_diff_sci = 1
FROM
    (SELECT
      wlab.taxon_id AS v4_taxon_id,
      wlab.taxon_name AS v4_taxon_name,
      wlab.taxon_scientific_name AS taxon_scientific_name,
      wlab_v2.taxon_id AS v2_taxon_id,
      wlab_v2.taxon_name AS v2_taxon_name,
      wlab_v2.taxon_scientific_name AS v2_taxon_scientific_name
    FROM wlab
    FULL OUTER JOIN wlab_v2 ON wlab.taxon_id = wlab_v2.taxon_id
    WHERE
      wlab.taxon_id IS NULL
    )sub
WHERE
  wlab.taxon_scientific_name = sub.v2_taxon_scientific_name
;

UPDATE wlab
SET v2_taxon_id_diff_common = 1
FROM
    (SELECT
      wlab.taxon_id AS v4_taxon_id,
      wlab.taxon_name AS v4_taxon_name,
      wlab.taxon_scientific_name AS taxon_scientific_name,
      wlab_v2.taxon_id AS v2_taxon_id,
      wlab_v2.taxon_name AS v2_taxon_name,
      wlab_v2.taxon_scientific_name AS v2_taxon_scientific_name
    FROM wlab
    FULL OUTER JOIN wlab_v2 ON wlab.taxon_id = wlab_v2.taxon_id
    WHERE
      wlab.taxon_id IS NULL
    )sub
WHERE
  wlab.taxon_name = sub.v2_taxon_name
;

UPDATE wlab
SET v2_taxon_name_diff_id = 1
FROM
    (SELECT
      wlab.taxon_id AS v4_taxon_id,
      wlab.taxon_name AS v4_taxon_name,
      wlab.taxon_scientific_name AS taxon_scientific_name,
      wlab_v2.taxon_id AS v2_taxon_id,
      wlab_v2.taxon_name AS v2_taxon_name,
      wlab_v2.taxon_scientific_name AS v2_taxon_scientific_name
    FROM wlab
    FULL OUTER JOIN wlab_v2 ON wlab.taxon_name = wlab_v2.taxon_name
    WHERE
      wlab.taxon_name IS NULL
    )sub
WHERE
  wlab.taxon_id = sub.v2_taxon_id
;

UPDATE wlab
SET v2_taxon_name_diff_sci = 1
FROM
    (SELECT
      wlab.taxon_id AS v4_taxon_id,
      wlab.taxon_name AS v4_taxon_name,
      wlab.taxon_scientific_name AS taxon_scientific_name,
      wlab_v2.taxon_id AS v2_taxon_id,
      wlab_v2.taxon_name AS v2_taxon_name,
      wlab_v2.taxon_scientific_name AS v2_taxon_scientific_name
    FROM wlab
    FULL OUTER JOIN wlab_v2 ON wlab.taxon_name = wlab_v2.taxon_name
    WHERE
      wlab.taxon_name IS NULL
    )sub
WHERE
  wlab.taxon_scientific_name = sub.v2_taxon_scientific_name
;

UPDATE wlab
SET v2_taxon_sci_name_diff_id = 1
FROM
    (SELECT
      wlab.taxon_id AS v4_taxon_id,
      wlab.taxon_name AS v4_taxon_name,
      wlab.taxon_scientific_name AS taxon_scientific_name,
      wlab_v2.taxon_id AS v2_taxon_id,
      wlab_v2.taxon_name AS v2_taxon_name,
      wlab_v2.taxon_scientific_name AS v2_taxon_scientific_name
    FROM wlab
    FULL OUTER JOIN wlab_v2 ON wlab.taxon_scientific_name = wlab_v2.taxon_scientific_name
    WHERE
      wlab.taxon_scientific_name IS NULL
    )sub
WHERE
  wlab.taxon_id = sub.v2_taxon_id
;

UPDATE wlab
SET v2_taxon_sci_name_diff_name = 1
FROM
    (SELECT
      wlab.taxon_id AS v4_taxon_id,
      wlab.taxon_name AS v4_taxon_name,
      wlab.taxon_scientific_name AS taxon_scientific_name,
      wlab_v2.taxon_id AS v2_taxon_id,
      wlab_v2.taxon_name AS v2_taxon_name,
      wlab_v2.taxon_scientific_name AS v2_taxon_scientific_name
    FROM wlab
    FULL OUTER JOIN wlab_v2 ON wlab.taxon_scientific_name = wlab_v2.taxon_scientific_name
    WHERE
      wlab.taxon_scientific_name IS NULL
    )sub
WHERE
  wlab.taxon_name = sub.v2_taxon_name
;

-- do sci names differ
alter table wlab drop column if exists v2_taxon_sci_name_diff;
alter table wlab add v2_taxon_sci_name_diff integer;
UPDATE wlab
SET v2_taxon_sci_name_diff = 1
FROM
  (SELECT
    wlab.is_ultrataxon AS v4_is_ultrataxon,
    wlab.taxon_level AS v4_taxon_level,
    wlab.sp_id AS v4_sp_id,
    wlab.taxon_id AS v4_taxon_id,
    wlab.taxon_name AS v4_taxon_name,
    wlab.taxon_scientific_name AS v4_taxon_scientific_name,
    wlab_v2.is_ultrataxon AS v2_is_ultrataxon,
    wlab_v2.taxon_level AS v2_taxon_level,
    wlab_v2.sp_id AS v2_sp_id,
    wlab_v2.taxon_id AS v2_taxon_id,
    wlab_v2.taxon_name AS v2_taxon_name,
    wlab_v2.taxon_scientific_name AS v2_taxon_scientific_name
  FROM wlab
  FULL OUTER JOIN wlab_v2 ON wlab.taxon_scientific_name = wlab_v2.taxon_scientific_name
  WHERE
    wlab.taxon_scientific_name IS NULL
  )sub
WHERE wlab.taxon_id = sub.v4_taxon_id
;

------------------------
------------------------
-- identify WLAB_v2 entries that differ from v4
-- populate WLAB_v4 with changes from WLAB_v2
alter table wlab_v2
  drop column v4_taxon_id_diff_sci;
alter table wlab_v2
  drop column v4_taxon_id_diff_common;
alter table wlab_v2
  drop column v4_taxon_name_diff_id;
alter table wlab_v2
  drop column v4_taxon_name_diff_sci;
alter table wlab_v2
  drop column v4_taxon_sci_name_diff_id;
alter table wlab_v2
  drop column v4_taxon_sci_name_diff_name;

alter table wlab_v2
  add v4_taxon_id_diff_sci integer,
  add v4_taxon_id_diff_common integer,
  add v4_taxon_name_diff_id integer,
  add v4_taxon_name_diff_sci integer,
  add v4_taxon_sci_name_diff_id integer,
  add v4_taxon_sci_name_diff_name integer
;

comment on column wlab_v2.v4_taxon_id_diff_sci is 'taxon_id differs based on taxon_scientific_name';
comment on column wlab_v2.v4_taxon_id_diff_common is 'taxon_id differs based on taxon_name';
comment on column wlab_v2.v4_taxon_name_diff_id is 'taxon_name differs based on taxon_id';
comment on column wlab_v2.v4_taxon_name_diff_sci is 'taxon_name differs based on taxon_scientific_name';
comment on column wlab_v2.v4_taxon_sci_name_diff_id is 'taxon_scientific_name differs based on taxon_id';
comment on column wlab_v2.v4_taxon_sci_name_diff_name is 'taxon_scientific_name differs based on taxon_name';

UPDATE wlab_v2
SET v4_taxon_id_diff_sci = 1
FROM
    (SELECT
      wlab.taxon_id AS v4_taxon_id,
      wlab.taxon_name AS v4_taxon_name,
      wlab.taxon_scientific_name AS taxon_scientific_name,
      wlab_v2.taxon_id AS v2_taxon_id,
      wlab_v2.taxon_name AS v2_taxon_name,
      wlab_v2.taxon_scientific_name AS v2_taxon_scientific_name
    FROM wlab_v2
    FULL OUTER JOIN wlab ON wlab_v2.taxon_id = wlab.taxon_id
    WHERE
      wlab.taxon_id IS NULL
    )sub
WHERE
  wlab_v2.taxon_scientific_name = sub.v2_taxon_scientific_name
;

UPDATE wlab_v2
SET v4_taxon_id_diff_common = 1
FROM
    (SELECT
      wlab.taxon_id AS v4_taxon_id,
      wlab.taxon_name AS v4_taxon_name,
      wlab.taxon_scientific_name AS taxon_scientific_name,
      wlab_v2.taxon_id AS v2_taxon_id,
      wlab_v2.taxon_name AS v2_taxon_name,
      wlab_v2.taxon_scientific_name AS v2_taxon_scientific_name
    FROM wlab_v2
    FULL OUTER JOIN wlab ON wlab_v2.taxon_id = wlab.taxon_id
    WHERE
      wlab.taxon_id IS NULL
    )sub
WHERE
  wlab_v2.taxon_name = sub.v2_taxon_name
;

UPDATE wlab_v2
SET v4_taxon_name_diff_id = 1
FROM
    (SELECT
      wlab.taxon_id AS v4_taxon_id,
      wlab.taxon_name AS v4_taxon_name,
      wlab.taxon_scientific_name AS taxon_scientific_name,
      wlab_v2.taxon_id AS v2_taxon_id,
      wlab_v2.taxon_name AS v2_taxon_name,
      wlab_v2.taxon_scientific_name AS v2_taxon_scientific_name
    FROM wlab_v2
    FULL OUTER JOIN wlab ON wlab_v2.taxon_name = wlab.taxon_name
    WHERE
      wlab.taxon_name IS NULL
    )sub
WHERE
  wlab_v2.taxon_id = sub.v2_taxon_id
;

UPDATE wlab_v2
SET v4_taxon_name_diff_sci = 1
FROM
    (SELECT
      wlab.taxon_id AS v4_taxon_id,
      wlab.taxon_name AS v4_taxon_name,
      wlab.taxon_scientific_name AS taxon_scientific_name,
      wlab_v2.taxon_id AS v2_taxon_id,
      wlab_v2.taxon_name AS v2_taxon_name,
      wlab_v2.taxon_scientific_name AS v2_taxon_scientific_name
    FROM wlab_v2
    FULL OUTER JOIN wlab ON wlab_v2.taxon_name = wlab.taxon_name
    WHERE
      wlab.taxon_name IS NULL
    )sub
WHERE
  wlab_v2.taxon_scientific_name = sub.v2_taxon_scientific_name
;

UPDATE wlab_v2
SET v4_taxon_sci_name_diff_id = 1
FROM
    (SELECT
      wlab.taxon_id AS v4_taxon_id,
      wlab.taxon_name AS v4_taxon_name,
      wlab.taxon_scientific_name AS taxon_scientific_name,
      wlab_v2.taxon_id AS v2_taxon_id,
      wlab_v2.taxon_name AS v2_taxon_name,
      wlab_v2.taxon_scientific_name AS v2_taxon_scientific_name
    FROM wlab_v2
    FULL OUTER JOIN wlab ON wlab_v2.taxon_scientific_name = wlab.taxon_scientific_name
    WHERE
      wlab.taxon_scientific_name IS NULL
    )sub
WHERE
  wlab_v2.taxon_id = sub.v2_taxon_id
;

UPDATE wlab_v2
SET v4_taxon_sci_name_diff_name = 1
FROM
    (SELECT
      wlab.taxon_id AS v4_taxon_id,
      wlab.taxon_name AS v4_taxon_name,
      wlab.taxon_scientific_name AS taxon_scientific_name,
      wlab_v2.taxon_id AS v2_taxon_id,
      wlab_v2.taxon_name AS v2_taxon_name,
      wlab_v2.taxon_scientific_name AS v2_taxon_scientific_name
    FROM wlab_v2
    FULL OUTER JOIN wlab ON wlab_v2.taxon_scientific_name = wlab.taxon_scientific_name
    WHERE
      wlab.taxon_scientific_name IS NULL
    )sub
WHERE
  wlab_v2.taxon_name = sub.v2_taxon_name
;
