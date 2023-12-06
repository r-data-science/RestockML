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
