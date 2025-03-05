MODEL (
  name omop_db.CONCEPT_CLASS,
  kind FULL
);

SELECT
    CAST(cc.concept_class_id AS VARCHAR(20)) AS concept_class_id,
    cc.name AS concept_class_name,
    0 AS concept_class_concept_id
FROM openmrs.concept_class AS cc
WHERE cc.retired = 0;
