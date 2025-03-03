MODEL (
  name omop_db.patient,
   kind FULL,
  cron '*/5 * * * *',
);

SELECT
  p.patient_id AS person_id,
  per.gender,
  per.date_created
FROM openmrs.patient AS p
INNER JOIN openmrs.person AS per
  ON p.patient_id = per.person_id
