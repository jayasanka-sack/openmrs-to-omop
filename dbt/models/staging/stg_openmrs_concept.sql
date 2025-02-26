SELECT
    c.concept_id AS concept_id,
    c.short_name AS concept_name,
    cc.name AS concept_class_name,
    cd.name AS datatype_name,
    c.description AS concept_description,
    c.date_created AS valid_start_date,
    NULL AS valid_end_date,  -- OpenMRS does not store end date
    NULL AS invalid_reason,  -- Not available in OpenMRS
    c.uuid AS concept_code
FROM {{ source('openmrs', 'concept') }} c
LEFT JOIN {{ source('openmrs', 'concept_class') }} cc
ON c.class_id = cc.concept_class_id
    LEFT JOIN {{ source('openmrs', 'concept_datatype') }} cd
    ON c.datatype_id = cd.concept_datatype_id
