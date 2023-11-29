#' Launch Package Apps
#'
#' @param SAVE_PLOTDATA Default is FALSE. Whether to keep plot input datasets generated during app session. Useful for plot development.
#' @param CLEAN_OUTPUTS Default is False. Whether to delete the session output directory. Useful for debuging
#'
#' @importFrom shiny runApp shinyOptions
#' @importFrom rdstools log_suc
#' @importFrom fs file_exists path
#'
#' @name run-app
NULL

#' @describeIn run-app run MLTuning app
#' @export
runAppRecModel <- function(SAVE_PLOTDATA = FALSE, CLEAN_OUTPUTS = TRUE) {
  if (!requireNamespace("waiter", quietly = TRUE)) {
    stop("'waiter' not available", call. = FALSE)
  }

  if (Sys.getenv("CONNECT_SERVER") == "")
    warning("Missing envvar... set with Sys.setenv(CONNECT_SERVER = '...')", call. = FALSE)
  if (Sys.getenv("CONNECT_API_KEY") == "")
    warning("Missing envvar... set with Sys.setenv(CONNECT_API_KEY = '...')", call. = FALSE)

  ## Set options for this app launch
  shiny::shinyOptions(
    save_plotdata = SAVE_PLOTDATA,
    clean_outputs = CLEAN_OUTPUTS
  )

  ## Set options for this app launch
  on.exit(shiny::shinyOptions(
    save_plotdata = NULL,
    clean_outputs = NULL,
    appDir = NULL
  ))

  ## Check For App
  appDir <- system.file("apps/mltuning/app", package = "rdsapps")
  if (!fs::file_exists(fs::path(appDir, "app.R")))
    stop("Could not find app. Re-install `rdsapps`.", call. = FALSE)

  rdstools::log_suc("Launching app from installed package home...")
  shiny::runApp(appDir, display.mode = "normal")
}



