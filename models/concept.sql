MODEL (
  name omop_db.CONCEPT,
  kind FULL
);

SELECT
    c.concept_id AS concept_id,
    COALESCE(cn.name, '') AS concept_name,
    '' AS domain_id,
    '' AS vocabulary_id,
    CAST(c.class_id AS VARCHAR(20)) AS concept_class_id,
    NULL AS standard_concept,
    COALESCE(c.uuid, '') AS concept_code,
    DATE(c.date_created) AS valid_start_date,
    COALESCE(DATE(c.date_retired), '2099-12-31') AS valid_end_date,
    CASE WHEN c.retired = 1 THEN 'D' ELSE NULL END AS invalid_reason
FROM openmrs.concept AS c
LEFT JOIN openmrs.concept_name AS cn ON c.concept_id = cn.concept_id AND cn.concept_name_type = 'FULLY_SPECIFIED'
WHERE c.retired = 0 OR c.date_retired IS NOT NULL;
