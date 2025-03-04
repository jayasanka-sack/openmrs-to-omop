MODEL (
  name omop_db.VISIT_OCCURRENCE,
  kind FULL
);

SELECT
    v.visit_id AS visit_occurrence_id,
    v.patient_id AS person_id,
    0 AS visit_concept_id,
    DATE(v.date_started) AS visit_start_date,
    v.date_started AS visit_start_datetime,
    DATE(v.date_stopped) AS visit_end_date,
    v.date_stopped AS visit_end_datetime,
    v.visit_type_id AS visit_type_concept_id, -- revisit this
    0 AS provider_id,
    v.location_id AS care_site_id,
    '' AS visit_source_value,
    0 AS visit_source_concept_id,
    0 AS admitted_from_concept_id,
    '' AS admitted_from_source_value,
    0 AS discharged_to_concept_id,
    '' AS discharged_to_source_value,
    0 AS preceding_visit_occurrence_id
FROM openmrs.visit AS v;
