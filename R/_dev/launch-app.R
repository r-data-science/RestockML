#' Launch Package Apps
#'
#' @name run-app
NULL

#' @param SAVE_PLOTDATA Default is FALSE. Whether to keep plot input datasets generated during app session. Useful for plot development.
#' @param CLEAN_OUTPUTS Default is False. Whether to delete the session output directory. Useful for debuging
#' @param DEV_MODE Set TRUE to launch app from current packages inst folder and not installed package in library
#'
#' @importFrom shiny runApp
#' @importFrom rdstools log_suc
#'
#' @describeIn run-app run MLTuning app
#' @export
runAppRecModel <- function(SAVE_PLOTDATA = FALSE, CLEAN_OUTPUTS = TRUE, DEV_MODE = TRUE) {

  ## Check For Deps
  if (!requireNamespace("bslib", quietly = TRUE)) {
    stop("'bslib' not available", call. = FALSE)

  } else if (!requireNamespace("sass", quietly = TRUE)) {
    stop("'sass' not available", call. = FALSE)

  } else if (!requireNamespace("shinyWidgets", quietly = TRUE)) {
    stop("'shinyWidgets' not available", call. = FALSE)

  } else if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("'shiny' not available", call. = FALSE)

  } else if (!requireNamespace("datamods", quietly = TRUE)) {
    stop("'datamods' not available", call. = FALSE)

  } else if (!requireNamespace("shinycssloaders", quietly = TRUE)) {
    stop("'shinycssloaders' not available", call. = FALSE)

  } else if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("'ggplot2' not available", call. = FALSE)

  } else if (!requireNamespace("ggthemes", quietly = TRUE)) {
    stop("'ggthemes' not available", call. = FALSE)

  } else if (!requireNamespace("ggtext", quietly = TRUE)) {
    stop("'ggtext' not available", call. = FALSE)

  } else if (!requireNamespace("scales", quietly = TRUE)) {
    stop("'scales' not available", call. = FALSE)

  } else if (!requireNamespace("connectapi", quietly = TRUE)) {
    stop("'connectapi' not available", call. = FALSE)

  } else if (!requireNamespace("rsconnect", quietly = TRUE)) {
    stop("'rsconnect' not available", call. = FALSE)
  }

  ## Check Envars
  if (Sys.getenv("CONNECT_SERVER") == "") {
    stop("Missing envvar... set with Sys.setenv(CONNECT_SERVER = 'https://happycabbage.app')", call. = FALSE)
  }

  if (Sys.getenv("CONNECT_API_KEY") == "") {
    stop("Missing envvar... set with Sys.setenv(CONNECT_API_KEY = '...')", call. = FALSE)
  }

  if (Sys.getenv("HCA_DB_PWD") == "") {
    stop("Missing envvar... set with Sys.setenv(HCA_DB_PWD = '...')", call. = FALSE)
  }

  ## Set options for this app launch
  shinyOptions(
    save_plotdata = SAVE_PLOTDATA,
    clean_outputs = CLEAN_OUTPUTS
  )

  ## Set options for this app launch
  on.exit(shinyOptions(
    save_plotdata = NULL,
    clean_outputs = NULL,
    appDir = NULL
  ))

  ## Check For App
  if (DEV_MODE) {
    if (!requireNamespace("rstudioapi", quietly = TRUE))
      stop("DEV_MODE is TRUE but Rstudio is not detected", call. = FALSE)

    appDir <- fs::path(rstudioapi::getActiveProject(), "inst/apps/mltuning")
    rdstools::log_suc("Dev mode detected...launching from project home")

  } else {
    appDir <- system.file("apps/mltuning", package = "rdsapps")
    rdstools::log_suc("Launching app from installed package home...")
  }

  if (!fs::file_exists(fs::path(appDir, "app.R")))
    stop("Could not find app mltuning. Try re-installing `rdsapps`.", call. = FALSE)


  shiny::runApp(appDir, display.mode = "normal")
}


