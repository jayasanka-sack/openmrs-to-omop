#!/usr/bin/Rscript

# This script is adapted from https://github.com/OHDSI/Broadsea-Achilles. We use our own entrypoint because the original
# version does not provide a way to override the JSON export functionality.

# Load Achilles and httr.
library(Achilles)
library(httr)

# Get passed environment variables.
env_var_names <- list(
  "ACHILLES_SOURCE",
  "ACHILLES_DB_URI",
  "ACHILLES_DB_USERNAME",
  "ACHILLES_DB_PASSWORD",
  "ACHILLES_CDM_SCHEMA",
  "ACHILLES_VOCAB_SCHEMA",
  "ACHILLES_RES_SCHEMA",
  "ACHILLES_OUTPUT_BASE",
  "ACHILLES_CDM_VERSION",
  "ACHILLES_NUM_THREADS"
)
env_vars <- Sys.getenv(env_var_names, unset = NA)

# Replace unset environment variables with defaults.
default_vars <-
  list(
    "unknown",
    "postgresql://localhost:5432/postgres",
    "",
    "",
    "public",
    "public",
    "public",
    "/opt/achilles/workspace",
    "5",
    "1"
  )
env_vars[is.na(env_vars)] <- default_vars[is.na(env_vars)]

# Otherwise "snow" will go wrong way: https://github.com/cran/snow/blob/b83f63db1072533b85e6e3146c51b7fca007425c/R/sock.R#L151
env_vars$ACHILLES_NUM_THREADS <-
  as.numeric(env_vars$ACHILLES_NUM_THREADS)

# Create name to tag results and output path from ACHILLES_SOURCE and timestamp
current_datetime <-
  strftime(Sys.time(), format = "%Y-%m-%dT%H.%M.%S")
output_path <-
  paste(env_vars$ACHILLES_OUTPUT_BASE,
        env_vars$ACHILLES_SOURCE,
        current_datetime,
        sep = "/")
dir.create(
  output_path,
  showWarnings = FALSE,
  recursive = TRUE,
  mode = "0755"
)

# Parse DB URI into pieces.
db_conf <- parse_url(env_vars$ACHILLES_DB_URI)

# Some connection packages need the database on the server argument.
server <- paste(db_conf$hostname, db_conf$path, sep = "/")

# Read the DB username and password from either the environment or from the parsed URL
db_username <-
  ifelse(
    env_vars$ACHILLES_DB_USERNAME == "" |
      is.na(env_vars$ACHILLES_DB_USERNAME),
    db_conf$username,
    env_vars$ACHILLES_DB_USERNAME
  )
db_password <-
  ifelse(
    env_vars$ACHILLES_DB_PASSWORD == "" |
      is.na(env_vars$ACHILLES_DB_PASSWORD),
    db_conf$password,
    env_vars$ACHILLES_DB_PASSWORD
  )

# Create connection details using DatabaseConnector utility.
connectionDetails <- createConnectionDetails(
  dbms = db_conf$scheme,
  user = db_username,
  password = db_password,
  server = server,
  port = db_conf$port
)

args <- commandArgs(trailingOnly = TRUE)

createIndices <-
  (db_conf$scheme != "redshift" && db_conf$scheme != "netezza")

if (length(args) == 0 || args[1] != "heel") {
  # Run Achilles report and generate data in the results schema.
  achillesResults <- achilles(
    connectionDetails,
    cdmDatabaseSchema = env_vars$ACHILLES_CDM_SCHEMA,
    resultsDatabaseSchema = env_vars$ACHILLES_RES_SCHEMA,
    vocabDatabaseSchema = env_vars$ACHILLES_VOCAB_SCHEMA,
    sourceName = env_vars$ACHILLES_SOURCE,
    cdmVersion = env_vars$ACHILLES_CDM_VERSION,
    createIndices = createIndices,
    numThreads = env_vars$ACHILLES_NUM_THREADS
  )
} else {
  # Run Achilles Heel only
  achillesHeel(
    connectionDetails,
    cdmDatabaseSchema = env_vars$ACHILLES_CDM_SCHEMA,
    resultsDatabaseSchema = env_vars$ACHILLES_RES_SCHEMA,
    vocabDatabaseSchema = env_vars$ACHILLES_VOCAB_SCHEMA,
    cdmVersion = env_vars$ACHILLES_CDM_VERSION,
    numThreads = env_vars$ACHILLES_NUM_THREADS
  )
}
