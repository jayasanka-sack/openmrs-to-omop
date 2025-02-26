#!/bin/bash
set -e

echo "Waiting for PostgreSQL to start..."
until pg_isready -U omop -d omop_db; do
  sleep 2
done

# Define schema name
SCHEMA_NAME="public"

# Replace @cdmDatabaseSchema with actual schema name in SQL files before execution
echo "Replacing @cdmDatabaseSchema with $SCHEMA_NAME..."
sed -i "s/@cdmDatabaseSchema/$SCHEMA_NAME/g" /docker-entrypoint-initdb.d/*.sql

echo "Executing SQL scripts..."

echo "Running DDL script..."
psql -U omop -d omop_db -f /docker-entrypoint-initdb.d/OMOPCDM_postgresql_5.4_ddl.sql

echo "Running Primary Keys script..."
psql -U omop -d omop_db -f /docker-entrypoint-initdb.d/OMOPCDM_postgresql_5.4_primary_keys.sql

echo "Running Constraints script..."
psql -U omop -d omop_db -f /docker-entrypoint-initdb.d/OMOPCDM_postgresql_5.4_constraints.sql

echo "Running Indices script..."
psql -U omop -d omop_db -f /docker-entrypoint-initdb.d/OMOPCDM_postgresql_5.4_indices.sql

echo "Database setup complete."
