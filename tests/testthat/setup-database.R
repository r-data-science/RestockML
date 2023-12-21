##
## Clear database values for these org/stores before tests begin
## to ensure a clean slate for testing logic
##
RestockML:::clear_db_params(
  "044d7564-db32-4100-b960-f225c6879280",
  "ecfb2baa-c5de-46f4-bb3a-96f62a819e3e"
)
RestockML:::clear_db_params(
  ..testuuid$oid,
  ..testuuid$sid
)


## Clear the session directory for testing
RestockML:::clear_session_dir()
