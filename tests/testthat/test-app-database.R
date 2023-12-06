oid <- ..testuuid$oid
sid <- ..testuuid$sid

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
