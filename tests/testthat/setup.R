##
## Load application support files into testing environment
##
shinytest2::load_app_env("test_app")


##
## Clear database values for these org/stores before tests begin
## to ensure a clean slate for testing logic
##
clear_db_params(
  "044d7564-db32-4100-b960-f225c6879280",
  "ecfb2baa-c5de-46f4-bb3a-96f62a819e3e"
)
clear_db_params(
  ..testuuid$oid,
  ..testuuid$sid
)


## Clear the session directory for testing
clear_session_dir()
