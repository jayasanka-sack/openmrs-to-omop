MODEL (
  name omop_db.CONDITION_OCCURRENCE,
  kind FULL
);

SELECT
    c.condition_id AS condition_occurrence_id,
    c.patient_id AS person_id,
    COALESCE(c.condition_coded, 0) AS condition_concept_id,
    DATE(c.onset_date) AS condition_start_date,
    c.onset_date AS condition_start_datetime,
    DATE(c.end_date) AS condition_end_date,
    c.end_date AS condition_end_datetime,
    0 AS condition_type_concept_id,
    0 AS condition_status_concept_id,
    COALESCE(c.void_reason, '') AS stop_reason,
    NULL AS provider_id,
    c.encounter_id AS visit_occurrence_id,
    NULL AS visit_detail_id,
    COALESCE(c.condition_non_coded, '') AS condition_source_value,
    COALESCE(c.condition_coded, 0) AS condition_source_concept_id,
    COALESCE(c.verification_status, '') AS condition_status_source_value
FROM openmrs.conditions AS c
WHERE c.voided = 0;
