#!/bin/bash

# === CONFIG ===
MYSQL_USER="root"
MYSQL_PASSWORD="openmrs"
MYSQL_HOST="localhost"
MYSQL_PORT="3306"
SOURCE_DB="omop_db"
TARGET_MYSQL_DB="omop_bb"

PG_USER="omop"
PG_PASSWORD="omop"
PG_HOST="localhost"
PG_PORT="5432"
TARGET_PG_DB="omop"

# === Step 1: Get all view names from the source DB ===
echo "🔍 Fetching all views from '$SOURCE_DB'..."
VIEW_LIST=$(mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -h $MYSQL_HOST -P $MYSQL_PORT --protocol=TCP -N -s -e "
SELECT TABLE_NAME FROM information_schema.VIEWS
WHERE TABLE_SCHEMA = '$SOURCE_DB';
")

if [ -z "$VIEW_LIST" ]; then
  echo "❌ No views found in '$SOURCE_DB'. Nothing to do."
  exit 1
fi

echo "✅ Found views:"
echo "$VIEW_LIST"

# === Step 2: Materialize each view into the target MySQL DB ===
for VIEW_NAME in $VIEW_LIST; do
  echo "🚧 Materializing view '$VIEW_NAME' into '$TARGET_MYSQL_DB'..."
  mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -h $MYSQL_HOST -P $MYSQL_PORT --protocol=TCP -e "
  DROP TABLE IF EXISTS \`$TARGET_MYSQL_DB\`.\`$VIEW_NAME\`;
  CREATE TABLE \`$TARGET_MYSQL_DB\`.\`$VIEW_NAME\` AS SELECT * FROM \`$SOURCE_DB\`.\`$VIEW_NAME\`;
  "

  # Verify materialization
  TABLE_EXISTS=$(mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -h $MYSQL_HOST -P $MYSQL_PORT --protocol=TCP -N -s -e "
  SELECT COUNT(*) FROM information_schema.TABLES
  WHERE TABLE_SCHEMA = '$TARGET_MYSQL_DB' AND TABLE_NAME = '$VIEW_NAME';
  ")

  if [[ "$TABLE_EXISTS" =~ ^[0-9]+$ && "$TABLE_EXISTS" -eq 1 ]]; then
    echo "✅ '$VIEW_NAME' successfully materialized."
  else
    echo "❌ Failed to materialize '$VIEW_NAME'."
  fi
done

# === Step 3: Migrate the entire MySQL DB to PostgreSQL ===
echo "🚚 Running pgloader to migrate entire database '$TARGET_MYSQL_DB' to PostgreSQL '$TARGET_PG_DB'..."

pgloader mysql://$MYSQL_USER:$MYSQL_PASSWORD@$MYSQL_HOST:$MYSQL_PORT/$TARGET_MYSQL_DB \
         postgresql://$PG_USER:$PG_PASSWORD@$PG_HOST:$PG_PORT/$TARGET_PG_DB

echo "✅ Migration complete: All materialized views are now in PostgreSQL database '$TARGET_PG_DB'."
