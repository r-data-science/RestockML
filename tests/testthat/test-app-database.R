test_that("App Database Interface", {

  oid <- ..testuuid$oid
  sid <- ..testuuid$sid

  on.exit(clear_db_params(oid, sid))

  ## Test app index data
  indx <- head(db_app_index_anon())
  expect_true(is.data.table(indx) & nrow(indx) == 6)

  apply(indx, 1, as.list) |>
    expect_snapshot_value()

  # snapshot default values
  defs <- default_ml_params()
  expect_true(is.list(defs) & length(defs) > 1)
  expect_snapshot_value(defs)

  # set params to random number
  .args <- sapply(defs, function(x) as.list(sample(seq_len(10), 1)))
  .args$ml_pooled_var <- FALSE # needs to be bool
  .args$ml_pair_ttest <- FALSE # needs to be bool

  # Save to db and check
  expect_equal(db_save_params(oid, sid, .args), 1)

  # Load recently saved params
  ck_params <- c(list(oid = oid, sid = sid), .args)
  expect_mapequal(db_load_params(oid, sid), ck_params)
})
