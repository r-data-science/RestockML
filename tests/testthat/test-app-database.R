oid <- ..testuuid$oid
sid <- ..testuuid$sid


test_that("Testing helpers", {
  expect_equal(nrow(get_db_params("fake oid", "fake sid")), 0)

  old <- tempfile()
  new <- tempfile()
  writeLines("test", old)
  writeLines("test", new)
  expect_true(compare_report(old, new))
})



# Set args to random values
test_args <- default_ml_params() |>
  sapply(function(x) as.list(sample(seq_len(10), 1)))
test_args$ml_pooled_var <- FALSE # needs to be bool
test_args$ml_pair_ttest <- FALSE # needs to be bool

test_that("Testing App Index", {
  expect_no_error(db_app_index_anon())
})

test_that("Testing Save Param Values", {
  expect_no_error(db_save_params(oid, sid, test_args))
})

test_that("Testing Load Param Values", {
  ck_params <- c(list(oid = oid, sid = sid), test_args)
  expect_mapequal(db_load_params(oid, sid), ck_params)
})


clear_db_params(oid, sid)
