#' Database Interface
#'
#' These functions are the only functions called by the restock recommendations endpoint that query an external datasource.
#'
#' @param cn a db connection
#' @param oid org uuid
#' @param sid store uuid
#' @param sku one or more skus to generate recommendations for
#' @param txt plain text containing query to interpolate
#'
#' @importFrom DBI sqlInterpolate SQL dbGetQuery
#' @importFrom stringr str_glue
#'
#' @name ml-database
NULL


#' @describeIn ml-database interpolate query
interp <- function(txt, cn, oid, sid, sku = NULL) {
  if (!is.null(sku)) {
    txt <- paste0(txt, " AND product_sku IN ?sku")
    qry <- DBI::sqlInterpolate(
      conn = cn,
      sql = txt,
      oid = oid,
      sid = sid,
      sku = DBI::SQL(paste0("('", paste0(sku, collapse = "','"), "')"))
    )
  } else {
    qry <- DBI::sqlInterpolate(
      conn = cn,
      sql = txt,
      oid = oid,
      sid = sid
    )
  }
  qry
}


#' @describeIn ml-database get recent population data
dbGetTransacts90 <- function(oid, sid, sku = NULL, cn=NULL) {
  if (is.null(cn)) {
    cn <- rpgconn::dbc(db = "integrated")
    on.exit(rpgconn::dbd(cn))
  }
  qry <- interp("
      SELECT *
      FROM v100d_population2
      WHERE org_uuid = ?oid
        AND store_uuid = ?sid
    ", cn, oid, sid, sku)

  DT <- setDT(DBI::dbGetQuery(cn, qry))[item_subtotal > 0]
  DT[, order_date := as.Date(order_time_utc)]
  setnames(DT, "order_subtotal", "order_tot")

  if (nrow(DT) == 0)
    stop("No population data for org/store and given skus", call. = FALSE)

  if (nrow(DT) < 10)
    stop("Not enough sales data to produce recommendations", call. = FALSE)

  return(DT[])
}


#' @describeIn ml-database get First and Last Sales dates by Sku
dbGetProductHist <- function(oid, sid, sku = NULL, cn=NULL) {
  if (is.null(cn)) {
    cn <- rpgconn::dbc(db = "integrated")
    on.exit(rpgconn::dbd(cn))
  }
  qry <- interp(
    "SELECT product_sku,
      first_order_date AS first_date,
      last_order_date AS last_date
     FROM vproduct_history
     WHERE org_uuid = ?oid
      AND store_uuid = ?sid
    ", cn, oid, sid, sku)

  DT <- setDT(DBI::dbGetQuery(cn, qry), key = "product_sku")

  if (nrow(DT) == 0)
    stop("No product history found for org/store and given sku(s)", call. = FALSE)

  return(DT[])
}


#' @describeIn ml-database get Sales statistics for transactions in the past 90 days by category
dbGetCatPricePts <- function(oid, sid, cn=NULL) {
  if (is.null(cn)) {
    cn <- rpgconn::dbc(db = "integrated")
    on.exit(rpgconn::dbd(cn))
  }
  qry <- interp("
  select category3, item_list_price
  from v100d_population2
  where org_uuid = ?oid
    and store_uuid = ?sid
    and item_list_price > 1
  ", cn, oid, sid)
  DT <- setDT(DBI::dbGetQuery(cn, qry), key = "category3")

  if (nrow(DT) == 0)
    stop("No prices found for Org/Store", call. = FALSE)
  return(DT[])
}
