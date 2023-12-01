#' Interface with Database
#'
#' @param oid org id
#' @param sid store id
#' @param args args to send to the db
#'
#' @import data.table
#' @importFrom rpgconn dbc dbd
#' @importFrom DBI dbGetQuery dbWithTransaction dbExecute dbAppendTable
#' @importFrom stringr str_glue
#' @importFrom rdstools log_suc log_err log_inf
#'
#' @name app-database
NULL


#' @describeIn app-database get primary app data
db_app_index <- function() {
  rdstools::log_inf("...Getting ML Tuning Index")

  f <- function() {
    cn <- rpgconn::dbc(db = "hcaconfig")
    on.exit(rpgconn::dbd(cn))
    store_index <- function(cn) {
      qry <- "SELECT org_uuid, store_uuid, short_name as store FROM org_stores"
      setDT(DBI::dbGetQuery(cn, qry), key = "org_uuid")[]
    }
    org_index <- function(cn) {
      qry1 <- "SELECT org_uuid, short_name as org FROM org_info"
      qry2 <- "SELECT * FROM org_pipelines_info"
      res1 <- setkey(data.table(DBI::dbGetQuery(cn, qry1)), org_uuid)
      res2 <- setkey(data.table(DBI::dbGetQuery(cn, qry2)), org_uuid)
      out <- res1[res2[current_client & in_population], .(org_uuid, org)]
      setkey(out, "org_uuid")[]
    }
    store_index(cn)[org_index(cn)]
  }

  cn <- rpgconn::dbc(db = "appdata")
  on.exit(rpgconn::dbd(cn))
  qry <- "SELECT org_uuid,
    store_uuid,
    category3,
    brand_name,
    product_sku,
    tot_sales,
    units_sold
  FROM vindex_product_velocity_daily
  WHERE product_sku != ''"
  index <- setcolorder(
    setkey(f(), org_uuid, store_uuid)[
      setDT(DBI::dbGetQuery(cn, qry), key = c("org_uuid","store_uuid"))
    ],
    neworder = c(
      "org", "store", "category3", "brand_name",
      "product_sku", "tot_sales", "units_sold"
    ))
  return(index[])
}


#' @describeIn app-database get default model params by location from the db
db_load_params <- function(oid, sid) {
  rdstools::log_inf("...Loading Model Params")

  cn <- rpgconn::dbc(db = "hcaconfig")
  on.exit(rpgconn::dbd(cn))
  tab <- "restock_ml_params"
  qry <- stringr::str_glue("SELECT * FROM {tab} WHERE oid = '{oid}' AND sid = '{sid}'")
  args <- setDT(DBI::dbGetQuery(cn, qry))

  if (nrow(args) == 0) {
    default_ml_params()
  } else {
    scale_ml_params(as.list(args))
  }

}


#' @describeIn app-database save custom model params by location to the db
db_save_params <- function(oid, sid, args) {
  rdstools::log_inf("...Saving Model Params")

  arg_row <- cbind(oid, sid, as.data.table(unscale_ml_params(args)))

  cn <- rpgconn::dbc(db = "hcaconfig")
  on.exit(rpgconn::dbd(cn))
  tab <- "restock_ml_params"
  n <- DBI::dbWithTransaction(cn, {
    qry <- stringr::str_glue("DELETE FROM {tab} WHERE oid = '{oid}' AND sid = '{sid}'")
    DBI::dbExecute(cn, qry)
    DBI::dbAppendTable(cn, tab, arg_row)
  })
  rdstools::log_inf("Saved Parameters", n)
  return(n)
}
