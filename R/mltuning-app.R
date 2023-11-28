#' Wrapper Functions for App
#'
#' Wrapper functions used by app that expose internal package functions
#'
#' @param ... arguments passed to internal functions
#'
#' @importFrom rdstools log_inf
#'
#' @name mltuning-app
NULL

#' @describeIn mltuning-app app function
#' @export
cleanOutDir <- function() {
  rdstools::log_inf("...Clearing session outputs")
  cleanOutputDir()
}

#' @describeIn mltuning-app app function
#' @export
createOutDir <- function() {
  rdstools::log_inf("...Creating output folders")
  createOutputDir()
}

#' @describeIn mltuning-app app function
#' @export
getDefaultParams <- function() {
  rdstools::log_inf("...Getting default parameters")
  default_params()
}

#' @describeIn mltuning-app app function
#' @export
saveParams <- function(...) {
  rdstools::log_inf("...Saving parameters")
  save_params(...)
}

#' @describeIn mltuning-app app function
#' @export
loadParams <- function(...) {
  rdstools::log_inf("...Loading parameters")
  load_params(...)
}

#' @describeIn mltuning-app app function
#' @export
saveContext <- function(...) {
  rdstools::log_inf("...Saving model context")
  save_ml_context(...)
}

#' @describeIn mltuning-app app function
#' @export
savePlotDatasets <- function(...) {
  rdstools::log_inf("...Saving plot datasets")
  savePlotData(...)
}

#' @describeIn mltuning-app app function
#' @export
plotDiag0 <- function(...) {
  rdstools::log_inf("...Creating plot 0")
  plot_diagnostic_0(...)
}

#' @describeIn mltuning-app app function
#' @export
plotDiag1 <- function(...) {
  rdstools::log_inf("...Creating plot 1")
  plot_diagnostic_1(...)
}

#' @describeIn mltuning-app app function
#' @export
plotDiag2 <- function(...) {
  rdstools::log_inf("...Creating plot 2")
  plot_diagnostic_2(...)
}

#' @describeIn mltuning-app app function
#' @export
plotDiag3 <- function(...) {
  rdstools::log_inf("...Creating plot 3")
  plot_diagnostic_3(...)
}

#' @describeIn mltuning-app app function
#' @export
plotDiag4 <- function(...) {
  rdstools::log_inf("...Creating plot 4")
  plot_diagnostic_4(...)
}

#' @describeIn mltuning-app app function
#' @export
saveGGPlots <- function(...) {
  rdstools::log_inf("...Saving plots")
  save_ggplots(...)
}

#' @describeIn mltuning-app app function
#' @export
buildScenario <- function() {
  rdstools::log_inf("...Building scenario")
  build_scenario_data()
}

#' @describeIn mltuning-app app function
#' @export
generateReport <- function(...) {
  rdstools::log_inf("...Generating report")
  generate_report(...)
}


#' @describeIn mltuning-app app ui function
#' @export
getMyColors <- function() {
  .hca_colors()
}

#' @describeIn mltuning-app app ui function
#' @export
getMlPlotPanel <- function() {
  uiModelPlotPanel(width = 12)
}

#' @describeIn mltuning-app app ui function
#' @export
getBSTheme <- function() {
  uiBootstrapTheme()
}

#' @describeIn mltuning-app app ui function
#' @export
getSelectionPanel <- function() {
  panel(
    uiSelectionFilts(width = 12),
    uiSelectionStats(width = 12, getMyColors())
  )
}

#' @describeIn mltuning-app app ui function
#' @export
getSlidersRow <- function() {
  fluidRow(
    .slider_model_sales(width = "20%", inline = TRUE),
    .slider_model_stock(width = "20%", inline = TRUE),
    .slider_price_qrtls(width = "20%", inline = TRUE),
    .slider_product_cls(width = "20%", inline = TRUE),
    .slider_menu_period(width = "20%", inline = TRUE)
  )
}

#' @describeIn mltuning-app app ui function
#' @export
getMlToggle <- function() {
  .toggle_model_ttest(width = "150px", inline = TRUE)
}


#' @describeIn mltuning-app app ui function
#' @export
getMlTuningIndex <- function() {
  rdstools::log_inf("...Getting ML Tuning Index")
  get_index()
}

#' @describeIn mltuning-app app ui function
#' @export
execMlRestock <- function(...) {
  rdstools::log_inf("...Executing model")
  exec_ml_restock(...)
}
