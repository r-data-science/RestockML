#' Interface with Database
#'
#' @param oid org id
#' @param sid store id
#' @param args args to send to the db
#'
#' @import data.table
#' @importFrom rpgconn dbc dbd
#' @importFrom DBI dbGetQuery dbWithTransaction dbExecute dbAppendTable dbReadTable
#' @importFrom stringr str_glue
#' @importFrom rdstools log_suc log_err log_inf
#'
#' @name app-database
NULL

#' @describeIn app-database get index of locations with anonomized names
db_app_index_anon <- function() {
  cn <- rpgconn::dbc(db = "appdata")
  on.exit(rpgconn::dbd(cn))

  # Get Values to Assign to Stores
  LIDs <- apply(CJ(LETTERS, LETTERS), 1, paste0, collapse = "")

  # Get Index from Table
  DT <- setDT(DBI::dbReadTable(cn, "vindex_product_velocity_daily"))

  # Assign anonomized org and store names
  DT[, org := paste0(
    c("ORG", c(rep(0, 3 - stringr::str_length(.GRP)), .GRP)),
    collapse = ""
  ), org_uuid][, store := .SD[, paste0(
    LIDs[.GRP],
    stringr::str_remove(org, "^ORG")
  ), store_uuid]$V1, org_uuid]

  # Make category labels more user-friendly
  levs <- c(
    "FLOWER", "PREROLLS", "VAPES",
    "EXTRACTS", "EDIBLES", "DRINKS",
    "TABLETS_CAPSULES", "TINCTURES",
    "TOPICALS", "ACCESSORIES", "OTHER"
  )
  labs <- c(
    "Flowers", "Prerolls", "Vapes & Cartridges",
    "Concentrates", "Edibles", "Drinks",
    "Tablets & Capsules", "Tictures",
    "Topicals", "Accessories", "Miscellaneous"
  )
  DT[, category3 := factor(
    x = category3,
    levels = levs,
    labels = labs
  )]

  # Order columns and return
  setcolorder(DT, c(
    "org", "store", "category3", "brand_name",
    "product_sku", "tot_sales", "units_sold"
  ))
  return(DT[])
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
