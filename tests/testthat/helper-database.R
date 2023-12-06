library(stringr)
library(data.table)
library(DBI)
library(rpgconn)

# Testing Functions -------------------------------------------------------


get_db_params <- function(oid, sid) {
  cn <- rpgconn::dbc(db = "hcaconfig")
  on.exit(rpgconn::dbd(cn))

  params <- data.table::as.data.table(DBI::dbGetQuery(
    cn,
    stringr::str_glue(
      "SELECT *
      FROM restock_ml_params
      WHERE oid = '{oid}'
      AND sid = '{sid}'"
    )
  ))
  params
}

clear_db_params <- function(oid, sid) {
  cn <- rpgconn::dbc(db = "hcaconfig")
  on.exit(rpgconn::dbd(cn))
  DBI::dbExecute(
    cn,
    stringr::str_glue(
      "DELETE FROM restock_ml_params
    WHERE oid = '{oid}' AND sid = '{sid}'"
    )
  )
}



