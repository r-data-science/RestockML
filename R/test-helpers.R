#' Internal Testing Helper Functions
#'
#' Unexported functions used in package unit tests
#'
#' @param oid org uuid
#' @param sid store uuid
#'
#' @importFrom stringr str_glue
#' @importFrom rpgconn dbc dbd
#' @importFrom DBI dbGetQuery dbExecute
#' @importFrom data.table as.data.table
#'
#' @name test-helpers
NULL

#' @describeIn test-helpers Function to retrieve database saved parameters for checking in unit tests
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

#' @describeIn test-helpers Function to clear any database parameters saved during unit tests
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



#' @param old filepath to old document
#' @param new filepath to new document
#'
#' @importFrom stringr str_which str_equal str_flatten
#'
#' @describeIn test-helpers Function to compare downloaded report in unit testing
compare_report <- function(old, new) {
  old_lines <- readLines(old)
  new_lines <- readLines(new)

  ## Remove any dates and image hashes
  pats <- c('h4 class\\=\\"date\\"', 'meta name\\=\\"date\\"', 'data\\:image')

  # Use either new or old lines to get drop index
  drop_index <- c(
    unlist(lapply(pats, function(x) {
      stringr::str_which(old_lines, x)
    })),
    stringr::str_which(old_lines, "Recommendations Generated On") + 1
  )

  stringr::str_equal(
    stringr::str_flatten(old_lines[-1 * drop_index]),
    stringr::str_flatten(new_lines[-1 * drop_index])
  )
}
