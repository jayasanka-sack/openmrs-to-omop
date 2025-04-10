MODEL (
  name omop_db.OBSERVATION_PERIOD,
  kind FULL
);

SELECT
    CAST(ROW_NUMBER() OVER (ORDER BY MIN(v.date_started)) AS INTEGER) AS observation_period_id,
    v.patient_id AS person_id,
    DATE(MIN(v.date_started)) AS observation_period_start_date,
    DATE(
    GREATEST(
    MAX(v.date_stopped),
    MAX(e.encounter_datetime)
    )
    ) AS observation_period_end_date,
    44814724 AS period_type_concept_id  -- EHR record
FROM openmrs.visit v
    LEFT JOIN openmrs.encounter e ON v.visit_id = e.visit_id
WHERE v.date_started IS NOT NULL
GROUP BY v.patient_id;
