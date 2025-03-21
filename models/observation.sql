MODEL (
  name omop_db.OBSERVATION,
  kind FULL
);

SELECT
    o.obs_id AS observation_id,
    o.person_id AS person_id,
    omrs_to_omop_concept.omop_concept_id AS observation_concept_id,
    DATE(o.obs_datetime) AS observation_date,
    o.obs_datetime AS observation_datetime,
    0 AS observation_type_concept_id,
    o.value_numeric AS value_as_number,
    LEFT(o.value_text, 60) AS value_as_string,
    o.value_coded AS value_as_concept_id,
    NULL AS qualifier_concept_id,
    NULL AS unit_concept_id,
    NULL AS provider_id,
    o.encounter_id AS visit_occurrence_id,
    NULL AS visit_detail_id,
    '' AS observation_source_value,
    omrs_to_omop_concept.omrs_concept_id AS observation_source_concept_id,
    '' AS unit_source_value,
    '' AS qualifier_source_value,
    '' AS value_source_value,
    NULL AS observation_event_id,
    NULL AS obs_event_field_concept_id
FROM openmrs.obs AS o
INNER JOIN raw.OMRS_TO_OMOP_CONCEPT omrs_to_omop_concept
           ON o.concept_id = omrs_to_omop_concept.omrs_concept_id  AND relationship_id='SAME-AS' AND vocabulary_id='CIEL'
WHERE o.voided = 0;
