test_that("App Database Interface", {
  skip_if_offline()

  # Clear db values on exit if they exist
  on.exit(clear_db_params(..testuuid$oid, ..testuuid$sid))

  cnams <- c("org", "store", "category3", "brand_name", "product_sku",
             "tot_sales", "units_sold", "org_uuid", "store_uuid")
  indx <- db_app_index_anon()
  expect_named(indx, cnams, ignore.order = TRUE)

  ## Testing With Fake UUIDs
  cnams <- c("oid", "sid", "ml_ltmi", "ml_npom", "ml_prim", "ml_secd",
             "ml_ppql", "ml_ppqh", "ml_trend_conf", "ml_stock_conf",
             "ml_trend_pval", "ml_stock_pval", "ml_pooled_var",
             "ml_pair_ttest")
  ll <- db_load_params(..testuuid$oid, ..testuuid$sid)
  expect_named(ll, cnams, ignore.order = TRUE)

  # Since this is a fake org/store, check to ensure values
  # are the default values returned when org/store does not
  # have saved db values
  expect_equal(ll, c(
    list(oid = ..testuuid$oid, sid = ..testuuid$sid),
    default_ml_params()
  ))

  # ensure there is nothing on the db for this fake org/store
  expect_equal(nrow(get_db_params(..testuuid$oid, ..testuuid$sid)), 0)

  # save values to db
  tmp <- default_ml_params()

  # zero out all values so we can identify test rows in db
  tmp$ml_npom <- 0
  tmp$ml_ltmi <- 0
  tmp$ml_secd <- 0
  tmp$ml_prim <- 0
  tmp$ml_ppql <- 0
  tmp$ml_ppqh <- 0
  tmp$ml_trend_pval <- 0
  tmp$ml_trend_conf <- 0
  tmp$ml_stock_pval <- 0
  tmp$ml_stock_conf <- 0
  tmp$ml_stock_conf <- 0
  tmp$ml_pooled_var <- 0
  tmp$ml_pair_ttest <- 0

  db_save_params(..testuuid$oid, ..testuuid$sid, tmp) |>
    expect_equal(1)
})
