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
