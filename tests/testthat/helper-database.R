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

compare_report <- function(old, new) {
  old_lines <- readLines(old)
  new_lines <- readLines(new)

  ## Remove any dates and image hashes
  pats <- c('h4 class\\=\\"date\\"', 'meta name\\=\\"date\\"', 'data\\:image')

  # Use either new or old lines to get drop index
  drop_index <- unlist(lapply(pats, function(x) {
    stringr::str_which(old_lines, x)
  }))

  stringr::str_equal(
    stringr::str_flatten(old_lines[-1 * drop_index]),
    stringr::str_flatten(new_lines[-1 * drop_index])
  )
}

