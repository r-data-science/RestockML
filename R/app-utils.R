#' App Utils
#'
#' Functions required to execute and facililate an application user session
#'
#' @param results results from shiny app
#' @param org org name
#' @param store store name
#' @param p0 plot
#' @param p1 plot
#' @param p2 plot
#' @param p3 plot
#' @param p4 plot
#' @param oid org id
#' @param sid store id
#' @param sku_data sku table
#' @param ml_args model args
#' @param skus skus to get recs for
#' @param ll argument list to scale or unscale values
#'
#' @import data.table
#' @importFrom rdstools log_suc log_err log_inf
#' @importFrom fs dir_create path dir_delete file_delete dir_ls file_exists path_package path_file
#' @importFrom stringr str_glue str_to_title str_remove_all str_remove str_subset
#' @importFrom ggplot2 ggsave
#' @importFrom lubridate now
#' @importFrom rmarkdown render
#'
#' @name app-utils
NULL


#' @describeIn app-utils creates and returns app dir path
get_app_dir <- function() {
  if (fs::file_exists("test-app/app.R")) {
    x <- fs::path_wd("test-app")
  } else if (shiny::isRunning()) {
    x <- fs::path_abs("ExplorePRM")
  } else {
    x <- fs::path_wd()
    # stop("Unknown error getting app dir path", call. = FALSE)
  }
  return(x)
}


#' @describeIn app-utils Set Plot colors
get_app_colors <- function() {
  list(
    bg = "#041E39",
    fg = "#E0ECF9",
    primary    = "#187dd4",
    secondary  = "#ED9100",
    success    = "#00A651",
    info       = "#fff573",
    warning    = "#7d3be8",
    danger     = "#DB14BF"
  )
}


#' @describeIn app-utils Run and Publishing Functions
create_session_dir <- function() {
  rdstools::log_inf("...Creating Session Directory")
  fs::dir_create(get_app_dir())
  fs::dir_create(get_app_dir(), "www")
  fs::dir_create(get_app_dir(), "output", c("plots", "temp", ".plotdata"))
}


#' @describeIn app-utils Run and Publishing Functions
clean_session_dir <- function() {
  rdstools::log_inf("...Cleaning Session Directory")
  path <- fs::path(get_app_dir(), "output")
  if (fs::dir_exists(path)) fs::dir_delete(path)
}


#' @describeIn app-utils keeps plot data generated during session
save_plot_data <- function(results) {
  rdstools::log_inf("...Saving Plot Datasets")
  dpath <- fs::path(get_app_dir(), "output/.plotdata")
  saveRDS(results[[1]], fs::path(dpath, "pdata0.rds"))
  saveRDS(results[[2]], fs::path(dpath, "pdata1.rds"))
  saveRDS(results[[3]], fs::path(dpath, "pdata2.rds"))
  saveRDS(results[[4]], fs::path(dpath, "pdata3.rds"))
  saveRDS(results[[5]], fs::path(dpath, "pdata4.rds"))
}


#' @describeIn app-utils Read in template, add the header and write report content to output dir
generate_report <- function(org, store) {
  rdstools::log_inf("...Generating Model Report")

  Org <- stringr::str_to_title(org)
  Store <- stringr::str_to_title(store)

  report_title <- stringr::str_glue("Product Recommendations - {Org}/{Store}")

  # define header
  headr <- c('---',
             stringr::str_glue('title: {report_title}'),
             stringr::str_glue('date: "{Sys.Date()}"'),
             'format: markdown',
             'resource_files:',
             ' - scenario.rds',
             ' - plots/*',
             '---')
  # read lines, append header, and write
  templ_path <- fs::path_package(package = "rdsapps", "docs", "template.rmd")
  report_path <- fs::path(get_app_dir(), "output/report.rmd")
  writeLines(c(headr, readLines(templ_path)), report_path)

  rdstools::log_inf("...Rendering Model Report")

  rmarkdown::render(
    input = report_path,
    output_dir = fs::path(get_app_dir(), "www"),
    clean = TRUE,
    output_options = "self-contained",
    encoding = 'UTF-8'
  ) |>
    fs::path_file()
}


#' @describeIn app-utils Saving plots for report
save_ggplots <- function(p0, p1, p2, p3, p4) {
  rdstools::log_inf("...Saving Plots as PNG Images")

  plot_path <- fs::path(get_app_dir(), "output/plots")
  ggplot2::ggsave(
    filename = "diagnostic-0.png",
    plot = p0,
    path = plot_path,
    width = 1800,
    height = 1150,
    units = "px",
    dpi = 125,
    bg = NULL
  )
  ggplot2::ggsave(
    filename = "diagnostic-1.png",
    plot = p1,
    path = plot_path,
    width = 1700,
    height = 1200,
    units = "px",
    dpi = 125,
    bg = NULL
  )
  ggplot2::ggsave(
    filename = "diagnostic-2.png",
    plot = p2,
    path = plot_path,
    width = 1500,
    height = 2500,
    units = "px",
    dpi = 150,
    bg = NULL
  )
  ggplot2::ggsave(
    filename = "diagnostic-3.png",
    plot = p3,
    path = plot_path,
    width = 2600,
    height = 1200,
    units = "px",
    dpi = 125,
    bg = NULL
  )
  ggplot2::ggsave(
    filename = "diagnostic-4.png",
    plot = p4,
    path = plot_path,
    width = 2000,
    height = 2500,
    units = "px",
    dpi = 150,
    bg = NULL
  )
  ## return plot objects
  return(invisible(TRUE))
}


#' @describeIn app-utils This will read from the temp outputs and construct the scenario dataset for the report
build_scenario_data <- function() {
  rdstools::log_inf("...Building Scenario Data")

  scenario <- NULL ## return null if data doesnt exist
  results_path <- fs::path(get_app_dir(), "output/temp/results.rds")
  context_path <- fs::path(get_app_dir(), "output/temp/context.rds")

  has_outputs <- fs::file_exists(results_path) & fs::file_exists(context_path)

  if (!has_outputs)
    return(NULL)

  ## Read in scenario and results from last run
  results <- readRDS(results_path)
  context <- readRDS(context_path)

  ## Get table of recs, sku info, and join on table containing model params
  skuRec <- setkey(results[["data"]][["rec"]][["results"]], product_sku)
  skuInf <- setkey(context[["products"]][[1]], product_sku)

  scenario <- as.data.table(c(
    context["org_uuid"], context["store_uuid"],
    context["run_utc"], context[["model"]]
  ))[ skuInf[skuRec], on = c("org_uuid", "store_uuid")]


  ## Order columns in table
  ordrCols <- c(
    "org_uuid", "store_uuid", "org", "store", "brand_name", "category3",
    "product_sku", "tot_sales", "units_sold", "restock", "is_recommended",
    stringr::str_subset(names(scenario), "^ml_"), "run_utc"
  )
  setcolorder(scenario, ordrCols)

  # save scenario to the output directory for report generation and return
  outpath <- fs::path(get_app_dir(), "output/scenario.rds")
  saveRDS(scenario[], outpath)
  return(scenario[])
}


#' @describeIn app-utils save ml context (internal)
save_ml_context <- function(oid, sid, sku_data, ml_args) {
  rdstools::log_inf("...Saving Model Context")
  context <- list(
    org_uuid = oid,
    store_uuid = sid,
    products = list(sku_data),
    model = unscale_ml_params(ml_args),
    run_utc = lubridate::now()
  )
  # save scenario to the output directory for report generation and return
  outpath <- fs::path(get_app_dir(), "output/temp/context.rds")
  print(outpath)
  stopifnot(fs::dir_exists(fs::path_dir(outpath)))
  saveRDS(context, outpath)
  invisible(TRUE)
}


#' @describeIn app-utils Run rec model, save results, and return
exec_ml_restock <- function(oid, sid, skus, ml_args) {
  args <- c(oid = oid, sid = sid, list(sku = skus), unscale_ml_params(ml_args))

  rdstools::log_inf("...Executing Rec Model")
  results <- do.call(ds_sku_recs_pdata, args)

  rdstools::log_inf("...Saving Model Results")
  outpath <- fs::path(get_app_dir(), "output/temp/results.rds")
  saveRDS(results, outpath)
  results
}


#' @describeIn app-utils get defaults and scale
default_ml_params <- function() {
  rdstools::log_inf("...Getting Default Params")
  scale_ml_params(
    list(
      ml_npom = 14,
      ml_ltmi = 182,
      ml_secd = .20,
      ml_prim = .45,
      ml_ppql = .20,
      ml_ppqh = .80,
      ml_pair_ttest = FALSE,
      ml_pooled_var = TRUE,
      ml_trend_pval = .05,
      ml_trend_conf = .85,
      ml_stock_pval = .05,
      ml_stock_conf = .85
    )
  )
}


#' @describeIn app-utils scale for shiny sliders
scale_ml_params <- function(ll) {
  ll$ml_secd <- ll$ml_secd * 100
  ll$ml_prim <- ll$ml_prim * 100
  ll$ml_ppql <- ll$ml_ppql * 100
  ll$ml_ppqh <- ll$ml_ppqh * 100

  ll$ml_trend_pval <- ll$ml_trend_pval * 100
  ll$ml_trend_conf <- ll$ml_trend_conf * 100
  ll$ml_stock_pval <- ll$ml_stock_pval * 100
  ll$ml_stock_conf <- ll$ml_stock_conf * 100
  ll
}


#' @describeIn app-utils scale for shiny sliders
unscale_ml_params <- function(ll) {
  ll$ml_secd <- ll$ml_secd / 100
  ll$ml_prim <- ll$ml_prim / 100
  ll$ml_ppql <- ll$ml_ppql / 100
  ll$ml_ppqh <- ll$ml_ppqh / 100

  ll$ml_trend_pval <- ll$ml_trend_pval / 100
  ll$ml_trend_conf <- ll$ml_trend_conf / 100
  ll$ml_stock_pval <- ll$ml_stock_pval / 100
  ll$ml_stock_conf <- ll$ml_stock_conf / 100
  ll
}



