SELECT
    p.patient_id AS person_id,  -- Use patient_id as OMOP person_id

    CASE
        WHEN per.gender = 'M' THEN 8507  -- OMOP concept_id for Male
        WHEN per.gender = 'F' THEN 8532  -- OMOP concept_id for Female
        ELSE 0  -- Use 0 for unknown gender-- Get gender from person table
    END AS gender_concept_id,

    YEAR(per.birthdate) AS year_of_birth,
    MONTH(per.birthdate) AS month_of_birth,
    DAY(per.birthdate) AS day_of_birth,
    per.birthdate AS birth_datetime,

    -- OMOP requires race/ethnicity, which OpenMRS lacks
    0 AS race_concept_id,  -- No race data in OpenMRS, set to 0 (unknown)
    0 AS ethnicity_concept_id,  -- No ethnicity data in OpenMRS, set to 0 (unknown)

    NULL AS location_id,  -- No direct mapping in OpenMRS
    NULL AS provider_id,  -- No direct mapping in OpenMRS
    NULL AS care_site_id,  -- No direct mapping in OpenMRS

    p.patient_id AS person_source_value,  -- Store OpenMRS patient ID as source value
    per.gender AS gender_source_value,  -- Keep original gender for traceability
    NULL AS gender_source_concept_id,  -- No OpenMRS concept for gender mapping
    NULL AS race_source_value,
    NULL AS race_source_concept_id,
    NULL AS ethnicity_source_value,
    NULL AS ethnicity_source_concept_id
FROM {{ source('openmrs', 'patient') }} p
JOIN {{ source('openmrs', 'person') }} per
    ON p.patient_id = per.person_id  -- Ensure 1:1 mapping
