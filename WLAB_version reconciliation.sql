-- identify differences based on one of x fields differing using a concat predicate
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

-- v2 entries which have changed based on any of an id or name difference in v4
DROP VIEW IF EXISTS wlab_v4_rows_differing_from_v2;
CREATE VIEW wlab_v4_rows_differing_from_v2 AS
SELECT
  wlab.taxon_sort,
  wlab.is_ultrataxon,
  wlab.taxon_level,
  wlab.sp_id,
  wlab.taxon_id,
  wlab.taxon_name,
  wlab.taxon_scientific_name,
  wlab.population,
  v2_taxon_id_diff_sci,
  v2_taxon_id_diff_common,
  v2_taxon_name_diff_id,
  v2_taxon_name_diff_sci,
  v2_taxon_sci_name_diff_id,
  v2_taxon_sci_name_diff_name,
  v2_taxon_sci_name_diff
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
  wlab_v2.taxon_sort,
  wlab_v2.is_ultrataxon,
  wlab_v2.taxon_level,
  wlab_v2.sp_id,
  wlab_v2.taxon_id,
  wlab_v2.taxon_name,
  wlab_v2.taxon_scientific_name,
  v4_taxon_id_diff_sci,
  v4_taxon_id_diff_common,
  v4_taxon_name_diff_id,
  v4_taxon_name_diff_sci,
  v4_taxon_sci_name_diff_id,
  v4_taxon_sci_name_diff_name
FROM wlab
FULL OUTER JOIN wlab_v2
ON CONCAT(wlab.sp_id, wlab.taxon_id, wlab.taxon_name, wlab.taxon_scientific_name) = CONCAT(wlab_v2.sp_id, wlab_v2.taxon_id, wlab_v2.taxon_name, wlab_v2.taxon_scientific_name)
WHERE
  CONCAT(wlab.sp_id, wlab.taxon_id, wlab.taxon_name, wlab.taxon_scientific_name) = ''
;
comment on view wlab_v4_rows_differing_from_v2 is 'v4 entries which were different in v2 based on any of an id or name difference in v2';

SELECT
  SUM(v2_taxon_id_diff_sci) AS num_v2_taxon_id_diff_sci,
  SUM(v2_taxon_id_diff_common) AS num_v2_taxon_id_diff_common,
  SUM(v2_taxon_name_diff_id) AS num_v2_taxon_name_diff_id,
  SUM(v2_taxon_name_diff_sci) AS num_v2_taxon_name_diff_sci,
  SUM(v2_taxon_sci_name_diff_id) AS num_v2_taxon_sci_name_diff_id,
  SUM(v2_taxon_sci_name_diff_name) AS num_v2_taxon_sci_name_diff_name
FROM wlab;

SELECT
  SUM(v4_taxon_id_diff_sci) AS num_v4_taxon_id_diff_sci,
  SUM(v4_taxon_id_diff_common) AS num_v4_taxon_id_diff_common,
  SUM(v4_taxon_name_diff_id) AS num_v4_taxon_name_diff_id,
  SUM(v4_taxon_name_diff_sci) AS num_v4_taxon_name_diff_sci,
  SUM(v4_taxon_sci_name_diff_id) AS num_v4_taxon_sci_name_diff_id,
  SUM(v4_taxon_sci_name_diff_name) AS num_v4_taxon_sci_name_diff_name
FROM wlab_v2;

-- bring in JD data and join - note I am using working wlab and he has wlab
SELECT
  wlab.*,
  wlab_jd.*
FROM wlab
FULL OUTER JOIN wlab_jd ON wlab.taxon_id = wlab_jd.taxon_id
;


-- do reconciliation
-- import
drop table if exists wlab_reco;
create table wlab_reco
(
    taxon_id  varchar DEFAULT NULL,
    change_class  varchar DEFAULT NULL,
    change_class_notes text DEFAULT NULL,
    sum_ref_diff_queries text DEFAULT NULL
);
copy wlab_reco FROM '/Users/glennehmke/Downloads/wlab_reco.csv' DELIMITER ';' CSV;


-- import via ingester
UPDATE wlab_reco
SET change_class = NULL
WHERE change_class = '0';
UPDATE wlab_reco
SET change_class_notes = NULL
WHERE change_class_notes = '0';
UPDATE wlab_reco
SET sum_ref_diff_queries = NULL
WHERE sum_ref_diff_queries = '0';

SELECT
  COUNT(change_class) AS num
FROM wlab_reco
WHERE change_class IS NOT NULL;

-- append to wlab
alter table public.wlab
  drop column if exists change_class;
alter table public.wlab
  drop column if exists change_class_notes;
alter table public.wlab
  drop column if exists sum_ref_diff_queries;

alter table public.wlab
    add change_class varchar;
alter table public.wlab
    add change_class_notes text;
alter table public.wlab
    add sum_ref_diff_queries integer;

UPDATE wlab
SET change_class = wlab_reco.change_class
FROM wlab_reco
WHERE wlab.taxon_id = wlab_reco.taxon_id;

UPDATE wlab
SET change_class_notes = wlab_reco.change_class_notes
FROM wlab_reco
WHERE wlab.taxon_id = wlab_reco.taxon_id;

UPDATE wlab
SET sum_ref_diff_queries = wlab_reco.sum_ref_diff_queries
FROM wlab_reco
WHERE wlab.taxon_id = wlab_reco.taxon_id;

-- make change type lut
DROP TABLE IF EXISTS lut_wlab_change_class CASCADE;
CREATE TABLE lut_wlab_change_class (
  id int NOT NULL,
  class int DEFAULT NULL,
  description text DEFAULT NULL,
  PRIMARY KEY (id)
);

-- summarise
SELECT
  wlab.change_class,
  lut_wlab_change_class.description,
  COUNT(wlab.taxon_id) AS num_changes
FROM wlab
LEFT JOIN lut_wlab_change_class ON wlab.change_class = lut_wlab_change_class.id
WHERE wlab.change_class IS NOT NULL
GROUP BY
  wlab.change_class,
  lut_wlab_change_class.description
ORDER BY
  wlab.change_class
;

-- compare
-- WLAB_v4_DONOT EDIT missed
SELECT
  wlab.change_class,
  lut_wlab_change_class.description,
  COUNT(wlab.taxon_id) AS num_changes
FROM wlab
LEFT JOIN lut_wlab_change_class ON wlab.change_class = lut_wlab_change_class.id
JOIN wlab_jd ON wlab.taxon_id = wlab_jd.taxon_id
WHERE
  wlab.change_class IS NOT NULL
  AND wlab_jd.changeneeded_v2_v4 = '0'
GROUP BY
  wlab.change_class,
  lut_wlab_change_class.description
ORDER BY
  wlab.change_class
;

-- WLAB_v4_DONOT EDIT identified but not necessary
SELECT
  COUNT(wlab.taxon_id) AS num_changes
FROM wlab
LEFT JOIN lut_wlab_change_class ON wlab.change_class = lut_wlab_change_class.id
JOIN wlab_jd ON wlab.taxon_id = wlab_jd.taxon_id
WHERE
  wlab.change_class IS NULL
  AND wlab_jd.changeneeded_v2_v4 = '1'
;

-- Relative difference queries
SELECT
  wlab.change_class,
  lut_wlab_change_class.description,
  COUNT(wlab.taxon_id) AS num_changes
FROM wlab
LEFT JOIN lut_wlab_change_class ON wlab.change_class = lut_wlab_change_class.id
WHERE
  wlab.change_class IS NOT NULL
  AND wlab.sum_ref_diff_queries IS NULL
GROUP BY
  wlab.change_class,
  lut_wlab_change_class.description
ORDER BY
  wlab.change_class
;

SELECT
  COUNT(wlab.taxon_id) AS num_changes
FROM wlab
LEFT JOIN lut_wlab_change_class ON wlab.change_class = lut_wlab_change_class.id
WHERE
  wlab.change_class IS NULL
  AND wlab.sum_ref_diff_queries IS NOT NULL
;

-- export for review
SELECT
  wlab.taxon_sort,
  wlab.is_ultrataxon,
  wlab.taxon_level,
  wlab.sp_id,
  wlab.taxon_id,
  wlab.taxon_name,
  wlab.taxon_scientific_name,
  wlab.family_name,
  wlab.family_scientific_name,
  wlab.t_order,
  wlab.population,
  wlab.supplementary,
  wlab.avibase_id,
  wlab.v2_taxon_id_diff_sci,
  wlab.v2_taxon_id_diff_common,
  wlab.v2_taxon_name_diff_id,
  wlab.v2_taxon_name_diff_sci,
  wlab.v2_taxon_sci_name_diff_id,
  wlab.v2_taxon_sci_name_diff_name,
  wlab.v2_taxon_sci_name_diff,
  wlab.change_class,
  wlab.change_class_notes,
  wlab.sum_ref_diff_queries,
  wlab_jd.changeneeded_v2_v4 wlab_jd_changeneeded_v2_v4,
  wlab_jd.changetype wlab_jd_changetype,
  wlab_jd.spatialchangetype wlab_jd_spatialchangetype,
  wlab_jd.responsibility wlab_jd_responsibility,
  wlab_jd.implemented wlab_jd_implemented,
  wlab_jd.implementedwhere wlab_jd_implementedwhere
FROM wlab
LEFT JOIN wlab_jd ON wlab.taxon_id = wlab_jd.taxon_id
;
