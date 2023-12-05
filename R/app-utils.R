#' App Utils
#'
#' Functions required to execute and facililate an application user session
#'
#' @param oid org id
#' @param sid store id
#' @param recs rec results from shiny app
#' @param results results from shiny app
#' @param plots list of diagnostic plots
#' @param context model context
#' @param scenario report scenario
#' @param index filtered products table from app
#' @param ml_args model args
#' @param skus skus to get recs for
#' @param ll argument list to scale or unscale values
#' @param file file name for report download passed from app
#'
#' @import data.table
#' @importFrom shiny a
#' @importFrom rdstools log_suc log_err log_inf
#' @importFrom fs dir_create path dir_delete file_delete dir_ls file_exists path_package path_file
#' @importFrom stringr str_glue str_to_title str_remove_all str_remove str_subset
#' @importFrom ggplot2 ggsave
#' @importFrom lubridate now
#' @importFrom rmarkdown render
#' @importFrom rdscore restock_rec_ep
#'
#' @name app-utils
NULL


#' @describeIn app-utils returns TRUE if called on CI
is_ci <- function() {
  isTRUE(as.logical(Sys.getenv("CI", "false")))
}


#' @describeIn app-utils returns TRUE if called while testing
is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}


#' @describeIn app-utils creates and returns app dir path
get_app_dir <- function() {
  if (is_testing()) {
    x <- "rdsapps-session"
  } else {
    x <- fs::path_temp("rdsapps-session")
  }
  fs::path_norm(x)
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
  rdstools::log_inf("...Launching Shiny App")
  app_d <- get_app_dir() |>
    fs::dir_create()
  rdstools::log_inf(paste0("...Output Dir -> ", app_d))
  fs::dir_create(get_app_dir(), "www")
  fs::dir_create(get_app_dir(), "output", c("plots/data"))
  cat("\n\n")
  cat("**************\n")
  fs::dir_tree(app_d)
  cat("**************\n")
  invisible(TRUE)
}


#' @describeIn app-utils Run and Publishing Functions
clear_session_dir <- function() {
  if (getOption("shiny.testmode", FALSE)) {
    rdstools::log_inf("...[Test Mode] skipping session clean")
  } else {
    appd <- get_app_dir()
    if (fs::dir_exists(appd)) {
      fs::dir_delete(appd)
      rdstools::log_suc("...Cleared Session Outputs")
      invisible(TRUE)
    } else {
      rdstools::log_wrn("...Session Outputs Not Found")
      invisible(FALSE)
    }
  }
}


#' @describeIn app-utils Generate report and return download link
generate_report <- function(file) {
  rdstools::log_inf("...Rendering Model Report")
  report_path <- fs::path(get_app_dir(), "output/report.Rmd")

  if (is_testing() & !shiny::isRunning()) {
    templ_path <- "docs/test-template.Rmd"
  } else {
    templ_path <- fs::path_package("rdsapps", "docs", "template.Rmd")
  }

  writeLines(readLines(templ_path), report_path)
  x <- rmarkdown::render(
    input = report_path,
    output_file = file,
    output_dir = get_app_dir(),
    output_format = switch(
      fs::path_ext(file),
      "pdf" = rmarkdown::pdf_document(),
      "html" = rmarkdown::html_document(),
      "docx" = rmarkdown::word_document()
    ),
    clean = TRUE,
    run_pandoc = TRUE,
    output_options = "self-contained",
    encoding = 'UTF-8'
  )
  rdstools::log_suc("...File Created for Download...", file)
  return(x)
}


#' @describeIn app-utils build plot data with result of rdscore::restock_rec_ep
build_plot_data <- function(recs) {

  ## Label failed skus in results table
  recs$results[(
    stringr::str_split_1(
      stringr::str_remove(
        recs$status_msg,
        "Recommendations failed for the following..."
      ), ", ?")),
    restock := "failed",
    on = "product_sku"]

  ## Set as factor columns
  levs <- c("yes", "no", "unsure", "failed")
  recs$results[, restock := factor(restock, levs)]

  ## Save labels for later
  labs <- c(
    "Restock Is<br>Recommended",
    "Restock Not<br>Recommended",
    "Uncertain<br>Recommendation",
    "Failed to Get<br>Recommendation"
  )
  label_table <- data.table(level = levs, label = labs)

  ## Set category factors
  recs$meta$stats[, category3 := factor(
    category3,
    levels = c(
      "FLOWER", "PREROLLS",
      "VAPES", "EXTRACTS",
      "EDIBLES", "DRINKS",
      "TABLETS_CAPSULES", "TINCTURES", "TOPICALS",
      "ACCESSORIES", "OTHER"
    ),
    labels = c(
      "Flowers", "Prerolls",
      "Vapes+Carts", "Concentrates",
      "Edibles", "Drinks",
      "Tabs+Caps", "Tinctures", "Topicals",
      "Accessories", "Other"
    )
  )]

  ## Get plot datasets
  pdata0 <- recs$results[, .N, restock]
  pdata0[, label := scales::percent(N / sum(N), accuracy = 1)]
  pdata0[, restock := factor(restock, levels = c("yes", "no", "unsure", "failed"))]

  pdata1 <- recs$results[
    recs$meta$stats[, .(product_sku, category3)],
    on = "product_sku"][, !"is_recommended"]
  pdata1[, restock := factor(restock, levels = c("yes", "no", "unsure"))]

  # Proportion by Flag
  recs$meta$flags[, has_sales_growth := trend_sign == "positive"]
  recs$meta$flags[, has_sales_decline := trend_sign == "negative"]
  recs$meta$flags[, is_price_high := price_point == "high"]
  recs$meta$flags[, is_price_low := price_point == "low"]
  recs$meta$flags[, price_point := NULL]
  recs$meta$flags[, trend_sign := NULL]

  pdata2 <- data.table::melt(recs$meta$flags, id.vars = "product_sku", variable.factor = FALSE)[!is.na(value)]
  labs <- pdata2[, .N, .(variable, value)][, perc := N / sum(N), variable][]
  labs[, pctlab := scales::percent(perc, accuracy = 1)]

  setkey(pdata2, variable, value)
  setkey(labs, variable, value)
  pdata2[labs, c("pct", "pctlab") := .(perc, pctlab)]

  pdata2[variable == "has_oos_risk",
         fac_var := "<span style= 'font-size:12pt;'>**Stockout Risk**</span><br>
         <span style= 'font-size:10pt;'>*Supply has<br>risk of Stockout*</span>"]
  pdata2[variable == "has_sales_decline",
         fac_var := "<span style= 'font-size:12pt;'>**Sales Decline**</span><br>
         <span style= 'font-size:10pt;'>*Sales Trend<br>is Negative*</span>"]
  pdata2[variable == "has_sales_growth",
         fac_var := "<span style= 'font-size:12pt;'>**Sales Growth**</span><br>
         <span style= 'font-size:10pt;'>*Sales Trend<br>is Positive*</span>"]
  pdata2[variable == "is_long_term",
         fac_var := "<span style= 'font-size:12pt;'>**Menu Classic**</span><br>
         <span style= 'font-size:10pt;'>*Long-Term<br>Menu Item*</span>"]
  pdata2[variable == "is_new_on_menu",
         fac_var := "<span style= 'font-size:12pt;'>**New Product**</span><br>
         <span style= 'font-size:10pt;'>*Recent Addition<br>on Menu*</span>"]
  pdata2[variable == "is_price_high",
         fac_var := "<span style= 'font-size:12pt;'>**Top Shelf**</span><br>
         <span style= 'font-size:10pt;'>*High Price<br>Relative to Category*</span>"]
  pdata2[variable == "is_price_low",
         fac_var := "<span style= 'font-size:12pt;'>**Bottom Shelf**</span><br>
         <span style= 'font-size:10pt;'>*Low Price<br>Relative to Category*</span>"]
  pdata2[variable == "is_primary",
         fac_var := "<span style= 'font-size:12pt;'>**Primary Product**</span><br>
         <span style= 'font-size:10pt;'>*Drives Majority<br>of Order Sales*</span>"]
  pdata2[variable == "is_secondary",
         fac_var := "<span style= 'font-size:12pt;'>**Secondary Item**</span><br>
         <span style= 'font-size:10pt;'>*Product is an<br>Addon Item*</span>"]
  pdata2[variable == "is_trending",
         fac_var := "<span style= 'font-size:12pt;'>**Trending Sales**</span><br>
         <span style= 'font-size:10pt;'>*Recent Sales<br>shows Trend*</span>"]


  ## Set factor order by flag frequency
  levs <- pdata2[value == FALSE, .SD[1], .(variable, value)][order(-pct), fac_var]
  pdata2[, fac_var := factor(fac_var, levels = levs)]

  ## Set factor orders for flag assignment
  pdata2[, value := factor(
    x = value,
    levels = c(FALSE, TRUE),
    labels = c("Flag Not Assigned", "Flag Assigned")
  )]

  setkey(pdata1, product_sku)
  setkey(pdata2, product_sku)
  pdata3 <- pdata1[pdata2][!is.na(value) & restock != "unsure"]

  pdata3[value == "Flag Assigned", value2 := "Assigned"]
  pdata3[value == "Flag Not Assigned", value2 := "Not Assigned"]

  # recs Breakdown by category
  #
  setkey(recs$meta$descr, product_sku)

  pdata4 <- recs$meta$descr[
    pdata3[, unique(.SD), .SDcols = c("product_sku", "restock", "category3")]
  ][!is.na(description)]

  pdata4[description == "No statistically significant sales trend",
         lab := "<span style= 'font-size:12pt;'>**No Sales Trend**</span><br>
                <span style= 'font-size:10pt;'>*No statistically<br>significant sales trend*</span>"]

  pdata4[description == "Based on historical data, product has limited to no supply risk",
         lab := "<span style= 'font-size:12pt;'>**Supply Not Risky**</span><br>
                <span style= 'font-size:10pt;'>*Product has limited<br>to no supply risk*</span>"]

  pdata4[description == "Price point is low relative to others in category",
         lab := "<span style= 'font-size:12pt;'>**Bottom Shelf**</span><br>
                <span style= 'font-size:10pt;'>*Low Priced Item*</span>"]

  pdata4[description == "Product is neither a primary or secondary item",
         lab := "<span style= 'font-size:12pt;'>**Ave Order Item**</span><br>
                <span style= 'font-size:10pt;'>*Products are neither<br>primary or secondary*</span>"]

  pdata4[description == "Product is a long-term menu item (first sold +6 months prior)",
         lab := "<span style= 'font-size:12pt;'>**Menu Classic**</span><br>
                <span style= 'font-size:10pt;'>*Long-term<br>menu items*</span>"]

  pdata4[description == "Based on historical data, product supply is highly volatile",
         lab := "<span style= 'font-size:12pt;'>**Supply Risky**</span><br>
                <span style= 'font-size:10pt;'>*Supply has risk<br>of stockouts*</span>"]

  pdata4[description == "Price point is within the average of others in category",
         lab := "<span style= 'font-size:12pt;'>**Mid-Shelf**</span><br>
                <span style= 'font-size:10pt;'>*Products are priced<br>within category range*</span>"]

  pdata4[description == "Price point is high relative to others in category",
         lab := "<span style= 'font-size:12pt;'>**Top Shelf**</span><br>
                <span style= 'font-size:10pt;'>*Products are priced<br>high relative to category*</span>"]

  pdata4[description == "Recent sales are trending upward",
         lab := "<span style= 'font-size:12pt;'>**Sales Growth**</span><br>
                <span style= 'font-size:10pt;'>*Sales are<br>trending up*</span>"]

  pdata4[description == "Recent sales are trending downward",
         lab := "<span style= 'font-size:12pt;'>**Sales Decline**</span><br>
                <span style= 'font-size:10pt;'>*Sales are<br>trending down*</span>"]

  pdata4[description == "This product drives less than 25% of the order total when purchased",
         lab := "<span style= 'font-size:12pt;'>**Secondary Item**</span><br>
                <span style= 'font-size:10pt;'>*Products are added<br>on to orders*</span>"]

  pdata4[description == "Product isn't a new menu offering, nor is it a long-term menu item",
         lab := "<span style= 'font-size:12pt;'>**Average History**</span><br>
                <span style= 'font-size:10pt;'>*Product not new<br>nor a menu classic*</span>"]

  pdata4[description == "Not enough sales days to evaluate recent trends",
         lab := "<span style= 'font-size:12pt;'>**Not enough data**</span><br>
                <span style= 'font-size:10pt;'>*Unable to model<br>sales trend*</span>"]

  pdata4[description == "This product drives the majority of sales per order when purchased",
         lab := "<span style= 'font-size:12pt;'>**Primary Product**</span><br>
                <span style= 'font-size:10pt;'>*Product drives the<br>majority of sales<br>per order*</span>"]

  list(
    pdata0 = pdata0,
    pdata1 = pdata1,
    pdata2 = pdata2,
    pdata3 = pdata3[variable != "is_trending"], # remove trending from plot3
    pdata4 = pdata4,
    data = list(recs = recs)
  )
}


#' @describeIn app-utils keeps plot data generated during session
save_plot_data <- function(results) {
  rdstools::log_inf("...Saving Plot Datasets")
  dpath <- fs::path(get_app_dir(), "output/plots/data")
  saveRDS(results[[1]], fs::path(dpath, "pdata0.rds"))
  saveRDS(results[[2]], fs::path(dpath, "pdata1.rds"))
  saveRDS(results[[3]], fs::path(dpath, "pdata2.rds"))
  saveRDS(results[[4]], fs::path(dpath, "pdata3.rds"))
  saveRDS(results[[5]], fs::path(dpath, "pdata4.rds"))
  saveRDS(results, fs::path(get_app_dir(), "output/results.rds"))
  invisible(dpath)
}


#' @describeIn app-utils get list of diagnostic plots given processed recs results
build_plot_objects <- function(results) {
  list(
    .plot_diagnostic_0(results[[1]]),
    .plot_diagnostic_1(results[[2]]),
    .plot_diagnostic_2(results[[3]]),
    .plot_diagnostic_3(results[[4]]),
    .plot_diagnostic_4(results[[5]])
  )
}


#' @describeIn app-utils Saving plots for report
save_plot_objects <- function(plots) {
  rdstools::log_inf("...Saving Plot Outputs")

  plot_path <- fs::path(get_app_dir(), "output/plots")
  p0 <- plots[[1]]
  p1 <- plots[[2]]
  p2 <- plots[[3]]
  p3 <- plots[[4]]
  p4 <- plots[[5]]


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
  return(invisible(plot_path))
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


#' @describeIn app-utils build model scenario
build_ml_scenario <- function(results, context) {
  rdstools::log_inf("...Building Model Scenario")

  ## Get table of recs, sku info, and join on table containing model params
  skuRec <- setkey(results[["data"]][["recs"]][["results"]], product_sku)
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
  return(scenario[])
}


#' @describeIn app-utils save model scenario
save_ml_scenario <- function(scenario) {
  rdstools::log_inf("...Saving Model Scenario")
  outpath <- fs::path(get_app_dir(), "output/scenario.rds")
  saveRDS(scenario[], outpath)
  invisible(outpath)
}


#' @describeIn app-utils build ml context (internal)
build_ml_context <- function(oid, sid, index, ml_args) {
  rdstools::log_inf("...Building Model Context")
  context <- list(
    org_uuid = oid,
    store_uuid = sid,
    products = list(index),
    model = unscale_ml_params(ml_args),
    run_utc = lubridate::now()
  )
  context
}


#' @describeIn app-utils save ml context (internal)
save_ml_context <- function(context) {
  rdstools::log_inf("...Saving Model Context")
  outpath <- fs::path(get_app_dir(), "output/context.rds")
  saveRDS(context, outpath)
  invisible(outpath)
}


#' @describeIn app-utils Run recs model, save results, and return
build_ml_recs <- function(oid, sid, skus, ml_args) {
  rdstools::log_inf("...Executing Model")
  args <- c(
    oid = oid,
    sid = sid,
    list(sku = skus),
    unscale_ml_params(ml_args)
  )
  rdscore::restock_rec_ep |>
    do.call(args)
}


#' @describeIn app-utils save ml results (internal)
save_ml_recs <- function(recs) {
  rdstools::log_inf("...Saving Model Results")
  outpath <- fs::path(get_app_dir(), "output/recs.rds")
  saveRDS(recs, outpath)
  invisible(outpath)
}






